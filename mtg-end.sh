#!/usr/bin/env bash
# MTG録音終了スクリプト
# ボイスメモの録音を止めた後、録音ファイルを文字起こしする
#
# 使い方:
#   ./mtg-end.sh                    # ファイル選択ダイアログで指定
#   ./mtg-end.sh /path/to/file.m4a  # 直接パス指定

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== MTG録音終了 ==="
echo ""
echo "【Zoom/Meetの出力デバイスを元に戻してください】"
echo "  設定 → オーディオ → スピーカー → 内蔵スピーカー"
echo ""

# 録音ファイルのパスを取得
if [ -n "${1:-}" ]; then
  INPUT="$1"
else
  # ボイスメモの保存先から最新ファイルを自動検出
  VOICE_MEMOS_DIR=~/Library/Group\ Containers/group.com.apple.VoiceMemos.shared/Recordings
  LATEST=$(ls -t "$VOICE_MEMOS_DIR"/*.m4a 2>/dev/null | head -1)

  if [ -n "$LATEST" ]; then
    echo "最新の録音ファイルを検出: $(basename "$LATEST")"
    INPUT="$LATEST"
  else
    echo "録音ファイルが見つかりません。パスを直接指定してください:"
    echo "  $0 /path/to/recording.m4a"
    exit 1
  fi
fi

echo "文字起こし開始: $(basename "$INPUT")"
echo ""
"$SCRIPT_DIR/transcribe.sh" "$INPUT"
