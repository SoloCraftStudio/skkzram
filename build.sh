#!/usr/bin/env bash
# 构建 skkzram Debian 包的脚本

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# 检查必要工具
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v dpkg-deb &> /dev/null; then
        missing_tools+=("dpkg-deb")
    fi
    
    if ! command -v fakeroot &> /dev/null; then
        missing_tools+=("fakeroot")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install them with: sudo apt install ${missing_tools[*]}"
        exit 1
    fi
    
    log_info "All prerequisites satisfied"
}

# 验证项目结构
validate_structure() {
    log_info "Validating project structure..."
    
    local required_files=(
        "DEBIAN/control"
        "usr/local/sbin/skkzram"
        "usr/lib/systemd/system/skkzram.service"
        "etc/skkzram.conf"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # 检查脚本可执行权限
    if [[ ! -x "usr/local/sbin/skkzram" ]]; then
        log_warn "skkzram script is not executable, fixing..."
        chmod +x "usr/local/sbin/skkzram"
    fi
    
    # 检查安装/卸载脚本权限
    if [[ ! -x "DEBIAN/postinst" ]] || [[ ! -x "DEBIAN/prerm" ]]; then
        log_warn "Package scripts not executable, fixing..."
        chmod +x "DEBIAN/postinst" "DEBIAN/prerm"
    fi
    
    log_info "Project structure validation passed"
}


# 构建deb包
build_package() {
    local package_name
    local version
    local arch
    
    # 从control文件中提取包信息
    package_name=$(grep "^Package:" DEBIAN/control | cut -d' ' -f2)
    version=$(grep "^Version:" DEBIAN/control | cut -d' ' -f2)
    arch=$(grep "^Architecture:" DEBIAN/control | cut -d' ' -f2)
    
    local deb_filename="${package_name}_${version}_${arch}.deb"
    
    log_info "Building package: $deb_filename"
    
    # 创建临时目录
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # 复制所有文件到临时目录
    cp -r . "$temp_dir/source"
    cd "$temp_dir/source"
    
    # 移除不需要打包的文件
    rm -f build.sh
    rm -f skkzram_*.deb
    
    # 构建deb包
    if fakeroot dpkg-deb --build . "../$deb_filename"; then
        log_info "Package built successfully"
        
        # 将包移回原目录
        mv "../$deb_filename" "$OLDPWD/$deb_filename"
        cd "$OLDPWD"
        
        # 清理临时目录
        rm -rf "$temp_dir"
        
        log_info "Package saved as: $deb_filename"
        echo
        log_info "Package information:"
        dpkg-deb --info "$deb_filename"
        echo
        log_info "Package contents:"
        dpkg-deb --contents "$deb_filename"
        
        return 0
    else
        cd "$OLDPWD"
        rm -rf "$temp_dir"
        log_error "Failed to build package"
        return 1
    fi
}

# 主函数
main() {
    log_info "Starting skkzram package build process"
    
    # 检查前提条件
    check_prerequisites
    
    # 验证项目结构
    validate_structure
    
    # 构建包
    if build_package; then
        log_info "Build process completed successfully"
    else
        log_error "Build process failed"
        exit 1
    fi
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi