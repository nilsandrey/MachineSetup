Disable-UAC
$ConfirmPreference = "None" #ensure installing powershell modules don't prompt on needed dependencies

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$strpos = $helperUri.LastIndexOf("/")
$helperUri = $helperUri.Substring(0, $strpos)
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

$path = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell'
$key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
if ($key -eq $null)
{
    (get-item HKLM:\Software\Policies\Microsoft).OpenSubKey("Windows", $true).CreateSubKey("PowerShell")
}
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" -Name "EnableScripts" -Value 00000001 -Type DWORD
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" -Name "ExecutionPolicy" -Value "Unrestricted"

Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot 

#--- Setting up Windows ---
executeScript "FileExplorerSettings.ps1";
executeScript "dev_app_desktop_.net.ps1";
executeScript "browsers.ps1";
executeScript "WUpdates.ps1";

#choco install -y powershell-core

#RefreshEnv

#Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot 
#Add Windows Credential
executeScript "AddWindowsCredentials.ps1";
#Turning .NetFramework3.5 on
executeScript "NetFramework35.ps1";
 