$projects = Get-ChildItem -recurse -filter *.vcxproj -name
$projects = $projects | sort

[Environment]::SetEnvironmentVariable('LibCXXTestDir',"C:\RTX64_LibcxxTestSuite\" , 'User')
$Env:LibCXXTestDir = "C:\RTX64_LibcxxTestSuite\"
$parents = @()

for ($m = 0; $m -lt $projects.length; $m++) 
{
    $leaf = Split-Path $projects[$m]
    $leaf = $leaf.Replace('\','\\')
    if(-Not ($parents."Name" -contains $leaf.ToString() ) )
    {
        $parents += New-Object PSObject -Property @{Name = $leaf; Pass = 0; Fail = 0 }
    }
}

$succeededProjects  = @()
$failedProjects  = @()



$succeeded= 0
$failed = 0
for ($i = 0; $i -lt $projects.Length; $i++) 
{
    $output = C:\"Program Files (x86)\Microsoft Visual Studio\2019\Preview\MSBuild\Current\Bin\amd64\MSBuild.exe"  $projects[$i]  '/t:rebuild' '/p:Configuration=RtssDebug' '/p:Platform=x64' '/p:PlatformToolset=v141'
    if($output -match "Build succeeded")
    {
    $succeeded++
    $succeededProjects += $projects[$i]
    "======= {0} =====" -f $projects[$i]
    ""
    ""
    ""
    "$output"
    Add-Content -Path "C:\CPPBuildLog.txt" -Value $output 

    Write-Host -NoNewLine 'Press any key to Run Program...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    #getcurrentdir
    $ProgramPath = ("{0}{1}" -f (Get-Item -Path ".\").FullName,'\')
    #add extra sub dir
    $ProgramPath += Split-Path $projects[$i]
    #Add build directory
    $ProgramPath += "\x64\RTSSDEBUG\"
    #add project folder
    $Program = Split-Path -Leaf $projects[$i]
    #add project Name
    $ProgramPath += [io.path]::GetFileNameWithoutExtension($Program)
    $ProgramPath += "\"
    $ProgramPath += [io.path]::GetFileNameWithoutExtension($Program)
    $ProgramPath += ".rtss"

    Start-Process -FilePath "C:\Program files\IntervalZero\Rtx64\Bin\RtssRun.exe" -ArgumentList "$ProgramPath"
    }
    else
    {
    $failed++
    $failedProjects += $projects[$i]
    "======= {0} =====" -f $projects[$i]
    ""
    ""
    ""
    "$output"


    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Clear-Host

}

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

"Builds that Succeeded: $succeeded"

"Builds that failed: $failed"

"Projects Pass/Fail`n"

for ($n = 0; $n -lt $parents.length; $n++) 
{
    $pName = $parents[$n]."Name".ToString()

    foreach( $success in $succeededProjects)
    {
        $tempSuccess = $success.Replace('\','\\')
        if($tempSuccess.Contains("$pName") )
        {
            $parents[$n]."Pass"++
        }
    }

    foreach( $fail in $failedProjects)
    {
        $tempFail = $fail.Replace('\','\\')
        if($tempFail.Contains("$pName") )
        {
            $parents[$n]."Fail"++
        }
    }
    
} 
"Pass`t/'tFail`tName`n"
foreach($p in $parents)
{
    "{0}`t/`t{1}`t{2}" -f $p."Pass", $p."Fail", $p."Name"
}


"Succeeded Projects:"

for ($j = 0; $j -lt $succeededProjects.length; $j++) 
{
    $succeededProject = $succeededProjects[$j]
    "$succeededProject `n"
}
"Failed Projects: "

for ($k = 0; $k -lt $failedProjects.length; $k++) 
{
    $failedproject = $failedProjects[$k]
    "$failedProject `n"
}
