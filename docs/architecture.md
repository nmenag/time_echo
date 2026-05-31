# ⏳ TimeEcho — System Architecture & Design

Welcome to the architectural overview of **TimeEcho**, a premium future-letter digital capsule platform built with **Ruby on Rails 8** and **Tailwind CSS v4 / DaisyUI v5**. 

This document details the core design patterns, data relationships, transactional workflows, and the secure magic-link authentication lifecycle powering the TimeEcho ecosystem.

---

## 🏛️ System Topology

TimeEcho adheres to a strict, highly decoupled **Model-View-Controller (MVC)** pattern supplemented by isolated **Service Objects** (under `app/services/`) for orchestrating cross-cutting business rules (e.g., authentication, analytics, mailings).

```mermaid
graph TD
    Client[Browser / Client View]
    
    subgraph Controllers [Controller Layer]
        LC[LettersController]
        SC[SettingsController]
        SessC[SessionsController]
        AC[AnalyticsController]
    end

    subgraph Services [Service Layer]
        MLS[Auth::MagicLinkService]
        TES[Analytics::TrackEventService]
    end

    subgraph Models [Active Record Models]
        Let[Letter]
        Pref[UserPreferences]
        Evt[AnalyticsEvent]
    end

    subgraph Cache & DB [Database Persistence]
        PG[(PostgreSQL DB)]
    end

    Client -->|HTTP Requests| Controllers
    Controllers -->|Orchestrates Auth| Services
    Controllers -->|Manipulates Data| Models
    Models -->|Performs Actions / Queries| PG
```

---

## 🔑 Secure Magic Link Authentication Lifecycle

TimeEcho is passwordless by design. Authentication is managed via atomic, single-use, time-sensitive access tokens generated on demand and dispatched securely.

```mermaid
sequenceDiagram
    autonumber
    actor User as User Browser
    participant App as Rails App
    participant DB as PostgreSQL
    participant SMTP as Resend Mailer

    User->>App: Submits email at /login
    activate App
    App->>App: Validates & Normalizes Email
    App->>App: Generates Cryptographically Secure Token
    App->>DB: Stores Hashed Token (expires in 15m)
    App->>SMTP: Dispatches email containing Token Link
    App-->>User: Renders Check Email Confirmation page
    deactivate App

    User->>App: Clicks Magic Link in Email
    activate App
    App->>DB: Looks up and decodes Token
    alt Token Valid & Unexpired
        App->>DB: Invalidates Token (single-use check)
        App->>App: Establishes session cookie (session[:current_user_email])
        App->>DB: Logs "user_logged_in" event
        App-->>User: Redirects to /dashboard (Success Notice)
    else Token Expired / Invalid
        App-->>User: Redirects to /login (Error Alert)
    end
    deactivate App
```

---

## 📊 Database Schema & Domain Relations

Below is the entity-relationship layout demonstrating the data boundary of a user's vault.

```mermaid
erDiagram
    UserPreferences {
        string email PK
        string locale
        boolean email_notifications
        boolean global_private_mode
        datetime created_at
        datetime updated_at
    }

    Letter {
        bigint id PK
        string email FK
        string title
        text content
        datetime deliver_at
        boolean is_public
        integer happiness_level
        integer anxiety_level
        integer motivation_level
        string prediction_city
        string prediction_salary
        string prediction_relationship
        string prediction_career
        string prediction_achievement
        text reality_commentary
        datetime verified_at
        datetime created_at
        datetime updated_at
    }

    AnalyticsEvent {
        bigint id PK
        string email FK
        string event_type
        jsonb properties
        datetime created_at
    }

    UserPreferences ||--o{ Letter : "owns"
    UserPreferences ||--o{ AnalyticsEvent : "triggers"
```

---

## 🔄 Transactional Data Migration Sequence

When a user migrates their email address inside `SettingsController#update`, TimeEcho executes a high-integrity, atomic Postgres transaction to preserve historical integrity, transfer entity ownership, and update active session markers in a single transaction step.

```mermaid
flowchart TD
    Start[User Submits New Email] --> CheckValid{Validations Pass?}
    CheckValid -- No --> RenderErr[Render error view]
    CheckValid -- Yes --> StartTx[Open ActiveRecord::Base.transaction]
    
    StartTx --> LockPref[Acquire row lock on UserPreferences]
    LockPref --> UpdatePref[Update Preferences Email]
    UpdatePref --> CascadeLetters[Update all matching Letters to new email]
    CascadeLetters --> CascadeEvents[Update all historical AnalyticsEvents]
    CascadeEvents --> CommitTx[Commit Database Transaction]
    
    CommitTx --> UpdateSession[Synchronize active session cookie]
    UpdateSession --> Success[Redirect with success flash banner]

    classDef danger fill:#fee2e2,stroke:#f87171,stroke-width:1px;
    classDef success fill:#dcfce7,stroke:#4ade80,stroke-width:1px;
    class RenderErr danger;
    class Success success;
```

---

## 🎨 Premium Style System Tokens (Tailwind v4 / DaisyUI v5)

TimeEcho operates on a tailored typographic and visual system, giving it a nostalgic, premium journal aesthetic.

### Typography Hierarchy
* **Main Headlines & Card Headers**: `font-serif italic text-primary` using **Instrument Serif** to convey elegance and memory preservation.
* **Secondary Action Labels & Metas**: `font-sans uppercase text-[10px] tracking-wider font-semibold` using **Inter** to maximize structural legibility.

### Semantic Color Design Rules
1. **Never use hardcoded hex codes** (e.g. `#5b21b6` is strictly replaced with `@theme` brand variables).
2. **Standardized Radii**: Standard components are locked into `rounded-xl` or `rounded-2xl` shapes; over-rounded shapes (`rounded-3xl`) are explicitly forbidden.
3. **Contrast Compliance**: Contrast ratios strictly respect WCAG AA guidelines by leveraging soft theme-neutral values and OKLCH color spaces.
