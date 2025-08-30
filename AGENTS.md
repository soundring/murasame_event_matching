# AGENTS

These guidelines standardize development for this Ruby on Rails project and ensure each contribution meets quality expectations.

## Environment
- Use the Ruby version specified in `.ruby-version` (currently 3.3).
- Install dependencies with `bundle install` when needed. Record any failures.
- Use `rg` for searching the codebase.

## Project Structure
- `app/` contains application code (models, controllers, views, etc.).
- `lib/` holds reusable modules.
- `spec/` contains RSpec tests.
- `config/` stores Rails configuration.

## Coding Style
- Follow the conventions enforced by `rubocop-rails-omakase` with project overrides.
  - String literal style is not enforced.
  - Spaces inside array literal brackets are allowed.
- Use two-space indentation and ensure files end with a newline.
- Favor existing patterns and keep methods small and focused.

## Development Workflow
1. Clarify the task and review relevant `AGENTS.md` instructions.
2. Explore existing code to mirror current patterns.
3. Implement changes with small, descriptive commits.
4. Run the Quality Assurance Checklist and compute the score.

## Quality Assurance Checklist
Score each item from 0 to 10. Proceed only when the total is **80 or more out of 100**.

| Item | Score (0-10) |
| --- | --- |
| `bundle install` executed | |
| `bundle exec rubocop` passes | |
| `bundle exec rspec` passes | |
| Code readability | |
| Ease of modification | |
| Meets objective and specification | |
| Tests added or updated | |
| Documentation updated | |
| No TODOs or debugging code remain | |
| Commit message is clear and conventional | |

If the total is below 80, address deficiencies and re-run the checklist before creating a pull request.

## Pull Requests
- Include a summary of changes, test outputs, and the QA checklist score in the pull request description.
- Ensure the working tree is clean before requesting review.
