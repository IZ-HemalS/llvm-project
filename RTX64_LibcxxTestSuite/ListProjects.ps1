#outputs a list of all vcxproj files within the current directory and below it. 
$projects = Get-ChildItem -recurse -filter *.vcxproj -name
Write-Host ($projects | Format-Table | Out-String)