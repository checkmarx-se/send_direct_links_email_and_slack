#
# Usage: ParseXMLandSendEmail -resultsFile <path-to-xml-results> -slackWebHook <slack hook> -emailList <list of email recipients> -logFile <log location>
 
param (
    [Parameter(Mandatory=$true)][string]$resultsFile,
    [string]$slackWebHook,
    [string]$emailList,
    [string]$logFile
)

$debug = "resultsFile " + $resultsFile + "," + $slackWebHook + "," + $emailList + "," + $logFile
Add-Content $logFile $debug

Function global:AddToMessage ($severity) {
    [string]$message += "`n[" + $severity + "]`n"
    
    #For each vulnerability, format a message 
    Foreach ($Vuln in $Vulns) {
        if($Vuln.Severity -eq $severity) {
            $message += "`n" + $Vuln.ParentNode.name + " vulnerability found"
 
            #Deep link to the vulnerability information in the portal

            $message += ": " + $Vuln.DeepLink
        }
    }

    $message += "`n" 

    return $message
}

### Parse XML file into an object

try {
    [xml]$results = get-content $resultsFile
}
catch {
    Write-Output "Error parsing " + $resultsFile
    Write-Output "Exception: $($_.Exception.Message)"
    Add-Content $logFile "Error parsing file"
    exit
}

[string]$project_name = $results.CxXMLResults.ProjectName
[string]$message = "Results for project " + $project_name + ".  Full results at: " + $results.CxXMLResults.DeepLink + "`n"

### Find all new vulnerabilities; modify the following line as needed

[Object []]$Vulns = $results.CxXMLResults.Query.Result | Where-Object {$_.Status -eq "New"}

$message += AddToMessage("High")
$message += AddToMessage("Medium")
$message += AddToMessage("Low")
$message += AddToMessage("Information")
 
Write-Output $message

### Send Slack Message 

try {
    ### work needs to be done here to tweak exactly what you want sent.  The body needs to be in a json format

    $body = '{"text":"New SAST vulnerabilites found - ' + $results.CxXMLResults.DeepLink + '"}'
    
    #$body = $message | ConvertTo-Json -Depth 99
    
    $response = Invoke-RestMethod -Uri $slackWebHook -Method Post -Body $body -ContentType 'application/json' 
} catch {
    Write-Output "Error sending slack "
    Add-Content $logFile "Error sending Slack"
    Add-Content $logFile $body
} 

Add-Content $logFile "Wrote message now sending email.  "

### Email Config 

$gmailUsername = "username@gmail.com"
$gmailPassword = "password"

### EMAIL 

try {

    $EmailFrom = $gmailUsername  
    $EmailTo = $emailList
    $Subject = "New Checkmarx Vulnerabilities" 
    $Body = $message 
    $SMTPServer = "smtp.gmail.com"  
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587);  
    $SMTPClient.EnableSsl = $true
    $SMTPClient.UseDefaultCredentials = $true  
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($gmailUsername, $gmailPassword);  

    # when using gmail you need to lower the security permissions or this .Send will fail

    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

    Add-Content $logFile "Sent email to "
    Add-Content $logFile $emailList
} catch {
    Write-Output "Error sending email " 
    Add-Content $logFile "Error sending email"
} 