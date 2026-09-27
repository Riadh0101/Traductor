@echo off
chcp 65001 >nul
echo ===================================================
echo   RealTime Translator - تثبيت التحديث على الهاتف
echo   الإصدار الحالي: v1.0.0 (Build #13)
echo ===================================================
echo.
echo [1/3] في انتظار اتصال الهاتف عبر USB...
adb wait-for-device
echo [2/3] تم الاتصال بالهاتف! جاري تثبيت الحزمة (APK)...

adb install -r -d build\app\outputs\flutter-apk\app-release.apk
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo   [نجاح] تم تثبيت التحديث بنجاح! جاري تشغيل التطبيق...
    echo ===================================================
    adb shell monkey -p com.antigravity.traductor.traductor -c android.intent.category.LAUNCHER 1
) else (
    echo.
    echo [تنبيه] إذا ظهرت رسالة في شاشة الهاتف تطلب الإذن بالتثبيت عبر USB، يرجى الضغط على "سماح" (Allow).
    echo جاري نسخ ملف APK إلى مجلد التنزيلات (Downloads) في هاتفك كخيار احتياطي...
    adb push build\app\outputs\flutter-apk\app-release.apk /sdcard/Download/Traductor_Build13.apk
    echo تم نسخ الملف إلى: /sdcard/Download/Traductor_Build13.apk
)
echo.
pause
