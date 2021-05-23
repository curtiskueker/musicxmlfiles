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
    echo       Converts a MusicXML database record to MusicXML.
    @echo.
    echo       SCORE_ID: the database record value in the score table, field id.
    @echo.
    echo       SCORE_NAME: the database record value in the score table, field score_name.
    @echo.
    echo       OUTPUT_FILE: the XML output filename.
    @echo.
    echo       If filename has .mxl extension, output file is zipped, and the /z^|--zipped-file option is required.
    @echo.
    echo       If no OUTPUT_FILE argument is given, output is to stdout.
    @echo.
    echo OPTIONS
    echo       /c, --skip-comments
    echo              don't include XML comments and processing instructions in the XML output
    @echo.
    echo       /v, --verbose
    echo              displays processing output
    @echo.
    echo       -z, --zipped-file ZIPPED_FILE_NAME
    echo              name of XML file included in zipped .mxl output file
    exit /b 0
:usage
    echo Usage: db2MusicXml [OPTIONS] SCORE_ID^|SCORE_NAME [OUTPUT_FILE]
    exit /b
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
    if %ARGUMENT%=="" call :usage & exit /b 1
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
