---
trigger: always_on
description: "Always display Persian (Farsi) and Arabic text inside Right-to-Left (RTL) boxes in chat and artifacts with Vazirmatn typography and readable 15px sizing, and never put Persian or Arabic text in LTR-only ArtifactMetadata.Summary cards or raw chat markdown."
---

# Bidirectional (BiDi) Right-to-Left (RTL) Display Rule (Persian & Arabic)

Whenever generating **Persian (Farsi)** or **Arabic** content for the user, **always display 100% of it inside Right-to-Left (RTL) boxes** rather than plain left-aligned (LTR) Markdown chat text:

1. **Strict Prohibition: Zero Raw Persian/Arabic in Plain Chat Markdown:**
   - **CRITICAL:** **NEVER output ANY Persian or Arabic prose, headings, introductions, bullet points, tips, or commentary as plain Markdown in the chat.**
   - Antigravity's chat container is strictly Left-to-Right (LTR). Any Persian or Arabic text written directly in chat will render left-aligned, reversed, and scrambled with broken punctuation and flipped colons.
   - **Every single Persian or Arabic sentence** (including conversational intros, audits, tips, summaries, next steps, and explanations) **MUST reside inside self-contained `<agent-embed>` HTML cards**.
   - The outer chat message MUST only contain:
     1. `<agent-embed src="file:///<artifact_path>/<name>.html"></agent-embed>`
     2. (Optional) Bare English-only file links at the bottom (e.g. `### Referenced Files\n- [filename](file:///...)`). **Never write Persian/Arabic descriptions or labels beside these links in outer chat.**

2. **Inline Chat Card Specs (`generative_ui`):**
   - Save cards in `<appDataDir>/brain/<conversation-id>/<name>.html` with `UserFacing: false` (to prevent duplicate LTR Artifact Drawer cards).
   - Structure each HTML widget with `<html lang="fa" dir="rtl">` (or `<html lang="ar" dir="rtl">` for Arabic).
   - Script: `<script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>`
   - **Typography & Font Stack (Local & CSP-safe):**
     `<style>body, .fa-text, .ar-text { font-family: "Vazirmatn", "Noto Sans Arabic", "Segoe UI", Tahoma, system-ui, -apple-system, sans-serif; } .ltr-pill { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; direction: ltr; unicode-bidi: isolate; display: inline-block; }</style>`
     Never put `Geeza Pro` ahead of `Vazirmatn` or `Tahoma`.
   - **Font Sizing & High Contrast (Dark & Light Themes):**
     - Never use `text-xs` (`12px`) for Persian/Arabic prose.
     - Body & list items: `text-[15px] leading-[1.9]`.
     - Secondary helper text: `text-[14px] leading-[1.8]`.
     - Card headers: `text-[17px]`–`text-lg` font-bold.
     - Text color: strictly `text-[var(--foreground)]`. Never use `text-[var(--muted-foreground)]` for readable prose or lists.
   - **Container:** `<div dir="rtl" class="bg-[var(--card)] text-[var(--foreground)] border border-[var(--border)] rounded-xl p-5 shadow-sm text-right text-[15px] leading-[1.9]">`
   - **BiDi Token Isolation:** Wrap inline English technical terms, paths, method names, and slash commands in `<span dir="ltr" class="ltr-pill text-[13px] px-1.5 py-0.5 rounded bg-[var(--secondary)] text-[var(--secondary-foreground)] font-mono">...</span>`.
   - **Interactive Quote & Copy Helper:** Because sandboxed `<agent-embed>` iframes isolate text from the host editor's selection listener, cards should include a copy button or floating quote button (copying selected text with `> ` markdown prefix to clipboard with `preventScroll: true` for easy <kbd>Cmd</kbd>+<kbd>V</kbd> pasting).
   - **Respect the 500px Viewport Limit:** Keep cards under `450px` tall so no internal scrollbar appears. If an answer has multiple sections (e.g., Analysis + Action Items), split into 2 compact `<agent-embed>` cards sequentially instead of spilling raw text into chat.

3. **System Artifact Cards (`ArtifactMetadata.Summary`):**
   - Antigravity's UI renders `UserFacing: true` Artifact Summary Cards in a strictly LTR, left-aligned container where Persian/Arabic mixed with English parentheses/acronyms becomes scrambled.
   - Therefore, **always write `ArtifactMetadata.Summary` in clear, concise English** (never mixed Persian or Arabic) for `UserFacing: true` artifacts, and do **not** mark duplicate RTL `.md` files in the brain directory as `UserFacing: true` when a standalone RTL `.html` artifact is already provided.

4. **Long-Form RTL Reports & Artifacts:**
   - Always generate a standalone `.html` artifact (`<html lang="fa" dir="rtl">` or `<html lang="ar" dir="rtl">`, `bg-[var(--background)]`, `Vazirmatn` font stack, `15px` body / `14px` tables, `UserFacing: true`, with English `ArtifactMetadata.Summary`) for long reports, tables, and diagrams so the side-pane renders in full native RTL.
   - For repository `.md` files written in Persian or Arabic, wrap the document or RTL sections in `<div dir="rtl">` (with blank lines after `<div dir="rtl">` and before `</div>`) for Markdown preview compatibility.
