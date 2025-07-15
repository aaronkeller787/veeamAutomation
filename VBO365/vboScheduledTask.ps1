$temp_recipients = "exmaple@example.com" # Used as a placeholder for the company email

Clear-Host

function gatherInfo {
    # Prompt user for necessary information
    Clear-Host
    $temp_client_org  = Read-Host -Prompt "Please enter in the Organization Name - Example: example.onmicrosoft.com"               
    $global:temp_client_name = Read-Host -Prompt "Please enter in the Company Name - Example: Example Corp"                            
    $temp_attachment  = Read-Host -Prompt "Please enter in the Organization Directory (No Spaces)"                                       
    $temp_recipients  = Read-Host -Prompt "Please enter in the clients email address"           										 

verifyInfo

}                                      

function verifyInfo{
    # Verify information entered before  proceeding to next step
    Clear-Host
    Write-Host ''
    Write-Host 'Please verify the following:'
    Write-Host 'Organization Name:' $temp_client_org
    Write-Host 'Client Company Name:' $temp_client_name
    Write-Host 'Org Directory Name:' "C:\Monitoring_Script\$temp_attachment\VBO_JobLog.txt"
    Write-Host 'Client email address:' $temp_recipients

    inputValidation
    
}

function inputValidation {

    while($true){
    $answer = Read-Host "Are you sure you wish to continue? [Y]es or [N]o"
    if  ($answer -eq "n"){
        gatherInfo
        
    }
    elseif ($answer -eq "y") {
       break
    }
    else{
        $answer = Read-Host "You entered an invalid response.`r`nPlease enter [Y]es or [N]o"
    }
  }
  createScript
}

function createScript {

    $dir_name = "C:\Monitoring_Script\$temp_attachment"


    if (Test-Path $dir_name){
        Write-Host "The given folder exists."
        break
    }
    else {
        Write-Host "The given folder does not exist."
        New-Item $dir_name -ItemType Directory
    }

    Copy-Item "C:\Monitoring_Script\Template.ps1" -Destination "$dir_name\VBO-Report-$temp_client_name.ps1"

    $Content = Get-Content "$dir_name\VBO-Report-$temp_client_name.ps1"
    $Content.replace('$template_client_org', "'$temp_client_org'") | Set-Content "$dir_name\VBO-Report-$temp_client_name.ps1"

    $Content = Get-Content "$dir_name\VBO-Report-$temp_client_name.ps1"
    $Content.replace('$template_client_name', "'$temp_client_name'") | Set-Content "$dir_name\VBO-Report-$temp_client_name.ps1"

    $Content = Get-Content "$dir_name\VBO-Report-$temp_client_name.ps1"
    $Content.replace('$template_attachment', "$temp_attachment") | Set-Content "$dir_name\VBO-Report-$temp_client_name.ps1"

    $Content = Get-Content "$dir_name\VBO-Report-$temp_client_name.ps1"
    $Content.replace('$recipients', "'$temp_recipients'") | Set-Content "$dir_name\VBO-Report-$temp_client_name.ps1"

    $Content = Get-Content "$dir_name\VBO-Report-$temp_client_name.ps1"
    $Content.replace('$template_recipients', "'$temp_recipients'") | Set-Content "$dir_name\VBO-Report-$temp_client_name.ps1"

    createTask
    
}

function createTask{

    # The below is what will actually be used in production
    $getTaskInfo = Get-ScheduledTask -TaskName "VBOReport*" | Get-ScheduledTaskInfo | Sort-Object Nextruntime | Select-Object Taskname, LastRunTime, NextRunTime | Sort-Object LastRunTime -Descending | Out-GridView

    $global:scheduleTime = Read-Host 'Please choose a time from the pop-up window. (Example 7:17am)'

    $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "$dir_name\VBO-Report-$temp_client_name.ps1"
    $trigger = New-ScheduledTaskTrigger -Daily -At $scheduleTime

    $description = New-ScheduledTask -Description "VBO Monitor for $temp_client_name"
    $timespan = New-TimeSpan -Hours 1
    $settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -ExecutionTimeLimit $timespan -AllowStartIfOnBatteries 

    Register-ScheduledTask -TaskName "VBOReport - $temp_client_name" -Trigger $trigger -Action $action -Settings $settings -Description "VBO Monitor for $temp_client_name" -RunLevel Highest 

    emailTo

}

function emailTo{

    $smtp_server = ""
    $email_from = ""
    $file = "C:\Monitoring_Script\$temp_attachment\VBO-Report-$temp_client_name.ps1"

$body = @"
    
Hello,

Please add the following to the wiki:
VBO Client Job reports - $temp_client_name 
Script runs off <VBS SERVER>
Task Scheduler job name - VBOReport - $temp_client_name
Description: VBO Report for $temp_client_name. VBO Org is $temp_client_org
Located at $file
Runs every day @$scheduleTime
Service Account - c

Regards,
Cloud Automation

"@
    
    Compress-Archive -Path $file -DestinationPath "C:\Monitoring_Script\$temp_attachment\$temp_client_name"
    $new_attachment = "C:\Monitoring_Script\$temp_attachment\$temp_client_name.zip"


    Send-MailMessage -Body $body -From $email_from -To $temp_recipients -Subject "VBO Wiki Update: $temp_client_name " -SmtpServer $smtp_server -Attachments $new_attachment
    Sleep 10
    Remove-Item $new_attachment -Force
}

gatherInfo





