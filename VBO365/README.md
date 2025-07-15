# Veeam Backup Office 365

## Description:
Designed and implemented a PowerShell-based automation solution to monitor the health of Veeam Backup for Microsoft 365 jobs and deliver daily status notifications. The script dynamically discovers backup jobs for a specified organization using Get-VBOOrganization and Get-VBOJob, retrieves recent job sessions with Get-VBOJobSession, and analyzes outcomes including object counts, progress, and error states.

It generates a detailed status report, conditionally attaches verbose job logs when warnings or failures are detected, and dispatches the results via Send-MailMessage with adaptive subject lines and attachments. To ensure consistent execution, the script was integrated into a Windows Scheduled Task, configured to run daily with appropriate triggers, credential handling, and logging for monitoring execution success. Post-run cleanup is handled through temporary file removal.

This solution significantly improved operational efficiency by eliminating manual checks, standardizing customer reporting, and ensuring reliable and timely visibility into backup job health across all managed tenants.

## How it Works

1. Uses PowerShell with Veeam PowerShell Snap-in to programmatically gather backup job data.

2. Retrieves job session information and metadata using Get-VBOOrganization, Get-VBOJob, and Get-VBOJobSession.

3. Parses job logs to extract backup object metrics and completion data.

4. Builds a custom email body with detailed job summaries.

5. Conditionally generates and attaches detailed logs for jobs in Warning or Failed states.

6. Sends emails with Send-MailMessage, using dynamic subject lines and optional attachments.

7. Appends logs using >> to preserve formatting and cleans up temporary files after email dispatch.

8. Implements a Windows Scheduled Task using schtasks.exe or PowerShell cmdlets (Register-ScheduledTask) to execute the script daily.

9. Task configuration includes secure credential handling, trigger time, and error logging to ensure reliability and unattended execution.
