#	Abstract:
#   	Script for building and running the Libcxx Test Suite.  
#   
#   Author:
#   	Owen Monahan
#
#	Notes:
#		This script will build and run all tests found in C:\RTX64_LibcxxTestSuite\test\std\ on the machine.
#		To build/run selectively, individual tests or entire folders of tests can be removed from that
#		directory.
#
#	Instructions:
#		Instructions for running this script can be found in "Libcxx Test Suite Steps.docx"
#
# Enum for capturing status at the different stages of each test
enum Status
{
    FAIL = 0
    PASS = 1
    NA = 2
    UNDETERMINED = 3
}

# Class to hold information about a single test
class Test
{
    [string]$TestName
    [string]$PID = "0"
    [bool]$ShouldBuild
    [Status]$CompilationCheck = [Status]::UNDETERMINED
    [Status]$RunCheck = [Status]::UNDETERMINED
    [Status]$ExecutionCheck = [Status]::UNDETERMINED
	[Status]$OverallStatus = [Status]::UNDETERMINED
}

# Class to hold information about an entire test area and all the tests within it (eg, Containers)
class TestArea
{
    [string]$AreaName = ""
    [int]$NumBuildFailed = 0
    [int]$NumRunFailed = 0
    [int]$NumTestFailed = 0
    [Test[]]$Tests = [Test[]]::new(0)
}

# Function for marking the ExecutionCheck of a Test as FAIL, for when a test prints failure
function ModifyFailedTest([string]$failString)
{

    for ($modAreaIndex = 0; $modAreaIndex -lt $Areas.Count; $modAreaIndex++)
    {
        if ($failString -match $Areas[$modAreaIndex].AreaName)
        {
            for ($modTestIndex = 0; $modTestIndex -lt $Areas[$modAreaIndex].Tests.Count; $modTestIndex++)
            {
                $compareString = "*" + $Areas[$modAreaIndex].Tests[$modTestIndex].TestName + "*"
                if ($failString -like $compareString)
                {
                    $Areas[$modAreaIndex].Tests[$modTestIndex].ExecutionCheck = [Status]::FAIL
					$Areas[$modAreaIndex].Tests[$modTestIndex].OverallStatus = [Status]::FAIL
                }
            }
        }
    }

}

# Function for marking the ExecutionCheck of a Test as FAIL, for when a test causes an exception
function FindPidAndMarkFail([string]$PidToFind)
{
    
    for ($modAreaIndex = 0; $modAreaIndex -lt $Areas.Count; $modAreaIndex++)
    {
        $tempArea = $Areas[$modAreaIndex]
        if ($PidToFind -le $tempArea.Tests[$tempArea.Tests.Count - 1].PID)
        {
            for ($modTestIndex = 0; $modTestIndex -lt $tempArea.Tests.Count; $modTestIndex++)
            {
                $Test = $tempArea.Tests[$modTestIndex]
                if ($PidToFind -match $Test.PID -AND $Test.PID -ne "0")
                {
                    $Test.ExecutionCheck = [Status]::FAIL
					$Test.OverallStatus = [Status]::FAIL
                }
            }
        }
    }

}


# Building the tests in both RtssDebug and RtssRelease
$buildConfigs = @("RtssDebug", "RtssRelease")

# This path will work as long as the instructions in "Libcxx Test Suite Steps.docx" are followed
cd "C:\RTX64_LibcxxTestSuite\test\std\"

# loop based on how many configurations you have
# run the whole test x times 
for ($configIndex = 0; $configIndex -lt $buildConfigs.Count; $configIndex++)
{
    Start-Process "C:\RTX64_LibcxxTestSuite\RTX64_LibcxxTestSuiteMonitor.exe"

    $projects = Get-ChildItem -recurse -filter *.vcxproj -name
    $projects = $projects | sort
		
	# Array of Test Areas
	# Test Areas are determined by the topmost folders in C:\RTX64_LibcxxTestSuite\test\std\
	#	- For example: containers, atomics, etc.
    [TestArea[]]$Areas = @()

    $Areas += [TestArea]::new()
    $Areas[0].AreaName = $projects[0].Substring(0, $projects[0].IndexOf("\"))

    $areaIndex = 0;
    $testIndex = -1;
    $lastPID = "0";
    for ($projectIndex = 0; $projectIndex -lt $projects.Count; $projectIndex++)
    {
        if ($projects[$projectIndex] -match $Areas[$areaIndex].AreaName)
        {
            $Areas[$areaIndex].Tests += [Test]::new()
            $testIndex++
            $Areas[$areaIndex].Tests[$testIndex].TestName = $projects[$projectIndex].Substring(0, $projects[$projectIndex].IndexOf(".vcxproj"))
        }
        else
        {
            $Areas += [TestArea]::new();
            $areaIndex++
            $Areas[$areaIndex].AreaName = $projects[$projectIndex].Substring(0, $projects[$projectIndex].IndexOf("\"))
            $Areas[$areaIndex].Tests += [Test]::new()
            $testIndex = 0
            $Areas[$areaIndex].Tests[$testIndex].TestName = $projects[$projectIndex].Substring(0, $projects[$projectIndex].IndexOf(".vcxproj"))
        }
		
		#Concat the configuration in
        $configString = '/p:Configuration=' + $buildConfigs[$configIndex]
		#Execute the test
        $buildOutput = C:\"Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\amd64\MSBuild.exe"  $projects[$projectIndex]  '/t:build' $configString '/p:Platform=x64' '/p:PlatformToolset=v143' '/v:d'

        if ($projects[$projectIndex] -match "\.fail")
        {
            $Areas[$areaIndex].Tests[$testIndex].ShouldBuild = $false
            if ($buildOutput -match "Build succeeded")
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::FAIL
                $Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::NA
                $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
			    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::FAIL
                $Areas[$areaIndex].NumBuildFailed++
                $Areas[$areaIndex].NumTestFailed++
            }
            else
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::PASS
                $Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::NA
                $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
			    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::PASS
            }
        }
        elseif ($projects[$projectIndex] -match "nothing_to_do")
		{
			$Areas[$areaIndex].Tests[$testIndex].ShouldBuild = $true
            if ($buildOutput -match "Build succeeded")
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::PASS
                $Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::NA
                $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
			    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::PASS
            }
            else
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::FAIL
                $Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::NA
                $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
			    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::FAIL
				$Areas[$areaIndex].NumBuildFailed++
                $Areas[$areaIndex].NumTestFailed++
            }
		}
		else
        {
            $Areas[$areaIndex].Tests[$testIndex].ShouldBuild = $true
            if ($buildOutput -match "Build succeeded")
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::PASS

                # Run the binary
                #getcurrentdir
                $ProgramPath = ("{0}{1}" -f (Get-Item -Path ".\").FullName,'\')
                #add extra sub dir
                $ProgramPath += Split-Path $projects[$projectIndex]
                #Add build directory
                $ProgramPath += "\x64\"
                $ProgramPath += $buildConfigs[$configIndex]
                $ProgramPath += "\"
                #add project folder
                $Program = Split-Path -Leaf $projects[$projectIndex]
                #add project Name
                $ProgramPath += [io.path]::GetFileNameWithoutExtension($Program)
                $ProgramPath += "\"
                $ProgramPath += [io.path]::GetFileNameWithoutExtension($Program)
                $ProgramPath += ".rtss"
                C:"\Program files\IntervalZero\Rtx64\Bin\RtssRunAndWait.exe" /p 8 $ProgramPath

                Start-Sleep -Milliseconds 500

                # Check if the test ran
				if (!(Test-Path "C:\CPPRunLog.txt"))
				{
					$Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::FAIL
                    $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
				    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::FAIL
				}
				else
				{
					$runOutput = Get-Content -Path "C:\CPPRunLog.txt"
					
					$newPID = "0"
					for ($runIndex = $runOutput.Length - 1; $newPID -eq 0 -AND $runIndex -ge 0; $runIndex--)
					{
						if ($runOutput[$runIndex] -match "EVENT_PROCESS_START")
						{
							$pidLocation = $runOutput[$runIndex].IndexOf("pID:") + 5
							$pidLength = $runOutput[$runIndex].IndexOf(", tID:") - $runOutput[$runIndex].IndexOf("pID:") - 5
							$newPID = [String]::Format("{0:x}", [Convert]::ToInt32($runOutput[$runIndex].Substring($pidLocation, $pidLength)))
						}
					}

					if ($newPID -ne $lastPID)
					{
						$Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::PASS
						$Areas[$areaIndex].Tests[$testIndex].PID = $newPID
						$lastPID = $newPID
					}
					else
					{
						$Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::FAIL
						$Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
						$Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::FAIL
					}
				}
            }
            else
            {
                $Areas[$areaIndex].Tests[$testIndex].CompilationCheck = [Status]::FAIL
                $Areas[$areaIndex].Tests[$testIndex].RunCheck = [Status]::NA
                $Areas[$areaIndex].Tests[$testIndex].ExecutionCheck = [Status]::NA
			    $Areas[$areaIndex].Tests[$testIndex].OverallStatus = [Status]::FAIL
                $Areas[$areaIndex].NumBuildFailed++
                $Areas[$areaIndex].NumTestFailed++

                Add-Content -Path "C:\CPPBuildLog.txt" -Value $buildOutput 
            }

        }
    }

    Stop-Process -Name "RTX64_LibcxxTestSuiteMonitor"

    Start-Sleep -Seconds 5

    $failOutput = Get-Content -Path "C:\CPPTestsLog.txt"
    for ($failIndex = 0; $failIndex -lt $failOutput.Length; $failIndex++)
    {
        if ($failOutput[$failIndex].ToString() -match "FAIL:")
        {
            ModifyFailedTest -failString $failOutput[$failIndex].ToString()
        }
    }

    # Get content of the Run Log one more time, and check for any exceptions
    $runOutput = Get-Content -Path "C:\CPPRunLog.txt"
    for ($i = 0; $i -lt $runOutput.Length; $i++)
    {
        $line = $runOutput[$i]
        if ($line -match "Exception")
        {
            $i++
            $line = $runOutput[$i]
            $exceptionPidLocation = $line.IndexOf("Pid=") + 4
            $exceptionPidLength = $line.IndexOf(", Tid=") - $line.IndexOf("Pid=") - 4
            $exceptionPid = $line.Substring($exceptionPidLocation, $exceptionPidLength)
            FindPidAndMarkFail $exceptionPid
        }
    }
	
	# Loop through all tests.  All tests which have passed the RunCheck and have not failed the ExecutionCheck must have passed.
    for ($i = 0; $i -lt $Areas.Count; $i++)
    {
        for ($j = 0; $j -lt $Areas[$i].Tests.Count; $j++)
        {
            if (($Areas[$i].Tests[$j].RunCheck -eq [Status]::PASS) -and ($Areas[$i].Tests[$j].ExecutionCheck -eq [Status]::UNDETERMINED))
            {
                $Areas[$i].Tests[$j].ExecutionCheck = [Status]::PASS
			    $Areas[$i].Tests[$j].OverallStatus = [Status]::PASS
            }
        }
    }

	
	# Assemble the data into a form which the Export-Csv cmdlet can recognize, then export the CSV
    $exportObject = @()
    $exportObject
    for ($i = 0; $i -lt $Areas.Count; $i++)
    {
        $Area = $Areas[$i]
        for ($j = 0; $j -lt $Area.Tests.Count; $j++)
        {
            $Test = $Area.Tests[$j]
            $exportObject += New-Object PSObject -Property @{Area = $Area.AreaName; Test = $Test.TestName; CompilationCheck = $Test.CompilationCheck; RunCheck = $Test.RunCheck; ExecutionCheck = $Test.ExecutionCheck; OverallStatus = $Test.OverallStatus; blank=""}
        }
    }

    $CSVPath = "C:\LibcxxTestSuiteResults_" + $buildConfigs[$configIndex] + ".csv"
    $exportObject | Select-Object Area,Test,CompilationCheck,RunCheck,ExecutionCheck,OverallStatus | Export-Csv -Path $CSVPath

    analyzer /stop

    TIMEOUT 5

	# Save off permanent logs and delete the old temporary logs
    $logPath = "C:\CPPTestsLog_" + $buildConfigs[$configIndex] + ".txt"
    Copy-Item -Path "C:\CPPTestsLog.txt" -Destination $logPath
    Remove-Item -Path "C:\CPPTestsLog.txt"
    $logPath = "C:\CPPRunLog_" + $buildConfigs[$configIndex] + ".txt"
    Copy-Item -Path "C:\CPPRunLog.txt" -Destination $logPath
    Remove-Item -Path "C:\CPPRunLog.txt"
    $logPath = "C:\CPPBuildLog_" + $buildConfigs[$configIndex] + ".txt"
    Copy-Item -Path "C:\CPPBuildLog.txt" -Destination $logPath
    Remove-Item -Path "C:\CPPBuildLog.txt"

}