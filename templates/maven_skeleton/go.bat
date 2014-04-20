@echo off
:begin
call golo golo --classpath jars/*.jar --files src/main/golo/libs/*.golo src/main/golo/app/*.golo src/main/golo/app/models/*.golo src/main/golo/app/controllers/*.golo src/main/golo/app/libs/*.golo src/main/golo/app/routes/*.golo src/main/golo/main.golo
set exitcode=%ERRORLEVEL%
echo %exitcode%
if %exitcode% == 1 goto begin