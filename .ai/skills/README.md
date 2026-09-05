# Skills Directory

This directory hosts and references the specialized skill modules available within TimeEcho's AI Engineering Harness.

To prevent duplication and preserve existing functionality, the harness directly reuses the project's foundational skills located in `.agents/skills/` via symbolic links.

---

## Available Skills

| Skill | Source | Purpose |
| ----- | ------ | ------- |
| [`rails-expert`](rails-expert) | `.agents/skills/rails-expert` | Rails 7+ & 8 expert patterns: Active Record query optimization, Turbo Frames / Streams, Hotwire, background jobs, and test patterns. |
| [`frontend-design`](frontend-design) | `.agents/skills/frontend-design` | Distinctive, intentional visual design guidance for shaping aesthetic direction, typography, and theme tokens. |
| [`impeccable`](impeccable) | `.agents/skills/impeccable` | Frontend design craft, UX polish, micro-interactions, responsive behavior, accessibility, and visual harmony. |
| [`copywriting`](copywriting) | `.agents/skills/copywriting` | Marketing and product copy guidance tailored for brand tone ("Calm, Nostalgic, Secure"). |
| [`find-skills`](find-skills) | `.agents/skills/find-skills` | Discovery tool for discovering and installing additional specialized skills when extending capabilities. |

---

## Adding New Skills

To add a new skill to the harness:
1. Create a subdirectory under `.ai/skills/<skill-name>/` (or `.agents/skills/<skill-name>/`).
2. Add a `SKILL.md` file with YAML frontmatter containing `name`, `description`, and instructions.
3. Add supporting reference files under `references/` if the skill requires deep domain knowledge.

