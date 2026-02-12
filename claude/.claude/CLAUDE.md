# General Rules

- The user's shell is **fish** (fish shell). Use fish-compatible syntax when providing shell commands or scripts.
- Always ensure the code is nice, clean, lean, accurate, idiomatic, consistent, coherent, with no issues/bugs/regressions. Be very thorough!
- Never add "Co-Authored-By" lines to git commits.
- Never add "🤖 Generated with [Claude Code](https://claude.com/claude-code)" lines to commits or PRs.
- Never commit or push to Git unless the user explicitly requests it. The user will invoke `/commit` when they want to commit and push.
- **When committing, always stage ALL changes from the session** — including formatter/linter-induced reformatting of existing files. Never selectively exclude files just because their changes are "only formatting". If a formatter touched the file during this session, it's part of the work and must be committed. Run `git status` after committing to verify a clean working tree; if any unstaged changes remain, they were missed and must be committed too.
- When making changes to dotfiles/config files (e.g., tmux, ghostty, k9s, fish, etc.), always commit and push the updated files in `~/Code/dotfiles` afterwards.
- When creating PRs, always rebase from main/master first and resolve all conflicts (if any) before creating the PR.
- For new projects, create a per-project `CLAUDE.md` in the project root with project-specific instructions (e.g., build commands, architecture notes, naming conventions, test strategies, environment setup). Keep it focused on what's unique to that project — do not duplicate global rules.
- When a project needs an `.env` file, always create a `.env.example` with documentation of the required variables (names, descriptions, expected format). Ensure `.env` is listed in `.gitignore`. Always verify that `.gitignore` is properly populated for the project's language/framework and warn the user if it is missing entries or is absent entirely.
- For every new project, create a `README.md` in the project root. When making significant updates to an existing project, update its `README.md` accordingly. The README should clearly explain: what the project is, how to install/set it up, how to use it (CLI commands, API, etc.), configuration options, and any other relevant details. Write it so that both humans and bots/agents can understand how to use the tools and APIs the project provides.
- You have access to **gcloud CLI**, **terraform**, and **kubectl**. Use them proactively to gather context (e.g., inspect infrastructure state, check resource configurations, view cluster status) and to fix issues when applicable.
- When a task can be broken into independent subtasks that don't touch the same files or shared state, run multiple agents in parallel to maximize throughput. Ensure each agent works on a distinct set of files/modules so they don't step on each other's toes. Examples: separate frontend and backend changes, independent test suites, linting one module while coding another. If subtasks share files or have ordering dependencies, run them sequentially instead.
- For new projects, always add a pre-commit hook that runs all linting/formatting checks and tests before allowing a commit. Use the appropriate tools for the language:
  - **Python**: Run `ruff check`, `ruff format --check`, `mypy`, and `pyright` for linting; run `uv run pytest` for tests.
  - **Swift**: Run `swiftformat --lint .` and `swiftlint` for linting; run `swift test` or `xcodebuild test` for tests.
  - **Shell**: Run `shellcheck` on all `.sh` files.
  - **General**: Use a `.git/hooks/pre-commit` script (make it executable) or install `pre-commit` framework when the project warrants it. The hook must exit non-zero on any failure to block the commit.

## Rules for Python

- Always use uv instead of pip.
- Always use "uv run" instead of running "naked" commands.
- Always prefer the latest Python version (i.e. 3.14) unless very specific libraries require a lower version.
- For CLI scripts, always use "rich" package for console output.
- For CLI scripts, always use "typer" package for arg parsing.
- For CLI scripts, always add a "dry-run" option and limit options as needed so you can run the actual script to ensure it works as expected: provides both functionality & output required.
- For new projects, always define a `[project.scripts]` entry in `pyproject.toml` so the project can be run with `uv run <project-name>` instead of `uv run python <file>.py`.
- For new projects, always install mypy, ruff, and pyright.
- For new projects, after the initial coding is complete, always init a git repository, add a relevant .gitignore, and create the first commit.
- Always run strict mypy, ruff, and pyright at the very end to ensure you fix all the linting/typing issues.

## Rules for Rust

- Always run `cargo fmt` before committing to ensure consistent formatting.
- Always run `cargo clippy` and fix all warnings before committing.
- For workspace projects, run from the workspace root: `cargo fmt --all` and `cargo clippy --all-targets`.
- Use `cargo fmt -- --check` to verify formatting without modifying files.

### SQLx Offline Mode (for projects using SQLx)

When a Rust project uses SQLx with compile-time query checking (`sqlx::query!` macros):

1. **Generate offline cache**: Run `cargo sqlx prepare --workspace` with a valid `DATABASE_URL` to generate the `.sqlx` directory
2. **Commit the `.sqlx` directory**: This allows CI to run without a live database connection
3. **Update after schema changes**: Re-run `cargo sqlx prepare` whenever SQL queries or database schema changes
4. **CI will use offline mode**: Set `SQLX_OFFLINE=true` in CI environments (automatic when `.sqlx` exists)

## Rules for Dart/Flutter

- Always run `dart format .` before committing to ensure consistent formatting.
- Always run `dart analyze` or `flutter analyze` and fix all issues before committing.
- For Flutter projects, run from the project root (e.g., `flutter/desktop_app/`).
- Use `dart format --set-exit-if-changed .` to verify formatting without modifying files.

## Rules for Shell Scripts

- Always run `shellcheck` on all `.sh` files before committing. Fix all warnings and errors.
- Use `#!/usr/bin/env bash` (or `#!/bin/bash`) as the shebang line.
- Always use `set -euo pipefail` at the top of scripts for strict error handling.
- Quote all variable expansions: `"$var"`, not `$var`.
- Use `[[ ]]` for conditionals in bash (preferred over `[ ]` for complex tests).
- Use `$(command)` for command substitution, not backticks.
- For functions invoked only via `trap`, add `# shellcheck disable=SC2317,SC2329` above the function definition.
- Install shellcheck: `brew install shellcheck`.
- When a project has shell scripts alongside other languages, shellcheck should be added to the same pre-commit hook that runs the other linters. Example pre-commit snippet:

  ```bash
  # Lint shell scripts
  sh_files=$(git diff --cached --name-only --diff-filter=ACM -- '*.sh')
  if [ -n "$sh_files" ]; then
      shellcheck $sh_files || exit 1
  fi
  ```

## Pre-Commit Checklist (All Languages)

Before creating commits or PRs, always run the appropriate formatters and linters:

| Language | Format Command | Lint Command |
|----------|----------------|--------------|
| Python | `ruff format .` | `ruff check . && mypy . && pyright` |
| Rust | `cargo fmt` | `cargo clippy` |
| Dart/Flutter | `dart format .` | `dart analyze` or `flutter analyze` |
| Swift | `swiftformat .` | `swiftlint` |
| Shell | N/A | `shellcheck *.sh` |

**IMPORTANT:** CI/CD pipelines will fail if code is not properly formatted or linted. Always format and lint before committing.

---

## Swift & SwiftUI Guidelines

### Core Principles

- **Frameworks**: Prioritize SwiftUI over UIKit. Use `@Observable` macro (iOS 17+) for state management.
- **Orientation Strategy**: Never use hardcoded frames. Use Stacks, Spacers, and `ViewThatFits`.
- **Adaptive Layouts**: Use `@Environment(\.horizontalSizeClass)` to detect orientation/device type.

### Apple Human Interface Guidelines (HIG)

Apple's design philosophy rests on four pillars: **Clarity**, **Deference**, **Depth**, and **Consistency**.

| Principle    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| Clarity      | Users should immediately understand navigation and interactions  |
| Deference    | UI elements shouldn't distract from essential content            |
| Depth        | Use layers, shadows, and motion to create visual hierarchy       |
| Consistency  | Use standard UI elements and visual cues familiar to Apple users |

#### Touch Targets

- **Minimum 44x44 points** for all interactive elements
- Apple research shows elements smaller than this are missed by >25% of users
- This is especially critical for accessibility

#### System Integration

- Use Apple's system components (Tab Bars, Toolbars, system fonts)
- Components automatically adapt to Dark Mode and Dynamic Type
- Match software design to hardware (rounded corners, minimal lines)

**Reference:** [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Layout Best Practices

- Respect safe areas—avoid `.ignoresSafeArea()` unless intentional (backgrounds, media)
- Support Dynamic Type: use `.font(.body)` etc., not fixed sizes
- Prefer `LazyVStack`/`LazyHStack` inside `ScrollView` for long lists
- Use `layoutPriority()` to control which views compress first
- Extract subviews into separate structs when a view exceeds ~50 lines
- **Never hardcode frames** - Use flexible layouts:

  ```swift
  // Bad
  .frame(width: 300, height: 100)

  // Good
  .frame(maxWidth: .infinity)
  ```

- Use GeometryReader sparingly - For dynamic sizing when needed
- Prefer NavigationSplitView - Automatically adapts between sidebar (iPad) and stack (iPhone)
- Use ViewThatFits - Automatically selects the first view that fits

#### Size Classes

| Size Class Combination | Typical Device           |
| ---------------------- | ------------------------ |
| compact × regular      | iPhone portrait          |
| compact × compact      | iPhone landscape         |
| regular × regular      | iPad (both orientations) |

#### Test on Multiple Devices

- iPhone SE (smallest)
- iPhone 15 Pro Max (largest iPhone)
- iPad Pro 12.9" (largest iPad)
- Both orientations

### Orientation-Specific

- For radically different layouts, use separate views switched via size class rather than excessive conditionals
- Test keyboard behavior in landscape (often needs `ScrollView` or `.ignoresSafeArea(.keyboard)`)
- Consider `toolbar` placement differences between orientations

### Previews

- Always include both portrait and landscape previews
- Add previews for Dynamic Type extremes (`.environment(\.sizeCategory, .accessibilityExtraExtraLarge)`)
- Use preview variants for light/dark mode

### Project Conventions

- One view per file, filename matches struct name
- Group related views in folders by feature
- Keep view models in separate files with `ViewModel` suffix

---

## Swift Build & Verify

### Linting Tools (Required)

SwiftLint and SwiftFormat must be installed via Homebrew:

```bash
brew install swiftlint swiftformat
```

### SwiftLint - Style & Convention Enforcement

- Run after completing code changes: `swiftlint`
- Auto-fix correctable issues: `swiftlint --fix`
- Check specific file: `swiftlint lint --path path/to/File.swift`

Common rules to be aware of:

- `line_length`: Max 120 characters (warning), 200 (error)
- `function_body_length`: Max 50 lines (warning), 100 (error)
- `file_length`: Max 400 lines (warning), 1000 (error)
- `identifier_name`: 3-40 characters, no underscores unless prefix
- `trailing_comma`: Required in multi-line collections

### SwiftFormat - Code Formatting

- Auto-format all files: `swiftformat .`
- Lint only (no changes): `swiftformat --lint .`
- Format specific file: `swiftformat path/to/File.swift`

Key formatting rules applied:

- `sortImports`: Alphabetical import ordering
- `trailingCommas`: Add trailing commas in multi-line collections
- `redundantSelf`: Remove unnecessary `self.` references
- `indent`: Consistent 4-space indentation

### Additional Static Analysis Tools

| Tool      | Purpose                  | Install                  |
| --------- | ------------------------ | ------------------------ |
| Periphery | Detect unused code       | `brew install periphery` |
| SwiftGen  | Type-safe assets/strings | `brew install swiftgen`  |
| Sourcery  | Code generation          | `brew install sourcery`  |

#### Periphery (Unused Code Detection)

```bash
# Install
brew install periphery

# Run (from project root)
periphery scan --setup  # First time
periphery scan          # Subsequent runs
```

Detects: unused classes, structs, enums, functions, properties, protocols, and imports.

### Build & Verify Workflow

1. Write/modify code
2. Run `swiftformat .` to auto-format
3. Run `swiftlint --fix` to auto-fix correctable issues
4. Run `swiftlint` to check remaining issues
5. Run `periphery scan` to find unused code
6. Manually fix any remaining violations before committing

---

## iOS Simulator MCP Tools

When using XcodeBuildMCP and ios-simulator-mcp servers:

### UI Verification Workflow

**CRITICAL: Do NOT rely on screenshots alone for UI verification.** Claude's vision cannot accurately measure pixels, padding, or alignment. Instead, use structured data from the accessibility/view hierarchy.

#### Step 1: Get Structured UI Data (Primary Method)

Always use `describe_ui` to get precise frame coordinates:

```text
mcp__XcodeBuildMCP__describe_ui
```

This returns JSON with exact frame data for every visible element:

```json
{
  "type": "Button",
  "frame": { "x": 16, "y": 120, "width": 343, "height": 44 },
  "accessibilityLabel": "Submit"
}
```

**Use this data to:**

- Calculate exact padding: `element2.y - (element1.y + element1.height)`
- Verify alignment: compare `x` values across elements
- Check consistent sizing: compare `width`/`height` values
- Detect centering issues: `(containerWidth - elementWidth) / 2 == element.x`

#### Step 2: Screenshots for Context (Secondary)

Use screenshots to understand the overall visual state, but NOT for measurements:

```text
mcp__XcodeBuildMCP__screenshot        # Visual reference
mcp__ios-simulator__ui_view           # Compressed screenshot
```

#### Step 3: Accessibility Tree for Element Discovery

```text
mcp__ios-simulator__ui_describe_all   # Full accessibility tree
mcp__ios-simulator__ui_describe_point # Element at specific coordinates
```

### Build and Run Commands

```text
mcp__XcodeBuildMCP__build_sim         # Build for simulator
mcp__XcodeBuildMCP__build_run_sim     # Build and launch
mcp__XcodeBuildMCP__launch_app_sim    # Launch already-built app
mcp__XcodeBuildMCP__stop_app_sim      # Stop running app
```

### UI Interaction

When interacting with the simulator, ALWAYS get coordinates from `describe_ui` first:

```text
mcp__XcodeBuildMCP__tap               # Tap by coordinates, id, or label
mcp__XcodeBuildMCP__swipe             # Swipe gesture
mcp__XcodeBuildMCP__type_text         # Type text input
mcp__XcodeBuildMCP__gesture           # Preset gestures (scroll-up, scroll-down, etc.)
```

**Preferred tap approach:**

```text
mcp__XcodeBuildMCP__tap with label="Submit"   # By accessibility label (best)
mcp__XcodeBuildMCP__tap with id="submitBtn"   # By accessibility ID
mcp__XcodeBuildMCP__tap with x=100 y=200      # By coordinates (use describe_ui first!)
```

### UI Verification Checklist

When asked to verify UI or check for issues:

1. **Run `describe_ui`** to get the view hierarchy with frames
2. **Analyze frame data mathematically:**
   - Are horizontal paddings consistent? (check `x` values)
   - Are vertical spacings consistent? (calculate gaps between elements)
   - Are elements properly sized? (check `width`/`height`)
   - Are elements centered? (calculate: `(parent.width - child.width) / 2`)
3. **Take a screenshot** only for overall visual context
4. **Report findings with exact pixel values**, not visual estimates

### Example: Checking Button Alignment

**Wrong approach:**

> "Looking at the screenshot, the buttons appear roughly aligned"

**Correct approach:**

> "From describe_ui:
>
> - Button1 frame: x=16, width=343
> - Button2 frame: x=16, width=343
> - Both buttons have identical x position (16px from left) and width (343px)
> - Buttons are properly aligned"

### Example: Checking Vertical Spacing

**Wrong approach:**

> "The spacing between items looks consistent"

**Correct approach:**

> "Calculating spacing from frame data:
> Item1: y=100, height=44 -> bottom edge at y=144.
> Item2: y=160 -> gap = 160 - 144 = 16px.
> Item2: y=160, height=44 -> bottom edge at y=204.
> Item3: y=220 -> gap = 220 - 204 = 16px.
> Spacing is consistent at 16px."

### Session Defaults

Set session defaults to avoid repeating configuration:

```text
mcp__XcodeBuildMCP__session-set-defaults
  - workspacePath or projectPath
  - scheme
  - simulatorId or simulatorName
```

### Video Recording

```text
mcp__XcodeBuildMCP__record_sim_video with start=true
# ... perform interactions ...
mcp__XcodeBuildMCP__record_sim_video with stop=true outputFile="/path/to/video.mp4"
```

### Log Capture

```text
mcp__XcodeBuildMCP__start_sim_log_cap with bundleId="com.example.app"
# ... use the app ...
mcp__XcodeBuildMCP__stop_sim_log_cap with logSessionId="<id>"
```

### Common UI Issues to Check

1. **Inconsistent padding** - Compare `x` values across similar elements
2. **Misaligned elements** - Elements that should align should have matching `x` or `y`
3. **Incorrect tap target size** - Buttons/tappables should be >= 44px in height/width
4. **Overlapping elements** - Check if any frames intersect unexpectedly
5. **Off-screen elements** - Check if any elements have negative coords or exceed screen bounds

---

## Performance Profiling with Xcode Instruments

### Key Instruments

| Tool           | Purpose                            | Target Threshold          |
| -------------- | ---------------------------------- | ------------------------- |
| Time Profiler  | CPU usage, identify slow functions | <80% CPU sustained        |
| Allocations    | Memory allocation patterns         | <50MB per process         |
| Leaks          | Memory leak detection              | 0 leaks                   |
| Core Animation | UI rendering, frame rate           | 60 FPS (16.67ms/frame)    |
| Energy Log     | Battery consumption                | Minimize background usage |

### Profiling Best Practices

1. **Always use Release configuration** - Debug builds distort timing
2. **Disable debug options** - Turn off Main Thread Checker during profiling
3. **Test on real devices** - Simulator performance can deviate by up to 30%
4. **Focus on functions >10% CPU time** in Time Profiler

### Running Instruments

```bash
# From command line
xcrun instruments -t "Time Profiler" -D output.trace YourApp.app

# Or use Xcode: Product → Profile (⌘I)
```

### Performance Targets

- **App launch:** <400ms to first frame
- **Frame rate:** 60 FPS (16.67ms per frame)
- **Scroll jank:** No dropped frames during scrolling
- **Memory:** Stay within system limits for device class

---

## Memory Management & ARC

### How ARC Works

- ARC (Automatic Reference Counting) manages memory at compile-time
- Objects deallocate when reference count reaches zero
- More predictable than garbage collection

### Retain Cycles

Retain cycles occur when objects hold strong references to each other:

```swift
// BAD: Retain cycle
class Parent {
    var child: Child?
}
class Child {
    var parent: Parent?  // Strong reference creates cycle
}

// GOOD: Break cycle with weak
class Child {
    weak var parent: Parent?  // Weak reference
}
```

### Reference Types

| Type    | Increases Ref Count | Nil on Dealloc | When to Use                       |
| ------- | ------------------- | -------------- | --------------------------------- |
| strong  | Yes                 | N/A            | Default, ownership                |
| weak    | No                  | Yes            | Delegates, parent references      |
| unowned | No                  | No (crashes)   | Only when certain object outlives |

### Common Leak Sources

1. **Closures capturing self:**

   ```swift
   // BAD
   apiClient.fetch { result in
       self.handle(result)  // Strong capture
   }

   // GOOD
   apiClient.fetch { [weak self] result in
       self?.handle(result)
   }
   ```

2. **Delegate patterns:**

   ```swift
   weak var delegate: MyDelegate?  // Always weak
   ```

3. **NotificationCenter observers:**

   ```swift
   // Use [weak self] in observer closures
   NotificationCenter.default.addObserver(
       forName: .someNotification,
       object: nil,
       queue: .main
   ) { [weak self] _ in
       self?.handleNotification()
   }
   ```

4. **SwiftUI ObservableObjects:**
   - Views are structs (no ARC issues)
   - But @StateObject/@ObservedObject classes can leak
   - Always use `[weak self]` in closures within ObservableObject

### Debugging Memory Issues

1. **Memory Graph Debugger** (Xcode): Debug → Debug Memory Graph
2. **Instruments Leaks**: Profile → Leaks template
3. **Implement deinit** to verify deallocation:

   ```swift
   deinit {
       print("\(Self.self) deallocated")
   }
   ```

---

## Swift Concurrency (async/await)

### Three-Phase Approach

1. **Phase 1:** Single-threaded, synchronous code
2. **Phase 2:** Async code without parallelism (async/await)
3. **Phase 3:** Parallel execution with structured concurrency

### Key Concepts

- `await` **yields** the thread, doesn't block it
- Just marking a function `async` doesn't make it parallel
- Must explicitly use `async let` or `TaskGroup` for parallelism

### Parallelization Patterns

**Known, finite tasks - use `async let`:**

```swift
async let image = loadImage()
async let metadata = loadMetadata()
async let comments = loadComments()

let result = await (image, metadata, comments)
```

**Dynamic number of tasks - use `TaskGroup`:**

```swift
await withTaskGroup(of: Image.self) { group in
    for url in urls {
        group.addTask { await loadImage(from: url) }
    }
    for await image in group {
        images.append(image)
    }
}
```

### Best Practices

1. **Keep Main Actor for UI only** - Offload work to background
2. **Use actors for shared mutable state** - Thread-safe by design
3. **Prefer async/await over GCD** - Avoids callback hell, thread explosion
4. **Support cancellation** - Check `Task.isCancelled`
5. **Use Sendable** - Swift 6 enforces data race safety at compile time

### I/O vs CPU-bound Work

- **I/O-bound** (network, disk): `async/await` works great
- **CPU-bound** (image processing): Must explicitly move to background:

  ```swift
  await Task.detached(priority: .userInitiated) {
      processImage()
  }.value
  ```

---

## Data Persistence

### When to Use Each

| Approach     | Use Case                               | iOS Version |
| ------------ | -------------------------------------- | ----------- |
| SwiftData    | New apps, simple-moderate data needs   | iOS 17+     |
| Core Data    | Complex apps, heavy migrations, legacy | iOS 3+      |
| UserDefaults | Small preferences, settings            | iOS 2+      |
| Keychain     | Sensitive data (passwords, tokens)     | iOS 2+      |
| File System  | Documents, large files, exports        | iOS 2+      |

### SwiftData (Recommended for new projects)

```swift
@Model
class Item {
    var name: String
    var createdAt: Date

    init(name: String) {
        self.name = name
        self.createdAt = .now
    }
}
```

**Advantages:**

- Native Swift syntax with @Model macro
- Automatic change tracking
- Seamless SwiftUI integration
- Automatic lightweight migrations

**Limitations:**

- iOS 17+ only
- No heavyweight/custom migrations yet
- Slightly slower than Core Data for large datasets

### Core Data (For complex needs)

Still the best choice when you need:

- Complex relationships and constraints
- Heavyweight migrations
- NSFetchedResultsController
- Maximum performance with large datasets

---

## Testing Best Practices

### Test Organization

```text
MyAppTests/           # Unit tests
  Models/
  ViewModels/
  Services/
MyAppUITests/         # UI tests
  Flows/
  Screens/
```

### XCTest Structure

```swift
class MyViewModelTests: XCTestCase {
    var sut: MyViewModel!  // System Under Test

    override func setUp() {
        super.setUp()
        sut = MyViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_whenCondition_shouldExpectedBehavior() {
        // Given
        let input = "test"

        // When
        let result = sut.process(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### Test Naming Convention

```swift
func test_<methodOrScenario>_<expectedBehavior>() {
    // Given: Setup
    // When: Action
    // Then: Assertions
}
```

### What to Test

- **Services**: API calls, data transformations, error handling, fallback logic
- **ViewModels**: State changes, user action handling
- **Models**: Computed properties, validation logic
- **Utilities**: Helper functions, formatters

### XCTest Tips

1. **Don't unit test UIKit/SwiftUI directly** - Extract logic to ViewModels
2. **One assertion per test** when possible - Clearer failure messages
3. **Use descriptive names:** `test_whenX_shouldY`
4. **Eliminate flakiness:** No random data, no timing dependencies
5. **Test on multiple devices** - Both simulators and real hardware
6. **Run tests in parallel** for speed

### XCUITest for UI Testing

```swift
func testLoginFlow() {
    let app = XCUIApplication()
    app.launch()

    app.textFields["email"].tap()
    app.textFields["email"].typeText("test@example.com")

    app.secureTextFields["password"].tap()
    app.secureTextFields["password"].typeText("password123")

    app.buttons["Login"].tap()

    XCTAssertTrue(app.staticTexts["Welcome"].waitForExistence(timeout: 5))
}
```

### Code Coverage

- Aim for high coverage but prioritize defect detection over metrics
- Focus on critical paths and edge cases
- Regularly refactor tests to remove duplication

---

## Error Handling

### Swift Error Types

| Method        | Use Case                                   |
| ------------- | ------------------------------------------ |
| throws        | Recoverable errors, sync functions         |
| async throws  | Recoverable errors, async functions        |
| Result<T, E>  | When you need to pass errors around        |
| Optional      | When nil is a valid "no value" response    |
| fatalError()  | Programmer errors that should never happen |
| assert()      | Debug-only checks                          |
| precondition()| Release checks for programmer errors       |

### Error Handling Best Practices

1. **Use custom Error enums:**

   ```swift
   enum NetworkError: Error {
       case noConnection
       case invalidResponse(statusCode: Int)
       case decodingFailed(underlying: Error)
   }
   ```

2. **Propagate errors to appropriate level:**

   ```swift
   func loadUser() throws -> User {
       let data = try fetchData()  // Propagates
       return try decode(data)
   }
   ```

3. **Use `try?` for optional results:**

   ```swift
   if let user = try? loadUser() {
       // Handle success
   }
   ```

4. **Avoid `try!`** except when failure is truly impossible

5. **Swift 6 Typed Throws:**

   ```swift
   func load() throws(NetworkError) -> Data {
       // Compiler enforces error type
   }
   ```

---

## Accessibility

### Minimum Requirements

1. **VoiceOver support** - All interactive elements need labels
2. **Dynamic Type** - Support text scaling
3. **Sufficient contrast** - 4.5:1 for normal text, 3:1 for large text
4. **Touch targets** - Minimum 44×44 points

### Implementation

```swift
Button("Submit") {
    submit()
}
.accessibilityLabel("Submit form")
.accessibilityHint("Double tap to submit your information")
```

### Testing Tools

| Tool                    | Purpose                                 |
| ----------------------- | --------------------------------------- |
| Accessibility Inspector | Xcode tool for checking labels/traits   |
| VoiceOver               | Test actual screen reader experience    |
| XCTest accessibility    | Automated accessibility checks in tests |

---

## App Store Review Checklist

### Common Rejection Reasons

1. **Performance issues** (~25% of rejections)
   - Crashes, broken flows
   - Unresponsive UI

2. **Privacy violations**
   - Missing privacy policy
   - Unclear data collection disclosure
   - No account deletion option

3. **Incomplete apps**
   - Placeholder text
   - Broken links
   - "Beta" or "0.1" version numbers

4. **Metadata mismatches**
   - Screenshots don't match app
   - Pricing inconsistencies

### Pre-Submission Checklist

- [ ] App doesn't crash on launch or during main flows
- [ ] All links work (privacy policy, terms, support)
- [ ] Privacy policy accessible within app
- [ ] Account deletion option available (if accounts exist)
- [ ] No placeholder text or images
- [ ] Screenshots match current app version
- [ ] Version number looks production-ready (1.0+)
- [ ] All IAP prices match metadata
- [ ] Test on clean device/simulator
- [ ] Provide demo credentials in App Review Notes

---

## Code Review Checklist

When reviewing Swift/iOS code:

### Architecture

- [ ] Single Responsibility Principle followed
- [ ] Dependencies injected (not hardcoded)
- [ ] Prefer Composition over inheritance
- [ ] ViewModels/logic separate from Views

### Memory

- [ ] No retain cycles (`[weak self]` in closures)
- [ ] Delegates are weak references
- [ ] Large objects released when not needed

### Concurrency

- [ ] Heavy work off main thread
- [ ] UI updates on main thread
- [ ] Proper use of async/await or actors
- [ ] Cancellation supported where appropriate

### Error Handling

- [ ] Errors handled appropriately
- [ ] No force unwraps (`!`) without justification
- [ ] User-facing errors have clear messages

### UI/UX

- [ ] Touch targets >= 44pt
- [ ] Supports Dynamic Type
- [ ] Works in both orientations
- [ ] Accessibility labels present
- [ ] Follows design system tokens

### Testing

- [ ] Unit tests for business logic
- [ ] UI tests for critical flows
- [ ] Edge cases covered

