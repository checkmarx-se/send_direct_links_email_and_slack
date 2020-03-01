## About

This script is not supported by Checkmarx and edge cases are not tested, use it as your own.

This powershell script runs after every scan and sends an email and slack on new vulnerabilities found.

Customize the script to remove email or slack if you don't want both.

# To configure CxSAST to run an executable before or after a scan:

Upload an executable: To ensure the integrity of the system and to restrict access, executable files must be uploaded manually by approved personnel. 

> The location used by CxSAST for executable files appears in Settings > Application Settings > General > Executables Folder. 

Define an Action for the executable: Go to Settings > Scan Settings > Pre & Post Scan Actions > Create New Action, and configure the following:

- Action Type: Pre-scan or Post-scan.
- Name: This will appear in a drop-down list when assigning the actions to a project.
- Command: Use the syntax as required by the executable or select from the list.

> Note that the command should use the same name that is used for the file located in the ‘Executables’ folder (files present in that folder will show up in the drop-down list), as defined in Settings > Application Settings > General > Executables Folder.

Arguments: Enter arguments required by the command.

For post-scan actions you can also select whether the scan results should be XML or CSV.

Assign the action to a project: In a project's Advanced Actions tab, select an action from the list.

Click Finish.
