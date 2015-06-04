@echo off

set psql_path=%~dp0
set psql_path="..\..\database\psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres
set archive_password=?

set createDB=NO


set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :



set transitionPath=transition\



REM The Database password should be set using PgAdmin III. When connecting to the database, 
REM choose the Store Password option. This will avoid a password prompt for every SQL file 
REM that is loaded. 
REM set /p password= DB Password [%password%] :


echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > build.log 2>&1


REM echo the files in the folder changeset
for /f "eol=: delims=" %%F in (
  'dir ..\%transitionPath%\*.sql /b /a-d /one   2^>nul'
) do echo  %%F 


REM echo the files in the folder changeset
for /f "eol=: delims=" %%F in (
  'dir ..\%transitionPath%\*.sql /b /a-d /one   2^>nul'
) do %psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\%transitionPath%\%%F  >> build.log 2>&1


echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause
