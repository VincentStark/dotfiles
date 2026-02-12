# Pull Request Branch Creator

Create a new branch, commit staged changes, push for a pull request, monitor review bot feedback, fix issues, merge, and verify post-merge steps.

## Instructions

1. Run `git diff --cached --stat` to see which files are staged
2. If nothing is staged, run `git add -A` to stage all changes first
3. Run `git diff --cached` to see the staged changes
4. Run `git diff --cached --stat` to see which files are affected
5. Analyze the changes to:
   - Generate a branch name
   - Generate a commit message following the Conventional Commits specification
6. Do NOT add "Co-Authored-By" footer to the commit message

## Branch Naming

Generate a branch name in the format: `vstark/<type>-<short-description>`

Examples:
- `vstark/feat-add-user-authentication`
- `vstark/fix-login-validation-error`
- `vstark/refactor-api-client`

Guidelines:
- Use lowercase letters, numbers, and hyphens only
- Keep it concise but descriptive (max 50 chars total)
- Use the same type prefix as the commit message

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

## Execution Order

Execute these steps in order without asking for confirmation:

1. **Create and checkout new branch:**
   ```bash
   git checkout -b vstark/<generated-branch-name>
   ```

2. **Stage changes** (if not already staged):
   ```bash
   git add -A
   ```

3. **Commit with HEREDOC:**
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <body>
   EOF
   )"
   ```

4. **Push branch with upstream tracking:**
   ```bash
   git push -u origin vstark/<generated-branch-name>
   ```

5. **Count changed files** against the base branch (main):
   ```bash
   git diff --stat main...HEAD | tail -1
   ```
   Parse the number of files changed from the output.

6. **Create the PR with `gh pr create`:**
   - Generate a concise PR title (under 70 characters)
   - Generate a summary body with bullet points describing the changes
   - **If the number of changed files exceeds 60**, append the following line at the end of the PR body:
     ```
     I KNOW WHAT IM DOING - This PR intentionally touches <N> files: <brief reason, e.g. "large-scale refactor", "new service with full test suite", etc.>
     ```
     This prevents the PR size check CI step from failing.
   - Use HEREDOC format:
     ```bash
     gh pr create --title "<title>" --body "$(cat <<'EOF'
     ## Summary
     - <bullet points>

     [optional: I KNOW WHAT IM DOING line if >60 files]
     EOF
     )"
     ```

**IMPORTANT:** Immediately after pushing and creating the PR, switch back to the base branch and pull-rebase to keep your local main up to date:
```bash
git checkout main && git pull --rebase
```
Then check out the PR branch again before continuing:
```bash
git checkout vstark/<generated-branch-name>
```

## Phase 2: Review Bot Monitoring & Fix Loop

After the PR is created, monitor for review bot comments and CI checks. Repeat until all checks pass.

**CRITICAL: No sleeps. No busy-wait polling.** Use event-driven `--watch` flags which stream updates and return immediately when all checks resolve. Never use `sleep` commands.

7. **Gauge expected CI duration from recent runs:**
   ```bash
   gh run list --limit 5 --json databaseId,status,conclusion,updatedAt,createdAt
   ```
   Compare `createdAt` and `updatedAt` timestamps of completed runs to estimate typical CI duration. This helps you know how long `--watch` will block. If CI typically runs fast (<2 min), the watch will return quickly. If CI is slow (>10 min), be aware the watch may block for a while — this is fine, it's event-driven and not wasting cycles.

8. **Wait for CI checks (event-driven, no polling):**
   ```bash
   gh pr checks <PR_NUMBER> --watch
   ```
   This streams status updates and exits as soon as all checks complete (default poll interval is 10s). If any check fails, `gh pr checks --watch` will still wait for the remaining checks to finish before exiting. The exit code indicates the result: 0 = all passed, non-zero = failure.

   If the watch hangs or the command is interrupted, fall back to a single non-watch check:
   ```bash
   gh pr checks <PR_NUMBER>
   ```
   If checks are still pending, report the status and ask the user whether to keep waiting.

9. **Fetch review bot comments immediately after checks resolve:**
   ```bash
   gh pr view <PR_NUMBER> --comments
   gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments
   gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments
   ```

10. **If review bot leaves comments or CI checks fail:**
    - Read each comment/failure carefully
    - Fix the issues in the code
    - Run formatters and linters appropriate for the project language (see Pre-Commit Checklist in CLAUDE.md)
    - Stage, commit, and push the fixes:
      ```bash
      git add -A
      git commit -m "$(cat <<'EOF'
      fix: address review bot feedback

      <description of what was fixed>
      EOF
      )"
      git push
      ```
    - Go back to step 8 and wait for checks again

11. **Repeat steps 8-10 until ALL checks are green and no unresolved review bot comments remain.**

## Phase 3: Merge

12. **Once all checks pass and there are no unresolved comments, merge the PR:**
    ```bash
    gh pr merge <PR_NUMBER> --squash --delete-branch
    ```
    Use `--squash` by default. If the repo requires a different merge strategy, adapt accordingly.

## Phase 4: Post-Merge Verification

13. **Switch back to the base branch and pull:**
    ```bash
    git checkout main && git pull
    ```

14. **Monitor post-merge CI/CD (event-driven, no polling):**
    Identify the workflow run triggered by the merge commit:
    ```bash
    gh run list --branch main --limit 5 --json databaseId,status,conclusion,headSha,name,event
    ```
    Match the run by the merge commit SHA, then watch it event-driven:
    ```bash
    gh run watch <RUN_ID> --exit-status
    ```
    `gh run watch` streams live updates and exits when the run completes. Do NOT add any `sleep` commands around this.

15. **If post-merge CI/CD fails:**
    - Inspect the failure immediately:
      ```bash
      gh run view <RUN_ID> --log-failed
      ```
    - Fix the issue on a new branch, then repeat the full PR process (Phase 1-4) for the fix
    - If the failure is unrelated to the changes made (pre-existing flake), note it in the output

16. **Repeat steps 14-15 until post-merge steps complete successfully.**

## Output

After completing all phases, display:
- The branch name created
- The commit message used
- The PR URL
- Number of review bot fix iterations (if any)
- Merge status (squash-merged, merge commit, etc.)
- Post-merge CI/CD status (all green, or details of any unrelated failures)
