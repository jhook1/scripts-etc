:: Bypass Domain Group Policy for Powershell script execution.
:: Lifetime of change is lifetime of spawned Powershell process (I think). Applies to ALL Powershell instances (seemingly; i.e. VS Nuget console).
:: Must be run as admin (probably).
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /v EnableScripts /t REG_DWORD /d 1
powershell.exe -NoExit -ExecutionPolicy Bypass -Command "Get-ExecutionPolicy -List"