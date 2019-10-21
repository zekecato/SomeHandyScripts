# This script will run all scripts in whatever folder it's placed in.
# Handy for scheduling one script to run a whole folder on that schedule.
# 

Start-Transcript $LogFilePath -Append

#Get scripts in this folder. but not this script.
$Tasks = Get-ChildItem $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name | Where-Object {$_.name -like '*.ps1'}

#Run scripts in this folder.

foreach ($task in $Tasks){
    try{
        "Starting task: $($task.basename)"
        & $task.fullname
    }catch{
        Write-Warning "Problem Executing task"
        $_
        continue
    }
}
