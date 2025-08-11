Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

function prompt_git_file_status() {
    $prompt_sep = " ~ "
    
    $in_git_repo = "$(git rev-parse --is-inside-work-tree 2>$null)"
    if ($in_git_repo -ne "true" ) {
        return $prompt_sep
    }

    $curr_branch = "$(git branch --show-current)"
    $diff_count = $(git rev-list --count --left-right origin/$curr_branch...HEAD 2>$null)
    $upstream_diff = switch -regex ($diff_count) {
        "^$" { ""; break }
        "0\s+0" { "|u="; break }
        "0\s.*" { "|u+$([regex]::Matches($diff_count,"\d+\s+(\d+)").Groups[1].Value)"; break }
        ".*\s0" { "|u-$([regex]::Matches($diff_count,"(\d+)\s+\d+").Groups[1].Value)"; break }
        default { "|u+$([regex]::Matches($diff_count,"\d+\s+(\d+)").Groups[1].Value)-$([regex]::Matches($diff_count,"(\d+)\s+\d+").Groups[1].Value)" }
    }

    $diff_type_counts=$(git status -s | Tee-Object -Variable stat | &{
        "A:$(($stat | select-string '^\s*A').count)";
        "M:$(($stat | select-string '^\s*M').count)";
        "D:$(($stat | select-string '^\s*D').count)";
        "U:$(($stat | select-string '^\s*\?\?').count)";
    })

    return " ($curr_branch$upstream_diff)$prompt_sep$($diff_type_counts)"
}

function prompt() {
    $prompt_curr_time = "[$((Get-Date).ToString("HH:mm:ss tt"))]"
    $prompt_root_content = "$($executionContext.SessionState.Path.CurrentLocation)"
    $prompt_custom_end = "`n$> "
    return "$prompt_curr_time $prompt_root_content$(prompt_git_file_status)$prompt_custom_end"
}
