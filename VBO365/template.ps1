$client_org = $template_client_org
$client_name = $template_client_name
$attachment = "C:\Monitoring_Script\$template_attachment\VBO_JobLog.txt"
$smtp_server = "<SMTP SERVER>"
$email_from = "<SENDER EMAIL HERE>"
$recipients = $recipients_pnap, $template_recipients

#Add-PSSnapin VeeamPSSnapin

$time_now = (Get-Date).ToString()	#Get Date/time to add to Alert
$time = (Get-Date).ToShortTimeString().ToString()	#Get Time to add to Alert
$monthly_email = (Get-Date).Day		#Get Day of month to send the log every month
$srv = "<FQDN FOR VEEAM BACKUP SERVER"

$eventlog = $log = $today = $null
$backup_name = $backup_completion = $backup_objects = $backup_objects_completed = $jobname = $null
$filler2 = "Job finished with Status: "
$filler3 = " ** VBO log for Job finished with Status: "

$n = "`n"
$r = "`r"

# Get configured jobs for the Client VBO Organization that you are reporting on
$jobs = Get-VBOOrganization -Name $client_name | Get-VBOJob

$log = @()

if ($jobs.Length -ge 1) {  # Org exists and there is at least 1 job configured, go on with script
   
$jobs | ForEach-Object {

$eventlog = $eventlog + "`n - Report for Job Name: " + $_.Name + $n
Write-Host "Processing report for Job Name: " $_.Name

$today = Get-VBOJobSession -Job $_ | Where-Object { $_.status -ne "Running" -and $_.endtime -ge (Get-Date).AddHours(-24) } # Get all job sessions executed in the last 24 hrs for the VBO job

# Get summary details for all the job sessions executed in the last 24 hrs
$total = $today.count
$warn = ($today | Where-Object { $_.status -eq "Warning" }).count
$succ = ($today | Where-Object { $_.status -eq "Success" }).count
$failed = ($today | Where-Object { $_.status -eq "Failed" }).count
$running = ($today | Where-Object { $_.status -eq "Running" }).count
$stopped = ($today | Where-Object { $_.status -eq "Stopped" }).count

$eventlog = $eventlog + " - Jobs run in the last 24Hrs: " + $total + " | Successful: " + $succ + " | Warning: " + $warn + " | Failed: " + $failed + " | Stopped: " + $stopped + " | Running now: " + $running + "`r`n`r`n"
$c = 0

$today | ForEach-Object { 
    
    $backup_objects = ($_.Log | Where-Object { $_.title -like '*`[Success`] Found*' -and $_.title -notlike '*excluded*' } | Select-Object -First 1).title.Replace("[Success] Found ","") # This gets the number of objects that are being backed up
    $backup_objects_completed = " | Backup completed on " + $_.Progress # $_.Progress is the number of items that completed the backup

    $job_detail = $filler2 + $_.status + " on " + $_.endtime.ToString() + $backup_objects_completed + " out of " + $backup_objects + "`t`n"
    $eventlog = $eventlog + $job_detail

    $c++ # Counter is used to trigger log export of the last job executed
    $c
    
    if (($c -eq $today.Length) -and ($_.status -eq "Warning" -or $_.status -eq "Failed")) {  # When this matches it means that the last job executed is being analyzed and if job ended in Warning or Failed, logs for this job are added to attachment
    
    
      
    $jobname = "`n *** " + $_.Jobname + " ***"
    $log_job_detail = $filler3 + $_.status + " on " + $_.endtime.ToString() + $backup_objects_completed + " out of " + $backup_objects + " **" + "`r`n"
    $log = $log + $jobname
    $log = $log + $log_job_detail
    $log = $log + $_.log    

}
    }           
           } -End { 
   
   $eventlog = $eventlog + "`t`n - Full logs from the last executed job/s IF it ended in Warning or Error state are attached"
   $eventlog

   # If $log is empty, the if/else logic will not send an empty text file in the email as an attachment
   # Change the Email subject according to Client

   if ($log.Count -gt 0) {  # There is data in the logfile i.e. last job has failed
   
   $log >> $attachment   # Add-Content was stripping some data from the log file, this appended to text file without any issues 
   Send-MailMessage -Body $eventlog -From $email_from -To $recipients -Subject "Daily Veeam Backup for O365 Report: $client_name" -SmtpServer $smtp_server -Attachments $attachment
   sleep 10  # Making sure that the text file with logs is attached to email before deleting it
   Remove-Item $attachment -Force

   } else { Send-MailMessage -Body $eventlog -From $email_from -To $recipients -Subject "Daily Veeam Backup for O365 Report: $client_name" -SmtpServer $smtp_server }   # Do not send empty attachment
    
    } 
       } else {  # No Jobs are configured for the Org or the Org does not exist so send email ONLY to admin

    Write-Host "There are no Jobs configured for VBO Org: $client_org"
    Send-MailMessage -Body "There are no Jobs configured for VBO Org: $client_org" -From $email_from -To <YOUR EMAIL HERE> -Subject "Daily Veeam Backup for O365 Report: $client_name" -SmtpServer $smtp_server

    }

