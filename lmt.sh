#!/bin/bash
LIBRETRANSLATE_API="http://localhost:5959/translate"
DOCS_DIR="docs"

translate(){
    local format="$1"
    local t_file="$2"
    case "$format" in 
        html)
            source="md"
            target="html"
            input_format="markdown"
            output_format="html"
            ;;
        md)
            source="html"
            target="md"
            input_format="html"
            # Using GitHub Flavored Markdown Spec
            output_format="gfm"
            ;;
    esac
    output="${t_file%.*}.$target"
    echo "  > Converting  : ${t_file##*/} -> ${output##*/}"
    pandoc "$t_file" \
        -f "$input_format" \
        -t "$output_format" \
        --wrap=none \
        -o "$output"
}

# Remove existing english Markdown translations before regenerating them.
for file in "$DOCS_DIR"/en-*.md; do
    [ -f "$file" ] || continue
    echo "$file"
    rm "$file"
done

# Convert Markdown to HTML before translation because LibreTranslate expects HTML input.
for file in "$DOCS_DIR"/*.md; do
    [ -f "$file" ] || continue
    # Get filename
    echo "Processing: $file"
    # 1. Convert the current 'file' to html using pandoc
    translate "html" "$file"

    # 2. Translate the current 'file'
    echo "  > Translating : ${output##*/}"
    tmp=$(mktemp)
    translated_html_path="${output%/*}/en-${output##*/}"
    if jq -n \
            --rawfile content "$output" \
            '{
                q: $content,
                source: "pt",
                target: "en",
                format: "html"
            }' |
        curl -fsS -X POST "$LIBRETRANSLATE_API" \
            -H "Content-Type: application/json" \
            --data-binary @- |
        jq -er '.translatedText' > "$tmp"; then

            mv "$tmp" "$translated_html_path"
            # Remove the HTML file generated from 
            # the original markdown file in pt
            rm $output
            # echo "      > Done"
    else
            rm -f "$tmp"
            echo "      > Error translating"
            exit 1
    fi
    # 3. Convert the translated file back to markdown using pandadoc
    translate "md" "$translated_html_path";
    # 4. Remove the translated HTML file
    rm "$translated_html_path"

    # 5. Prepend the translation warning from header to the translated Markdown file
    tmp=$(mktemp)
    cat header "$output" > "$tmp" && mv "$tmp" "$output"
done