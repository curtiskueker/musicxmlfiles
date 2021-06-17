@echo off
setlocal

set JAR_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\lib
set JAR_FILE=musicxmltasks.jar
set JAVA_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\bin

SET "PATH=%JAVA_DIR%;%PATH%"
set CLASSPATH=%JAR_DIR%\%JAR_FILE%

goto :init

:help
    call :usage
    @echo.
    echo        Converts a MusicXML database record to LilyPond.
    @echo.
    echo        SCORE_ID: the database record value in the score table, field id.
    @echo.
    echo        SCORE_NAME: the database record value in the score table, field score_name.
    @echo.
    echo        OUTPUT_FILE: the LilyPond output filename.
    @echo.
    echo        If no OUTPUT_FILE argument is given, output is to stdout.
    @echo.
    echo OPTIONS
    echo        /b, --include-breaks
    echo               include page and system breaks in the LilyPond output
    @echo.
    echo        /v, --verbose
    echo               displays processing output
    exit /b 0
:usage
    echo Usage: db2Ly [OPTIONS] SCORE_ID^|SCORE_NAME [OUTPUT_FILE]
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    call :usage
    exit /b 1
:init
    set SCORE_ID=
    set SCORENAME=
    set INCLUDE_BREAKS=
    set VERBOSE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/b" set INCLUDE_BREAKS=INCLUDE_BREAKS & shift & goto :arguments
    if "%ARGUMENT%"=="--include-breaks" set INCLUDE_BREAKS=INCLUDE_BREAKS & shift & goto :arguments
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT%"=="/v" set VERBOSE=VERBOSE & shift & goto :arguments
    if "%ARGUMENT%"=="--verbose" set VERBOSE=VERBOSE & shift & goto :arguments
    if "%ARGUMENT:~0,1%"=="/" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    if "%ARGUMENT:~0,2%"=="--" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    set /a SCORE_ID=%ARGUMENT% 2>nul
    if not "%SCORE_ID%"=="%ARGUMENT%" set SCORENAME="%ARGUMENT%" & set SCORE_ID=
    set OUTPUT_FILE="%~2"
    if %OUTPUT_FILE%=="" set OUTPUT_FILE=STDOUT
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.Db2Ly SCORENAME=%SCORENAME% SCORE_ID=%SCORE_ID% OUTPUT_FILE=%OUTPUT_FILE% %INCLUDE_BREAKS% %VERBOSE%
    exit /b 0
