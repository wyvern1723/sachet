#!/bin/bash

# 执行 flutter build
flutter build apk --release --split-per-abi

# 重命名输出文件
mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/app/outputs/flutter-apk/sachet-arm64-v8a.apk
mv build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk build/app/outputs/flutter-apk/sachet-armeabi-v7a.apk
mv build/app/outputs/flutter-apk/app-x86_64-release.apk build/app/outputs/flutter-apk/sachet-x86_64.apk
