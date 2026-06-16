# Agent Skills for HanaUta/Kantabi

These are the core expertise modules "installed" for this project. All AI agents must adhere to these patterns.

## 1. Architectural Skill: Clean Feature-First
- **Pattern**: Domain -> Data -> Presentation.
- **Rule**: Never allow `presentation` (Widgets/Notifiers) to depend on `data` implementations. Always go through `domain` abstract classes/interfaces.
- **State**: Use `@riverpod` functional generation exclusively.

## 2. Linguistic Skill: JLPT Calibration
- **Context**: The app is a linguistic analyzer.
- **Rule**: Strictly adhere to JLPT N5-N1 classifications. If a Kanji or word is historically N2, do not let the AI "guess" it is N3 for simplicity. 
- **Skill**: Verify and calibrate all linguistic prompts against established JLPT standards.

## 3. UI/UX Skill: Premium Aesthetics
- **Style**: "Delicate, clean, slightly feminine" (HanaUta theme).
- **Tooling**: Use custom `ThemeData`, Google Fonts (Outfit, Noto Sans JP), and micro-animations to maintain a premium feel.
- **Rule**: No generic Material "defaults." Every component should feel bespoke.

## 4. Multi-Context AI Skill
- **Awareness**: Differentiate between `lyrics_anki_app` (Firebase AI) and `kantabi` (On-device AI).
- **Pattern**: Ensure AI logic is swappable by maintaining a clean `LyricsRepository` interface.

## 5. Development Skill: Ponytail (Lazy Senior Developer Mode)
- **Philosophy**: "The best code is the code you never wrote." Focus on YAGNI and efficiency.
- **Checklist**: Before writing code, evaluate tasks against the Ponytail Ladder:
  1. Does this need to be built at all? (YAGNI/Speculative need = skip it).
  2. Does the standard library already do this? (Use it).
  3. Does a native platform feature cover it? (Use it).
  4. Does an already-installed dependency solve it? (Use it).
  5. Can this be one line? (Make it one line).
  6. Only then: write the minimum code that works.
- **Rules**:
  - Favor deletion over addition. Boring over clever. Fewest files possible.
  - Question complex requests: "Do you actually need X, or does Y cover it?"
  - Pick the edge-case-correct option when two stdlib/platform approaches are similar size; lazy means less code, not fragile code.
  - **No Laziness on Quality**: Do not take shortcuts on security, error handling for data loss, input validation at boundaries, or accessibility.
- **Debt Tracking**: When taking deliberate shortcuts, mark them with a comment: `// ponytail: [short explanation of shortcut & upgrade path]` or `# ponytail: [explanation]`. Run `scripts/ponytail_debt.sh` to scan and report deferred items.

