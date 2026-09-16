# 📜 TimeEcho — UI/UX Design System & Architectural Specification

> **A tactile, nostalgic, and secure digital time-capsule experience.**
> TimeEcho consciously rejects the homogeny of modern corporate SaaS in favor of an **archival and epistolary design language**. The platform feels like stepping into a private records vault: letters sealed in carmine wax, folios classified in manila dossiers, and dates stamped in postmark indigo.

---

## 1. Design Philosophy & Metaphor

TimeEcho is built around the intimate act of writing a letter to your future self and rediscovering it years later. Generic SaaS conventions—such as purple gradients, neon status pills, and identical rounded cards—destroy the quiet, emotional weight of this experience.

### Core Pillars
1. **Nostalgic Materiality**: Physical artifacts over digital abstractions. Sheets of paper (`.paper-sheet`), lined letter canvases (`.lined-paper-canvas`), cancellation stamps (`.postmark-stamp`), and wax seals (`.wax-seal`).
2. **Archival Integrity**: The dashboard is an **archival ledger / expediente**, not a Kanban board or social feed. Capsules are identified with docket numbers (`№ TE-00042`), filing dates, and official postal statuses.
3. **Calm & Reverent Space**: Generous margins, literary typography, and unhurried whitespace. The UI gets out of the way when the user writes or reflects.
4. **Physical Tactility in Motion**: Interactive moments mimic analog mechanisms. Unlocking a capsule triggers a physical wax seal fracture (`seal-crack-left` and `seal-crack-right`), revealing the parchment inside.

---

## 2. Explicit Anti-Patterns (Strictly Avoid)

Every designer and AI agent working on TimeEcho must actively avoid the following common "AI-generated SaaS" clichés:

| Cliché / Anti-Pattern | Why It Is Prohibited | What TimeEcho Uses Instead |
| :--- | :--- | :--- |
| **Identical Rounded Cards** (`rounded-2xl p-6 shadow-md` everywhere) | Creates a monotonous, templated appearance with zero visual hierarchy. | **Folio sheets & ledger rows** (`.paper-sheet`, `.archival-folder`) with varying structural weights and physical borders (`#D8D2C2`). |
| **Icons in Colored Pastel Circles** (e.g. envelope inside a soft blue circle) | Generic template cliché with no brand identity or emotional resonance. | **Typographic docket numbers (`01`, `02`), physical cancellation stamps**, or raw monochrome icons. |
| **Corporate Purple / Violet Buttons** (`bg-purple-600`, `oklch(... 290)`) | Reads as generic crypto, AI productivity, or B2B SaaS. | **Wax Seal Carmine Red** (`#8E2818` / `#6A1E12` / `#D14930`), rooted in historical letter sealing. |
| **Warm Beige + Serif Cliché without Materiality** | An overused aesthetic that feels superficial when applied as a flat background color. | **Layered physical textures**: Parchment paper (`#FAF9F5`), Manila folder tabs (`#EFECE3`), and ink-stamped typography. |
| **All-Caps Eyebrow Dividers with Dots** (`CÁPSULA · PENDIENTE →`) | Overused marketing layout trope that looks robotic. | **Postmark stamps** (`.postmark-stamp`) or ledger metadata brackets (`[ ESTADO: EN TRÁNSITO ]`). |
| **Emojis as System UI Icons** (⏳, 🔒, 📝, 🚀 inside buttons or headers) | Cheapens the solemnity of personal letters and looks unprofessional. | **Clean inline SVG strokes** (1.5px stroke width) or classical typographical symbols (`№`, `§`, `¶`). |

---

## 3. Typography Hierarchy

TimeEcho employs a tripartite typographic system calibrated for literary reflection, historical docketing, and ergonomic digital utility:

```
┌────────────────────────────────────────────────────────────────────────┐
│  1. EDITORIAL SERIF (Fraunces)                                         │
│     ↳ Section titles, capsule headlines, reveal moments, literary body │
├────────────────────────────────────────────────────────────────────────┤
│  2. ARCHIVAL & EPISTOLARY (Courier Prime)                              │
│     ↳ Letter bodies, docket numbers (№ TE-00042), postmarks, metadata  │
├────────────────────────────────────────────────────────────────────────┤
│  3. FUNCTIONAL UI (IBM Plex Sans / Work Sans)                          │
│     ↳ Navigation, form labels, buttons, operational status, microcopy  │
└────────────────────────────────────────────────────────────────────────┘
```

### Font Families & Classes

```css
@theme {
  --font-serif-editorial: "Fraunces", "Instrument Serif", Georgia, serif;
  --font-letter: "Courier Prime", "Courier New", monospace;
  --font-ui: "IBM Plex Sans", "Work Sans", system-ui, sans-serif;
}
```

- **`font-serif-editorial` (`Fraunces`)**:
  - Warm, variable optical-sized serif with distinctive character.
  - Used for: Page headers, capsule titles, key emotional quotes, and the letter reveal screen.
  - Weights: `font-normal` (400) for reading; `font-semibold` (600) for hero section titles.
- **`font-letter` (`Courier Prime`)**:
  - Monospaced typewriter typeface designed specifically for epistolary and screenplay work.
  - Used for: Letter composition and reading, docket IDs (`№ TE-00042`), postmark cancellation stamps, dates, and archival counters.
  - Weights: `font-normal` (400) and `font-bold` (700) for stamps.
- **`font-ui` (`IBM Plex Sans`)**:
  - High-legibility grotesque sans-serif.
  - Used for: Buttons, form labels, dashboard stats, dropdowns, tooltips, and legal microcopy.
  - Weights: `font-normal` (400) for inputs; `font-medium` (500) for button labels; `font-semibold` (600) for badge labels.

---

## 4. Color Palette & Semantic Tokens

The color palette is derived from physical archival materials: aged correspondence, sealing wax, and typewriter ribbon ink.

```
       CARMINE WAX               POSTMARK INK              MANILA DOSSIER
    ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
    │     #8E2818     │       │     #2C485E     │       │     #EFECE3     │
    │  Seal Red Base  │       │  Stamp Indigo   │       │   Folder Kraft  │
    └─────────────────┘       └─────────────────┘       └─────────────────┘
       PARCHMENT SHEET            INK BORDER               WAX DARK MODE
    ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
    │     #FAF9F5     │       │     #D8D2C2     │       │     #D14930     │
    │  Letter Paper   │       │   Fold Crease   │       │  Wax Highlight  │
    └─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Palette Matrix

| Semantic Token | Light Mode Hex | Dark Mode Hex | Usage |
| :--- | :--- | :--- | :--- |
| **Wax Seal Carmine (Primary)** | `#8E2818` | `#D14930` | Wax seals, primary CTAs, active states, focus rings. |
| **Wax Seal Dark (Hover/Active)**| `#6A1E12` | `#E05A40` | Hover states for primary buttons and interactive seals. |
| **Postmark Ink (Accent)** | `#2C485E` | `#77A3C4` | Cancellation stamps, archive badges, timeline nodes. |
| **Paper Parchment (Surface)** | `#FAF9F5` | `#16181D` | Letter writing canvas, reading sheets, modal backgrounds. |
| **Manila Dossier (Secondary)** | `#EFECE3` | `#1C2028` | Archival folder tabs, secondary cards, table headers. |
| **Archival Crease (Border)** | `#D8D2C2` | `#2D3340` | Subtle hairline dividers, paper sheet outlines, input borders. |
| **Primary Ink (Content)** | `#1A1A1A` | `#E5E7EB` | Headings, letter text, primary readable content. |
| **Muted Ribbon Ink** | `#6B7280` | `#9CA3AF` | Metadata, date annotations, helper hints. |

### Semantic Theme Declaration (`application.tailwind.css`)

```css
@plugin "daisyui/theme" {
  name: "timeecho";
  default: true;
  --color-primary: #8E2818;
  --color-primary-content: #FAF9F5;
  --color-secondary: #2C485E;
  --color-secondary-content: #FAF9F5;
  --color-base-100: #FAF9F5;
  --color-base-200: #EFECE3;
  --color-base-300: #D8D2C2;
  --color-base-content: #1A1A1A;
}

@plugin "daisyui/theme" {
  name: "timeecho-dark";
  --color-primary: #D14930;
  --color-primary-content: #16181D;
  --color-secondary: #77A3C4;
  --color-secondary-content: #16181D;
  --color-base-100: #16181D;
  --color-base-200: #1C2028;
  --color-base-300: #2D3340;
  --color-base-content: #E5E7EB;
}
```

---

## 5. Specialized Component Vocabulary

TimeEcho provides purpose-built CSS component classes that encapsulate physical postal metaphors:

### A. The Paper Sheet (`.paper-sheet`)
Represents an individual physical sheet of letter paper.
```html
<div class="paper-sheet rounded-xs p-6 sm:p-10 border border-[#D8D2C2] dark:border-[#2D3340]">
  <!-- Letter or form content -->
</div>
```
- Flat, tactile surface using `bg-[#FAF9F5]` (light) / `bg-[#16181D]` (dark).
- Subtle, crisp hairline perimeter simulating the edge of cut stationery.
- Soft, realistic physical shadow (`box-shadow: 0 1px 3px rgba(0,0,0,0.05)`).

### B. The Archival Folder (`.archival-folder`)
Used for groupings of records, dashboard overviews, and dossiers.
```html
<div class="archival-folder rounded-xs p-6 border border-[#D8D2C2] dark:border-[#2D3340]">
  <div class="border-b border-[#D8D2C2] pb-3 mb-4 flex justify-between items-center">
    <span class="font-letter text-xs uppercase tracking-wider text-base-content/60">№ TE-00421</span>
    <span class="font-letter text-xs text-base-content/50">EXPEDIENTE OFICIAL</span>
  </div>
  <!-- Folder contents -->
</div>
```

### C. Postmark Cancellation Stamp (`.postmark-stamp`)
Replaces generic status pills and badges.
```html
<span class="postmark-stamp text-[10px] py-0.5 px-2.5">
  DESPACHADO · 14 OCT 2024
</span>
```
- Bordered with an ink-style dashed border (`border border-dashed border-[#2C485E]/60`).
- Rotated slightly by `-1deg` to `+1.5deg` to simulate hand-stamped ink impressions.
- Typeset in `font-letter` with uppercase letter-spacing.

### D. Wax Seal (`.wax-seal`)
The brand's primary tactile hallmark.
```html
<div class="wax-seal w-12 h-12 rounded-full flex items-center justify-center text-[#FAF9F5] font-letter font-bold text-sm select-none">
  TE
</div>
```
- Deep carmine color (`#8E2818`) with embossed inner and outer bevel shadows.
- Monogram or capsule index stamped into the center.

### E. Wax Seal Fracture Animation (Letter Unsealing)
When a delivered capsule is opened, the seal splits down the center with physical cracks:
```css
@keyframes seal-crack-left {
  0%   { transform: translateX(0) rotate(0deg); opacity: 1; }
  100% { transform: translateX(-14px) rotate(-6deg); opacity: 0.9; }
}

@keyframes seal-crack-right {
  0%   { transform: translateX(0) rotate(0deg); opacity: 1; }
  100% { transform: translateX(14px) rotate(6deg); opacity: 0.9; }
}
```

### F. Ruled Letter Composition Canvas (`.lined-paper-canvas`)
Provides notebook-style guide lines for drafting letters without distracting from typography:
```html
<div class="lined-paper-canvas rounded-xs p-8 font-letter">
  <textarea class="bg-transparent border-0 w-full resize-none font-letter leading-relaxed focus:ring-0 ..."></textarea>
</div>
```

### G. Reality Verification Ledger (`Expediente de Realidad`)
In `letters/show`, predictions made years ago are compared to actual outcomes in a twin-column ledger:
- **Left Column**: The original prediction written in the past, stamped with category (`EMPLEO`, `CIUDAD`, `SALARIO`).
- **Right Column**: The retrospective verification form with outcome verification pills (`CUMPLIDA`, `PARCIAL`, `NO CUMPLIDA`).

---

## 6. Icons & Favicon Specification

TimeEcho rejects low-contrast or generic icon packs in favor of a bespoke, high-contrast postal seal:

```
       FAVICON & APP ICON DESIGN
    ┌─────────────────────────────┐
    │         ●════════●          │
    │      ╱   #8E2818   ╲        │  <- Circular Wax Seal Carmine (Radius 240)
    │     │    ┌─────┐    │       │
    │     │    │✉ / ◷│    │       │  <- High-Contrast Pure White (#FFFFFF)
    │     │    └─────┘    │       │     Envelope & Clock Dial Center
    │      ╲             ╱        │
    │         ●════════●          │
    │   [Transparent Corners]     │  <- True 32-bit RGBA (0, 0, 0, 0)
    └─────────────────────────────┘
```

- **Geometry**: Perfectly circular badge with transparent perimeter corners (`(0, 0, 0, 0)` RGBA).
- **Contrast**: Pure white glyph (`#FFFFFF`) over carmine red (`#8E2818`), achieving a WCAG AAA contrast ratio of **6.1:1**.
- **Supported Formats**:
  - `public/icon.svg`: Scalable vector icon used in modern browsers.
  - `public/favicon.ico`: True 32-bit RGBA multi-resolution Windows/browser icon (16x16, 32x32, 48x48).
  - `public/apple-touch-icon.png`: 180x180 iOS home screen icon.
  - `public/icon.png`: 512x512 high-resolution app icon.

---

## 7. Responsive & Dark Mode Adaptation

TimeEcho ensures consistent archival warmth across all viewports and color schemes:

### Dark Mode Principles
- **No Pure Black (`#000000`)**: Dark mode uses warm graphite and dark slate (`#16181D` for paper, `#1C2028` for dossiers) to retain the feel of a dimly lit library or archival vault.
- **Inverted Inks**: Text shifts to off-white parchment ink (`#E5E7EB`), while cancellation stamps use softer slate-indigo (`#77A3C4`).
- **Luminescent Wax**: The wax seal shifts to `#D14930` with subtle glow highlights for readability against dark surfaces.

### Accessibility & Touch Ergonomics Standards
- **WCAG AA Compliance**: All text-to-background combinations maintain a contrast ratio ≥ 4.5:1 (large text ≥ 3.0:1).
- **Minimum Touch Targets**: All interactive elements (buttons, inputs, language switches, navigation items) enforce a minimum tap target of ≥ 44×44px on coarse-pointer/touchscreen devices via `@media (pointer: coarse)`.
- **Safe Area Insets & Viewport Fit**: HTML viewport includes `viewport-fit=cover` and CSS exposes environment variables (`--sat`, `--sar`, `--sab`, `--sal`) to protect content around device notches and home indicators.
- **Typographic Wrapping**: Headings (`h1`–`h6`) use `text-wrap: balance` to prevent orphaned words; prose body paragraphs use `text-wrap: pretty`.
- **Reduced Motion**: All animations (`seal-crack-left`, `seal-crack-right`, hover scales, page transitions) strictly honor `prefers-reduced-motion`:
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, ::before, ::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important;
    }
  }
  ```
- **Focus Rings**: Keyboard navigation highlights interactive elements with an archival carmine outline (`outline: 2px solid #8E2818; outline-offset: 2px;`).

---

## 8. View Implementation Reference

| Screen | File | Postal Component Pattern |
| :--- | :--- | :--- |
| **Landing Page** | `app/views/pages/landing.html.erb` | Official registry header, hero write-in paper sheet, numbered wax seal steps (`01`, `02`, `03`), archival footer. |
| **Capsule Vault (Index)** | `app/views/letters/index.html.erb` | Archival ledger summary, docket identifier rows (`№ TE-00042`), postmark cancellation stamps for states. |
| **Writing Desk (New)** | `app/views/letters/new.html.erb` | Lined writing sheet, postal date stamp, numbered appendices (`ANEXO I`, `ANEXO II`), carmine seal submission button. |
| **Capsule Unsealing (Show)** | `app/views/letters/show.html.erb` | Interactive wax seal fracture unsealing, reality verification ledger, letter reading manuscript. |
| **Authentication** | `app/views/sessions/new.html.erb` | Folded stationery sheet, wax seal badge, single-action carmine login button. |
| **Settings Panel** | `app/views/settings/show.html.erb` | Archival dossier folder, tactile toggles, carmine account action controls. |
| **Analytics Dashboard** | `app/views/analytics/index.html.erb` | Archival ledger cards, radial accuracy dials, accessible emotional growth progress indicators. |

