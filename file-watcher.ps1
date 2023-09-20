$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "c:\temp\watched"
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    $logline = "$(Get-Date), $changeType, $path"
    Add-content "c:\temp\log.txt" -value $logline
    Move-Item -Path $path -Destination "c:\temp\dest"
}

Register-ObjectEvent $watcher "Created" -Action $action
while ($true) {sleep 5}