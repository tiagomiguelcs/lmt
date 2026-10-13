# Lecture Markdown Translator (LMT)

A small Bash script that translates Portuguese lecture notes from Markdown into English using a local LibreTranslate API. It converts Markdown to HTML with Pandoc, translates the HTML, converts it back to GitHub-Flavored Markdown, and prepends a translation disclaimer.

## Requirements

Install the following tools and make sure they are available on your `PATH`:

- [Pandoc](https://pandoc.org/)
- [jq](https://jqlang.org/)
- `curl`
- A running [LibreTranslate](https://github.com/LibreTranslate/LibreTranslate) instance that supports Portuguese-to-English translation

Start LibreTranslate at `http://localhost:5959/translate`, or change `LIBRETRANSLATE_API` in `translate.sh`.

### Run LibreTranslate Locally
```bash
git clone https://github.com/LibreTranslate/LibreTranslate.git
cd LibreTranslate
./run.sh --load-only en,pt --port 5959
```

## Usage

1. Copy the Markdown files you want to translate into the `docs/` directory.
2. From the project root, run:

	```bash
	bash lmt.sh
	```

For each Markdown document in `docs/`, the script creates an English translation named `en-<original-name>.md`. For example, `docs/LP-Lecture-01.md` becomes `docs/en-LP-Lecture-01.md`.

:warning: Before translating, the script deletes every file matching `docs/en-*.md` and regenerates those translations. Back up any files matching that pattern that you need to keep. The original source Markdown files are not intentionally modified.
