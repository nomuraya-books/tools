#!/usr/bin/env bash
# 録音ファイルを文字起こし+話者分離するスクリプト
# 使い方: ./transcribe.sh /path/to/recording.m4a

set -euo pipefail

INPUT="${1:?使い方: $0 /path/to/recording.m4a}"
BASENAME=$(basename "${INPUT%.*}")
TIMESTAMP=$(TZ=Asia/Tokyo date +%Y%m%d-%H%M)
WAV="/tmp/${BASENAME}.wav"
OUTPUT="$(dirname "$INPUT")/${TIMESTAMP}-${BASENAME}.txt"

echo "=== 文字起こし+話者分離 ==="
echo "入力: $INPUT"
echo "出力: $OUTPUT"

# Step1: wav変換
echo "[1/3] wav変換中..."
ffmpeg -i "$INPUT" -ar 16000 -ac 1 "$WAV" -y -loglevel error

# Step2: 文字起こし+話者分離
echo "[2/3] 処理中（録音長によっては数十分かかります）..."
uv run --with pyannote.audio --with faster-whisper python3 - << PYEOF
from pyannote.audio import Pipeline
from faster_whisper import WhisperModel
import datetime

audio = "$WAV"
output_path = "$OUTPUT"

print("  話者分離モデル読み込み中...")
pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1")

print("  文字起こしモデル読み込み中...")
whisper = WhisperModel("large-v3", device="cpu", compute_type="int8")

print("  話者分離中...")
diarization = pipeline(audio)

print("  文字起こし中...")
segments, _ = whisper.transcribe(audio, language="ja", beam_size=5)
segments = list(segments)

print("  統合して出力中...")
header = f"録音ファイル: $(basename "$INPUT")\n文字起こし日時: $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M')\n\n"
lines = []
for seg in segments:
    speaker = "UNKNOWN"
    for turn, _, spk in diarization.itertracks(yield_label=True):
        if turn.start <= seg.start <= turn.end:
            speaker = spk
            break
    line = f"[{seg.start:.1f}s] **{speaker}**: {seg.text.strip()}"
    lines.append(line)

with open(output_path, "w", encoding="utf-8") as f:
    f.write(header)
    f.write("\n".join(lines) + "\n")

print(f"  完了: {output_path}")
PYEOF

echo "[3/3] 完了"
echo "出力ファイル: $OUTPUT"
echo ""
echo "話者名を置き換える場合:"
echo "  sed -i '' 's/SPEAKER_00/名前/g' \"$OUTPUT\""
