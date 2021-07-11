@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  apk build script for windows only support Non aar project
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

call :setUpEnvironmentAndConfiguration
call :genR 
call :genAidl
call :compile
call :packResourceFile
call :genDexFile
call :buildUnsignedApk
call :signApk
call :alignApk

goto mainEnd

:setUpEnvironmentAndConfiguration
for /f "tokens=1,2 delims==" %%i in (config.ini) do (
    ::red and set variables from config.ini file
 	set %%i=%%j
)

set ANDROID_JAR=%SDK_HOME%/platforms/%PLATFORM_VERSION%/android.jar
set AAPT=%SDK_HOME%/build-tools/%BUILD_TOOL_VERSION%/aapt.exe
set AIDL=%SDK_HOME%/build-tools/%BUILD_TOOL_VERSION%/aidl.exe
set DX=%SDK_HOME%/build-tools/%BUILD_TOOL_VERSION%/dx.bat
set APK_BUILDER=java -classpath %SDK_HOME%/tools/lib/sdklib-26.0.0-dev.jar com.android.sdklib.build.ApkBuilderMain
set ZIP_ALIGN=%SDK_HOME%/build-tools/%BUILD_TOOL_VERSION%/zipalign.exe

::check environment is ready
if not exist "%ANDROID_JAR%" (echo "Could not find file in %ANDROID_JAR% " && goto fail)
if not exist %AAPT% (echo "Could not find file in %AAPT% " && goto fail)
if not exist %AIDL% (echo "Could not find file in %AIDL% " && goto fail)
if not exist %DX% (echo "Could not find file in %DX% "&& goto fail)

goto :eof

::end setUpEnvironmentAndConfiguration

:genR
rm gen -r -f

mkdir gen

%AAPT% p -f -m -J gen -S %RES% -I %ANDROID_JAR% -M %ANDROID_MANIFEST%

goto :eof
:: end genR

:genAidl

if %HAS_AIDL%=="true" %AIDL% -p%AIDL% -I%SRC% -ogen

goto :eof

::end genAidl

:compile

mkdir bin
::generate all source  files
rm sourcefiles.txt
for %%i in (%SRC%%PACKAGE%\*.java) do echo %%i>>sourcefiles.txt
echo gen%PACKAGE%\R.java >> sourcefiles.txt

::compile whole java file
javac -encoding UTF-8 -target 1.8 -bootclasspath %ANDROID_JAR% -d bin  @sourcefiles.txt -classpath %LIBS%\*.jar
del sourcefiles.txt

goto :eof
:: end compile

:packResourceFile

%AAPT% package -f -S %RES% -I %ANDROID_JAR% -A %ASSERT% -M %ANDROID_MANIFEST% -F ./bin/resources.ap_
echo package resource success

goto :eof

::end packResourceFile

:genDexFile

call %DX% --dex --output=./bin/classes.dex ./bin
echo dex file generated 

goto :eof

::end genDexFile

:buildUnsignedApk

%APK_BUILDER%  ./bin/unsinged.apk -u -z  ./bin/resources.ap_ -f  ./bin/classes.dex  -rf  %SRC%  -rj  %LIBS%

goto :eof
:: end buildUnsignedApk

:signApk
::generate android keystore
keytool -genkey -alias HelloWorld.keystore -keyalg RSA -validity 1000 -keystore gen\HelloWorld.keystore -dname "CN=w,OU=w,O=localhost,L=w,ST=w,C=CN" -keypass 123456 -storepass 123456
jarsigner -verbose -keystore gen\HelloWorld.keystore -signedjar bin\signed.apk bin\unsinged.apk  HelloWorld.keystore
goto :eof
::end signApk

:alignApk
%ZIP_ALIGN% -f 4 bin\signed.apk bin\signedAligned.apk
goto :eof
:: end alignApk

:fail
exit /b 1


:mainEnd
if "%OS%"=="Windows_NT" endlocal


