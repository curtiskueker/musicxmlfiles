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
    echo       Converts MusicXML to a MusicXML database record.
    @echo.
    echo       INPUT_FILE: the MusicXML input filename.
    @echo.
    echo       SCORE_NAME: the database record score name.
    @echo.
    echo       The score name must be unique in the database.
    @echo.
    echo OPTIONS
    echo       /v, --verbose
    echo              displays processing output
    exit /b 0
:usage
    echo Usage: musicXml2Db [OPTIONS] INPUT_FILE SCORE_NAME
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set INPUT_FILE=
    set SCORENAME=
    set VERBOSE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT%"=="/v" set VERBOSE=VERBOSE & shift & goto :arguments
    if "%ARGUMENT%"=="--verbose" set VERBOSE=VERBOSE & shift & goto :arguments
    set INPUT_FILE="%~1"
    set SCORENAME="%~2"
:main
    java -classpath %CLASSPATH% -Dnet.sf.ehcache.enableShutdownHook=true org.curtis.musicxml.bin.MusicXml2Db INPUT_FILE=%INPUT_FILE% SCORENAME=%SCORENAME% %VERBOSE%
    exit /b 0
