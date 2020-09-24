ECHO "MuseScore build"

SET BUILD_NUMBER=""
SET TELEMETRY_TRACK_ID=""
SET CRASH_LOG_SERVER_URL=""
SET TARGET_PROCESSOR_BITS=64

:GETOPTS
IF /I "%1" == "-n" SET BUILD_NUMBER=%2 & SHIFT
IF /I "%1" == "-b" SET TARGET_PROCESSOR_BITS=%2 & SHIFT
IF /I "%1" == "--telemetry" SET TELEMETRY_TRACK_ID=%2 & SHIFT
IF /I "%1" == "--crashurl" SET CRASH_LOG_SERVER_URL=%2 & SHIFT
SHIFT
IF NOT "%1" == "" GOTO GETOPTS

IF %BUILD_NUMBER% == "" ( ECHO "error: not set BUILD_NUMBER" & EXIT /b 1)
IF NOT %TARGET_PROCESSOR_BITS% == 64 (
    IF NOT %TARGET_PROCESSOR_BITS% == 32 (
        ECHO "error: not set TARGET_PROCESSOR_BITS, must be 32 or 64, current TARGET_PROCESSOR_BITS: %TARGET_PROCESSOR_BITS%"
        EXIT /b 1
    )
)

XCOPY "C:\musescore_dependencies" %CD% /E /I /Y

SET GENERATOR_NAME=Visual Studio 16 2019
SET MSCORE_STABLE_BUILD="TRUE"

:: TODO We need define paths during image creation
SET "JACK_DIR=C:\Program Files (x86)\Jack"
SET "QT_DIR=C:\Qt\5.9.9"

IF %TARGET_PROCESSOR_BITS% == 64 ( 
    SET "PATH=%QT_DIR%\msvc2017_64\bin;%JACK_DIR%;%PATH%"
) ELSE ( 
    SET "PATH=%QT_DIR%\msvc2015\bin;%JACK_DIR%;%PATH%"
)

CALL msvc_build.bat revision 
CALL msvc_build.bat relwithdebinfo %TARGET_PROCESSOR_BITS% %BUILD_NUMBER%
CALL msvc_build.bat installrelwithdebinfo

mkdir build.artifacts
mkdir build.artifacts\env

bash ./build/ci/tools/make_release_channel_env.sh 
bash ./build/ci/tools/make_version_env.sh %BUILD_NUMBER%
bash ./build/ci/tools/make_revision_env.sh