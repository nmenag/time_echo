# Automated Code Formatting & Linting (RuboCop)

## Mandatory Auto-correction
Whenever any additions or modifications are made to Ruby files (`app/`, `config/`, `lib/`, `test/`, etc.):
1. Automatically run `bundle exec rubocop -a` (safe autocorrect) on the affected files or whole project.
2. Verify that there are zero offenses remaining.
3. Ensure no RuboCop offenses or style regressions are left uncorrected after any edit or task.
