@echo off

set JAR_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\lib
set JAR_FILE=musicxmltasks.jar
set JAVA_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\bin

SET "PATH=%JAVA_DIR%;%PATH%"
set CLASSPATH=%JAR_DIR%\%JAR_FILE%

goto :init

:help
    echo help output
    exit /b 0
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set SCORE_ID=
    set SCORENAME=
    set SKIP_COMMENTS=
    set VERBOSE=
    set ZIPPED_FILE=
:arguments
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :error_message "Usage error" & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/c" set SKIP_COMMENTS=SKIP_COMMENTS & shift & goto :arguments
    if "%ARGUMENT%"=="--skip-comments" set SKIP_COMMENTS=SKIP_COMMENTS & shift & goto :arguments
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT%"=="/v" set VERBOSE=VERBOSE & shift & goto :arguments
    if "%ARGUMENT%"=="--verbose" set VERBOSE=VERBOSE & shift & goto :arguments
    if "%ARGUMENT%"=="/z" set ZIPPED_FILE=%~2 & shift & shift & goto :arguments
    if "%ARGUMENT%"=="--zipped-file" set ZIPPED_FILE=%~2 & shift & shift & goto :arguments
    if "%ARGUMENT:~0,1%"=="/" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    if "%ARGUMENT:~0,2%"=="--" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    set /a SCORE_ID=%ARGUMENT% 2>nul
    if not "%SCORE_ID%"=="%ARGUMENT%" set SCORENAME="%ARGUMENT%" & set SCORE_ID=
    set OUTPUT_FILE="%~2"
    if %OUTPUT_FILE%=="" set OUTPUT_FILE=STDOUT
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.Db2MusicXml SCORENAME=%SCORENAME% SCORE_ID=%SCORE_ID% OUTPUT_FILE=%OUTPUT_FILE% ZIPPED_FILE=%ZIPPED_FILE% %SKIP_COMMENTS% %VERBOSE%
    exit /b 0
