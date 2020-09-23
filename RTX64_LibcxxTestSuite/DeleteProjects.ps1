$TargetFolder = Get-Location
pushd $TargetFolder/test
$Files = Get-ChildItem $TargetFolder/test -Recurse -include *.vcxproj,*.pdb,*.log,*.rtss -name 
foreach ($File in $Files)
{ 
    write-host “Deleting File $File” -foregroundcolor “Red”;
    Remove-Item $File | out-null
}
popd