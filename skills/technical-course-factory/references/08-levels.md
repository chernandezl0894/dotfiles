# 08 — Level profiles

The same topic needs different pacing, examples and exercises depending on level. Record the course level and, for mixed courses, the level of each lesson.

## Beginner

**Assumes:** nothing or very little.

**Goals:** confidence, vocabulary, first working example.

**Lesson shape:**

- Short definition and why it matters.
- Setup or mental model.
- 2–3 small worked examples with expected output.
- Common mistakes and how to recognize them.
- Guided exercise + independent exercise + quiz.

**Pacing:** 15–25 min.

**Avoid:** jargon without definition, large code blocks, architecture debates, “just read the docs”.

**Success:** the learner can reproduce the example and explain it in their own words.

## Intermediate

**Assumes:** basic syntax and tools.

**Goals:** solve realistic problems, understand tradeoffs, write tests.

**Lesson shape:**

- Problem and context.
- Two possible approaches.
- One realistic example.
- Tradeoffs and pitfalls.
- Independent + challenge + quiz.

**Pacing:** 20–35 min.

**Avoid:** re-teaching basics for too long, toy examples only.

**Success:** the learner can choose an approach and justify it.

## Advanced

**Assumes:** working experience.

**Goals:** design, performance, edge cases, maintainability.

**Lesson shape:**

- Real constraint or incident.
- Options and tradeoffs.
- Production-like example.
- Failure modes and observability.
- Challenge + critique + quiz.

**Pacing:** 30–45 min.

**Avoid:** step-by-step hand-holding, hiding complexity.

**Success:** the learner can critique a design and propose an alternative.

## Expert

**Assumes:** production experience.

**Goals:** architecture, research, organizational impact.

**Lesson shape:**

- Case study or research question.
- Constraints and competing forces.
- Multiple solutions with consequences.
- Incident analysis or migration plan.
- Design/critique + capstone.

**Pacing:** 40–60 min.

**Avoid:** “best practice” without context, recipes.

**Success:** the learner can lead a decision and explain the tradeoffs.

## Mixed

- Set a base level for the course.
- Mark each lesson with its level.
- Add optional “stretch” sections and challenges.
- Do not hide prerequisites; state them.

## Exercise mapping

| Level | Guided | Independent | Challenge | Quiz |
|---|---|---|---|---|
| Beginner | Required | Required | Optional | Required |
| Intermediate | Optional | Required | Required | Required |
| Advanced | No | Required | Required | Required |
| Expert | No | Optional | Required | Required |
| Mixed | Per lesson | Per lesson | Optional | Required |

## Level consistency checklist

- [ ] The lesson’s level matches the TOC and manifest.
- [ ] Prerequisites match the level.
- [ ] Examples are not too advanced for the level.
- [ ] Exercises match the level.
- [ ] The quiz tests the objectives, not trivia.
- [ ] The next lesson does not assume untaught concepts.
