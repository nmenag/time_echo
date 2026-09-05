# Project Context: Domain & Business Model

This document outlines the core business domain, data models, and user journeys of **TimeEcho**, grounded directly in the database schema and application design.

---

## 1. Domain Philosophy & Product Identity

TimeEcho is a premium digital time capsule platform designed for introspective self-reflection, emotional tracking, and life prediction comparison.

- **Brand Personality**: Calm, Nostalgic, Secure.
- **Anti-Patterns Avoided**: Avoids hyper-saturated SaaS dashboards, corporate productivity gamification, and aggressive marketing buzzwords.
- **Core Value Proposition**: Allows users to bridge their past, present, and future selves through letters, emotional snapshots, and prediction evaluations.

---

## 2. Core Entities & Data Model

```mermaid
erDiagram
    UserPreference ||--o{ Letter : "owns"
    UserPreference ||--o{ SessionToken : "requests"
    Letter ||--|| EmotionalSnapshot : "has one"
    Letter ||--o{ Prediction : "has many"

    Letter {
        bigint id PK
        string email FK
        string title
        text content
        string status "pending / queued / delivered / failed"
        datetime scheduled_at
        string timezone "IANA timezone string"
        datetime queued_at
        datetime delivered_at
        datetime opened_at
        string language "en / es"
        integer reveal_happiness "1-10 post-unlock rating"
        integer reveal_anxiety "1-10 post-unlock rating"
        integer reveal_motivation "1-10 post-unlock rating"
        datetime created_at
        datetime updated_at
    }

    EmotionalSnapshot {
        bigint id PK
        bigint letter_id FK
        integer happiness_level "1-10 baseline rating"
        integer anxiety_level "1-10 baseline rating"
        integer motivation_level "1-10 baseline rating"
        datetime created_at
        datetime updated_at
    }

    Prediction {
        bigint id PK
        bigint letter_id FK
        string category "city / salary / relationship / career / achievement / happiness"
        text prediction "The predicted statement"
        text reality "The retrospective outcome"
        boolean matched "Whether prediction was accurate"
        datetime created_at
        datetime updated_at
    }

    SessionToken {
        bigint id PK
        string email
        string token UK "Hashed cryptographic token"
        datetime expires_at "15 minutes expiration"
        datetime used_at "Single-use invalidation timestamp"
        datetime created_at
        datetime updated_at
    }

    UserPreference {
        bigint id PK
        string email UK
        string appearance_mode "system / light / dark"
        string theme "timeecho / pastel / autumn / luxury"
        string reflection_style "reflective / motivational / nostalgic"
        string memory_frequency "low / normal / frequent"
        boolean all_letters_private
        boolean anonymous_analytics
        boolean future_letter_reminders
        boolean monthly_checkpoints
        boolean surprise_memories
        boolean emotional_summary_emails
        boolean automatic_memories
        datetime confirmed_at
        string unconfirmed_email
        datetime created_at
        datetime updated_at
    }

    AnalyticsEvent {
        bigint id PK
        string event_type
        jsonb metadata
        datetime occurred_at
        datetime created_at
        datetime updated_at
    }
```

---

## 3. Capsule Lifecycle & State Machine

Every letter traverses a strict status lifecycle:

```mermaid
stateDiagram-v2
    [*] --> pending: Letter authored & scheduled
    pending --> queued: DispatchPendingService runs (scheduled_at <= now)
    queued --> delivered: LetterMailer successfully sent via Resend
    queued --> failed: Resend delivery permanently fails after retries
    delivered --> [*]
    failed --> [*]
```

1. **`pending`**: The letter is written and sealed. It cannot be read in full by anyone until `scheduled_at` arrives. Owners can view a countdown screen.
2. **`queued`**: Picked up by `Letters::DispatchPendingJob` (or `rake letters:deliver`). A delivery job (`Letters::DeliverLetterJob`) is scheduled.
3. **`delivered`**: Delivered via email with a secure link to the capsule. The user can open, read, and reflect on the letter.
4. **`failed`**: Delivery encountered fatal errors and could not be completed after polynomial retries.

---

## 4. Key User Journeys

### 1. Writing a Time Capsule
- The user composes a letter on the simulated lined paper canvas (`.writing-canvas`).
- Rates baseline emotions: Happiness, Anxiety, and Motivation on a 1–10 scale (`EmotionalSnapshot`).
- Makes specific life predictions across categories (career, relationships, salary, etc.).
- Selects future delivery date and local timezone (`Intl.DateTimeFormat().resolvedOptions().timeZone` automatically captured via browser).
- `LetterForm` validates all models and atomically commits them in a database transaction.

### 2. Passwordless Authentication & Verification
- If the letter is written while unauthenticated, an unconfirmed account is created and a single-use magic link is sent via `AuthMailer`.
- Clicking the link logs the user into their session (`session[:current_user_email]`) and activates their vault.

### 3. Vault & Vertical Reflective Timeline
- Authenticated users access `/dashboard` to view their timeline:
  - Pending capsules with live countdown days remaining.
  - Delivered capsules ready for introspection.

### 4. Unlocking & Retrospective Comparison
- Once unlocked, the user revisits the letter.
- Records their present emotional state (`reveal_happiness`, `reveal_anxiety`, `reveal_motivation`) to compare emotional evolution against their baseline.
- Rates whether their predictions `matched` reality and adds retrospective commentary.

### 5. Analytics & Self-Discovery (`/analytics`)
- Visualizes emotional shifts (happiness growth, anxiety reduction, motivation changes).
- Measures prediction accuracy rates and delivery engagement.

