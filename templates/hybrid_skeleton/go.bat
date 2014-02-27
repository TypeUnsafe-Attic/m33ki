@echo off
:begin
call golo golo --classpath jars/*.jar --files libs/*.golo app/*.golo main.golo
set exitcode=%ERRORLEVEL%
echo %exitcode%
if %exitcode% == 1 goto begin