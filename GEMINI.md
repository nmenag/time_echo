# TimeEcho — Gemini Context

## Project Overview
TimeEcho is a premium digital time-capsule platform built with **Ruby on Rails 8.1** and **PostgreSQL**. Users write private letters to their future selves, capture emotional snapshots, make life predictions, and compare outcomes when capsules unlock. The product identity is **calm, nostalgic, and secure** — it intentionally avoids flashy SaaS aesthetics.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 8.1 (Ruby 3.2+) |
| Database | PostgreSQL 14+ |
| Styling | Tailwind CSS v4 · DaisyUI v5 |
| Asset Pipeline | Propshaft · Importmap-Rails |
| Frontend | Hotwire (Turbo + Stimulus) |
| Background Jobs | GoodJob (database-backed Active Job) |
| Email | Resend API via `AuthMailer` and `LetterMailer` |
| Auth | Passwordless magic-link tokens |
| Deployment | Kamal · Docker |
| Locale | Spanish (`es`) — single locale |

## Architecture & Design Patterns

TimeEcho uses a deeply layered, single-responsibility architecture:

```
app/
├── controllers/    # Strictly RESTful (7 standard actions only)
├── decorators/     # SimpleDelegator-based view formatting
├── forms/          # Multi-model validation & atomic transactions
├── services/       # Single-action business logic units
├── queries/        # Reusable AR query objects (eager-loading, row locks)
├── policies/       # Access control (public vs. private letters)
├── jobs/           # GoodJob cron & async workers
├── models/         # Thin AR models
├── mailers/        # Resend-backed transactional email
└── views/          # Lightweight ERB — no logic, no comments
```

### Key Models
- `Letter` — core capsule entity (states: `sealed`, `pending`, `delivered`)
- `EmotionalSnapshot` — happiness / anxiety / motivation ratings (1-10)
- `Prediction` — user predictions with retrospective outcome ratings
- `SessionToken` — single-use magic-link authentication tokens
- `AnalyticsEvent` — event tracking for opens, clicks, deliveries
- `UserPreference` — per-user settings

### Background Jobs (GoodJob Cron)
- `DeliverPendingLettersJob` — runs **every minute**, delivers capsules whose `deliver_at` has passed
- `CleanupExpiredTokensJob` — runs **every hour**, purges stale magic-link tokens

### Routes Structure
- **Auth**: `GET/POST /login`, `GET /login/:token`, `DELETE /logout`
- **Letters**: `resources :letters` (new, create, show) + dashboard at `GET /dashboard`
- **Predictions**: `POST /letters/:letter_id/predictions`
- **Analytics**: `GET /analytics`
- **Settings**: `GET/PATCH/DELETE /settings`, email confirmation at `settings/confirm_email`

## Directory Map

```
time_echo/
├── app/                  # Application code (MVC + patterns above)
├── config/
│   ├── routes.rb         # All route definitions
│   ├── application.rb    # GoodJob cron, locale config
│   ├── deploy.yml        # Kamal deployment config
│   └── database.yml      # PostgreSQL connection (env-var driven)
├── db/                   # Migrations & seeds
├── docs/architecture.md  # Detailed system architecture document
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
- Namespaced by domain: `Auth::`, `Letters::`, `Analytics::`, `Settings::`

### Forms (`app/forms/`)
- Multi-model validation in a single transactional boundary
- `LetterForm` manages `Letter` + `EmotionalSnapshot` + `Prediction` records atomically

### Database
- Batch aggregation queries (no sequential `COUNT`/`SUM` flooding)
- Reuse plucked ID arrays — never re-pluck
- Concurrent-safe row locks (`FOR UPDATE SKIP LOCKED`) in delivery queries

### Styling (Tailwind CSS v4 + DaisyUI v5)
- **Semantic tokens only** — `bg-base-100`, `text-base-content`, `text-primary` (no `bg-white`, `text-slate-900`)
- **Typography**: `font-serif` (Instrument Serif) for headings, `font-sans` (Inter) for body, `font-handwritten` (Caveat) for notes
- **Micro-animations**: `hover:scale-[1.02]`, `active:scale-[0.98]`, smooth transitions
- Honor `@media (prefers-reduced-motion: reduce)`
- WCAG AA contrast compliance (≥ 4.5:1)

## Execution Restrictions for AI Agents
- ❌ **Never** run database migrations (`db:migrate`, `db:rollback`)
- ❌ **Never** start the Rails server (`rails s`, `bin/dev`)
- ❌ **Never** execute Docker commands (`docker compose`, `docker ps`)
