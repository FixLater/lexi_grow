##打包 分架构
flutter build apk --split-per-abi

##指定架构并安装
flutter build apk --target-platform android-arm64 && flutter install
