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
