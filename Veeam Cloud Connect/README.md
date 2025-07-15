# Veeam Cloud Connect
A Veeam Cloud Connect automated log generation project written in Powershell.

## Description
To streamline support operations for large Veeam Cloud Connect environments—where log generation can be time-consuming—a PowerShell script was developed to automate the creation and retention of support log bundles. The script runs on a scheduled basis, automatically generating a complete log bundle and storing it in a designated local directory. To optimize storage usage and maintain a clean environment, the script retains only the three most recent log bundles, automatically purging the oldest file during each execution cycle.

## How it works
The script operates by scanning the designated local directory to determine the current number of existing log bundles. If three log bundles are already present, it automatically identifies and removes the oldest to maintain the defined retention policy. It then proceeds to generate fresh logs from the configured components—such as Veeam Backup Servers, Proxies, and WAN Accelerators—using parameters defined within the script. Once collected, the logs are compressed, renamed for consistency, and stored locally for support use.
