@echo off
:begin
call golo golo --classpath jars/*.jar --files libs/*.golo app/*.golo app/models/*.golo app/controllers/*.golo app/libs/*.golo app/routes/*.golo main.golo
set exitcode=%ERRORLEVEL%
echo %exitcode%
if %exitcode% == 1 goto begin