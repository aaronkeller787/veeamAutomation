$logPath = 'K:\DailyLogs-New'

Get-ChildItem -Path $logPath -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddHours(-24))} | Remove-Item -Recurse

# Add as many servers here as you have configured in the Veeam Backup Server - including Proxies, WAN, etc
$server = '<SERVER NAME>',`
          '<SERVER NAME>,`
          '<SERVER NAME>

Export-VBRLogs -Server $server -FolderPath $logPath -Compress -LastDays 3 


