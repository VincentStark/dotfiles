# Commit Message Generator

Generate a Conventional Commit message for the currently staged changes.

## Instructions

1. Run `git diff --cached --stat` to see which files are staged
2. If nothing is staged, run `git add -A` to stage all changes first
3. Run `git diff --cached` to see the staged changes
4. Run `git diff --cached --stat` to see which files are affected
5. Analyze the changes and generate a commit message following the Conventional Commits specification
6. Do NOT add "Co-Authored-By" footer to the commit message

## Conventional Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files

### Guidelines

- Use imperative mood in the description ("add" not "added" or "adds")
- Don't capitalize the first letter of the description
- No period at the end of the description
- Keep the description under 72 characters
- Add a body if the change needs more explanation
- Reference issues in the footer if applicable

## Output

Commit immediately without asking for confirmation.

Use a HEREDOC for commit messages:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body>
EOF
)"
```

After committing, push the branch:

```bash
git push
```
