@echo off

set JAR_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\lib
set JAR_FILE=musicxmltasks.jar
set JAVA_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\bin

SET "PATH=%JAVA_DIR%;%PATH%"
set CLASSPATH=%JAR_DIR%\%JAR_FILE%

goto :init

:help
    call :usage
    echo Validates a MusicXML file against the MusicXML 3.1 schema.
    @echo.
    echo INPUT_FILE: the MusicXML input filename.
    exit /b 0
:usage
    echo Usage: musicXmlValidate INPUT_FILE
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set INPUT_FILE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT:~0,1%"=="/" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    if "%ARGUMENT:~0,2%"=="--" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    set INPUT_FILE="%~1"
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.ValidateXml INPUT_FILE=%INPUT_FILE%
    exit /b 0
