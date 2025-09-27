# skkzram

skkzram 是一个轻量级的 zram 交换空间管理工具，通过 systemd 实现在系统启动时自动配置 zram 交换空间。

## 功能特性

- 自动在系统启动时设置 zram 交换空间
- 可配置的压缩算法 (lzo, lz4, zlib, lz4hc, zstd)
- 可调整的交换空间大小和优先级
- 支持多个 zram 设备
- 增强的日志记录功能（ERROR, WARN, INFO, DEBUG 级别）
- 写回设备支持（将空闲页面写回到指定设备）
- 基于内存百分比的动态大小调整
- 空闲页面写回超时配置
- 详细的监控功能

## 配置

配置文件位于 `/etc/skkzram.conf`，支持以下参数：

- `ALGO` - 压缩算法 (默认: lz4)
- `SIZE` - 交换空间大小 (默认: 3G)
- `PRIO` - 交换优先级 (默认: 100)
- `DEVICES` - zram 设备数量 (默认: 1)
- `LOG_LEVEL` - 日志级别 (0=ERROR, 1=WARN, 2=INFO, 3=DEBUG)
- `WRITEBACK_DEV` - 写回设备（可选）
- `MEM_PERCENTAGE_LIMIT` - 内存使用百分比限制（可选）
- `IDLE_WRITEBACK_SECS` - 空闲写回超时秒数（可选）

## 构建

使用 [build.sh](file:///home/chen/%E4%B8%8B%E8%BD%BD/skkzram/build.sh) 脚本构建 Debian 包：

```bash
./build.sh
```

构建脚本会自动：
1. 检查必要的构建工具
2. 验证项目结构
3. 计算安装大小并更新控制文件
4. 创建 `.deb` 包

## 安装

```bash
sudo dpkg -i skkzram_*.deb
```

安装后服务会自动启动。

## 使用

### 管理服务

```bash
# 启动服务
sudo systemctl start skkzram.service

# 停止服务
sudo systemctl stop skkzram.service

# 重启服务
sudo systemctl restart skkzram.service

# 查看服务状态
sudo systemctl status skkzram.service
```

### 手动管理

```bash
# 启动 zram 交换
sudo /usr/local/sbin/skkzram start

# 停止 zram 交换
sudo /usr/local/sbin/skkzram stop

# 重启 zram 交换
sudo /usr/local/sbin/skkzram restart

# 监控 zram 状态
sudo /usr/local/sbin/skkzram monitor
```

## 许可证

GPL-3.0