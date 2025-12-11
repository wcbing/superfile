# Nestif Linter Remediation Plan

## Overview
The `nestif` linter reports deeply nested if statements that make code hard to read and maintain. Currently there are **11 issues** with complexity ranging from 5-7.

## Current Issues Summary
```
1. src/internal/common/load_config.go:28 - complexity: 5
2. src/internal/common/load_config.go:112 - complexity: 5  
3. src/internal/config_function.go:101 - complexity: 5
4. src/internal/handle_modal.go:173 - complexity: 5
5. src/internal/handle_panel_movement.go:34 - complexity: 6
6. src/internal/handle_panel_up_down.go:65 - complexity: 5
7. src/internal/model.go:269 - complexity: 5
8. src/internal/model_render.go:218 - complexity: 7 (highest)
9. src/internal/ui/preview/model.go:240 - complexity: 6
10. src/internal/ui/prompt/model.go:132 - complexity: 7 (highest)
11. src/internal/ui/prompt/tokenize.go:30 - complexity: 5
```

## Refactoring Strategies

### Strategy 1: Early Return Pattern
Replace nested if-else with early returns to reduce nesting levels.

**Before:**
```go
if condition1 {
    if condition2 {
        if condition3 {
            // do something
        }
    }
}
```

**After:**
```go
if !condition1 {
    return
}
if !condition2 {
    return
}
if !condition3 {
    return
}
// do something
```

### Strategy 2: Extract Helper Functions
Move nested logic into separate functions with descriptive names.

### Strategy 3: Switch Statements
For multiple conditions on same variable, use switch instead of nested ifs.

### Strategy 4: Guard Clauses
Use guard clauses at the beginning to handle edge cases.

## Detailed Fix Plan

### Phase 1: High Complexity Issues (complexity 7)

#### 1. src/internal/model_render.go:218 (renderClipboardRender)
**Problem:** Deep nesting in clipboard rendering with empty check, loop, error handling, and file info checks.

**Solution:**
```go
func (m *model) renderClipboardContent() string {
    if len(m.copyItems.items) == 0 {
        return m.renderEmptyClipboard()
    }
    return m.renderClipboardItems()
}

func (m *model) renderEmptyClipboard() string {
    r := utils.NewPageRender(m.footerWidth(), m.footerHeight+common.BorderPadding)
    r.AddLines("", " "+icon.Error+"  No content in clipboard")
    return r.Render()
}

func (m *model) renderClipboardItems() string {
    r := utils.NewPageRender(m.footerWidth(), m.footerHeight+common.BorderPadding)
    itemsToRender := min(len(m.copyItems.items), m.footerHeight)
    
    for i := 0; i < itemsToRender; i++ {
        r.AddLines(m.formatClipboardItem(i))
    }
    return r.Render()
}

func (m *model) formatClipboardItem(index int) string {
    // Extract item formatting logic
}
```

#### 2. src/internal/ui/prompt/model.go:132 (Render method)
**Problem:** Nested logic for shell mode vs SPF mode, hint sections, and command matching.

**Solution:**
```go
func (m *Model) Render() string {
    r := utils.NewPageRender(m.width, m.height)
    // ... header code ...
    
    m.renderModeHints(&r)
    m.renderResultMessage(&r)
    
    return r.Render()
}

func (m *Model) renderModeHints(r *utils.PageRender) {
    if m.shellMode {
        m.renderShellModeHints(r)
    } else {
        m.renderSPFModeHints(r)
    }
}

func (m *Model) renderSPFModeHints(r *utils.PageRender) {
    if m.textInput.Value() == "" {
        r.AddSection()
        r.AddLines(" '" + m.shellPromptHotkey + "' - Get into Shell mode")
        return
    }
    
    m.renderMatchingCommands(r)
}
```

### Phase 2: Medium Complexity Issues (complexity 6)

#### 3. src/internal/handle_panel_movement.go:34 (enterPanel)
**Problem:** Directory check with nested symlink resolution and path operations.

**Solution:**
- Extract `resolveSymlinkIfNeeded()` function
- Use early return for non-directories
- Simplify the main flow

#### 4. src/internal/ui/preview/model.go:240
**Problem:** Format checking with nested preview type handling.

**Solution:**
- Use switch statement for format types
- Extract each format handler to separate function

### Phase 3: Standard Complexity Issues (complexity 5)

#### 5. src/internal/common/load_config.go:28
**Fix:** Extract theme loading error handling

#### 6. src/internal/common/load_config.go:112
**Fix:** Use early returns for config writing errors

#### 7. src/internal/config_function.go:101
**Fix:** Extract path validation to separate function

#### 8. src/internal/handle_modal.go:173
**Fix:** Simplify help menu cursor movement

#### 9. src/internal/handle_panel_up_down.go:65
**Fix:** Extract panel boundary calculation

#### 10. src/internal/model.go:269
**Fix:** Simplify footer toggle conditions

#### 11. src/internal/ui/prompt/tokenize.go:30
**Fix:** Extract bracket matching logic

## Implementation Order

1. **Phase 1:** Fix 2 highest complexity issues first (complexity 7)
2. **Phase 2:** Fix 2 medium complexity issues (complexity 6)
3. **Phase 3:** Fix remaining 7 standard issues (complexity 5)

## Testing Strategy

After each refactoring:
1. **Compile:** `go build -o bin/spf ./src/cmd`
2. **Unit tests:** `go test ./...` for affected package
3. **Lint check:** `golangci-lint run --enable=nestif`
4. **Manual testing:**
   - Clipboard operations (copy/paste)
   - Prompt mode switching (shell/SPF)
   - Directory navigation
   - File preview functionality
   - Help menu navigation

## Expected Outcome

- **All 11 nestif issues resolved**
- **Improved code quality:**
  - Flatter, more readable structure
  - Smaller, focused functions
  - Better separation of concerns
- **Better maintainability:**
  - Easier to understand
  - Easier to test
  - Easier to modify

## Estimated Effort

- **Phase 1 (2 files, complexity 7):** 2-3 hours
- **Phase 2 (2 files, complexity 6):** 1-2 hours  
- **Phase 3 (7 files, complexity 5):** 2-3 hours
- **Testing & verification:** 1 hour
- **Total:** 6-9 hours

## Benefits

1. **Improved Readability:** Flatter code is easier to scan and understand
2. **Better Testability:** Extracted functions can be unit tested in isolation
3. **Reduced Cognitive Load:** Less mental state tracking while reading code
4. **Easier Debugging:** Simpler control flow makes bugs easier to locate
5. **Lower Maintenance Cost:** Future changes are easier and safer to implement

## Notes

- Some refactoring may slightly increase line count but significantly improves readability
- Focus on clarity over brevity
- Maintain existing functionality - this is pure refactoring
- Consider adding unit tests for newly extracted functions
