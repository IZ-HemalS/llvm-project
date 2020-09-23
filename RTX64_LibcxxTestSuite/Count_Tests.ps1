# Counts the amount of projects created under the /test directory and then jumps 1 level lower and counts that teir.  provides a breakdown report. 
Push-Location .\test
$Dirs =  Get-ChildItem -Directory
"$Dirs"

$ListCount = @()

ForEach( $dir in $Dirs)
{
    Push-Location $dir
    $Tests = Get-ChildItem -file -recurse -filter *.vcxproj -name
    $ListCount += New-Object PSObject -Property @{Name = $dir; count = $Tests.Count}
    $SubDirs = Get-ChildItem  -Directory
    ForEach( $subdir in $SubDirs)
    {
        Push-Location $subdir
        $Tests = Get-ChildItem  -recurse -filter *.vcxproj -name
        $ListCount += New-Object PSObject -Property @{Name = "{0}\{1}" -f $dir.ToString(),$subdir.ToString(); count = $Tests.Count}
        Pop-Location
    }
   Pop-Location
}

Pop-Location

Write-Host ($ListCount | Format-Table | Out-String)

