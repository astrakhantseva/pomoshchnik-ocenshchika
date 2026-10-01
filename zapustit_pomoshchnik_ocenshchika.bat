@echo off
rem =====================================================================
rem  ENCODING: CP866 (OEM Cyrillic). Do NOT save this file as UTF-8 --
rem  cmd.exe cannot parse multibyte text and the launcher will break.
rem  КОДИРОВКА ФАЙЛА: CP866. Не сохраняйте его в UTF-8.
rem =====================================================================
chcp 866 >nul
title Помощник оценщика
cd /d "%~dp0"

echo.
echo   ======================================
echo      Помощник оценщика
echo   ======================================
echo.

rem --- Уже запущено? Тогда просто открываем окно в браузере ---------------
netstat -ano | findstr ":8501 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo   Приложение уже работает - открываю его в браузере.
    start "" http://localhost:8501
    timeout /t 3 >nul
    exit /b 0
)

rem --- Есть ли на компьютере Python ---------------------------------------
python --version >nul 2>&1
if errorlevel 1 (
    echo   [!] На этом компьютере не найден Python.
    echo.
    echo       Установите его с сайта python.org, и при установке
    echo       обязательно поставьте галочку "Add Python to PATH".
    echo       Потом запустите этот значок ещё раз.
    echo.
    pause
    exit /b 1
)

rem --- Есть ли нужные библиотеки -------------------------------------------
python -c "import streamlit, curl_cffi, openpyxl, docx" >nul 2>&1
if errorlevel 1 (
    echo   Первый запуск: доустанавливаю нужные библиотеки.
    echo   Это займёт несколько минут. Дальше запуск будет быстрым.
    echo.
    python -m pip install --disable-pip-version-check streamlit curl_cffi openpyxl python-docx Pillow
    if errorlevel 1 (
        echo.
        echo   [!] Библиотеки установить не удалось.
        echo       Проверьте интернет и попробуйте ещё раз.
        echo.
        pause
        exit /b 1
    )
    echo.
)

rem --- Убираем разовый вопрос Streamlit про электронную почту ---------------
rem Без этого файла программа при первом запуске спрашивает адрес почты
rem и ждёт ответа в этом окне, а браузер так и не открывается.
if not exist "%USERPROFILE%\.streamlit\credentials.toml" (
    if not exist "%USERPROFILE%\.streamlit" mkdir "%USERPROFILE%\.streamlit"
    >"%USERPROFILE%\.streamlit\credentials.toml" echo [general]
    >>"%USERPROFILE%\.streamlit\credentials.toml" echo email = ""
)

echo   Запускаю. Через несколько секунд откроется вкладка в браузере.
echo.
echo   ----------------------------------------------------------
echo    ВАЖНО: не закрывайте это окно, пока работаете с программой.
echo    Чтобы закончить работу - просто закройте его.
echo   ----------------------------------------------------------
echo.

python -m streamlit run app.py

echo.
echo   Приложение остановлено.
pause
