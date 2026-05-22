# ⏳ TimeEcho — Secure Digital Time Capsule

TimeEcho is a premium future-letter platform designed to capture personal evolution, emotional shifts, and life predictions over time. Unlike generic platforms, TimeEcho lets users bridge their past and present selves through an interactive comparison dashboard, vertical reflective timelines, and robust retrospective analytics.

---

## ✨ Features

- **Future Letters**: Write secure, deeply private letters to your future self, scheduled for precise future delivery dates.
- **Personal Evolution Tracker**:
  - **Emotional Snapshot**: Rate Happiness, Anxiety, and Motivation. TimeEcho calculates baseline shifts and traces emotional growth upon delivery.
  - **Predictions vs Reality**: Predict specific future categories (city, salary, career, relationships, achievements) and confirm matches when unlocked.
- **Minimalist Vertical Timeline**: Scroll through backdated sealed capsules and completed interactive reflections.
- **Retrospective Analytics**: Visualize average emotional growth matrices and track prediction match accuracy with responsive progress metrics and radial gauges.

---

## 🛠️ Prerequisites & Stack

- **Ruby**: `~> 3.2` (with Rails `~> 8.1.3`)
- **Node.js**: `v18.x` or higher (with `npm`)
- **Database**: PostgreSQL
- **Styling**: Tailwind CSS v4 & DaisyUI v5 (CSS-first setup)

---

## 🚀 Getting Started

Follow these steps to install and run the project locally.

### 1. Clone & Set Up the Repository

```bash
git clone https://github.com/your-username/time_echo.git
cd time_echo
```

### 2. Install Ruby & Node Dependencies

Install all gems and package dependencies:

```bash
bundle install
npm install
```

### 3. Database Configuration

Ensure PostgreSQL is running locally. You can customize database connection credentials by setting the following environment variables (or fall back to defaults):

- `DATABASE_HOST` (default: `localhost`)
- `DATABASE_USERNAME` (default: `postgres`)
- `DATABASE_PASSWORD` (default: `postgres`)

Initialize the database schema and run the migrations:

```bash
bundle exec rails db:create db:migrate
```

### 4. Seed backdated Capsule Data (Optional but Recommended)

Seed backdated pre-delivered, pending, and sealed capsules to populate your dashboard timeline and analytics pages instantly:

```bash
bundle exec rails db:seed
```

---

## 💻 Running the Application

TimeEcho uses **Foreman** to run the Rails server and compile CSS changes in tandem. To boot the development stack, simply run:

```bash
bin/dev
```

This will:
- Start the Rails server on `http://localhost:3000`
- Compile and hot-reload Tailwind CSS v4 stylesheets via `@tailwindcss/cli`

Alternatively, you can run them manually in separate terminal windows:
```bash
# Terminal 1: Watch & compile Tailwind styles
npm run watch:css

# Terminal 2: Start Rails server
bundle exec rails server
```

---

## 🧪 Testing the Suite

To run the automated Rails test suite, run:

```bash
bundle exec rails test
```
