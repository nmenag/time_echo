# ⏳ TimeEcho — Secure Digital Time Capsule

TimeEcho is a premium future-letter digital capsule platform built to capture personal evolution, emotional shifts, and life predictions over time. Unlike generic platforms, TimeEcho lets users bridge their past and present selves through an interactive comparison dashboard, vertical reflective timelines, and rich retrospective analytics.

Built with **Ruby on Rails 8**, **Tailwind CSS v4 / DaisyUI v5**, and a PostgreSQL backend, the application has been architected from the ground up for high integrity, passwordless security, and asynchronous scalability.

---

## ✨ Features

- **Future Letters (Digital Capsules)**: Write deeply private letters to your future self, scheduled for precise future delivery dates.
- **Personal Evolution Tracker**:
  - **Emotional Snapshot**: Rate Happiness, Anxiety, and Motivation (1-10) when writing. TimeEcho calculates baseline shifts and traces emotional growth upon delivery.
  - **Predictions vs. Reality**: Predict future milestones (city, salary, relationships, career, achievements). Once the capsule unlocks, rate whether they matched and add retrospective reflections.
- **Minimalist Vertical Timeline**: Scroll through backdated, pending, and unlocked capsules in a premium journal-like design.
- **Retrospective Analytics**: Visualize average emotional growth matrices, open rates, click rates, and prediction match accuracy with responsive progress meters and radial gauges.
- **PWA Enabled**: Native Progressive Web App integration with offline asset caching and support for standard mobile app layouts.
- **Architectural Integrity**: Atomic PostgreSQL transactional updates, single-use magic-link auth cycles, and concurrent-safe background delivery jobs.

---

## 🏛️ System Architecture & Design Patterns

TimeEcho adopts a layered, highly decoupled design pattern that keeps models focused, controllers strictly RESTful, and templates thinned:

1. **RESTful Controller Design**: All controllers are strictly focused on the seven standard RESTful actions (`index`, `show`, `new`, `create`, `update`, `destroy`). Non-RESTful custom actions are extracted into dedicated single-responsibility sub-resources (e.g. `LetterPredictionsController`, `Settings::EmailConfirmationsController`).
2. **Decorator / Presenter Pattern (`app/decorators/`)**: Removes all visual formatting, countdown calculations, and i18n label selectors from view templates. Built around a base `ApplicationDecorator` using Ruby's native `SimpleDelegator` standard library.
3. **Form Objects (`app/forms/`)**: Enforce complex multi-model validation. `LetterForm` validates and saves `Letter`, `EmotionalSnapshot`, and several nested `Prediction` records within a single database transaction.
4. **Service Objects (`app/services/`)**: Isolate single business actions (e.g. `Letters::DispatchPendingService`, `Letters::DeliverService`, `Auth::MagicLinkService`, `Analytics::TrackEventService`).
5. **Query Objects (`app/queries/`)**: Decouple database querying. `UserTimelineQuery` uses eager-loading to avoid $N+1$ query overheads, and `PendingLettersQuery` runs highly concurrent row locks (`FOR UPDATE SKIP LOCKED`).
6. **Policy Layer (`app/policies/`)**: Manages access controls (e.g. public letters are open to everyone, but pending/private letters are locked strictly to their creator).
7. **Background Jobs & Rake Tasks (GoodJob)**: Standard Active Job queuing in Rails 8. Uses `rake letters:deliver` to dispatch pending capsules daily, and GoodJob cron to purge expired tokens hourly.

For detailed system sequence diagrams, database schemas, and transactional boundary details, read the:
👉 **[System Architecture & Design Document (docs/architecture.md)](docs/architecture.md)**

---

## 🛠️ Prerequisites & Stack

- **Ruby**: `~> 3.2` or `3.3` (with Rails `8.1.x`)
- **Node.js**: `v18.x` or higher (with `npm`)
- **Database**: PostgreSQL (v14+)
- **Styling**: Tailwind CSS v4 & DaisyUI v5 (CSS-first setup)
- **Active Job Queue**: GoodJob (database-backed)

---

## 🚀 Getting Started

Follow these steps to set up and run the project locally.

### 1. Clone & Set Up the Repository

```bash
git clone https://github.com/your-username/time_echo.git
cd time_echo
```

### 2. Install Ruby & Node Dependencies

Install all gems and frontend packages:

```bash
bundle install
npm install
```

### 3. Database Configuration

Ensure PostgreSQL is running locally. You can customize connection credentials by setting the following environment variables (or let them fall back to standard defaults):

- `DATABASE_HOST` (default: `localhost`)
- `DATABASE_PORT` (default: `5432`)
- `DATABASE_USERNAME` (default: `postgres`)
- `DATABASE_PASSWORD` (default: `postgres`)

Initialize the database schema and apply migrations:

```bash
bundle exec rails db:create db:migrate
```

### 4. Seed Simulated Capsule Data (Highly Recommended 🌟)

To populate your dashboard timeline and analytics with realistic pre-delivered, pending, and sealed capsules instantly, run:

```bash
bundle exec rails db:seed
```

This seeds backdated letters, emotional snapshot metrics, and predictions, enabling you to inspect the full retrospective comparison interface right away.

---

## 💻 Running the Application

TimeEcho uses **Foreman** to execute the Rails server, watch Tailwind CSS v4 changes, and run the Active Job worker in tandem. To boot the full development stack, simply run:

```bash
bin/dev
```

This starts the application at `http://localhost:3000` and does the following:

- Launches the Puma server on port 3000.
- Compiles and hot-reloads Tailwind CSS v4 stylesheets.
- Bootstraps the `GoodJob` in-process worker to process background jobs and cron schedules.

_(Alternatively, you can run them manually in separate shells: `npm run watch:css` and `bundle exec rails server`)_

---

## 🐋 Running with Docker

TimeEcho ships with a multi-stage `Dockerfile` and a `docker-compose.yml` for containerized development and production builds.

### Prerequisites

- **Docker** installed locally (Docker Desktop on Windows/macOS, or Docker Engine on Linux).
- A C compiled Ruby image is pulled automatically — no local Ruby installation required for container runs.

### 1. Uncomment the `web` and `queue` Services

The `web` and `queue` services in `docker-compose.yml` are commented out by default. Uncomment them to enable the Rails server and GoodJob worker:

```yaml
web:
  build:
    context: .
    dockerfile: Dockerfile
  command: ./bin/rails server -b 0.0.0.0
  environment:
    RAILS_ENV: development
    DATABASE_HOST: db
    DATABASE_USERNAME: postgres
    DATABASE_PASSWORD: postgres
    PORT: 3000
  volumes:
    - .:/rails
    - bundle_cache:/usr/local/bundle
  ports:
    - "3000:3000"
  depends_on:
    db:
      condition: service_healthy
    mailpit:
      condition: service_started

queue:
  build:
    context: .
    dockerfile: Dockerfile
  command: bundle exec good_job start
  environment:
    RAILS_ENV: development
    DATABASE_HOST: db
    DATABASE_USERNAME: postgres
    DATABASE_PASSWORD: postgres
  volumes:
    - .:/rails
    - bundle_cache:/usr/local/bundle
  depends_on:
    db:
      condition: service_healthy
```

### 2. Build and Start the Stack

```bash
docker compose up --build
```

This starts three services:

| Service   | Ports         | Purpose                                                      |
| --------- | ------------- | ------------------------------------------------------------ |
| `db`      | `5432`        | PostgreSQL 14 database (pre-seeded with default credentials) |
| `web`     | `3000`        | Rails server (accessible at `http://localhost:3000`)         |
| `queue`   | (internal)    | GoodJob background worker for scheduled deliveries           |
| `mailpit` | `8025`/`1025` | Local SMTP catcher for previewing emails sent by the app     |

The `entrypoint.sh` script automatically waits for PostgreSQL to be ready, runs `bundle install` as needed, and executes `rails db:prepare` to set up the schema and seed data before booting.

### 3. Run Migrations (if needed)

If you've added new migrations, run them from the host or inside the container:

```bash
docker compose exec web bundle exec rails db:migrate
```

> **Note**: The entrypoint already calls `db:prepare` on container start, which runs pending migrations automatically.

### 4. Stop the Stack

```bash
docker compose down
```

To remove all data volumes (database and bundle cache) as well:

```bash
docker compose down -v
```

### 5. Production Image (Kamal / Deployment)

For production builds, the same `Dockerfile` is used by Kamal. A lean, multi-stage image is produced. See [Production & Deployment](#-production--deployment-kamal) below for details.

---

## 🌐 Internationalization (i18n)

TimeEcho supports **English (`:en`)** and **Spanish (`:es`)** as the only two available locales. The application's default locale is English, but content is rendered in Spanish when the browser requests it.

### Locale Detection & Fallback Flow

The `set_locale` before_action in `ApplicationController` detects the browser's preferred language via the `Accept-Language` HTTP header. If a supported locale is detected (`es` or `en`), it is applied. If the requested locale is unsupported (e.g. `fr`, `de`), the locale is **not changed**, allowing the Rails default locale (`:en`) to be used. If no `Accept-Language` header is present, the default locale is used.

### Configuration

- **`config/i18n.available_locales`**: `[:es, :en]` — limited to these two.
- **`config/i18n.default_locale`**: `:en` — English is the fallback default.
- **`config/i18n.fallbacks`**: `true` — in production and test environments, missing translations in a locale fall back to the default locale rather than showing the key name.

### Test Environment

All tests establish `I18n.locale = :es` globally via `test/test_helper.rb`, so assertions match Spanish text expectations. The `set_locale` method respects this pre-set locale because test requests do not send an `Accept-Language` header.

### File Structure

```
config/locales/
├── en.yml  # English translations (no Spanish text)
└── es.yml  # Spanish translations (full coverage of en.yml keys)
```

---

## 🧪 Testing the Suite

To run the automated Rails test suite, run:

```bash
bundle exec rails test
```

---

## 🚀 Production & Deployment (Kamal)

TimeEcho is completely containerized and deployment-ready via **Kamal**:

- **Kamal Deployment**: Configuration is stored in `config/deploy.yml`. Deploy to your cloud servers with `kamal deploy`.
- **Docker Support**: Uses the multi-stage standard Rails `Dockerfile` for super-lean image builds.
- **Mail Delivery**: Configured to run through **Resend** using `AuthMailer` and `LetterMailer`. To enable delivery in production, set the `RESEND_API_KEY` environment variable.
- **APP_HOST**: Ensure `APP_HOST` is configured to your production domain (e.g. `vault.timeecho.com`) so magic login links render correct URLs.
