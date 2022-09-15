:: Temporarily bypass Domain Group Policy folder redirection for Documents library, point to local folder instead. Will be updated on restart.
:: Intended for installs etc. which write to Documents folder.
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Personal /t REG_SZ /d C:\Users\<USER>\Documents
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_SZ /d C:\Users\<USER>\Documents
