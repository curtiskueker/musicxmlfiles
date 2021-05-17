@echo off
setlocal EnableDelayedExpansion

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
    if %ARGUMENT%=="" call :error_message "Usage error" & exit /b 1
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
    :get_input_item
        set ARGUMENT=%~1
        if "%ARGUMENT%"=="" goto :main
        set INPUT_LIST=%INPUT_LIST% %ARGUMENT%
        shift
        goto :get_input_item
:main
    if "%INPUT_LIST%"=="" call :error_message "Input list is empty" & exit /b 1
    for %%I in (%INPUT_LIST%) do (
        if %SCRIPT_NAME%==musicXmlValidate call :execute_input %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==musicXmlCompress call :execute_input_output %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==musicXml2Db call :execute_input_output_verbose %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==musicXml2Ly call :execute_input_output_verbose %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==musicXml2Pdf call :execute_input_output_verbose %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==ly2Pdf call :execute_input_output_verbose %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==db2MusicXml call :execute_from_database %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==db2Ly call :execute_from_database %SCRIPT_NAME% %%I
        if %SCRIPT_NAME%==db2Pdf call :execute_from_database %SCRIPT_NAME% %%I
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
