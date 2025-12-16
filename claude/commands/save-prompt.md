---
description: Convert conversation into reusable prompt template
argument-hint: [optional-name]
allowed-tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# Save Prompt Command

Transform the current conversation into a generalized, reusable prompt template.

## Argument

`$ARGUMENTS` - Optional custom name for the prompt file (kebab-case)

If not provided, generate a descriptive name from the conversation.

## 7-Step Workflow

### 1. Analyze Conversation
- Review the conversation history
- Identify the core task or problem being solved
- Note key requirements and constraints

### 2. Validate Input
- Ensure conversation contains meaningful work
- Verify it's suitable for reuse
- Check for complete task flow

### 3. Generalize Task
- Extract the abstract pattern
- Identify what varies vs what's constant
- Determine which parts need user input

### 4. Remove Specifics
- Strip out project-specific paths
- Remove hardcoded values
- Replace names with placeholders
- Generalize file references

### 5. Create Template
- Structure as clear instructions
- Use descriptive placeholders: `<project-name>`, `<file-path>`
- Include context about when to use this prompt
- Add examples if helpful

### 6. Write Description
- Summarize what the prompt does (1-2 sentences)
- Note key use cases
- Mention any prerequisites

### 7. Define Arguments
- List expected inputs/variables
- Describe what user should provide
- Give examples of valid inputs

## Output Format

Create `.prompt.md` file in current working directory:

```markdown
---
name: <kebab-case-name>
description: <brief-description>
argument-hint: <expected-inputs>
---

<Generalized prompt instructions>

## Variables to Replace

- `<placeholder-1>`: Description
- `<placeholder-2>`: Description

## Example Usage

[Optional: Show example of filled-in prompt]
```

## Guidelines

- Make prompts broadly applicable
- Use clear, descriptive placeholders
- Include enough context to understand purpose
- Remove all personal/project-specific details
- Test mental model: "Could someone else use this?"

## Process

1. Analyze the full conversation
2. Follow 7-step workflow systematically
3. Generate frontmatter and content
4. Write to `.prompt.md` in current directory
5. Confirm creation and show preview
