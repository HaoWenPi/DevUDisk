@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
:: ============================================================
:: DevUDisk 开发环境安全退出脚本
:: 职责：结束 VS Code 进程、卸载 RAMDisk（如存在）、清理临时构建目录、弹出 U 盘
:: ============================================================
title DevUDisk - Stopping...
:: 1. 计算 U 盘盘符
set "U_DISK=%~d0"
echo [INFO] U 盘盘符：%U_DISK%
:: 2. 结束 VS Code 进程
echo [INFO] 正在备份 Git 关键状态...
call "%~dp0PortableEnv\_git_failsafe.bat"
echo [INFO] 正在关闭 VS Code...
taskkill /F /IM Code.exe >nul 2>&1
ping -n 3 127.0.0.1 >nul
:: 3. 判断当前是否拥有管理员权限
net session >nul 2>&1
set "IS_ADMIN=0"
if %errorlevel% equ 0 set "IS_ADMIN=1"
:: 4. 卸载 RAMDisk（如果存在）
set "AIMLL=%U_DISK%\PortableEnv\ImDisk\aim_cli\x64\aim_ll.exe"
set "RAMSERVICE=%U_DISK%\PortableEnv\ImDisk\RamService.exe"
set "IMDISK=%U_DISK%\PortableEnv\ImDisk\imdisk.exe"
set "RAMDISK_LETTER=R:"
:: 4.1 优先使用 aim_ll 直接卸载 RAMDisk
if exist "%AIMLL%" (
    if %IS_ADMIN% equ 1 (
        echo [INFO] 正在使用 aim_ll 卸载 RAMDisk %RAMDISK_LETTER% ...
        "%AIMLL%" -d -m %RAMDISK_LETTER%
        if !errorlevel! equ 0 (
            echo [INFO] RAMDisk 已卸载。
        ) else (
            echo [WARN] aim_ll 卸载 RAMDisk 可能失败，请手动检查。
        )
    ) else (
        echo [WARN] 未以管理员身份运行，跳过 RAMDisk 卸载。
    )
    goto :ramdisk_done
)
:: 4.2 回退到停止 Arsenal RAMDisk 服务
if exist "%RAMSERVICE%" (
    if %IS_ADMIN% equ 1 (
        echo [INFO] 正在停止 ArsenalRamDisk 服务 ...
        set /a "stop_retry=0"
        :stop_ramdisk
        net stop ArsenalRamDisk >nul 2>&1
        if !errorlevel! equ 0 (
            echo [INFO] RAMDisk 已卸载。
        ) else (
            set /a "stop_retry+=1"
            if !stop_retry! lss 10 (
                ping -n 2 127.0.0.1 >nul
                goto :stop_ramdisk
            ) else (
                echo [WARN] 停止 ArsenalRamDisk 服务可能失败，请手动检查。
            )
        )
    ) else (
        echo [WARN] 未以管理员身份运行，跳过 RAMDisk 服务停止。
    )
    goto :ramdisk_done
)
:: 4.2 回退到 ImDisk
if exist "%IMDISK%" (
    if %IS_ADMIN% equ 1 (
        echo [INFO] 正在卸载 RAMDisk %RAMDISK_LETTER% ...
        "%IMDISK%" -D -m %RAMDISK_LETTER%
        if !errorlevel! neq 0 (
            echo [WARN] RAMDisk 卸载可能失败，请手动检查。
        ) else (
            echo [INFO] RAMDisk 已卸载。
        )
    ) else (
        echo [WARN] 未以管理员身份运行，跳过 RAMDisk 卸载。
    )
)
:ramdisk_done
:: 5. 清理本地临时构建目录
echo [INFO] 正在清理临时构建目录...
if exist "%TEMP%\DevUDisk_build" (
    rmdir /S /Q "%TEMP%\DevUDisk_build"
)
:: 6. 弹出 U 盘
echo [INFO] 正在弹出 U 盘 %U_DISK% ...
powershell -NoProfile -Command "$disk='%U_DISK%'.Replace(':',''); try { (New-Object -comObject Shell.Application).Namespace(17).ParseName($disk+':').InvokeVerb('Eject') } catch { Write-Host '[WARN] 弹出 U 盘失败，请手动安全删除。' }"
echo [INFO] 可以安全拔出 U 盘。
ping -n 4 127.0.0.1 >nul
endlocal
