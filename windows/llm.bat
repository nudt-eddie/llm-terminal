@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 检查环境变量，如果存在则使用环境变量，否则使用默认值
if not defined API_KEY set "API_KEY=sk-690174582eb54260893ad3954aff7cec"
if not defined BASE_URL set "BASE_URL=https://api.deepseek.com/v1"
if not defined MODEL set "MODEL=deepseek-chat"

REM 检查参数
if "%1"=="-r" (
    echo Usage: %~nx0 -r "your question"
    echo Example: %~nx0 -r "你好，请介绍一下自己"
    set "DEFAULT_ROLE=你是一个问答机器人，请根据用户的需求，回答用户的问题。"
)

if "%1"=="-cmd" (
    echo Usage: %~nx0 -cmd "your command"
    echo Example: %~nx0 -cmd "如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器"
    set "DEFAULT_ROLE=你是一个经验丰富的（%OS%）系统管理员，擅长使用shell命令，请根据用户的需求，只输出shell命令，不要输出任何其他内容。"
)

if "%1"=="-python" (
    echo Usage: %~nx0 -python "your python code"
    echo Example: %~nx0 -python "生成斐波那契数列的python代码"
    set "DEFAULT_ROLE=你是一个经验丰富程序员，擅长python代码，请根据用户的需求，只输出python代码，代码结构专业，内容简洁能完全实现用户的需求，只输出python代码，不要输出任何其他内容。"
)

if not "%1"=="-r" if not "%1"=="-cmd" if not "%1"=="-python" (
    echo Usage: %~nx0 -r "your question"
    echo Example: %~nx0 -r "你好，请介绍一下自己"
    echo Usage: %~nx0 -cmd "your command"
    echo Example: %~nx0 -cmd "如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器"
    echo Usage: %~nx0 -python "your python code"
    echo Example: %~nx0 -python "生成斐波那契数列的python代码"
    goto :end
)

if "%2"=="" (
    echo Error: Please provide a question after -r
    echo Usage: %~nx0 -r "your question"
    goto :end
)

REM 设置变量
set "QUESTION=%~2"

echo ==================== Configuration ====================
@REM echo [92mResponse Got:[0m
powershell -command "Write-Host 'Question: !QUESTION!' -ForegroundColor Cyan; Write-Host 'Model: !MODEL!' -ForegroundColor Cyan; Write-Host 'API URL: !BASE_URL!/chat/completions' -ForegroundColor Cyan; Write-Host 'API Key: !API_KEY:~0,10!...' -ForegroundColor Cyan"
echo ========================================================
echo.

REM 创建临时文件使用PowerShell确保UTF-8编码
set "TEMP_FILE=qwen3-32b_%RANDOM%.json"

REM 使用PowerShell创建正确的JSON文件
@REM echo [92mResponse Got:[0m
powershell -Command "& {Write-Host 'Creating request JSON...' -ForegroundColor Magenta; $json = @{model='!MODEL!'; messages=@(@{role='system'; content='!DEFAULT_ROLE!'},@{role='user'; content='!QUESTION!'}); stream=$false; max_tokens=512} | ConvertTo-Json -Depth 10; $utf8 = New-Object System.Text.UTF8Encoding $false; [System.IO.File]::WriteAllText('!TEMP_FILE!', $json, $utf8)} -ForegroundColor Cyan"
echo.

REM 发送请求
set "RESPONSE_FILE=response_%RANDOM%.json"
powershell -command "Write-Host 'Response file will be: !RESPONSE_FILE!' -ForegroundColor Magenta"

curl -X POST "!BASE_URL!/chat/completions" ^
     -H "Content-Type: application/json; charset=utf-8" ^
     -H "Authorization: Bearer !API_KEY!" ^
     -d "@!TEMP_FILE!" ^
     -o "!RESPONSE_FILE!" ^
     -w "HTTP Status: %%{http_code}\n"

set "CURL_EXIT_CODE=%errorlevel%"

echo ==================== Response ====================
if exist "!RESPONSE_FILE!" (
    @REM echo [92mResponse Got:[0m
    powershell -Command "& {try { $content = Get-Content '!RESPONSE_FILE!' -Raw -Encoding UTF8; $json = $content | ConvertFrom-Json; if ($json.choices -and $json.choices[0] -and $json.choices[0].message) { Write-Host $json.choices[0].message.content -ForegroundColor Green } else { Write-Host 'Error: Invalid response format' -ForegroundColor Red } } catch { Write-Host 'Error parsing JSON response' -ForegroundColor Red; Get-Content '!RESPONSE_FILE!' -Raw -Encoding UTF8 }}"
    
) else (
    echo No response file generated at: !RESPONSE_FILE!
    echo Checking current directory...
    dir "response_*.json" 2>nul
)
echo ==================================================

if !CURL_EXIT_CODE! neq 0 (
    echo Error: Curl failed with exit code !CURL_EXIT_CODE!
)

REM 清理
del "!TEMP_FILE!" 2>nul
del "!RESPONSE_FILE!" 2>nul

:end
endlocal 