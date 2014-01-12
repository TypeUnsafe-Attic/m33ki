@echo off

:start
golo golo --classpath jars/*.jar --files libs/*.golo app/*.golo main.golo
set exitcode=%ERRORLEVEL%

if %exitcode% == "0" (goto :start)