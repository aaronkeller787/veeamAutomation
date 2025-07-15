$directory = 'K:\DailyLogs-New\VeeamSupportLogs\'
$brokenDir = Read-Host "Please paste the directory path here "

Get-ChildItem -Recurse $directory\$brokenDir | Where { $_.PSIsContainer } | ForEach-Object -Begin { $Counter = 1 } -Process { Rename-Item $_.FullName -NewName $Counter ; $Counter++ }
Remove-Item -Recurse $directory\$brokenDir
