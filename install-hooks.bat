@echo off

if not exist .git\hooks\ (
	echo Installed hooks dir does not exist. Creating...
	mkdir .git\hooks
)

xcopy git-hooks\ .git\hooks\
