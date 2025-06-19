# LLM in Terminal

一个跨平台的命令行工具，用于与大语言模型进行交互。支持不同的角色模式，可以进行问答、生成Shell命令和Python代码。

## 功能特性

- 🤖 **问答模式**：通用AI助手，回答各种问题
- 💻 **命令模式**：生成系统管理相关的Shell命令
- 🐍 **Python模式**：生成Python代码片段
- 🌐 **跨平台支持**：Windows (批处理) 和 Linux (Shell脚本)
- 🎨 **彩色输出**：清晰的彩色终端输出
- ⚙️ **环境变量配置**：支持自定义API配置

## 文件说明

- `llm.bat` - Windows批处理脚本
- `llm.sh` - Linux Shell脚本

## 环境要求

### Windows (llm.bat)
- Windows 10/11
- PowerShell 5.0+
- curl命令

### Linux (llm.sh)
- Bash shell
- curl命令
- python3 或 jq (用于JSON解析，可选)

## 安装和配置

### Windows

1. 下载 `llm.bat` 文件
2. 赋予执行权限并添加到系统PATH

#### 方法一：复制到系统目录
将 `llm.bat` 复制到已存在于PATH中的目录：
```cmd
copy llm.bat C:\Windows\System32\
```

#### 方法二：添加自定义目录到PATH
1. 创建专门的目录（推荐）：
   ```cmd
   mkdir C:\tools
   copy llm.bat C:\tools\
   ```

2. 添加到PATH环境变量：
   - **通过系统设置**：
     - 右键"此电脑" → "属性" → "高级系统设置"
     - 点击"环境变量"
     - 在"系统变量"中找到"Path"，点击"编辑"
     - 点击"新建"，输入 `C:\tools`
     - 确定并重启命令行

   - **通过命令行**（管理员权限）：
     ```cmd
     setx /M PATH "%PATH%;C:\tools"
     ```

3. 重新打开命令行，测试：
   ```cmd
   llm -r "测试命令"
   ```

### Linux

1. 下载 `llm.sh` 文件
2. 赋予执行权限：
   ```bash
   chmod +x llm.sh
   ```

#### 方法一：移动到系统目录
```bash
# 移动到全系统可访问的目录
sudo mv llm.sh /usr/local/bin/llm

# 或者移动到用户目录（无需sudo）
mkdir -p ~/.local/bin
mv llm.sh ~/.local/bin/llm
```

#### 方法二：创建符号链接
```bash
# 保持文件在当前位置，创建符号链接
sudo ln -s $(pwd)/llm.sh /usr/local/bin/llm

# 或者创建到用户目录
mkdir -p ~/.local/bin
ln -s $(pwd)/llm.sh ~/.local/bin/llm
```

#### 方法三：添加当前目录到PATH
1. 编辑shell配置文件：
   ```bash
   # 对于bash用户
   echo 'export PATH="$PATH:$(pwd)"' >> ~/.bashrc
   source ~/.bashrc

   # 对于zsh用户
   echo 'export PATH="$PATH:$(pwd)"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. 或者添加固定目录：
   ```bash
   # 创建专门目录
   mkdir -p ~/bin
   cp llm.sh ~/bin/llm
   chmod +x ~/bin/llm

   # 添加到PATH
   echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. 测试安装：
   ```bash
   llm -r "测试命令"
   ```

### 验证安装

安装完成后，在任意目录打开终端/命令行：

**Windows:**
```cmd
llm -r "你好"
```

**Linux:**
```bash
llm -r "你好"
```

如果能正常输出响应，说明安装成功！

## 使用方法

### 问答模式 (-r)

回答一般性问题：

**Windows:**
```cmd
llm.bat -r "你好，请介绍一下自己"
llm.bat -r "什么是人工智能？"
```

**Linux:**
```bash
./llm.sh -r "你好，请介绍一下自己"
./llm.sh -r "什么是人工智能？"
```

### 命令模式 (-cmd)

生成系统管理命令：

**Windows:**
```cmd
llm.bat -cmd "如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器"
llm.bat -cmd "查看当前目录下所有文件的详细信息"
```

**Linux:**
```bash
./llm.sh -cmd "如何ssh连接到服务器ip为192.168.1.100的用户名为root的机器"
./llm.sh -cmd "查看系统内存使用情况"
```

### Python模式 (-python)

生成Python代码：

**Windows:**
```cmd
llm.bat -python "生成斐波那契数列的python代码"
llm.bat -python "写一个快速排序算法"
```

**Linux:**
```bash
./llm.sh -python "生成斐波那契数列的python代码"
./llm.sh -python "写一个快速排序算法"
```

## 环境变量配置

可以通过环境变量自定义API配置：

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| API_KEY | sk-690174582eb54260893ad3954aff7cec | API密钥 |
| BASE_URL | https://api.deepseek.com/v1 | API基础URL |
| MODEL | deepseek-chat | 使用的模型名称 |

### 设置环境变量

**Windows:**
```cmd
set API_KEY=your_api_key_here
set BASE_URL=https://your-api-url.com/v1
set MODEL=your_model_name
```

**Linux:**
```bash
export API_KEY=your_api_key_here
export BASE_URL=https://your-api-url.com/v1
export MODEL=your_model_name
```

## 输出示例

```
==================== Configuration ====================
Question: 你好，请介绍一下自己
Model: deepseek-chat
API URL: https://api.deepseek.com/v1/chat/completions
API Key: sk-6901745...
========================================================

Creating request JSON...
Response file will be: response_12345.json
HTTP Status: 200
==================== Response ====================
你好！我是一个AI助手，基于大语言模型技术开发。我可以帮助你回答问题、
生成代码、提供建议和进行各种对话。有什么我可以帮助你的吗？
==================================================
```

## 故障排除

### 常见问题

1. **curl命令未找到**
   - Windows: 确保Windows 10版本1803或更高，或手动安装curl
   - Linux: 安装curl包 `sudo apt install curl` 或 `sudo yum install curl`

2. **JSON解析错误** (仅Linux)
   - 安装python3: `sudo apt install python3`
   - 或安装jq: `sudo apt install jq`

3. **网络连接问题**
   - 检查BASE_URL是否正确
   - 确认网络连接正常
   - 验证API_KEY是否有效

4. **权限问题** (仅Linux)
   - 确保脚本有执行权限: `chmod +x llm.sh`

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 更新日志

### v0.0.1
- 初始版本
- 支持Windows批处理脚本
- 支持Linux Shell脚本
- 三种模式：问答、命令、Python
- 彩色输出支持
- 环境变量配置支持
