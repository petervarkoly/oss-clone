###################################################################################################
# Win10 Initial Setup Script
# Author: Disassembler <disassembler@dasm.cz>
# Version: 1.7, 2016-08-15
# Edited: Helmuth Varkoly 30.06.2020 
#
#

###
#
#To use with CRANIX-Server
#
#location: /home/software/oss/Win10_clean.ps1 
#
#You can modify the locaton, but then you have to modify the /srv/itool/config/Win10Domain.xml accordingly 
#

# https://docs.microsoft.com/de-de/windows/application-management/apps-in-windows-10

# dasm's script: https://github.com/Disassembler0/Win10-Initial-Setup-Script/

# Weitere sinnvolle Links.
# https://www.howtogeek.com/224798/how-to-uninstall-windows-10s-built-in-apps-and-how-to-reinstall-them/
# https://www.deskmodder.de/wiki/index.php?title=Startmen%C3%BC_reparieren_Windows_10
# https://www.deskmodder.de/wiki/index.php/Windows_10_Apps_entfernen_deinstallieren
# https://www.askvg.com/guide-how-to-remove-all-built-in-apps-in-windows-10/


# THIS IS A PERSONALIZED VERSION
# This script leaves more MS defaults on, including MS security features.
# Tweaked based on personal preferences for @alirobe 2016-11-16 - v1.7.1

# NOTE: READ THIS SCRIPT CAREFULLY BEFORE RUNNING IT. ADJUST COMMENTS AS APPROPRIATE.
# This script will reboot your machine when completed.
# Setting up a new machine? See http://ninite.com (for devs, http://chocolatey.org)
###################################################################################################
 
# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
 
###################################################################################################
# Privacy Settings
###################################################################################################
 
# Disable Telemetry
# Disable Telemetry
Write-Host "Disabling Telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Enable Telemetry
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3

# Disable Wi-Fi Sense
Write-Host "Disabling Wi-Fi Sense..."
If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
 
# Enable Wi-Fi Sense
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1
 
# Disable SmartScreen Filter
# Write-Host "Disabling SmartScreen Filter..."
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
 
# Enable SmartScreen Filter
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "RequireAdmin"
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation"
 
# Disable Bing Search in Start Menu
Write-Host "Disabling Bing Search in Start Menu..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
 
# Enable Bing Search in Start Menu
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled"
 
# Disable Start Menu suggestions
Write-Host "Disabling Start Menu suggestions..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0

# Enable Start Menu suggestions
# Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 1

# Disable Location Tracking
Write-Host "Disabling Location Tracking..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
 
# Enable Location Tracking
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 1
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 1
 
# Disable Feedback
Write-Host "Disabling Feedback..."
If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
    New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
 
# Enable Feedback
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod"
 
# Disable Advertising ID
Write-Host "Disabling Advertising ID..."
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
 
# Enable Advertising ID
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled"
 
# Disable Cortana
Write-Host "Disabling Cortana..."
If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
    New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
 
# Enable Cortana
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy"
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts"
 
# Restrict Windows Update P2P only to local network
Write-Host "Restricting Windows Update P2P only to local network..."
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value 3
 
# Unrestrict Windows Update P2P
# Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode"
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode"
 
# Remove AutoLogger file and restrict directory
Write-Host "Removing AutoLogger file and restricting directory..."
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
    Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
}
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
 
# Unrestrict AutoLogger directory
# $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
# icacls $autoLoggerDir /grant:r SYSTEM:`(OI`)`(CI`)F | Out-Null
 
# Stop and disable Diagnostics Tracking Service
Write-Host "Stopping and disabling Diagnostics Tracking Service..."
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled
 
# Enable and start Diagnostics Tracking Service
# Set-Service "DiagTrack" -StartupType Automatic
# Start-Service "DiagTrack"
 
# Stop and disable WAP Push Service
Write-Host "Stopping and disabling WAP Push Service..."
Stop-Service "dmwappushservice"
Set-Service "dmwappushservice" -StartupType Disabled
 
# Enable and start WAP Push Service
# Set-Service "dmwappushservice" -StartupType Automatic
# Start-Service "dmwappushservice"
# Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1

###################################################################################################
# Cranix modification
###################################################################################################

# Activate Administrator
net user administrator /active:yes

# Disable Hibernate 
# Disable sleep mode

powercfg -h off 

powercfg -x -standby-timeout-dc 0

powercfg -x -standby-timeout-ac 0

# Administrator needs this 

Set-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections " -Type DWORD  -Value 1 

# Administrator stays forever

Set-LocalUser -Name "Administrator" -AccountNeverExpires

Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name Type -Value NTP

Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name NtpServer -Value admin
###################################################################################################
# Service Tweaks
###################################################################################################
 
# Lower UAC level
# Write-Host "Lowering UAC level..."
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
 
# Raise UAC level
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
 
# Enable sharing mapped drives between users
# Write-Host "Enabling sharing mapped drives between users..."
# Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
 
# Disable sharing mapped drives between users
# Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections"
 
# Disable Firewall
# Write-Host "Disabling Firewall..."
# Set-NetFirewallProfile -Profile * -Enabled False
 
# Enable Firewall
Set-NetFirewallProfile -Profile * -Enabled True
 
# Disable Windows Defender
# Write-Host "Disabling Windows Defender..."
# Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
 
# Enable Windows Defender
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware"
 
# Disable Windows Update automatic restart
Write-Host "Disabling Windows Update automatic restart..."
#Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
 
# Enable Windows Update automatic restart
Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 0
 
# Stop and disable Home Groups services
# Write-Host "Stopping and disabling Home Groups services..."
# Stop-Service "HomeGroupListener"
# Set-Service "HomeGroupListener" -StartupType Disabled
# Stop-Service "HomeGroupProvider"
# Set-Service "HomeGroupProvider" -StartupType Disabled
 
# Enable and start Home Groups services
Set-Service "HomeGroupListener" -StartupType Manual
Set-Service "HomeGroupProvider" -StartupType Manual
Start-Service "HomeGroupProvider"
 
# Disable Remote Assistance
# Write-Host "Disabling Remote Assistance..."
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
 
# Enable Remote Assistance
# 20191001_Hans Wagner, Remote Assistance aktiviert.
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
 
# Enable Remote Desktop w/o Network Level Authentication
# 20191001_Hans Wagner, Zugriff via RDP erlaubt.
Write-Host "Enabling Remote Desktop w/o Network Level Authentication..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
 
# Disable Remote Desktop
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1
 
###################################################################################################
# UI Tweaks
###################################################################################################
 
# Disable Action Center
# Write-Host "Disabling Action Center..."
# If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
#   New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
# }
# Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
 
# Enable Action Center
# 20191001_Hans Wagner, Action center aktiviert.
Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter"
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled"
 
# Disable Lock screen
# 20191001_Hans Wagner, Lockscreen Enabled.
# Write-Host "Disabling Lock screen..."
#If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization")) {
#	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" | Out-Null
#}
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1

# Enable Lock screen
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen"

# Disable Lock screen (Anniversary Update workaround)
#If ([System.Environment]::OSVersion.Version.Build -gt 14392) { # Apply only for Redstone 1 or newer
#	$service = New-Object -com Schedule.Service
#	$service.Connect()
#	$task = $service.NewTask(0)
#	$task.Settings.DisallowStartIfOnBatteries = $false
#	$trigger = $task.Triggers.Create(9)
#	$trigger = $task.Triggers.Create(11)
#	$trigger.StateChange = 8
#	$action = $task.Actions.Create(0)
#	$action.Path = "reg.exe"
#	$action.Arguments = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
#	$service.GetFolder("\").RegisterTaskDefinition("Disable LockScreen", $task, 6, "NT AUTHORITY\SYSTEM", $null, 4) | Out-Null
#}

# Enable Lock screen (Anniversary Update workaround)
#If ([System.Environment]::OSVersion.Version.Build -gt 14392) { # Apply only for Redstone 1 or newer
#	Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$false -ErrorAction SilentlyContinue
#}

# Disable Autoplay
Write-Host "Disabling Autoplay..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

# Enable Autoplay
# Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 0

# Disable Autorun for all drives
Write-Host "Disabling Autorun for all drives..."
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
  New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
 
# Enable Autorun
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun"
 
#Disable Sticky keys prompt
Write-Host "Disabling Sticky keys prompt..." 
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
 
# Enable Sticky keys prompt
# Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "510"
 
# Hide Search button / box
Write-Host "Hiding Search Box / Button..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
 
# Show Search button / box
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode"
 
# Hide Task View button
# Write-Host "Hiding Task View button..."
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
 
# Show Task View button
# 20191001_Hans Wagner, Show Task View enabled.
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton"
 
# Show small icons in taskbar
# Write-Host "Showing small icons in taskbar..."
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type DWord -Value 1
 
# Show large icons in taskbar
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons"
 
# Show titles in taskbar
# Write-Host "Showing titles in taskbar..."
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
 
# Hide titles in taskbar
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel"
 
# Show all tray icons
Write-Host "Showing all tray icons..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
 
# Hide tray icons as needed
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray"
 
# Show known file extensions
Write-Host "Showing known file extensions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
 
# Hide known file extensions
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
 
# Show hidden files
# Write-Host "Showing hidden files..."
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1

# 20191001_Hans Wagner, Hide hidden files
# Hide hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
 
# Change default Explorer view to "Computer"
Write-Host "Changing default Explorer view to `"Computer`"..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
 
# Change default Explorer view to "Quick Access"
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo"
 
# Show Computer shortcut on desktop
# Write-Host "Showing Computer shortcut on desktop..."
# If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
#   New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" | Out-Null
# }
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
 
# Hide Computer shortcut from desktop
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
# Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
 
# Remove Desktop icon from computer namespace
# Write-Host "Removing Desktop icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -Recurse -ErrorAction SilentlyContinue
 
# Add Desktop icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
 
# Remove Documents icon from computer namespace
# Write-Host "Removing Documents icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -Recurse -ErrorAction SilentlyContinue
 
# Add Documents icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
 
# Remove Downloads icon from computer namespace
# Write-Host "Removing Downloads icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -Recurse -ErrorAction SilentlyContinue
 
# Add Downloads icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
 
# Remove Music icon from computer namespace
# Write-Host "Removing Music icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Recurse -ErrorAction SilentlyContinue
 
# Add Music icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
 
# Remove Pictures icon from computer namespace
# Write-Host "Removing Pictures icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -Recurse -ErrorAction SilentlyContinue
 
# Add Pictures icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
 
# Remove Videos icon from computer namespace
# Write-Host "Removing Videos icon from computer namespace..."
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Recurse -ErrorAction SilentlyContinue
 
# Add Videos icon to computer namespace
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
# New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
 
## Add secondary en-US keyboard
# 20191001_Hans Wagner, zweites Tastaturlayout en-us hinzugefügt
Write-Host "Adding secondary en-US keyboard..."
$langs = Get-WinUserLanguageList
$langs.Add("en-US")
Set-WinUserLanguageList $langs -Force
 
# Remove secondary en-US keyboard
# $langs = Get-WinUserLanguageList
# Set-WinUserLanguageList ($langs | ? {$_.LanguageTag -ne "en-US"}) -Force
 
###################################################################################################
# Remove unwanted applications
###################################################################################################
 
# Disable OneDrive
# Write-Host "Disabling OneDrive..."
# If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
#     New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
#     }
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
 
# Enable OneDrive
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC"
 
# Uninstall OneDrive
# 20191001_Hans Wagner, Onedrive deinstallieren.
# Write-Host "Uninstalling OneDrive..."
# Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
# Start-Sleep -s 3
# $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
# If (!(Test-Path $onedrive)) {
    # $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
# }
# Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
# Start-Sleep -s 3
# Stop-Process -Name explorer -ErrorAction SilentlyContinue
# Start-Sleep -s 3
# Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
# Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
# Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
# If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
    # Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
# }
# If (!(Test-Path "HKCR:")) {
    # New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
# }
# Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
 
# Install OneDrive
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
If (!(Test-Path $onedrive)) {
  $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive -NoNewWindow
 
# Uninstall default bloatware
Write-Host "Uninstalling default bloatware..."
# Get-AppxPackage -AllUsers "Microsoft.3DBuilder" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.BingFinance" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.BingNews" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.BingSports" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.BingWeather" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Getstarted" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.Office.OneNote" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.People" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.SkypeApp" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.Windows.Photos" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsAlarms" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsCamera" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "microsoft.windowscommunicationsapps" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsMaps" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsPhone" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage

# 20200529_Hans_Wagner, Remove All unwanted X-BOX Apps.
Get-AppxPackage -AllUsers "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Xbox.TCUI" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxGameCallableUI" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxApp" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxGameOverlay" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxIdentityProvider" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.ZuneMusic" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.ZuneVideo" | Remove-AppxPackage

# Some further Informations about AppConnector, do not remove it.
# https://answers.microsoft.com/en-us/windows/forum/windows_10-other_settings/windows-10-app-connector-and-windows-shell/975e590b-1258-4552-b50f-f8e20e9aa285?auth=1
# https://superuser.com/questions/1003207/windows-10-what-is-the-microsoft-app-connector-and-why-would-it-want-need-acc
#Get-AppxPackage -AllUsers "Microsoft.AppConnector" | Remove-AppxPackage

Get-AppxPackage -AllUsers "Microsoft.ConnectivityStore" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Office.Sway" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Messaging" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.CommsPhone" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "9E2F88E3.Twitter" | Remove-AppxPackage
Get-AppxPackage -AllUsers "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
Get-AppxPackage -AllUsers "4DF9E0F8.Netflix" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Drawboard.DrawboardPDF" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.OneConnect" | Remove-AppxPackage
Get-AppxPackage -AllUsers "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
Get-AppxPackage -AllUsers "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
Get-AppxPackage -AllUsers "king.com.FarmHeroesSaga" | Remove-AppxPackage
Get-AppxPackage -AllUsers "king.com.CandyCrushFriends" | Remove-AppxPackage
Get-AppxPackage -AllUsers "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxIdentityProvider" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxGamingOverlay" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.Xbox.TCUI" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.XboxGameCallableUI" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.StorePurchaseApp" | Remove-AppxPackage
Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
Get-AppxPackage -AllUsers "A278AB0D.MarchofEmpires" | Remove-AppxPackage

Get-AppxPackage | where $_.Name -like "*xbox*" | Remove-AppxPackage
# Get-AppxPackage -AllUsers "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage 

# Install default Microsoft applications
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.3DBuilder").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.BingFinance").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.BingNews").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.BingSports").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.BingWeather").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.Getstarted").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.MicrosoftOfficeHub").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.MicrosoftSolitaireCollection").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.Office.OneNote").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.People").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.SkypeApp").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.Windows.Photos").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsAlarms").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsCamera").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.windowscommunicationsapps").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsMaps").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsPhone").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsSoundRecorder").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.XboxApp").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.ZuneMusic").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.ZuneVideo").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.AppConnector").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.ConnectivityStore").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.Office.Sway").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.Messaging").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.CommsPhone").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "9E2F88E3.Twitter").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "king.com.CandyCrushSodaSaga").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "4DF9E0F8.Netflix").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Drawboard.DrawboardPDF").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.MicrosoftStickyNotes").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.OneConnect").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "D52A8D61.FarmVille2CountryEscape").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "GAMELOFTSA.Asphalt8Airborne").InstallLocation)\AppXManifest.xml"
# Add-AppxPackage -DisableDevelopmentMode -Register "$($(Get-AppXPackage -AllUsers "Microsoft.WindowsFeedbackHub").InstallLocation)\AppXManifest.xml"
# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse
 
# Disable Xbox DVR
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

# Enable Xbox DVR
# Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue

# Uninstall Windows Media Player
# Write-Host "Uninstalling Windows Media Player..."
# dism /online /Disable-Feature /FeatureName:MediaPlayback /Quiet /NoRestart
 
# Install Windows Media Player
# dism /online /Enable-Feature /FeatureName:MediaPlayback /Quiet /NoRestart
 
# Uninstall Work Folders Client
# Write-Host "Uninstalling Work Folders Client..."
# dism /online /Disable-Feature /FeatureName:WorkFolders-Client /Quiet /NoRestart
 
# Install Work Folders Client
# dism /online /Enable-Feature /FeatureName:WorkFolders-Client /Quiet /NoRestart
 
# Set Photo Viewer as default for bmp, gif, jpg and png
Write-Host "Setting Photo Viewer as default for bmp, gif, jpg, png and tif..."
If (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
    New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
    New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
    Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
    Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
}
 
# Remove or reset default open action for bmp, gif, jpg and png
# If (!(Test-Path "HKCR:")) {
#   New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
# }
# Remove-Item -Path "HKCR:\Paint.Picture\shell\open" -Recurse
# Remove-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "MuiVerb"
# Set-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "CommandId" -Type String -Value "IE.File"
# Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "(Default)" -Type String -Value "`"$env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1"
# Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "DelegateExecute" -Type String -Value "{17FE9752-0B5A-4665-84CD-569794602F5C}"
# Remove-Item -Path "HKCR:\jpegfile\shell\open" -Recurse
# Remove-Item -Path "HKCR:\pngfile\shell\open" -Recurse
 
# Show Photo Viewer in "Open with..."
Write-Host "Showing Photo Viewer in `"Open with...`""
If (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
 
# Remove Photo Viewer from "Open with..."
# If (!(Test-Path "HKCR:")) {
#   New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
# }
# Remove-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Recurse
 
# Enable F8 boot menu options
#Write-Host "Enabling F8 boot menu options..."
#bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null

# Disable F8 boot menu options
# bcdedit /set `{current`} bootmenupolicy Standard | Out-Null

# Install Powershell man pages locally (low priority, uses bandwidth)
Update-Help

###################################################################################################
# Restart
###################################################################################################
#Write-Host
#Write-Host "Press any key to restart your system..." -ForegroundColor Black -BackgroundColor White
#$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#Write-Host "All these Settings are only active after Restarting the Operating System ..."

#Restart-Computer

