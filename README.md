# ⏳ TimeEcho — Secure Digital Time Capsule

TimeEcho is a premium future-letter digital capsule platform built to capture personal evolution, emotional shifts, and life predictions over time. Unlike generic platforms, TimeEcho lets users bridge their past and present selves through an interactive comparison dashboard, vertical reflective timelines, and rich retrospective analytics. 

Built with **Ruby on Rails 8**, **Tailwind CSS v4 / DaisyUI v5**, and a PostgreSQL backend, the application has been architected from the ground up for high integrity, passwordless security, and asynchronous scalability.

---

## ✨ Features

* **Future Letters (Digital Capsules)**: Write deeply private letters to your future self, scheduled for precise future delivery dates.
* **Personal Evolution Tracker**:
  * **Emotional Snapshot**: Rate Happiness, Anxiety, and Motivation (1-10) when writing. TimeEcho calculates baseline shifts and traces emotional growth upon delivery.
  * **Predictions vs. Reality**: Predict future milestones (city, salary, relationships, career, achievements). Once the capsule unlocks, rate whether they matched and add retrospective reflections.
* **Minimalist Vertical Timeline**: Scroll through backdated, pending, and unlocked capsules in a premium journal-like design.
* **Retrospective Analytics**: Visualize average emotional growth matrices, open rates, click rates, and prediction match accuracy with responsive progress meters and radial gauges.
* **PWA Enabled**: Native Progressive Web App integration with offline asset caching and support for standard mobile app layouts.
* **Architectural Integrity**: Atomic PostgreSQL transactional updates, single-use magic-link auth cycles, and concurrent-safe background delivery jobs.

---

## 🏛️ System Architecture & Design Patterns

TimeEcho adopts a layered, highly decoupled design pattern that keeps models focused, controllers strictly RESTful, and templates thinned:

1. **RESTful Controller Design**: All controllers are strictly focused on the seven standard RESTful actions (`index`, `show`, `new`, `create`, `update`, `destroy`). Non-RESTful custom actions are extracted into dedicated single-responsibility sub-resources (e.g. `LetterPredictionsController`, `Settings::EmailConfirmationsController`, `Webhooks::ResendsController`).
2. **Decorator / Presenter Pattern (`app/decorators/`)**: Removes all visual formatting, countdown calculations, and i18n label selectors from view templates. Built around a base `ApplicationDecorator` using Ruby's native `SimpleDelegator` standard library.
3. **Form Objects (`app/forms/`)**: Enforce complex multi-model validation. `LetterForm` validates and saves `Letter`, `EmotionalSnapshot`, and several nested `Prediction` records within a single database transaction.
4. **Service Objects (`app/services/`)**: Isolate single business actions (e.g. `Letters::DeliverService`, `Auth::MagicLinkService`, `Analytics::TrackEventService`).
5. **Query Objects (`app/queries/`)**: Decouple database querying. `UserTimelineQuery` uses eager-loading to avoid $N+1$ query overheads, and `PendingLettersQuery` runs highly concurrent row locks (`FOR UPDATE SKIP LOCKED`).
6. **Policy Layer (`app/policies/`)**: Manages access controls (e.g. public letters are open to everyone, but pending/private letters are locked strictly to their creator).
7. **Background Jobs (GoodJob)**: Standard Active Job queuing in Rails 8. Uses `config/application.rb` cron configuration to trigger capsule delivery scripts every minute and cleanup expired tokens every hour.
8. **Webhook Pipeline**: Ingests Resend Webhook API callbacks asynchronously via `Webhooks::ResendsController#create`, allowing instant background processing of email delivery updates.

For detailed system sequence diagrams, database schemas, and transactional boundary details, read the:
👉 **[System Architecture & Design Document (docs/architecture.md)](docs/architecture.md)**

---

## 🛠️ Prerequisites & Stack

* **Ruby**: `~> 3.2` or `3.3` (with Rails `8.1.x`)
* **Node.js**: `v18.x` or higher (with `npm`)
* **Database**: PostgreSQL (v14+)
* **Styling**: Tailwind CSS v4 & DaisyUI v5 (CSS-first setup)
* **Active Job Queue**: GoodJob (database-backed)

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

* `DATABASE_HOST` (default: `localhost`)
* `DATABASE_USERNAME` (default: `postgres`)
* `DATABASE_PASSWORD` (default: `postgres`)

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
* Launches the Puma server on port 3000.
* Compiles and hot-reloads Tailwind CSS v4 stylesheets.
* Bootstraps the `GoodJob` in-process worker to process background jobs and cron schedules.

*(Alternatively, you can run them manually in separate shells: `npm run watch:css` and `bundle exec rails server`)*

---

## 🧪 Testing the Suite

To run the automated Rails test suite, run:

```bash
bundle exec rails test
```

---

## 🚀 Production & Deployment (Kamal)

TimeEcho is completely containerized and deployment-ready via **Kamal**:

* **Kamal Deployment**: Configuration is stored in `config/deploy.yml`. Deploy to your cloud servers with `kamal deploy`.
* **Docker Support**: Uses the multi-stage standard Rails `Dockerfile` for super-lean image builds.
* **Mail Delivery**: Configured to run through **Resend** using `TimeCapsuleMailer`. To enable delivery in production, set the `RESEND_API_KEY` environment variable.
* **APP_HOST**: Ensure `APP_HOST` is configured to your production domain (e.g. `vault.timeecho.com`) so magic login links render correct URLs.
