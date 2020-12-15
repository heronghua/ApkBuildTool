call genR.bat
call genAidl.bat

mkdir bin
::generate all source  files
rm sourcefiles.txt
for %%i in (%SRC%%PACKAGE%\*.java) do echo %%i>>sourcefiles.txt
echo gen%PACKAGE%\R.java >> sourcefiles.txt

::compile whole java file
javac -encoding UTF-8 -target 1.8 -bootclasspath %ANDROID_JAR% -d bin  @sourcefiles.txt -classpath %LIBS%\*.jar

::package resource file
%AAPT% package -f -S %RES% -I %ANDROID_JAR% -A %ASSERT% -M %ANDROID_MANIFEST% -F ./bin/resources.ap_
echo package resource success

::generate dex file for dalvik machine to run
call %DX% --dex --output=./bin/classes.dex ./bin
echo dex file generated 

::buidl apk
%APK_BUILDER%  ./bin/unsinged.apk -u -z  ./bin/resources.ap_ -f  ./bin/classes.dex  -rf  %SRC%  -rj  %LIBS%


::gen key
keytool -genkey -alias HelloWorld.keystore -keyalg RSA -validity 1000 -keystore HelloWorld.keystore -dname "CN=w,OU=w,O=localhost,L=w,ST=w,C=CN" -keypass 123456 -storepass 123456

jarsigner -verbose -keystore HelloWorld.keystore -signedjar bin\signed.apk bin\unsinged.apk  HelloWorld.keystore


