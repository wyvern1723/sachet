#!/bin/bash

# 定义目标 ABI 数组
TARGET_ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")
TARGET_PLATFORMS=("android-arm64" "android-arm" "android-x64")

GRADLE_PROPERTIES="./android/gradle.properties"

# 循环构建不同 ABI 的 APK
for i in "${!TARGET_ABIS[@]}"; do
    ABI=${TARGET_ABIS[$i]}
    PLATFORM=${TARGET_PLATFORMS[$i]}
    
    echo "Building APK for ABI: $ABI..."
    
    # 添加 targetAbisForBuild 到 gradle.properties
    echo "targetAbisForBuild=$ABI," >> "$GRADLE_PROPERTIES"
    
    # 执行 flutter build
    flutter build apk --release --target-platform "$PLATFORM" --dart-define="abi=$ABI"
    
    # 检查构建是否成功
    if [ $? -ne 0 ]; then
        echo "Error: Build failed for ABI $ABI"
        # 删除添加的配置行
        sed -i '$d' "$GRADLE_PROPERTIES"
        exit 1
    fi
    
    # 重命名输出文件
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/sachet-$ABI.apk
    mv build/app/outputs/flutter-apk/app-release.apk.sha1 build/app/outputs/flutter-apk/sachet-$ABI.apk.sha1
    
    # 删除添加的配置行
    sed -i '$d' "$GRADLE_PROPERTIES"
    
    echo "Successfully built APK for ABI: $ABI"
    echo "----------------------------------------"
done

echo "All builds completed successfully!"
