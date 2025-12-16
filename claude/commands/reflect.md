---
description: Generate structured markdown reflection analyzing session meta-aspects
allowed-tools: ["Bash", "Write"]
---

# Reflect Command

Generate a structured reflection document analyzing the meta-aspects of how work was done in this session.

## Output Location

Create the reflection file at:
`~/.claude/reflections/<YYYY-MM-DD>-<descriptive-name>.md`

Where:
- `<YYYY-MM-DD>` is today's date
- `<descriptive-name>` is a kebab-case summary of the session topic

## Required Sections

### 1. What Went Well
- Successful approaches, tools, or strategies
- Moments of clarity or breakthrough
- Effective collaboration patterns

### 2. What Went Wrong
- Challenges, blockers, or mistakes
- Misunderstandings or miscommunications
- Dead ends or wasted effort

### 3. Lessons Learned
- Key insights from the session
- Updated mental models
- New understanding of tools or concepts

### 4. Action Items
- Follow-up tasks
- Things to investigate further
- Process improvements to implement

### 5. Tips & Tricks
- Useful commands discovered
- Tool features learned
- Workflow optimizations

### 6. Generalization Opportunities
- Patterns that could apply to other contexts
- Reusable approaches or templates
- Transferable insights

## Guidelines

- Focus on HOW work was done, not WHAT was built
- Be honest about failures and mistakes
- Include specific examples
- Make insights actionable
- Use concrete details over vague generalizations

## Process

1. Create `~/.claude/reflections/` directory if it doesn't exist
2. Analyze the conversation history
3. Generate the reflection content
4. Write to appropriately named file
5. Confirm file creation with full path
