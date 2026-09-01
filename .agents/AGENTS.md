# AI Agent Guidelines & Constraints — TimeEcho

Welcome to **TimeEcho**! As an AI coding assistant, you must strictly adhere to the following rules, constraints, and patterns when working on this codebase. These guidelines are designed to ensure database safety, maintain visual consistency, preserve architectural integrity, and keep the code clean.

---

## 🚫 1. Execution Restrictions (Migrations, Server, Docker)
* **No Database Migrations**: AI agents and automated assistants must **NEVER** run database migrations (such as `bin/rails db:migrate`, `db:rollback`, or `bundle exec rake db:migrate`). All migrations must be run manually by the developer.
* **No Server Execution**: AI agents must **NEVER** start or run the local Rails server (such as `rails server`, `bin/rails s`, or `bin/dev`).
* **No Docker Control**: AI agents must **NEVER** execute Docker or docker-compose commands (such as `docker ps`, `docker compose up`, or docker start/stop/prune actions).

---

## 🎨 2. Design System & Premium Aesthetics
TimeEcho uses a refined, nostalgic, and secure visual identity built on top of **Tailwind CSS v4** and **DaisyUI v5**.
* **Typography**:
  - Headings: Use the serif font stack (`font-serif` using Instrument Serif) for literary reflection.
  - Body: Use the geometric **Inter** sans-serif font stack (`font-sans`) for clean structure.
  - Handwritten notes: Use **Caveat** (`font-handwritten`) for organic, journal-like annotations.
* **Semantic Layout Styling**:
  - Avoid hardcoded colors like `bg-white`, `text-slate-900`, or direct hex values.
  - Utilize theme-aware semantic tokens like `bg-base-100`, `bg-base-200`, `text-base-content`, `text-primary`, and `bg-primary/5` (for subtle overlays) to ensure dark mode works seamlessly.
* **Writing Canvas**:
  - When rendering letters, use the `.writing-canvas` and `.lined-paper-canvas` classes to provide a realistic notebook feel.
* **Micro-animations**: Integrate smooth transitions and interactive states (`hover:scale-[1.02]`, `active:scale-[0.98]`).

---

## 🏛️ 3. Thin Controllers & Service Objects
TimeEcho enforces a strict separation of concerns following the **"Thin Controllers, Single-Responsibility Services"** standard.
* **No Database Operations in Controllers**: Controller actions must not contain direct multi-table transactions, format validations, token creations, mailer dispatch loops, or raw SQL.
* **Service Objects**: Complex business logic must be isolated in service objects under `app/services/`.
* **RESTful Actions Only**: Controllers must stick to the seven standard RESTful actions (`index`, `show`, `new`, `edit`, `create`, `update`, `destroy`). Avoid custom member/collection actions. Introduce a new resource controller instead.

---

## 🔮 4. Decorator / Presenter Pattern
Views must remain lightweight and declarative.
* **Model Decoration**: Any model requiring custom visual formatting (dates, localized state badges, icon strings) must be wrapped in a decorator located in `app/decorators/` extending `ApplicationDecorator`.
* **View Separation**: Never perform date calculations, localized string mappings, or conditional color matches in ERB files. Call decorated methods instead.

---

## 🧹 5. Zero Comments Policy in Views & Controllers
* **No Comments in ERB**: Do not include ERB comments (`<%# ... %>`) or visual layout dividers inside view templates.
* **No Comments in Controllers**: Keep controllers clean, self-documenting, and free of step comments (`# ...`).

---

## ⚡ 6. Database Optimization
* **Batch Queries**: Consolidate multiple sequential `COUNT`, `SUM`, or `AVG` database checks on the same table into a single `select` query with inline conditional SQL statements to prevent query flooding.
* **Pluck Caching**: Avoid plucking IDs multiple times; reuse plucked arrays.

---

## 🛠️ 7. Dev Workflow & Tailwind CLI Watcher
* **Watcher Setting**: When starting Tailwind watching, always use the `--watch=always` flag in the CLI script.
* **Why**: This prevents Foreman (`bin/dev`) from silently shutting down the background compilation process when stdin is closed.

---

## 🔀 9. Pull Request Formatting Rule
* **Template Standard**: When the user requests a "pull request", AI agents must structure the pull request description strictly adhering to the sections in `.github/pull_request_template.md`.
* **Direct Output Only**: AI agents must return the formatted pull request markdown directly in the chat response inside a single markdown code block for easy copying, without creating temporary markdown files (such as `.pr_body.md`).
