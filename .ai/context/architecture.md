# Project Context: Architecture & Tech Stack

This document describes the actual architecture, tech stack, and execution runtime of **TimeEcho**, grounded directly in the codebase.

---

## 1. Technology Stack

| Component | Technology | Role / Details |
| --------- | ---------- | -------------- |
| **Framework** | Ruby on Rails 8.1 | Core MVC web framework (Ruby 3.2+). |
| **Database** | PostgreSQL 14+ | Relational persistence with UUID extensions and JSONB. |
| **Asset Pipeline** | Propshaft | Modern Rails 8 asset pipeline (`app/assets/builds/`). |
| **Frontend Framework** | Hotwire (Turbo 8 + Stimulus) | SPA-like navigation without client-side heavy JavaScript frameworks. |
| **Styling** | Tailwind CSS v4 & DaisyUI v5 | CSS-first configuration using semantic design tokens. |
| **Background Jobs** | GoodJob | PostgreSQL database-backed Active Job queue with integrated cron. |
| **Transactional Email**| Resend API | Integrated via `action_mailer.delivery_method = :resend` (`AuthMailer`, `LetterMailer`). |
| **Authentication** | Passwordless Magic Links | Cryptographically secure single-use tokens (`SecureRandom.hex(24)`). |
| **Internationalization**| Rails I18n | Bilingual English (`:en`, default) and Spanish (`:es`). |
| **Deployment** | Render & Kamal | Turnkey Render PaaS configuration (`render.yaml`) and Kamal container deployment (`config/deploy.yml`). |

---

## 2. Directory Organization

```
time_echo/
├── app/
│   ├── controllers/    # Thin RESTful controllers (7 standard actions only)
│   ├── decorators/     # SimpleDelegator view presenters (ApplicationDecorator)
│   ├── forms/          # Multi-model form objects & atomic transactions (LetterForm)
│   ├── jobs/           # GoodJob ActiveJob workers (Letters::DeliverLetterJob)
│   ├── mailers/        # Resend-backed mailers (AuthMailer, LetterMailer)
│   ├── models/         # ActiveRecord models (Letter, Prediction, EmotionalSnapshot, etc.)
│   ├── policies/       # Access control and authorization (LetterPolicy)
│   ├── queries/        # Reusable database queries (UserTimelineQuery, PendingLettersQuery)
│   ├── services/       # Single-responsibility business services (Letters::, Auth::, etc.)
│   └── views/          # Declarative ERB templates (zero ERB comments, all i18n t())
├── bin/
│   ├── dev             # Foreman runner booting Puma, Tailwind watcher, GoodJob
│   └── render-build.sh # Render deployment build script
├── config/
│   ├── application.rb  # GoodJob cron schedules, i18n settings
│   ├── deploy.yml      # Kamal container deployment config
│   ├── puma.rb         # Single-mode Puma on free tier (WEB_CONCURRENCY=0)
│   └── routes.rb       # RESTful application routes
├── db/
│   ├── migrate/        # Schema migrations
│   ├── schema.rb       # Authoritative database schema
│   └── seeds.rb        # Realistic demo data seeding
├── docs/architecture.md# Deep architectural reference document
├── render.yaml         # Render infrastructure-as-code blueprint
└── test/               # Comprehensive Minitest test suite (100% line coverage)
```

---

## 3. Background Job Architecture (GoodJob)

GoodJob runs database-backed Active Job queues in PostgreSQL.

### Scheduled Cron Tasks (`config/application.rb`):
- `cleanup_expired_tokens`: Runs every hour (`0 * * * *`) via `CleanupExpiredTokensJob` to purge spent/expired magic-link tokens.
- `dispatch_pending_letters`: Runs daily at midnight (`0 0 * * *`) via `Letters::DispatchPendingJob` to find due letters (`scheduled_at <= Time.current`), mark them `queued`, and enqueue `Letters::DeliverLetterJob` workers.

### Manual CLI Dispatch:
- `rake letters:deliver`: CLI task invoking `Letters::DispatchPendingService` directly.

### Delivery Workers:
- `Letters::DeliverLetterJob`: Worker processing individual capsule delivery via `Letters::DeliverService`. Features polynomial retry backoff:
  ```ruby
  retry_on Resend::Error, wait: :polynomially_longer, attempts: 5
  ```

---

## 4. Internationalization (i18n) Engine

- **Available Locales**: Strictly `:es` and `:en`. Default is `:en`.
- **Three-Tier Locale Resolution**:
  1. `session[:locale]`: Set when the user clicks the interactive language toggle button in the navigation header (`LocalesController#create` / `#destroy`).
  2. `HTTP_ACCEPT_LANGUAGE`: Scans browser headers for supported two-letter codes.
  3. `I18n.default_locale`: Falls back to `:en`.
- **Dynamic Letter Title Localization**: `LetterDecorator#display_title` dynamically detects default titles (`"your_letter"`, `"Tu Carta"`, `"Your Letter"`) and translates them into the currently active locale.
- **Test Environment**: `test_helper.rb` configures `setup { I18n.locale = :es }`.

