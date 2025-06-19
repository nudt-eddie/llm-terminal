    #!/bin/bash
if [ -z "$API_KEY" ]; then
    API_KEY="sk-"
fi
if [ -z "$BASE_URL" ]; then
    BASE_URL="https://api.deepseek.com/v1"
fi
if [ -z "$MODEL" ]; then
    MODEL="deepseek-chat"
fi
# 设置UTF-8编码
export LANG=en_US.UTF-8

if [ "$1" = "-r" ]; then
    echo "Usage: $0 -r \"your question\""
    echo "Example: $0 -r \"你好，请介绍一下自己\""
    DEFAULT_ROLE="你是一个问答机器人，请根据用户的需求，回答用户的问题。"
fi

if [ "$1" = "-cmd" ]; then
    echo "Usage: $0 -cmd \"your command\""
    echo "Example: $0 -cmd \"如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器\""
    DEFAULT_ROLE="你是一个经验丰富的（$(uname -s)）系统管理员，擅长使用shell命令，请根据用户的需求，只输出shell命令，不要输出任何其他内容。"
fi

if [ "$1" = "-python" ]; then
    echo "Usage: $0 -python \"your python code\""
    echo "Example: $0 -python \"生成斐波那契数列的python代码\""
    DEFAULT_ROLE="你是一个经验丰富程序员，擅长python代码，请根据用户的需求，只输出python代码，代码结构专业，内容简洁能完全实现用户的需求，只输出python代码，不要输出任何其他内容。"
fi

if [ "$1" != "-r" ] && [ "$1" != "-cmd" ] && [ "$1" != "-python" ]; then
    echo "Usage: $0 -r \"your question\""
    echo "Example: $0 -r \"你好，请介绍一下自己\""
    echo "Usage: $0 -cmd \"your command\""
    echo "Example: $0 -cmd \"如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器\""
    echo "Usage: $0 -python \"your python code\""
    echo "Example: $0 -python \"生成斐波那契数列的python代码\""
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: Please provide a question after $1"
    echo "Usage: $0 $1 \"your question\""
    exit 1
fi

QUESTION="$2"

echo "==================== Configuration ===================="
echo -e "\033[36mQuestion: $QUESTION\033[0m"
echo -e "\033[36mModel: $MODEL\033[0m"
echo -e "\033[36mAPI URL: $BASE_URL/chat/completions\033[0m"
echo -e "\033[36mAPI Key: ${API_KEY:0:10}...\033[0m"
echo "========================================================"
echo

TEMP_FILE="qwen3-32b_$RANDOM.json"

echo -e "\033[35mCreating request JSON...\033[0m"
cat > "$TEMP_FILE" << EOF
{
  "model": "$MODEL",
  "messages": [
    {
      "role": "system",
      "content": "$DEFAULT_ROLE"
    },
    {
      "role": "user", 
      "content": "$QUESTION"
    }
  ],
  "stream": false,
  "max_tokens": 512
}
EOF

echo

RESPONSE_FILE="response_$RANDOM.json"
echo -e "\033[35mResponse file will be: $RESPONSE_FILE\033[0m"

curl -X POST "$BASE_URL/chat/completions" \
     -H "Content-Type: application/json; charset=utf-8" \
     -H "Authorization: Bearer $API_KEY" \
     -d "@$TEMP_FILE" \
     -o "$RESPONSE_FILE" \
     -w "HTTP Status: %{http_code}\n"

CURL_EXIT_CODE=$?

echo "==================== Response ===================="
if [ -f "$RESPONSE_FILE" ]; then
    if command -v python3 &> /dev/null; then
        python3 -c "
import json
import sys
try:
    with open('$RESPONSE_FILE', 'r', encoding='utf-8') as f:
        data = json.load(f)
    if 'choices' in data and len(data['choices']) > 0 and 'message' in data['choices'][0]:
        print('\033[32m' + data['choices'][0]['message']['content'] + '\033[0m')
    else:
        print('\033[31mError: Invalid response format\033[0m')
        with open('$RESPONSE_FILE', 'r', encoding='utf-8') as f:
            print(f.read())
except Exception as e:
    print('\033[31mError parsing JSON response:', str(e), '\033[0m')
    with open('$RESPONSE_FILE', 'r', encoding='utf-8') as f:
        print(f.read())
"
    elif command -v jq &> /dev/null; then
        content=$(jq -r '.choices[0].message.content' "$RESPONSE_FILE" 2>/dev/null)
        if [ "$content" != "null" ] && [ -n "$content" ]; then
            echo -e "\033[32m$content\033[0m"
        else
            echo -e "\033[31mError: Invalid response format\033[0m"
            cat "$RESPONSE_FILE"
        fi
    else
        echo -e "\033[33mWarning: Neither python3 nor jq found. Raw response:\033[0m"
        cat "$RESPONSE_FILE"
    fi
else
    echo "No response file generated at: $RESPONSE_FILE"
    echo "Checking current directory..."
    ls -la response_*.json 2>/dev/null || echo "No response files found"
fi
echo "=================================================="

if [ $CURL_EXIT_CODE -ne 0 ]; then
    echo "Error: Curl failed with exit code $CURL_EXIT_CODE"
fi

rm -f "$TEMP_FILE" 2>/dev/null
rm -f "$RESPONSE_FILE" 2>/dev/null 
