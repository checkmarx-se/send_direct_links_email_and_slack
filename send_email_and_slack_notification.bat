@echo off

set logFile="C:\Program Files\Checkmarx\Executables\log-test.txt"
del %logFile%
echo "Post-scan action with file %1" > %logFile%

cd "C:\Program Files\Checkmarx\Executables"

echo "Email list %2" >> %logFile%

set slack="https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

set ps_exe=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
set ps_script=".\parse_xml_send_email_slack_notification.ps1"
%ps_exe% "%ps_script% -resultsFile %1 -slackWebHook '%slack%' -emailList %2 -logFile '%logFile%'"
