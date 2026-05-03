# Phase 7: Slash Commands
_Depends on: Phase 1 (.claude/commands/ must exist), Phase 6 (workflows must exist)_

### `.claude/commands/personal-os-daily-briefing.md`

```markdown
Generate the daily coaching briefing.

Load `profile/preferences/briefing.md` first — this governs tone, depth, and what to surface.
Then follow `_system/workflows/daily-briefing.md` exactly.

At the end, ask: "Should I send this to Telegram?"
```

### `.claude/commands/personal-os-process-inbox.md`

```markdown
Process all new items in the Inbox.

1. Load `Inbox/CLAUDE.md` and `_system/data/synthesis-log.json`
2. Scan each Inbox subfolder for files not in synthesis-log
3. For each new file, determine type and apply correct workflow from `_system/workflows/`
4. Process one file at a time, update synthesis-log after each
5. Report: N files processed, N skipped, any errors
```

### `.claude/commands/personal-os-cascade.md`

```markdown
Run the weekly Cascade workflow.

Load `_system/workflows/cascade.md` and follow it exactly.
For each elicitation question, generate 3–5 options from loaded context before asking — do not present blank questions.
Do not send anything to Slack without explicit approval.
Present all three drafts (Down, Lateral, Up) and ask which to activate.
```

### `.claude/commands/personal-os-1on1-prep.md`

```markdown
Prepare for a 1on1. Usage: /personal-os-1on1-prep [name]

$ARGUMENTS contains the person's name.
If no name provided, ask: "Who is this 1on1 with?"

If `1on1s/[Name]/ready-note.md` exists, open with it — it's the pre-built prep.
Surface the `## My Notes` section and suggest adding any new notes there.
Then follow `_system/workflows/1on1-prep.md` to supplement anything not already covered.
```

### `.claude/commands/personal-os-ingest-url.md`

```markdown
Fetch, annotate, and file a URL. Usage: /personal-os-ingest-url [url]

$ARGUMENTS contains the URL.

1. Fetch the URL content
2. Save raw to `Inbox/links/[slug].md`
3. Annotate using `_system/templates/source-annotation.md`
4. Save annotated to `Knowledge/sources/[slug].md`
5. Update `_system/data/synthesis-log.json`
6. Move `Inbox/links/[slug].md` to `Inbox/archive/links/[slug].md`
7. Report: title, key concepts extracted, connections identified
```

### `.claude/commands/personal-os-nightly.md`

```markdown
Run nightly synthesis manually.

Follow `_system/workflows/nightly-synthesis.md` exactly.
Process only new/changed files — never reprocess what's already in synthesis-log.
Report: files processed, loops created, wiki pages updated, any patterns flagged.
```

### `.claude/commands/personal-os-open-loops.md`

```markdown
Review open loops. Usage: /personal-os-open-loops [optional filter]

$ARGUMENTS may contain a person name or project name.

1. Read `_system/data/open-loops.json`
2. Filter if argument provided (context_person or project match)
3. Sort: overdue first → due this week → critical priority → high priority → rest
4. Display each: title, owner, priority, due date, days open, source
5. Flag any loop open >14 days without a note update
6. Ask: "Do you want to update or archive any of these?"
7. For each confirmed closure: set status="archived", closed_date=today
```

### `.claude/commands/personal-os-new-1on1.md`

```markdown
Create a new person folder in 1on1s/. Usage: /personal-os-new-1on1 [name]

$ARGUMENTS contains the person's name.

1. Create `1on1s/[Name]/` directory
2. Create `1on1s/[Name]/CLAUDE.md` from `_system/templates/person-folder.md`
3. Create `1on1s/[Name]/profile.md` (sections: Role, Background, Working Style, Themes, Notes)
4. Create `1on1s/[Name]/open-loops.md` with empty header
5. Create `1on1s/[Name]/sessions/` directory
6. Create `1on1s/[Name]/ready-note.md` from `_system/templates/1on1-ready-note.md` with placeholder content
7. Ask: "Tell me about [Name] — role, relationship to you, key context?"
8. Fill in CLAUDE.md from the answer
9. Add to `People/team.md` or `People/stakeholders.md` as appropriate
```

### `.claude/commands/personal-os-new-interview-role.md`

```markdown
Open a new interview role folder. Usage: /personal-os-new-interview-role [role]

$ARGUMENTS contains the role name (e.g. "Head of Product - Acme").

1. Create `Interviews/[role]/` directory
2. Create `Interviews/[role]/role-context.md` with blank template (Company, JD summary, Why interested, Key contacts)
3. Create `Interviews/[role]/question-bank.md` with blank question list, tagged by type [culture] [strategy] [role] [growth]
4. Create `Interviews/[role]/notes/` directory
5. Update `Interviews/_index.md` with new entry (role, company, stage: screening, status: active, opened: today)
6. Ask: "Tell me about this role — company, what drew you to it, and the JD summary?"
7. Fill in role-context.md from the answer
```

### `.claude/commands/personal-os-interview-prep.md`

```markdown
Prepare for an upcoming interview. Usage: /personal-os-interview-prep [role]

$ARGUMENTS contains the role name (must match a folder under Interviews/).

1. Read `Interviews/[role]/role-context.md`
2. Read `Interviews/[role]/question-bank.md`
3. Read `Interviews/_index.md` to get current stage and last activity
4. If notes/ exists, read the most recent note to understand where the process left off
5. Based on role context and current stage, select the 6-8 most relevant questions from question-bank.md
6. Generate a prep brief:
   - Company / role reminder (2-3 bullets from role-context)
   - Where you are in the process and who you're meeting
   - Recommended questions for this stage, ranked by relevance
   - 2-3 talking points to reinforce your narrative for this role
7. Create a notes file: `Interviews/[role]/notes/YYYY-MM-DD.md` with today's date
8. Ask: "Who are you meeting with, and what stage is this?"
```

### `.claude/commands/personal-os-career-evidence.md`

````markdown
Review captured career evidence and optionally generate a brag doc.
Usage: /personal-os-career-evidence [last 90d | last 6mo | all]

$ARGUMENTS may contain a time range. Default: last 90 days.

Follow `_system/workflows/career-evidence.md` exactly.
````

### `.claude/commands/personal-os-week-ahead.md`

```markdown
Run the week-ahead planning review.

Follow `_system/workflows/week-ahead.md` exactly.
```

### `.claude/commands/personal-os-remember.md`

```markdown
File insights from this session into the wiki.

Follow `_system/workflows/wiki-remember.md` exactly.
If nothing from this session meets the bar for wiki filing, say so directly — do not force it.
```
