import 'dart:ffi';

extension AbiNameExtension on Abi {
  /// 获取当前平台的架构名称
  String get architectureName {
    return switch (this) {
      // --- Android ---
      Abi.androidArm64 => 'arm64-v8a',
      Abi.androidArm => 'armeabi-v7a',
      Abi.androidX64 => 'x86_64',
      Abi.androidIA32 => 'x86',
      Abi.androidRiscv64 => 'riscv64',

      // --- iOS ---
      Abi.iosArm64 => 'arm64',
      Abi.iosX64 => 'x86_64',
      Abi.iosArm => 'armv7',

      // --- macOS ---
      Abi.macosArm64 => 'arm64',
      Abi.macosX64 => 'x86_64',

      // --- Windows ---
      Abi.windowsArm64 => 'arm64',
      Abi.windowsX64 => 'x64',
      Abi.windowsIA32 => 'x86',

      // --- Linux ---
      Abi.linuxArm64 => 'arm64',
      Abi.linuxX64 => 'x86_64',
      Abi.linuxArm => 'arm',
      Abi.linuxIA32 => 'x86',
      Abi.linuxRiscv64 => 'riscv64',
      Abi.linuxRiscv32 => 'riscv32',

      // --- Fuchsia ---
      Abi.fuchsiaArm64 => 'arm64',
      Abi.fuchsiaX64 => 'x64',
      Abi.fuchsiaRiscv64 => 'riscv64',

      // --- 其他情况 ---
      _ => 'unknown',
    };
  }

  /// 获取当前操作系统的名称
  String get operatingSystemName {
    return switch (this) {
      Abi.androidArm64 ||
      Abi.androidArm ||
      Abi.androidX64 ||
      Abi.androidIA32 ||
      Abi.androidRiscv64 =>
        'android',
      Abi.iosArm64 || Abi.iosX64 || Abi.iosArm => 'ios',
      Abi.macosArm64 || Abi.macosX64 => 'macos',
      Abi.windowsArm64 || Abi.windowsX64 || Abi.windowsIA32 => 'windows',
      Abi.linuxArm64 ||
      Abi.linuxX64 ||
      Abi.linuxArm ||
      Abi.linuxIA32 ||
      Abi.linuxRiscv32 ||
      Abi.linuxRiscv64 =>
        'linux',
      Abi.fuchsiaArm64 || Abi.fuchsiaX64 || Abi.fuchsiaRiscv64 => 'fuchsia',
      _ => 'unknown',
    };
  }
}
