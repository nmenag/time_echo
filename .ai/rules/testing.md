# Engineering Rules: Testing & Quality Assurance

TimeEcho enforces a strict automated testing standard requiring **100.00% line coverage** across the application. The test suite is built on Rails' standard **Minitest** framework and monitored via SimpleCov.

---

## 1. Test Suite Architecture

The test suite is organized into distinct functional layers matching the application architecture:

```
test/
├── controllers/    # Integration tests (ActionDispatch::IntegrationTest)
├── decorators/     # Decorator formatting & view presentation tests
├── fixtures/       # Database fixtures for reproducible initial state
├── jobs/           # ActiveJob execution & queue tests (ActiveJob::TestCase)
├── mailers/        # Transactional email delivery tests (ActionMailer::TestCase)
├── models/         # Model validations & Form Object transaction tests
├── services/       # Unit tests for domain service objects
├── tasks/          # Rake task execution tests
└── test_helper.rb  # Global test setup (SimpleCov, parallelization, i18n locale)
```

---

## 2. 100% Line Coverage Standard

- **SimpleCov Requirement**: SimpleCov is initialized at the very top of `test/test_helper.rb` before Rails boots.
- **Zero Coverage Regression**: Any code contribution (features, bugfixes, refactors) must achieve 100% line coverage on new or modified lines.
- **Branch Coverage**: Test all branches of conditional statements (`if/else`, `case`, fallback handlers, error rescues).

---

## 3. Test Environment & Internationalization (i18n)

- **Default Test Locale**: `test/test_helper.rb` configures a global setup hook:
  ```ruby
  module ActiveSupport
    class TestCase
      parallelize(workers: 1) unless Gem.win_platform?
      setup { I18n.locale = :es }
      fixtures :all
    end
  end
  ```
- **Spanish Expectation by Default**: Because test requests do not send an `Accept-Language` header or a preset session locale by default, assertions for flash banners, button labels, and page titles must match **Spanish** text from `config/locales/es.yml`.
- **Testing English Flows**: When validating English rendering, explicitly switch the locale in integration tests:
  ```ruby
  post locales_path, params: { locale: "en" }
  # or pass session / header
  ```

---

## 4. Testing Layer Guidelines

### Controllers (`test/controllers/`)
- Test HTTP status codes (`assert_response :success`, `:redirect`, `:unprocessable_entity`).
- Test redirects (`assert_redirected_to`).
- Test flash notices (`assert_equal t('flash.notice'), flash[:notice]`).
- Test session manipulation (`session[:locale]`, `session[:current_user_email]`).
- Test authorization boundaries: unauthorized requests must redirect or block access.

### Services (`test/services/`)
- Test standard success outcome and return values.
- Test validation failures, transaction rollbacks, and error raises.
- Verify side effects (e.g., records created, status transitioned from `pending` to `queued`).

### Form Objects (`test/models/`)
- Test invalid inputs (missing fields, invalid email format, anxiety/happiness ratings out of range 1–10).
- Test atomic rollback: ensure no parent `Letter` is persisted if child `Prediction` records fail validation.

### Decorators (`test/decorators/`)
- Test date formatting with different timezones.
- Test badge strings and CSS status classes.
- Test relative countdown logic (`days_left_text`).
- Test dynamic localized letter title resolution (`display_title`).

### Background Jobs (`test/jobs/`)
- Test queue placement:
  ```ruby
  assert_enqueued_with(job: Letters::DeliverLetterJob, queue: "mailers")
  ```
- Test direct job execution:
  ```ruby
  Letters::DispatchPendingJob.perform_now
  ```

### Mailers (`test/mailers/`)
- Verify subject, recipients, and sender addresses.
- Verify message body contains required security tokens or capsule details.
- Clear `ActionMailer::Base.deliveries` between scenarios.

---

## 5. Execution Commands

```bash
# Run entire test suite
bundle exec rails test

# Run a specific test file
bundle exec rails test test/controllers/letters_controller_test.rb

# Run an individual test case by line number
bundle exec rails test test/services/letters/deliver_service_test.rb:25
```

