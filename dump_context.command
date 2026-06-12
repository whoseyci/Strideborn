#!/bin/bash
# Double-click to run. Copies all lib/**/*.dart to clipboard.
# Place this file in your project root.

cd "$(dirname "$0")"

ROOT="lib"
COUNT=$(find "$ROOT" -name "*.dart" ! -name "*.g.dart" | wc -l | tr -d ' ')

{
  echo "# Flutter project context — $(date '+%Y-%m-%d %H:%M')"
  echo "# Source: $ROOT ($COUNT files)"
  echo ""

  find "$ROOT" -name "*.dart" ! -name "*.g.dart" | sort | while read -r file; do
    echo "// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "// FILE: $file"
    echo "// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$file"
    echo ""
    echo ""
  done
} | pbcopy

echo "✓ Copied $COUNT dart files to clipboard."
