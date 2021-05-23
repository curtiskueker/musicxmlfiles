@echo off

set JAR_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\lib
set JAR_FILE=musicxmltasks.jar
set JAVA_DIR=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\bin

SET "PATH=%JAVA_DIR%;%PATH%"
set CLASSPATH=%JAR_DIR%\%JAR_FILE%

goto :init

:help
    call :usage
    @echo.
    echo       Compresses a MusicXML file as a .mxl file.
    @echo.
    echo       INPUT_FILE: the MusicXML input filename.
    @echo.
    echo       OUTPUT_FILE: the compressed MusicXML output filename.
    exit /b 0
:usage
    echo Usage: musicXmlCompress INPUT_FILE OUTPUT_FILE
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set INPUT_FILE=
    set OUTPUT_FILE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT:~0,1%"=="/" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    if "%ARGUMENT:~0,2%"=="--" call :error_message "Unrecognized argument: %ARGUMENT%" & exit /b 1
    set INPUT_FILE="%~1"
    set OUTPUT_FILE="%~2"
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.CompressXml INPUT_FILE=%INPUT_FILE% OUTPUT_FILE=%OUTPUT_FILE%
    exit /b 0
