# TimeEcho — Gemini Context

## Project Overview

TimeEcho is a premium digital time-capsule platform built with **Ruby on Rails 8.1** and **PostgreSQL**. Users write private letters to their future selves, capture emotional snapshots, make life predictions, and compare outcomes when capsules unlock. The product identity is **calm, nostalgic, and secure** — it intentionally avoids flashy SaaS aesthetics.

## Tech Stack

| Layer           | Technology                                     |
| --------------- | ---------------------------------------------- |
| Framework       | Rails 8.1 (Ruby 3.2+)                          |
| Database        | PostgreSQL 14+                                 |
| Styling         | Tailwind CSS v4 · DaisyUI v5                   |
| Asset Pipeline  | Propshaft · Importmap-Rails                    |
| Frontend        | Hotwire (Turbo + Stimulus)                     |
| Background Jobs | GoodJob (database-backed Active Job)           |
| Email           | Resend API via `AuthMailer` and `LetterMailer` |
| Auth            | Passwordless magic-link tokens                 |
| Deployment      | Kamal · Docker                                 |
| Locale          | Bilingual: English (`:en`, default) & Spanish (`:es`) |

## Architecture & Design Patterns

TimeEcho uses a deeply layered, single-responsibility architecture:

```
app/
├── controllers/    # Strictly RESTful (7 standard actions only)
├── decorators/     # SimpleDelegator-based view formatting
├── forms/          # Multi-model validation & atomic transactions
├── services/       # Single-action business logic units
├── queries/        # Reusable AR query objects (eager-loading, row locks)
├── policies/       # Access control (owner-only access to private letters)
├── jobs/           # GoodJob cron & async workers
├── models/         # Thin AR models
├── mailers/        # Resend-backed transactional email
└── views/          # Lightweight ERB — no logic, no comments
```

### Key Models

- `Letter` — core capsule entity (states: `pending`, `queued`, `delivered`, `failed`), encrypted at rest via Active Record Encryption (`encrypts :title`, `encrypts :content`)
- `EmotionalSnapshot` — happiness / anxiety / motivation ratings (1-10)
- `Prediction` — user predictions with retrospective outcome ratings
- `SessionToken` — single-use magic-link authentication tokens
- `AnalyticsEvent` — event tracking for opens, clicks, deliveries
- `UserPreference` — per-user settings

### Background Jobs & Rake Tasks

- `Letters::DispatchPendingJob` — runs **daily at midnight (`0 0 * * *`)** via GoodJob cron, transitions due capsules to `queued` and enqueues deliver jobs
- `Letters::DeliverLetterJob` — Active Job worker processing capsule delivery via `Letters::DeliverService` with polynomial retry backoff
- `CleanupExpiredTokensJob` — runs **every hour (`0 * * * *`)** via GoodJob cron, purges stale magic-link tokens
- `rake letters:deliver` — manual/CLI task backed by `Letters::DispatchPendingService`

### Routes Structure

- **Auth**: `GET/POST /login`, `GET /login/:token`, `DELETE /logout`, `GET /check_email`
- **Letters**: `resources :letters, only: [:new, :create, :show]`, dashboard at `GET /dashboard`, `GET /letters/success`
- **Predictions**: `POST /letters/:letter_id/predictions`
- **Locales**: `resources :locales, only: [:create, :destroy]` (persisted in `session[:locale]`)
- **Analytics**: `GET /analytics`
- **Settings**: `GET/PATCH/DELETE /settings`, email confirmation at `GET /settings/confirm_email`
- **Pages**: `root "pages#landing"`, `GET /about`, `GET /privacy`, `GET /terms`
- **Engine**: `mount GoodJob::Engine => "/good_job"` (authenticated)

## Directory Map

```
time_echo/
├── app/                  # Application code (MVC + patterns above)
├── bin/
│   └── dev               # Foreman runner (server + Tailwind watcher)
├── config/
│   ├── routes.rb         # All route definitions
│   ├── application.rb    # GoodJob cron, locale config
│   ├── deploy.yml        # Kamal deployment config
│   ├── puma.rb           # Puma configuration (single-mode on free tier)
│   └── database.yml      # PostgreSQL connection (env-var driven)
├── docs/
│   ├── architecture.md   # Detailed system architecture document
│   └── ui-ux.md          # UI/UX design system & architectural specification
├── skills/               # Specialized agent skills (rails-expert, impeccable, etc.)
├── test/                 # Minitest suite
├── AGENTS.md             # AI agent rules & constraints
├── PRODUCT.md            # Product brief, brand, design principles
├── Procfile.dev          # Foreman process file (server + CSS watcher)
├── package.json          # Tailwind CLI scripts
└── docker-compose.yml    # Local PostgreSQL container
```

## Development Workflow

```bash
# 1. Install dependencies
bundle install && npm install

# 2. Database setup (manual — never run via AI agents)
bundle exec rails db:create db:migrate
bundle exec rails db:seed  # seeds realistic demo data

# 3. Start the full dev stack
bin/dev
# → Puma on :3000, Tailwind watcher, GoodJob worker

# 4. CSS compilation
npm run watch:css   # uses --watch=always (required by Foreman)
npm run build:css   # production minified build
```

## Coding Conventions

### Controllers

- **RESTful only** — `index`, `show`, `new`, `edit`, `create`, `update`, `destroy`
- No custom member/collection actions; extract new resource controllers instead
- No database operations, raw SQL, or multi-table transactions
- No comments (`# ...`) — code must be self-documenting

### Views (ERB)

- No logic, date calculations, or conditional formatting
- No ERB comments (`<%# %>`)
- Call decorator methods for all visual formatting
- Use `.writing-canvas` / `.lined-paper-canvas` for letter rendering

### Decorators (`app/decorators/`)

- Extend `ApplicationDecorator` (which uses `SimpleDelegator`)
- Handle dates, state badges, icons, countdown text, CSS class selection

### Services (`app/services/`)

- One public method per service (`call` or equivalent)
- Namespaced by domain:
  - `Auth::MagicLinkService`
  - `Letters::AccessService`, `Letters::CreateService`, `Letters::DeliverService`, `Letters::DispatchPendingService`, `Letters::UpdatePredictionsService`
  - `Analytics::FetchMetricsService`, `Analytics::TrackEventService`
  - `Settings::RequestEmailUpdateService`, `Settings::ConfirmEmailUpdateService`, `Settings::UpdatePreferencesService`, `Settings::DestroyAccountService`

### Forms (`app/forms/`)

- Multi-model validation in a single transactional boundary
- `LetterForm` manages `Letter` + `EmotionalSnapshot` + `Prediction` records atomically

### Database

- Batch aggregation queries (no sequential `COUNT`/`SUM` flooding)
- Reuse plucked ID arrays — never re-pluck
- Concurrent-safe row locks (`FOR UPDATE SKIP LOCKED`) in delivery queries

### Styling (Tailwind CSS v4 + DaisyUI v5 — Postal & Archival System)

- **Design Philosophy**: Physical postal and archival aesthetic (see **[`docs/ui-ux.md`](docs/ui-ux.md)**). Strictly avoid generic AI/SaaS tropes (identical rounded cards, pastel icon circles, purple buttons, flat beige clichés, emojis as UI icons).
- **Physical Palette**:
  - Primary (Wax Seal Carmine): `#8E2818` (light), `#6A1E12` (hover), `#D14930` (dark). Absolutely no purple or violet (`oklch(... 290)`).
  - Accent (Postmark Ink Indigo): `#2C485E` (light), `#77A3C4` (dark).
  - Surfaces: `#FAF9F5` (stationery paper), `#16181D` (dark paper), `#EFECE3` (manila folder), `#1C2028` (dark folder).
  - Borders: `#D8D2C2` (hairline crease), `#2D3340` (dark border).
- **Typography Hierarchy**:
  - `font-serif-editorial` (**Fraunces**): section titles, capsule titles, reveal moments.
  - `font-letter` (**Courier Prime**): letter composition & reading, docket numbers (`№ TE-00042`), postmark cancellation stamps, dates.
  - `font-ui` / `font-sans-ui` (**IBM Plex Sans** / **Work Sans**): buttons, form inputs, operational statuses, navigation.
- **Specialized Components**: `.paper-sheet`, `.archival-folder`, `.postmark-stamp`, `.wax-seal` (with `seal-crack-left` / `seal-crack-right` unsealing animations), `.lined-paper-canvas`, and two-column `Expediente de Realidad`.
- **Accessibility & Motion**:
  - WCAG AA contrast compliance (≥ 4.5:1).
  - Honor `@media (prefers-reduced-motion: reduce)`.
  - Keyboard focus rings using `#8E2818`.

### Internationalization (i18n)

- Support bilingual locales: `:en` (default) and `:es`.
- Use `t()` helper for all view text; never hardcode strings in views.
- Format dates and badges in decorators (`LetterDecorator`, `PredictionDecorator`).
- Locale resolution priority: `session[:locale]` (from UI language switcher) ➔ `HTTP_ACCEPT_LANGUAGE` header ➔ default locale (`:en`).

### Code Quality & Formatting (RuboCop)

- **Mandatory Auto-correction**: For any code change or modification to Ruby files (`app/`, `config/`, `lib/`, `test/`, etc.), always run `bundle exec rubocop -a` (safe autocorrect) to maintain consistent styling and clean code.
- **Zero Offenses**: Ensure zero RuboCop offenses remain before completing tasks.

## Pull Request Formatting Rule

- **Template Standard**: When the user requests a "pull request", AI agents must structure the pull request description strictly adhering to the sections in `.github/pull_request_template.md`.
- **Direct Output Only**: AI agents must return the formatted pull request markdown directly in the chat response inside a single markdown code block for easy copying, without creating temporary markdown files (such as `.pr_body.md`).

## Execution Restrictions for AI Agents

- ❌ **Never** run database migrations (`db:migrate`, `db:rollback`)
- ❌ **Never** start the Rails server (`rails s`, `bin/dev`)
- ❌ **Never** execute Docker commands (`docker compose`, `docker ps`)

