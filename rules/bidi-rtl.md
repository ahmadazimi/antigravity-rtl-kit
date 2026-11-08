---
trigger: always_on
description: "Always display Persian (Farsi) and Arabic text inside Right-to-Left (RTL) boxes in chat and artifacts with Vazirmatn typography and readable 15px sizing, and never put Persian or Arabic text in LTR-only ArtifactMetadata.Summary cards."
---

# Bidirectional (BiDi) Right-to-Left (RTL) Display Rule (Persian & Arabic)

Whenever generating **Persian (Farsi)** or **Arabic** content for the user, **always display it inside Right-to-Left (RTL) boxes** rather than plain left-aligned (LTR) Markdown text:

1. **Inline Chat Responses (`generative_ui` RTL Boxes):**
   - Antigravity's default Markdown chat container is LTR, which makes Persian and Arabic prose (especially mixed with English technical terms) left-aligned and hard to read.
   - Render RTL chat content using self-contained HTML card widgets saved in `<appDataDir>/brain/<conversation-id>/` (`UserFacing: false` for inline chat cards so they do not spawn extra LTR Artifact Cards at the bottom of the message) and embedded inline via `<agent-embed src="file:///<artifact_path>/<name>.html"></agent-embed>`.
   - **Typography & Sizing (Crucial for RTL Readability):**
     - Always declare:
       `<style>body, .fa-text, .ar-text { font-family: "Vazirmatn", "Noto Sans Arabic", "Segoe UI", Tahoma, system-ui, -apple-system, sans-serif; } .ltr-pill { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; direction: ltr; unicode-bidi: isolate; }</style>`.
       Never put `Geeza Pro` ahead of `Vazirmatn` or `Tahoma`.
     - **Never use `text-xs` (`12px`) for Persian or Arabic prose or lists.** Use **`text-[15px] leading-[1.9]`** (`15px` with generous line height) for main paragraphs and bullet items, **`text-[14px] leading-[1.8]`** (`text-sm`) for secondary/helper descriptions, and **`text-[17px]`–`text-lg`** for card headers.
     - **High-Contrast Text Color (Crucial for Dark & Light Themes):** Never use `text-[var(--muted-foreground)]` for main paragraphs, list items, or table cells—it renders too dim/gray on dark backgrounds. Always use **`text-[var(--foreground)]`** for all readable prose, lists, and table content, reserving `--muted-foreground` strictly for tiny metadata tags or subtitles if needed.
   - Structure each HTML widget with `<html lang="fa" dir="rtl">` (or `<html lang="ar" dir="rtl">` for Arabic), include `<script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>`, use `<body class="bg-transparent text-[var(--foreground)] antialiased p-2">`, and wrap content in `<div dir="rtl" class="bg-[var(--card)] text-[var(--foreground)] border border-[var(--border)] rounded-xl p-5 shadow-sm text-right text-[15px] leading-[1.9]">`.
   - Wrap inline English technical terms, paths, and slash commands in `<span dir="ltr" class="ltr-pill inline-block text-[13px] px-1.5 py-0.5 rounded bg-[var(--secondary)] text-[var(--secondary-foreground)]">...</span>` so bidirectional text never scrambles sentence order.
   - **Respect the 500px Inline Viewport Limit:** Because `15px` RTL text takes slightly more vertical space, split multi-part answers into 2–3 compact `<agent-embed>` cards (each comfortably under `450px` tall; never use `100vh`/`h-screen`) so none require internal scrolling.
   - Place clickable `[filename](file:///...)` Markdown file chips directly in the chat outside `<agent-embed>` when referencing workspace files, since links inside iframes cannot open IDE tabs.

2. **System Artifact Cards (`ArtifactMetadata.Summary`):**
   - Antigravity's UI renders `UserFacing: true` Artifact Summary Cards in a strictly LTR, left-aligned container where Persian/Arabic mixed with English parentheses/acronyms becomes scrambled.
   - Therefore, **always write `ArtifactMetadata.Summary` in clear, concise English** (never mixed Persian or Arabic) for `UserFacing: true` artifacts, and do **not** mark duplicate RTL `.md` files in the brain directory as `UserFacing: true` when a standalone RTL `.html` artifact is already provided.

3. **Long-Form RTL Reports & Artifacts:**
   - Always generate a standalone `.html` artifact (`<html lang="fa" dir="rtl">` or `<html lang="ar" dir="rtl">`, `bg-[var(--background)]`, `Vazirmatn` font stack, `15px` body / `14px` tables, `UserFacing: true`, with English `ArtifactMetadata.Summary`) for long reports, tables, and diagrams so the side-pane renders in full native RTL.
   - For repository `.md` files written in Persian or Arabic, wrap the document or RTL sections in `<div dir="rtl">` (with blank lines after `<div dir="rtl">` and before `</div>`) for Markdown preview compatibility.
