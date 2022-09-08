# Return the markup (.aspx) file corresponding to the input file
function GetMarkupFile([String]$filename) {
	if($filename.EndsWith(".vb")) {
		return $filename.Remove($filename.Length - 3)
	}
	else {
		return $filename
	}
}

# Return the local resource form of a filename given the original file and the culture
function GetResourceFilename([String]$input_file, [String]$culture, [Boolean]$is_resource) {
	if($culture) {
		# is_resource param indicates whether the input_file already has a .resx extension
		if ($is_resource) {			
			return $input_file.Insert($input_file.LastIndexOf("."), "." + $culture)
		}
		else {
			$parent = Split-Path -Path $input_file -Parent
			$leaf = Split-Path -Path $input_file -Leaf
			$leaf = GetMarkupFile -filename $leaf
			return $parent + "/App_LocalResources/" + $leaf + "." + $culture + ".resx"
		}
	}
	else {
		$parent = Split-Path -Path $input_file -Parent
		$leaf = Split-Path -Path $input_file -Leaf
		$leaf = GetMarkupFile -filename $leaf
		return $parent + "/App_LocalResources/" + $leaf + ".resx"
	}
}

# Copy the template file to the target path if the file doesn't exist and capture it's XML content
function CreateFileFromTemplate([String]$template_file, [string]$target_file, [ref]$xml_doc_list) {
	if(!(Test-Path -Path $target_file)) {
		$parent = Split-Path -Path $target_file -Parent
		if(!(Test-Path -Path $parent)) {
			New-Item -ItemType "directory" -Path $parent
		}
		Copy-Item $template_file -Destination $target_file
	}
	[xml]$xml_doc = Get-Content $target_file
	$xml_doc_list.Value += $xml_doc
}

# Create target resource files for given locales and capture their XML content
function CreateTargetFiles([String]$template_file, [ref]$xml_map, [String[]]$input_files, [String[]]$cultures) {
	$template_file = "ResourceTemplate.resx"
	$input_files | ForEach-Object {
		$xml_docs=@()
		
		$target_file = GetResourceFilename -input_file $_
		CreateFileFromTemplate -template_file $template_file -target_file $target_file -xml_doc_list ([ref]$xml_docs)
		
		$cultures | ForEach-Object {
			$culture_target_file = GetResourceFilename -input_file $target_file -culture $_ -is_resource 1
			CreateFileFromTemplate -template_file $template_file -target_file $culture_target_file -xml_doc_list ([ref]$xml_docs)
		}
		
		$xml_file_key = Resolve-Path -Path $_
		$xml_file_key = GetMarkupFile -filename $xml_file_key.Path
		$xml_map.Value[$xml_file_key] = $xml_docs
	}
}

# Remove captured prop attributes from source files
function StripCapturedProps([ref]$match_set) {
	for($i=0; $i -lt $match_set.Value.Matches.Length; $i++) {
		if($match_set.Value.Matches[$i].Groups["PropVal"].Success) {
			$source_file = if($match_set.Value.Matches.Length -eq 1) {$match_set.Value.Path} else {$match_set.Value.Path[$i]}
			$replaced_str = $match_set.Value.Matches[$i].Groups[0].Value -replace $match_set.Value.Matches[$i].Groups["PropVal"].Value,""
			(Get-Content $source_file) -replace $match_set.Value.Matches[$i].Groups[0].Value,$replaced_str | Out-File $source_file
		}
	}
}

# Iterate over given properties, extracting resource tags and corresponding properties from the input aspx files
function ExtractResourceInfo([String[]]$input_files, [String[]]$props, [Boolean]$strip_props) {
	$props | ForEach-Object {
		$m = Select-String -Path $input_files -Pattern "\b(?<PropVal>(?<Prop>$_)=`"(?<Value>[^`"]*)`").*meta:resourcekey=`"(?<Key>[^`"]*)`""
		return $m
	}
	$m = Select-String -Path $input_files -Pattern "GetLocalResourceObject\(`"(?<Dynamic>[^`"]*)`"\)"
	return $m
}

# Create XML resource nodes
function CreateResourceNode([ref]$xml_doc_list, [ref]$match_obj) {
	for($i=0; $i -lt $xml_doc_list.Value.Length; $i++) {
		$xml_doc = $xml_doc_list.Value[$i]
		
		if($xml_doc) {
			if($match_obj.Value.Groups["Key"].Success -and $match_obj.Value.Groups["Prop"].Success) {
			
				# Check if resource key exists before creating a new XML resource node
				$resource_key = $match_obj.Value.Groups["Key"].Value + "." + $match_obj.Value.Groups["Prop"].Value
				if(!($xml_doc.SelectSingleNode("root/data[@name='$resource_key']"))) {
				
					$new_elem = $xml_doc.CreateElement("data")
					$retval = $new_elem.SetAttribute("name", $resource_key)
					$retval = $new_elem.SetAttribute("xml:space","preserve")
					
					$value_text = if($i -eq 0) {$match_obj.Value.Groups["Value"].Value} else {""}
					[xml]$value_doc = "<value>" + $value_text + "</value>"
					$retval = $new_elem.AppendChild($xml_doc.ImportNode($value_doc.DocumentElement,1))
					
					$comment_text = if($i -ne 0) {$match_obj.Value.Groups["Value"].Value} else {""}
					[xml]$comment_doc = "<comment>" + $comment_text + "</comment>"
					$retval = $new_elem.AppendChild($xml_doc.ImportNode($comment_doc.DocumentElement,1))
					
					$retval = $xml_doc.DocumentElement.AppendChild($new_elem)
				}
			}
			elseif($match_obj.Value.Groups["Dynamic"].Success) {
				
				# Check if resource key exists before creating a new XML resource node
				$resource_key = $match_obj.Value.Groups["Dynamic"].Value
				if(!($xml_doc.SelectSingleNode("root/data[@name='$resource_key']"))) {
					
					$new_elem = $xml_doc.CreateElement("data")
					$retval = $new_elem.SetAttribute("name", $resource_key)
					$retval = $new_elem.SetAttribute("xml:space","preserve")
					
					[xml]$value_doc = "<value></value>"
					$retval = $new_elem.AppendChild($xml_doc.ImportNode($value_doc.DocumentElement,1))
					
					[xml]$comment_doc = "<comment></comment>"
					$retval = $new_elem.AppendChild($xml_doc.ImportNode($comment_doc.DocumentElement,1))
					
					$retval = $xml_doc.DocumentElement.AppendChild($new_elem)
				}
			}
		}
	}
}

# Driver function
function GenerateResource([String[]]$input_files, [String[]]$props, [Boolean]$strip_props, [String[]]$cultures) {
	$xml_doc_map = @{}
	CreateTargetFiles -xml_map ([ref]$xml_doc_map) -input_files $input_files -cultures $cultures
	$match_set = ExtractResourceInfo -input_files $input_files -props $props -strip_props $strip_props
	if($strip_props) {
		StripCapturedProps -match_set ([ref]$match_set)
	}
	for($i=0; $i -lt $match_set.Matches.Length; $i++) {
		$file_path = if($match_set.Matches.Length -eq 1) {$match_set.Path} else {$match_set.Path[$i]}
		$xml_map_key = GetMarkupFile -filename $file_path
		CreateResourceNode -xml_doc_list ([ref]$xml_doc_map[$xml_map_key]) -match_obj ([ref]$match_set.Matches[$i])
	}
	$input_files | ForEach-Object {
		$source_file = Resolve-Path -Path $_
		$source_file = GetMarkupFile -filename $source_file.Path
		for($i=0; $i -lt $xml_doc_map[$source_file].Length; $i++) {
			$resource_file = if($i -eq 0) {GetResourceFilename -input_file $source_file} else {GetResourceFilename -input_file $source_file -culture $cultures[$i-1] -is_resource 0}
			$xml_doc_map[$source_file][$i].Save($resource_file)
		}
	}
}

# $in_files_arr = @()
# Get-ChildItem -Path "folder/*" -Recurse -Include "*.aspx*","*.master*" -Exclude "*.resx","*.designer.*","*.resources" | ForEach-Object { $in_files_arr += $_.FullName}
# GenerateResource -input_files $in_files_arr -props "Text","Title","aria-label","placeholder","HeaderText","ToolTip","AlternateText" -strip_props 1 -cultures "es-MX"
