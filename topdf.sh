#!/bin/bash

# --- Settings ---
# Target extensions (space-separated)
TARGET_EXTENSIONS=("*.py" "*.js")
# Output PDF file name
OUTPUT_PDF="repository_code.pdf"
# Temporary Markdown file name
TEMP_MD="temp_code.md"

# --- Script Body ---

# Remove old temporary files if they exist
rm -f "$TEMP_MD"

# Build the -o (or) option for the find command
FIND_ARGS=()
for ext in "${TARGET_EXTENSIONS[@]}"; do
  if [ ${#FIND_ARGS[@]} -gt 0 ]; then
    FIND_ARGS+=("-o")
  fi
  FIND_ARGS+=("-name" "$ext")
done

echo "✅ Searching for code and compiling it into a Markdown file..."

# Find files and loop through them
find . -type f \( "${FIND_ARGS[@]}" \) | sort | while read -r filename; do
  lang="${filename##*.}"

  echo "---" >> "$TEMP_MD"
  echo "" >> "$TEMP_MD"
  echo "### \`$filename\`" >> "$TEMP_MD"
  echo "" >> "$TEMP_MD"
  echo "\`\`\`$lang" >> "$TEMP_MD"
  cat "$filename" >> "$TEMP_MD"
  echo "" >> "$TEMP_MD"
  echo "\`\`\`" >> "$TEMP_MD"
  echo "" >> "$TEMP_MD"
done

echo "✅ Generating PDF from Markdown file..."

# Try multiple methods to generate the PDF
if command -v pandoc >/dev/null 2>&1; then
  # Method 1: Run pandoc with more compatible options
  pandoc "$TEMP_MD" \
    -o "$OUTPUT_PDF" \
    -s \
    --toc \
    --pdf-engine=xelatex \
    --highlight-style=kate \
    -V mainfont="DejaVu Sans" \
    -V monofont="DejaVu Sans Mono" \
    -V geometry:"margin=2cm" \
    2>/dev/null

  # Fallback if the above fails
  if [ ! -f "$OUTPUT_PDF" ]; then
    echo "⚠️  Failed with xelatex. Trying pdflatex..."
    pandoc "$TEMP_MD" \
      -o "$OUTPUT_PDF" \
      -s \
      --toc \
      --pdf-engine=pdflatex \
      --highlight-style=kate \
      -V geometry:"margin=2cm" \
      2>/dev/null
  fi

  # If that still fails, try converting via HTML
  if [ ! -f "$OUTPUT_PDF" ]; then
    echo "⚠️  pdflatex also failed. Trying to generate PDF via HTML..."
    TEMP_HTML="temp_code.html"
    pandoc "$TEMP_MD" \
      -o "$TEMP_HTML" \
      -s \
      --toc \
      --highlight-style=kate \
      --css=<(echo "
        body { font-family: Arial, sans-serif; margin: 2cm; }
        code { background-color: #f5f5f5; padding: 2px 4px; }
        pre { background-color: #f5f5f5; padding: 10px; overflow-x: auto; }
        h3 { color: #333; border-bottom: 1px solid #ccc; }
      ")

    # Convert HTML to PDF
    # 1. Try Chrome/Chromium in headless mode
    CHROME_COMMANDS=("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "/usr/bin/google-chrome" "/usr/bin/chromium-browser" "google-chrome" "chromium")
    PDF_GENERATED=false

    for chrome_cmd in "${CHROME_COMMANDS[@]}"; do
      if command -v "$chrome_cmd" >/dev/null 2>&1 || [ -x "$chrome_cmd" ]; then
        echo "Generating PDF using Chrome/Chromium..."
        "$chrome_cmd" --headless --disable-gpu --print-to-pdf="$OUTPUT_PDF" --print-to-pdf-no-header "file://$(pwd)/$TEMP_HTML" 2>/dev/null
        if [ -f "$OUTPUT_PDF" ]; then
          PDF_GENERATED=true
          break
        fi
      fi
    done

    # 2. Try wkhtmltopdf
    if [ "$PDF_GENERATED" = false ] && command -v wkhtmltopdf >/dev/null 2>&1; then
      echo "Generating PDF using wkhtmltopdf..."
      wkhtmltopdf --page-size A4 --margin-top 20mm --margin-bottom 20mm --margin-left 20mm --margin-right 20mm "$TEMP_HTML" "$OUTPUT_PDF" 2>/dev/null
      if [ -f "$OUTPUT_PDF" ]; then
        PDF_GENERATED=true
      fi
    fi

    if [ "$PDF_GENERATED" = false ]; then
      echo "❌ PDF generation failed. Please check the HTML file '$TEMP_HTML'."
      echo "   You can convert it to PDF using the following methods:"
      echo "   1. Open in browser: open '$TEMP_HTML'"
      echo "   2. Install wkhtmltopdf: brew install wkhtmltopdf"
      echo "   3. Make sure Google Chrome is installed"
    else
      rm -f "$TEMP_HTML"
    fi
  fi
else
  echo "❌ pandoc is not installed."
  echo "   If you are using Homebrew: brew install pandoc"
  echo "   Or install from the official website: https://pandoc.org/installing.html"
fi

# Remove temporary files
rm -f "$TEMP_MD"

if [ -f "$OUTPUT_PDF" ]; then
  echo "🎉 Done! Please check '$OUTPUT_PDF'."
else
  echo "❌ PDF generation failed. Please check the messages above."
fi