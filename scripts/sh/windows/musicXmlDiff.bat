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
    echo       Compares two MusicXML files.
    @echo.
    echo       Diff output is to stdout.
    @echo.
    echo       The two MusicXML files are first standardized using xmllint before the diff is performed.
    @echo.
    echo       Unlike Unix diff, all '^<' lines appear before all '^>' lines.
    @echo.
    echo       INPUT_FILE: the MusicXML input filename.
    @echo.
    echo       COMPARE_FILE: the filename of the MusicXML file that the INPUT_FILE is compared to.
    exit /b 0
:usage
    echo Usage: musicXmlDiff INPUT_FILE COMPARE_FILE
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set INPUT_FILE=
    set COMPARE_FILE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT:~0,1%"=="/" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    if "%ARGUMENT:~0,2%"=="--" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    set INPUT_FILE="%~1"
    set COMPARE_FILE="%~2"
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.MusicXmlDiff INPUT_FILE=%INPUT_FILE% COMPARE_FILE=%COMPARE_FILE%
    exit /b 0
