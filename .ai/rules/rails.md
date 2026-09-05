# Engineering Rules: Ruby on Rails (Rails 8.1)

This document establishes the mandatory engineering standards for Ruby on Rails development within TimeEcho. All agents and developers must strictly comply with these rules.

---

## 1. Controllers & Request Lifecycle

- **RESTful Actions Only**: Controllers must stick strictly to the 7 standard RESTful actions (`index`, `show`, `new`, `create`, `update`, `destroy`, `edit`).
- **No Custom Member or Collection Actions**: Do not add custom action methods (e.g., `def deliver`, `def toggle_privacy`). Instead, extract a dedicated sub-resource controller (e.g., `LetterPredictionsController`, `Settings::EmailConfirmationsController`, `LocalesController`).
- **Zero Business Logic in Controllers**: Controllers must only receive parameters, invoke a Service or Form object, set flash notices, and redirect or render views. Controllers must never contain:
  - Multi-table database transactions
  - Raw SQL queries
  - Direct mailer dispatch loops
  - Format or cryptographic token calculations
- **Zero Comments Policy**: Controllers must be clean, readable, and free of step comments (`# ...`).
- **Strong Parameters**: Explicitly define and sanitize inputs in private controller methods using `params.require(...).permit(...)`.

---

## 2. ActiveRecord & Database Optimization

- **Atomic Transactions**: Any operation that mutates more than one database table must be wrapped in `ActiveRecord::Base.transaction` to guarantee atomicity and rollback upon failure.
- **Concurrent Row Locking**: When querying records destined for background processing or batch mutations by concurrent workers, use `lock("FOR UPDATE SKIP LOCKED")` to eliminate race conditions and avoid worker collisions.
- **N+1 Query Prevention**:
  - Always eager-load associations when querying collections that render child entities in views:
    ```ruby
    # GOOD - Eager loading
    Letter.includes(:predictions, :emotional_snapshot).where(email: current_user_email)
    ```
  - Use `eager_load` when filtering or sorting on associated tables via `LEFT OUTER JOIN`.
- **Batch Aggregations**:
  - Consolidate multiple sequential `COUNT`, `SUM`, or `AVG` calculations on the same table into a single SQL `select` statement using inline conditional SQL (`COUNT(CASE WHEN ... END)`) to prevent database roundtrip flooding.
- **Pluck Caching**:
  - Never execute `.pluck(:id)` multiple times in the same request or worker execution; pluck once and reuse the cached array.
- **ActiveRecord Encryption**:
  - Sensitive columns are protected using Rails' built-in deterministic or non-deterministic encryption configured in `config/environments/production.rb`.

---

## 3. Database Migrations & Schema Safety

- 🚫 **Execution Prohibition**: Automated AI agents must **NEVER** run database migrations (such as `bin/rails db:migrate`, `db:rollback`, or `bundle exec rake db:migrate`). All migrations must be run manually by the human developer.
- **Idempotent & Reversible Migrations**: All migration files must define reversible changes via `change` or explicit `up`/`down` methods.
- **Sensible Defaults & Constraints**: Always specify explicit nullability (`null: false`) and default values where appropriate in migrations to preserve database consistency.

---

## 4. Background Jobs & Asynchronous Workflows (GoodJob)

- **Database-Backed Active Job**: TimeEcho uses **GoodJob** as its queue adapter in all environments.
- **Job Idempotency**: All background job workers must be idempotent. Re-running a job with the same parameters must not produce duplicate side effects (e.g., sending duplicate capsule emails or charging twice).
- **Polynomial Retry Backoff**:
  - Network-dependent tasks (such as transactional email dispatch through the Resend API) must define polynomial retry backoff:
    ```ruby
    retry_on Resend::Error, wait: :polynomially_longer, attempts: 5
    ```
- **Queue Segregation**:
  - Assign jobs to explicit queues (`default` for dispatchers, `mailers` for transactional communications).
- **Scheduled Cron**:
  - Background cron schedules are defined centrally in `config/application.rb` under `config.good_job.cron`.

---

## 5. Asset Pipeline & Frontend Conventions

- **Propshaft**: Modern asset pipeline in Rails 8. Asset files reside in `app/assets/` and precompiled assets in `app/assets/builds/`.
- **Tailwind CSS v4 & DaisyUI v5**:
  - Use semantic theme tokens (`bg-base-100`, `text-base-content`, `text-primary`, `bg-primary/5`).
  - Do not hardcode utility colors (`bg-white`, `text-slate-900`) or raw hex strings.
  - Watcher setting: Always use `--watch=always` in Tailwind CLI scripts to prevent premature exit under Foreman (`bin/dev`).

