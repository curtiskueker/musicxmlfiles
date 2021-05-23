@echo off
setlocal EnableDelayedExpansion

goto :init

:help
    call :usage
    @echo.
    echo Executes bulk runs of a script by calling SCRIPT_NAME for each item in an INPUT_LIST.
    @echo.
    echo An OUTPUT_DIRECTORY argument is required for some values of SCRIPT_NAME.
    @echo.
    echo SCRIPT_NAME: One of the following values:
    @echo.
    echo musicXmlValidate
    echo musicXmlCompress
    echo musicXml2Db
    echo musicXml2Ly
    echo musicXml2Pdf
    echo db2MusicXml
    echo db2Ly
    echo db2Pdf
    echo ly2Pdf
    @echo.
    echo OUTPUT_DIRECTORY:  Required for SCRIPT_NAME values that generate output:
    @echo.
    echo Output filenames:
    @echo.
    echo musicXmlCompress:  Output filenames are same as the MusicXML input filenames, but with a .mxl extension
    echo musicXml2Ly:  Output filenames are same as the MusicXML input filenames, but with a .ly extension
    echo musicXml2Pdf:  Output filenames are same as the MusicXML input filenames, but with a .pdf extension
    echo db2MusicXml:  Output filenames are the Score IDs or score names passed as arguments, with underscores replacing spaces, and a .xml extension
    echo db2Ly:  Output filenames are the Score IDs or score names passed as arguments, with underscores replacing spaces, and a .ly extension
    echo db2Pdf:  Output filenames are the Score IDs or score names passed as arguments, with underscores replacing spaces, and a .pdf extension
    echo ly2Pdf:  Output filenames are same as the LilyPond input filenames, but with a .pdf extension
    @echo.
    echo INPUT_LIST: For scripts that take file input (scripts musicXml* and ly2Pdf), the input list is a space-separated list of file names and directories, including wildcards.
    echo OPTIONS
    echo        /v, --verbose
    echo               displays processing output
    @echo.
    echo EXAMPLES
    echo Input list examples:
    @echo.
    echo Single file input: files\jsbach\Invention_1.xml
    @echo.
    echo A list of files matching a pattern: files\jsbach\Invention_*.xml
    @echo.
    echo All files in a directory: files\jsbach\*
    @echo.
    echo Database record input (scripts db2*): the input list is a space- or comma-separated list of score names, score IDs, and score ID ranges.
    @echo.
    echo Score names that contain commas or spaces need to be placed within quotes.
    @echo.
    echo Score ID lists and ranges can be comma-separated lists of ID numbers with dashes indicating score ranges.
    @echo.
    echo Score ID range example: 3,18-20,39 will execute score IDs 3, 18, 19, 20, and 39.
    @echo.
    echo musicXmlProcess script call examples:
    @echo.
    echo Output Score ID database records 1 to 50 as MusicXML to directory files\output:
    @echo.
    echo musicXmlProcess db2MusicXml files\output 1-50
    @echo.
    echo Output database records with score names "movement 1", "movement 2", "movement 3", and "movement 4" as LilyPond files to directory files\output:
    @echo.
    echo musicXmlProcess db2Ly files\output "movement 1","movement 2","movement 3","movement 4"
    echo or
    echo musicXmlProcess db2Ly files\output "movement 1" "movement 2" "movement 3" "movement 4"
    @echo.
    echo Load all MusicXML files in directory files\jsbach into the database with verbose output:
    @echo.
    echo musicXmlProcess /v musicXml2Db files\jsbach\*
    exit /b 0
:usage
    echo Usage: musicXmlProcess [OPTIONS] SCRIPT_NAME [OUTPUT_DIRECTORY] INPUT_LIST
    exit /b
:error_message
    set message=%*
    set message=%message:"=%
    echo %message% >&2
    exit /b 1
:init
    set SCRIPT_NAME=
    set SCRIPT_INPUT=
    set OUTPUT_DIRECTORY=
    set INPUT_LIST=
    set VERBOSE=
    set SCRIPT_DIRECTORY=C:\Users\farid\Downloads\musicxmltasks\musicxmltasks\scripts
    set SCRIPTS=musicXmlValidate musicXmlCompress musicXml2Db musicXml2Ly musicXml2Pdf db2MusicXml db2Ly db2Pdf ly2Pdf
    set OUTPUT_SCRIPTS=musicXmlCompress musicXml2Ly musicXml2Pdf db2MusicXml db2Ly db2Pdf ly2Pdf
    set INPUT_SCRIPTS=musicXmlValidate musicXmlCompress musicXml2Db musicXml2Ly musicXml2Pdf ly2Pdf
    set RANGE_START=
    set RANGE_END=
    set HAS_RANGE=
:arguments
    set ARGUMENT="%~1"
    if %ARGUMENT%=="" call :usage & exit /b 1
    set ARGUMENT=%ARGUMENT:"=%
    if "%ARGUMENT%"=="/h" shift & goto :help
    if "%ARGUMENT%"=="--help" shift & goto :help
    if "%ARGUMENT%"=="/v" set VERBOSE=/v & shift & goto :arguments
    if "%ARGUMENT%"=="--verbose" set VERBOSE=/v & shift & goto :arguments
    set SCRIPT_NAME=%~1
    shift
    set SCRIPT_INPUT=%~1
    shift
    for %%S in (%SCRIPTS%) do if "%SCRIPT_NAME%"=="%%S" goto :get_output_directory
    call :error_message "Script not found" & exit /b 1
:get_output_directory
    for %%S in (%OUTPUT_SCRIPTS%) do if "%SCRIPT_NAME%"=="%%S" goto set_output_directory
    set INPUT_LIST=%SCRIPT_INPUT%
    goto get_input_list
:set_output_directory
    set OUTPUT_DIRECTORY=%SCRIPT_INPUT%
    if "%OUTPUT_DIRECTORY%"=="" call :error_message "Output directory not found" & exit /b 1
:get_input_list
    set /a INPUT_INDEX=0
    :get_input_item
        set ARGUMENT=%~1
        if "%ARGUMENT%"=="" goto :main
        set /a INPUT_INDEX+=1
        set INPUT_LIST[%INPUT_INDEX%]=%ARGUMENT%
        set index=%INPUT_INDEX%
        shift
        goto :get_input_item
:main
    if %INPUT_INDEX%==0 call :error_message "Input list is empty" & exit /b 1
    for /L %%I in (1,1,%INPUT_INDEX%) do (
        if %SCRIPT_NAME%==musicXmlValidate call :execute_input %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==musicXmlCompress call :execute_input_output %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==musicXml2Db call :execute_input_output_verbose %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==musicXml2Ly call :execute_input_output_verbose %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==musicXml2Pdf call :execute_input_output_verbose %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==ly2Pdf call :execute_input_output_verbose %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==db2MusicXml call :execute_from_database %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==db2Ly call :execute_from_database %SCRIPT_NAME% !INPUT_LIST[%%I]!
        if %SCRIPT_NAME%==db2Pdf call :execute_from_database %SCRIPT_NAME% !INPUT_LIST[%%I]!
    )
    exit /b 0
:execute_input
    call :execute %1 %2
    exit /b
:execute_input_output
    call :execute %1 %2 %OUTPUT_DIRECTORY%\%~n2
    exit /b
:execute_input_output_verbose
    call :execute %1 %VERBOSE% %2 %OUTPUT_DIRECTORY%\%~n2
    exit /b
:execute_from_database
    set input_item=%2
    if not x%input_item:-=%==x%input_item% (for %%S in ("%input_item:-=" "%") do call :set_range_input %%~S)
    if "%HAS_RANGE%"=="TRUE" (
        FOR /L %%S IN (%RANGE_START%,1,%RANGE_END%) DO call :execute %1 %VERBOSE% %%~S %OUTPUT_DIRECTORY%\%%~S
        set RANGE_START=
        set RANGE_END=
        exit /b
    )
    call :execute %1 %VERBOSE% %2 %OUTPUT_DIRECTORY%\%~n2
    exit /b
:set_range_input
    set /a range_test=%1 2>nul
    if not "%range_test%"=="%1" exit /b
    if "%RANGE_START%"=="" set RANGE_START=%range_test% & exit /b
    set RANGE_END=%range_test%
    if not %RANGE_END% GTR %RANGE_START% call :error_message "Invalid range" & exit /b 1
    set HAS_RANGE=TRUE
    exit /b
:execute
    echo Executing: %*
    call %*
    exit /b
