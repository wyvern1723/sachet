#!/bin/bash

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 项目根目录 (脚本所在目录的上一级目录)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 配置文件路径
ENV_FILE="$SCRIPT_DIR/local.signing.env"
ENV_EXAMPLE="$SCRIPT_DIR/local.signing.env.example"


# 1. 检查 .env 配置文件是否存在，不存在则提示用户从模板创建
if [ ! -f "$ENV_FILE" ]; then
    echo "错误: 缺少配置文件 '$ENV_FILE'"
    if [ -f "$ENV_EXAMPLE" ]; then
        echo "请参考 '$ENV_EXAMPLE' 创建它。"
    fi
    exit 1
fi

# 2. 从配置文件中加载变量
get_env_val() {
    local key=$1
    grep "^${key}=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r'
}

KEY_ALIAS=$(get_env_val "KEY_ALIAS")
KEYSTORE_PATH=$(get_env_val "KEYSTORE_PATH")

# 检查变量是否成功加载
if [ -z "$KEY_ALIAS" ] || [ -z "$KEYSTORE_PATH" ]; then
    echo "错误: $ENV_FILE 中缺少 KEY_ALIAS 或 KEYSTORE_PATH"
    exit 1
fi

# 3. 获取 StorePassword
echo -n "Enter StorePassword for [$KEYSTORE_PATH]: "
read -s STOREPWD
echo ""

# 4. 获取 keyPassword
echo -n "Enter keyPassword for [$KEY_ALIAS]: "
read -s KEYPWD
echo ""

# 5. 生成临时的 key.properties
cat <<EOF > $PROJECT_ROOT/android/key.properties
storePassword=$STOREPWD
keyPassword=$KEYPWD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_PATH
EOF

# 6. 构建函数
build_apk() {
    local abi=$1
    local platform=$2
    
    echo "--------------------------------------"
    echo "开始构建 ABI: $abi"
    
    # 设置 abiFilters
    echo "targetAbisForBuild=$abi," >> "$PROJECT_ROOT/android/gradle.properties"
    
    # 确保在项目根目录运行指令
    cd "$PROJECT_ROOT"

    # 执行构建
    flutter build apk --release --target-platform "$platform"

    local exit_code=$?

    # 删除 gradle.properties 的最后一行（即本次添加的 abiFilters）
    sed -i '$d' "$PROJECT_ROOT/android/gradle.properties"

    # 检查返回状态码
    if [ $exit_code -eq 0 ]; then
        mv $PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk $PROJECT_ROOT/build/app/outputs/flutter-apk/sachet-$abi.apk
        mv $PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk.sha1 $PROJECT_ROOT/build/app/outputs/flutter-apk/sachet-$abi.apk.sha1
        echo "成功: 已生成 sachet-$abi.apk"
    else
        echo "错误: sachet-$abi.apk 构建过程出错"
        rm $PROJECT_ROOT/android/key.properties
        exit 1
    fi
}

# 7. 执行操作
build_apk "arm64-v8a" "android-arm64"
# build_apk "armeabi-v7a" "android-arm"
# build_apk "x86_64" "android-x64"

# 8. 清理
rm -f $PROJECT_ROOT/android/key.properties
echo "--------------------------------------"
echo "所有任务已完成。"
