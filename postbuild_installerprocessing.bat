@echo off

:: Acquire arguments from Visual Studio environment
set ProjectDir=%~1
set BuiltOutputPath=%~2

echo Arg 1: "%ProjectDir%"
echo Arg 2: "%BuiltOutputPath%"

:: Pull the component id for the service executable from msi installer database
cscript /nologo "%ProjectDir%wirunsql.vbs" "%BuiltOutputPath%" "SELECT Component_ FROM MsiAssemblyName WHERE Value='PROJECT.SERVICE'" > "%ProjectDir%componentkey.txt"
set /p COMPONENTIDVAL=<"%ProjectDir%componentkey.txt"

echo Component ID: "%COMPONENTIDVAL%"

:: Insert a service control record to stop and delete the service before uninstalling (type 32+128=160)
cscript /nologo "%ProjectDir%wirunsql.vbs" "%BuiltOutputPath%" "INSERT INTO ServiceControl (ServiceControl,Name,Event,Component_) VALUES ('BeforeUninstallStopService','SERVICENAME',160,'%COMPONENTIDVAL%')"

:: Update InstallExecuteSequence table to uninstall the service before upgrading versions
cscript /nologo "%ProjectDir%wirunsql.vbs" "%BuiltOutputPath%" "UPDATE InstallExecuteSequence SET Sequence=1510 WHERE Action='RemoveExistingProducts'"
cscript /nologo "%ProjectDir%wirunsql.vbs" "%BuiltOutputPath%" "UPDATE InstallExecuteSequence SET Condition='$%COMPONENTIDVAL%=2 Or UPDATINGPRODUCTCODE' WHERE Condition='$%COMPONENTIDVAL%=2'"

:: Cleanup temp file
del "%ProjectDir%componentkey.txt"

:: "$(ProjectDir)postbuild_installerprocessing.bat" "$(ProjectDir)" "$(BuiltOuputPath)"