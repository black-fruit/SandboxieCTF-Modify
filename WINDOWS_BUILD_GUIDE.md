# Windows编译指南 - Sandboxie-Plus破解版

## 📋 前置要求

### 1. 安装 Visual Studio 2019 或 2022

下载链接: https://visualstudio.microsoft.com/downloads/

**必需组件:**
- ✅ 使用C++的桌面开发 (Desktop development with C++)
- ✅ Windows 10 SDK (最新版本)
- ✅ MSVC v142 或 v143 编译器

**安装步骤:**
1. 运行Visual Studio安装程序
2. 选择"使用C++的桌面开发"工作负载
3. 在右侧"安装详细信息"中确保勾选:
   - MSVC v143 - VS 2022 C++ x64/x86生成工具
   - Windows 10/11 SDK
   - C++ CMake工具
4. 点击"安装"

### 2. 安装 Windows Driver Kit (WDK)

下载链接: https://learn.microsoft.com/zh-cn/windows-hardware/drivers/download-the-wdk

**重要:** WDK版本必须与Windows SDK版本匹配！

**安装步骤:**
1. 先安装Visual Studio和SDK
2. 下载对应版本的WDK安装程序
3. 运行安装程序，选择完整安装
4. 安装完成后重启计算机

### 3. 安装 Qt Framework

下载链接: https://www.qt.io/download-qt-installer

**推荐版本:** Qt 6.5.x 或 Qt 5.15.x

**安装步骤:**
1. 下载Qt在线安装程序
2. 创建Qt账号（免费）
3. 选择组件:
   - ✅ Qt 6.5.3 (或最新稳定版)
   - ✅ MSVC 2019 64-bit
   - ✅ Qt Creator (可选，但推荐)
4. 默认安装路径: `C:\Qt\6.5.3`

### 4. 安装 CMake

下载链接: https://cmake.org/download/

**推荐:** 使用Windows x64 Installer

**安装步骤:**
1. 下载最新稳定版安装程序
2. 运行安装，勾选"Add CMake to system PATH"
3. 完成安装

### 5. 安装 Git (可选)

下载链接: https://git-scm.com/download/win

用于克隆源码仓库（如果还没有源码）

---

## 🔧 编译步骤

### 方法1: 使用自动化脚本 (推荐)

1. **打开Visual Studio开发者命令提示符**
   - 开始菜单 → Visual Studio 2022 → Developer Command Prompt for VS 2022
   - 或者: Developer PowerShell for VS 2022

2. **导航到项目目录**
   ```cmd
   cd C:\path\to\leak-bus
   ```

3. **应用补丁**
   ```cmd
   python patcher.py patch
   ```

4. **验证补丁**
   ```cmd
   python verify_patches.sh
   ```
   (如果没有bash，跳过此步骤)

5. **运行构建脚本**
   ```cmd
   build_patched.bat
   ```
   
   **注意:** 在运行脚本前，编辑`build_patched.bat`文件，设置正确的Qt路径:
   ```batch
   set QT_PATH=C:\Qt\6.5.3\msvc2019_64
   ```
   改为你实际的Qt安装路径

6. **等待编译完成**
   - 编译需要10-30分钟，取决于电脑性能
   - 成功后会显示输出文件路径

---

### 方法2: 手动命令行编译

1. **打开Developer Command Prompt for VS 2022**

2. **设置环境变量**
   ```cmd
   set QT_PATH=C:\Qt\6.5.3\msvc2019_64
   set PATH=%QT_PATH%\bin;%PATH%
   ```

3. **导航到项目**
   ```cmd
   cd C:\path\to\leak-bus\Sandboxie-Plus
   ```

4. **创建构建目录**
   ```cmd
   mkdir build
   cd build
   ```

5. **运行CMake配置**
   ```cmd
   cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="%QT_PATH%"
   ```
   
   **如果使用VS 2019:**
   ```cmd
   cmake .. -G "Visual Studio 16 2019" -A x64 -DCMAKE_PREFIX_PATH="%QT_PATH%"
   ```

6. **编译项目**
   ```cmd
   cmake --build . --config Release -j 8
   ```
   
   参数说明:
   - `--config Release`: 编译发布版本
   - `-j 8`: 使用8个CPU核心并行编译（根据你的CPU调整）

7. **等待完成**
   编译完成后，输出文件位于:
   ```
   build\Sandboxie\core\drv\Release\SbieDrv.sys      (驱动)
   build\Sandboxie\core\svc\Release\SbieSvc.exe      (服务)
   build\SandboxiePlus\SandMan\Release\SandMan.exe   (GUI)
   ```

---

### 方法3: 使用Visual Studio IDE

1. **打开Visual Studio 2022**

2. **打开文件夹**
   - 文件 → 打开 → 文件夹
   - 选择: `C:\path\to\leak-bus\Sandboxie-Plus`

3. **配置CMake设置**
   - 项目 → CMake设置
   - 在"CMake命令参数"中添加:
     ```
     -DCMAKE_PREFIX_PATH=C:\Qt\6.5.3\msvc2019_64
     ```

4. **生成项目**
   - 生成 → 全部生成
   - 或按 Ctrl+Shift+B

5. **查看输出**
   - 输出窗口会显示编译进度
   - 完成后在`out\build\x64-Release`目录下查找文件

---

## 🚀 安装编译后的文件

### 自动安装 (推荐)

1. **以管理员身份运行命令提示符**
   - 右键点击"命令提示符"
   - 选择"以管理员身份运行"

2. **运行安装脚本**
   ```cmd
   cd C:\path\to\leak-bus
   install_patched.bat
   ```

3. **按照提示操作**
   - 脚本会自动备份原文件
   - 停止服务
   - 复制新文件
   - 启用测试签名模式
   - 重启计算机

### 手动安装

1. **备份原文件**
   ```cmd
   cd "C:\Program Files\Sandboxie-Plus"
   mkdir backup
   copy SbieDrv.sys backup\
   copy SbieSvc.exe backup\
   copy SandMan.exe backup\
   ```

2. **停止服务**
   ```cmd
   net stop SbieSvc
   ```

3. **复制新文件**
   ```cmd
   copy /Y "C:\path\to\leak-bus\Sandboxie-Plus\build\Sandboxie\core\drv\Release\SbieDrv.sys" "C:\Program Files\Sandboxie-Plus\"
   
   copy /Y "C:\path\to\leak-bus\Sandboxie-Plus\build\Sandboxie\core\svc\Release\SbieSvc.exe" "C:\Program Files\Sandboxie-Plus\"
   
   copy /Y "C:\path\to\leak-bus\Sandboxie-Plus\build\SandboxiePlus\SandMan\Release\SandMan.exe" "C:\Program Files\Sandboxie-Plus\"
   ```

4. **启用测试签名 (必需！)**
   ```cmd
   bcdedit /set testsigning on
   ```

5. **重启电脑**
   ```cmd
   shutdown /r /t 0
   ```

6. **重启后启动服务**
   ```cmd
   net start SbieSvc
   ```

---

## ✅ 验证安装

### 1. 检查测试签名模式

重启后，桌面右下角应该显示"测试模式"水印:
```
Windows 11
版本 22H2
测试模式
```

### 2. 启动GUI

运行: `C:\Program Files\Sandboxie-Plus\SandMan.exe`

### 3. 检查证书状态

在GUI中:
1. 点击 帮助 → 关于
2. 查看证书信息:
   - Certificate Status: **Active** ✅
   - Certificate Level: **MAXLEVEL** ✅
   - Security Enhanced: **Enabled** ✅
   - Encrypted Boxes: **Enabled** ✅
   - Advanced Network: **Enabled** ✅

### 4. 测试高级功能

**测试1: UseSecurityMode (不会5分钟后被杀)**
1. 创建新沙盒 "TestBox"
2. 右键 → 沙盒设置
3. 高级 → 安全选项
4. 勾选 "UseSecurityMode"
5. 在沙盒中运行记事本
6. 等待10分钟以上
7. ✅ 如果记事本还在运行 = 补丁成功

**测试2: ConfidentialBox (加密沙盒)**
1. 创建新沙盒 "SecureBox"
2. 沙盒设置 → 高级 → 盒子保护
3. 勾选 "ConfidentialBox"
4. 应用设置
5. 在此沙盒中启动程序
6. ✅ 如果程序能正常启动 = 补丁成功

---

## 🔧 常见问题

### 问题1: CMake找不到Qt

**错误信息:**
```
Could NOT find Qt6 (missing: Qt6_DIR)
```

**解决方法:**
```cmd
set CMAKE_PREFIX_PATH=C:\Qt\6.5.3\msvc2019_64
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:\Qt\6.5.3\msvc2019_64"
```

---

### 问题2: 编译器版本不匹配

**错误信息:**
```
The C compiler identification is unknown
```

**解决方法:**
- 必须在"Developer Command Prompt for VS"中运行
- 不能在普通cmd中运行
- 确保安装了MSVC编译器

---

### 问题3: WDK相关错误

**错误信息:**
```
Cannot find Windows Driver Kit
```

**解决方法:**
1. 确认WDK已安装
2. 版本必须匹配SDK版本
3. 检查环境变量:
   ```cmd
   set
   ```
   应该看到 `WindowsSdkDir` 和 `WindowsSdkVersion`

---

### 问题4: 驱动无法加载 (代码577)

**错误信息:**
```
Windows无法验证此文件的数字签名
错误代码: 577
```

**解决方法:**
1. 启用测试签名:
   ```cmd
   bcdedit /set testsigning on
   ```

2. 重启计算机

3. 如果仍然失败，禁用驱动签名强制:
   - 按住Shift点击"重启"
   - 疑难解答 → 高级选项 → 启动设置 → 重启
   - 按F7选择"禁用驱动程序强制签名"

---

### 问题5: 服务启动失败

**错误信息:**
```
服务无法启动
错误1275: 此驱动程序已被阻止加载
```

**解决方法:**
1. 确认测试签名已启用
2. 关闭安全启动(Secure Boot):
   - 重启进入BIOS/UEFI
   - 找到Secure Boot选项
   - 设置为Disabled
   - 保存并重启

---

### 问题6: 编译时内存不足

**错误信息:**
```
fatal error C1060: 编译器堆空间不足
```

**解决方法:**
1. 减少并行编译线程:
   ```cmd
   cmake --build . --config Release -j 2
   ```

2. 关闭其他程序释放内存

3. 增加虚拟内存:
   - 系统属性 → 高级 → 性能设置 → 高级 → 虚拟内存
   - 设置为系统管理大小或更大值

---

### 问题7: Qt版本冲突

**错误信息:**
```
Qt6 version 6.5.3 is required, but 6.2.0 was found
```

**解决方法:**
1. 完全卸载旧版本Qt
2. 安装推荐版本
3. 清理CMake缓存:
   ```cmd
   cd build
   del CMakeCache.txt
   cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:\Qt\6.5.3\msvc2019_64"
   ```

---

## 📦 完整编译示例

从零开始的完整流程:

```cmd
REM 1. 打开 Developer Command Prompt for VS 2022

REM 2. 设置环境
set QT_PATH=C:\Qt\6.5.3\msvc2019_64
set PATH=%QT_PATH%\bin;%PATH%

REM 3. 导航到项目
cd C:\Users\YourName\Downloads\leak-bus

REM 4. 应用补丁
python patcher.py patch

REM 5. 进入源码目录
cd Sandboxie-Plus

REM 6. 创建构建目录
mkdir build
cd build

REM 7. 配置CMake
cmake .. -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_PREFIX_PATH="%QT_PATH%" ^
    -DCMAKE_BUILD_TYPE=Release

REM 8. 开始编译 (使用4个CPU核心)
cmake --build . --config Release -j 4

REM 9. 等待编译完成...
REM 编译成功后，文件在:
REM   build\Sandboxie\core\drv\Release\SbieDrv.sys
REM   build\Sandboxie\core\svc\Release\SbieSvc.exe
REM   build\SandboxiePlus\SandMan\Release\SandMan.exe

REM 10. 返回上层目录
cd ..\..

REM 11. 以管理员身份安装 (需要新开管理员cmd)
REM install_patched.bat
```

---

## 🎯 编译时间参考

根据硬件配置，编译时间大约:

| CPU | 内存 | 时间 |
|-----|------|------|
| i5-8代 4核 | 8GB | ~25分钟 |
| i7-10代 8核 | 16GB | ~12分钟 |
| i9-12代 16核 | 32GB | ~6分钟 |

使用`-j`参数可以加速编译:
```cmd
cmake --build . --config Release -j 8   # 使用8核
```

---

## 📝 编译输出说明

成功编译后，你会得到3个关键文件:

### 1. SbieDrv.sys (内核驱动)
- 位置: `build\Sandboxie\core\drv\Release\`
- 大小: ~400 KB
- 功能: 内核级沙盒隔离和证书验证绕过

### 2. SbieSvc.exe (后台服务)
- 位置: `build\Sandboxie\core\svc\Release\`
- 大小: ~2 MB
- 功能: 管理沙盒生命周期

### 3. SandMan.exe (图形界面)
- 位置: `build\SandboxiePlus\SandMan\Release\`
- 大小: ~8 MB
- 功能: 用户界面，证书检查绕过

还有一些依赖文件也会被编译，但主要就是这3个文件需要替换。

---

## 🔐 关于代码签名

编译出的驱动是**未签名**的。要在Windows上加载，你有3个选择:

### 选项1: 测试签名模式 (推荐)
```cmd
bcdedit /set testsigning on
shutdown /r /t 0
```
- ✅ 最简单
- ✅ 持久有效
- ❌ 桌面有水印

### 选项2: 自签名证书
需要创建测试证书并签名驱动:
```cmd
makecert -r -pe -ss PrivateCertStore -n "CN=TestCert" TestCert.cer
signtool sign /v /s PrivateCertStore /n TestCert /t http://timestamp.digicert.com SbieDrv.sys
```

### 选项3: 禁用驱动签名强制 (临时)
- 重启时按Shift
- 疑难解答 → 高级选项 → 启动设置
- 重启后按F7
- ❌ 每次重启都要设置

---

## 🎉 成功标志

如果你看到以下内容，说明编译和安装成功:

1. ✅ 编译过程没有ERROR(有WARNING没关系)
2. ✅ 3个文件都生成了
3. ✅ 服务能正常启动
4. ✅ GUI显示证书为MAXLEVEL
5. ✅ 高级功能可以启用且不被终止
6. ✅ 桌面右下角显示"测试模式"

恭喜你完成了整个编译和破解过程！🎊

---

**有问题？** 检查上面的"常见问题"部分，或查看构建日志文件了解详细错误信息。
