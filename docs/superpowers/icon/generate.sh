#!/bin/bash
set -e

SVG="/Users/sumin/dev/ios/whiskey-note/docs/superpowers/icon/icon-master.svg"
OUT="/Users/sumin/dev/ios/whiskey-note/docs/superpowers/icon"

for size in 1024 180 120 87 80 60 58 57 40 29 114; do
  echo "Generating ${size}x${size}..."
  magick \
    -background '#2d1e0a' \
    -density 300 \
    "$SVG" \
    -resize "${size}x${size}" \
    -flatten \
    "${OUT}/${size}.png"
done

echo ""
echo "Verifying dimensions..."
for size in 1024 180 120 87 80 60 58 57 40 29 114; do
  actual=$(magick identify -format "%wx%h" "${OUT}/${size}.png")
  expected="${size}x${size}"
  if [ "$actual" = "$expected" ]; then
    echo "  ✓ ${size}.png"
  else
    echo "  ✗ ${size}.png — got $actual, expected $expected"
  fi
done
