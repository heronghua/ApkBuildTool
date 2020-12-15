call SDK_ENVIRONMENT.bat
call PROJECT_CONFIG.bat

rm gen bin -r -f
mkdir gen
echo gen cleared and regenerated success

%AAPT% p -f -m -J gen -S %RES% -I %ANDROID_JAR% -M %ANDROID_MANIFEST%