#!/usr/bin/env bash
# MTG録音準備スクリプト
# Blackhole経由で自分の声+相手の声を両方録音できる状態にする
#
# 前提: BlackHole 2ch インストール済み、Audio MIDI Setupで集約デバイス作成済み
# 集約デバイス名: "MTG録音" (内蔵マイク + BlackHole 2ch)

set -euo pipefail

AGGREGATE_DEVICE="MTG録音"

echo "=== MTG録音セットアップ ==="
echo ""
echo "【手順】"
echo "1. Zoom/Meetの出力デバイスを「BlackHole 2ch」に設定"
echo "   (相手の声がBlackholeに流れる)"
echo ""
echo "2. ボイスメモの入力を「$AGGREGATE_DEVICE」に設定"
echo "   (自分の声+相手の声が録音される)"
echo ""
echo "3. ボイスメモで録音開始"
echo ""
echo "録音後は mtg-end.sh を実行してください"
echo ""

# Audio MIDI Setupで集約デバイスが存在するか確認
if system_profiler SPAudioDataType 2>/dev/null | grep -q "$AGGREGATE_DEVICE"; then
  echo "✓ 集約デバイス「$AGGREGATE_DEVICE」を確認"
else
  echo "⚠️  集約デバイス「$AGGREGATE_DEVICE」が見つかりません"
  echo ""
  echo "【集約デバイスの作成手順】"
  echo "1. アプリケーション → ユーティリティ → Audio MIDI Setup を開く"
  echo "2. 左下「+」→「集約デバイスを作成」"
  echo "3. デバイス名を「$AGGREGATE_DEVICE」に変更"
  echo "4. 「BlackHole 2ch」と「内蔵マイク」の両方にチェック"
  open -a "Audio MIDI Setup"
fi
