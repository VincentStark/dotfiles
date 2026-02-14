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

## Phase 2A: Review Bot Loop

After the PR is created, focus **exclusively** on the "Claude Code Review" bot first. Do NOT wait for all CI checks — only the review bot check matters at this stage.

**CRITICAL: No sleeps. No busy-wait polling.** Use `--watch` flags or API queries. Never use `sleep` commands.

7. **Wait for the "Claude Code Review" check to complete:**
   ```bash
   gh pr checks <PR_NUMBER> --watch --fail-fast
   ```
   As soon as the review bot check resolves (regardless of other checks still running), proceed to step 8. If `--fail-fast` is not available, use:
   ```bash
   timeout 120 gh pr checks <PR_NUMBER> --watch
   ```

8. **Fetch review bot comments:**
   ```bash
   gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews
   gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments
   gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments
   ```
   Look specifically for comments/reviews from the **"Claude Code Review"** bot (or similar review bot).

   **If no review bot comments exist, skip directly to Phase 2B (step 11).**

9. **Fix review bot feedback:**
   - Read each review comment carefully
   - Fix the issues in the code
   - For any comment you intentionally **disagree with or choose not to fix**, reply to the comment with a clear explanation of why — do not silently ignore it
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

10. **Go back to step 7** to wait for the review bot to re-run on the new commit. After re-fetching comments in step 8, **verify that the bot has updated its comment to confirm the previous feedback is resolved** before concluding the loop. Do not assume fixes are accepted — wait for the bot's updated comment. Repeat steps 7-9 until the review bot has **no new actionable comments** (all fixed or replied to) and the bot's latest comment confirms resolution.

## Phase 2B: CI Checks

Once all review bot comments are resolved (fixed or replied to with justification):

11. **Wait for ALL remaining CI checks to pass:**
    ```bash
    gh pr checks <PR_NUMBER> --watch
    ```
    If any check fails:
    - Fetch the failure details and fix them
    - Stage, commit, push, and repeat this step

12. **Verify no new review comments appeared** (fix commits may trigger another review round):
    ```bash
    gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews
    gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments
    gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments
    ```
    If new actionable review comments exist, go back to **step 9** in Phase 2A. Otherwise, proceed to merge.

## Phase 3: Merge

13. **Once all checks pass and there are no unresolved comments, merge the PR:**
    ```bash
    gh pr merge <PR_NUMBER> --squash --delete-branch
    ```
    Use `--squash` by default. If the repo requires a different merge strategy, adapt accordingly.

## Phase 4: Post-Merge Verification

14. **Switch back to the base branch and pull:**
    ```bash
    git checkout main && git pull
    ```

15. **Monitor post-merge CI/CD (event-driven, no polling):**
    Identify the workflow run triggered by the merge commit:
    ```bash
    gh run list --branch main --limit 5 --json databaseId,status,conclusion,headSha,name,event
    ```
    Match the run by the merge commit SHA, then watch it event-driven:
    ```bash
    gh run watch <RUN_ID> --exit-status
    ```
    `gh run watch` streams live updates and exits when the run completes. Do NOT add any `sleep` commands around this.

16. **If post-merge CI/CD fails:**
    - Inspect the failure immediately:
      ```bash
      gh run view <RUN_ID> --log-failed
      ```
    - Fix the issue on a new branch, then repeat the full PR process (Phase 1-4) for the fix
    - If the failure is unrelated to the changes made (pre-existing flake), note it in the output

17. **Repeat steps 15-16 until post-merge steps complete successfully.**

## Output

After completing all phases, display:
- The branch name created
- The commit message used
- The PR URL
- Number of review bot fix iterations (if any)
- Merge status (squash-merged, merge commit, etc.)
- Post-merge CI/CD status (all green, or details of any unrelated failures)
