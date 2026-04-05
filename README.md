# HE-Music-Flutter (iOS Fork)

这个仓库是 `serious-snow/HE-Music-Flutter` 的一个 fork，主要目标是：

- 仅用于构建 iOS 版本
- 生成 unsigned IPA 以便后续签名或侧载
- 保留现有的 Flutter 项目结构

> 本仓库不是官方 App Store / TestFlight 发布流程。
> 它输出的是供后续签名/分发链路使用的 iOS IPA 产物。

## 说明

仓库的核心用途是生成 iOS App 的构建产物，当前没有包含完整的 Apple 签名流程。
如果要提交 App Store / TestFlight，还需要在后续步骤中为生成的 IPA 签名。

## 主要功能

- 使用 GitHub Actions 构建 iOS unsigned IPA
- 通过 `scripts/build_ios.sh` 生成 `he-music-vX.Y.Z.ipa`
- 适配当前项目的 iOS 地址和版本策略
