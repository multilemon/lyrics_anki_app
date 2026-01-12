---
trigger: always_on
---

# HanaUta Project Instructions

## 1. Architectural Patterns

- **Standard**: Feature-first Clean Architecture (domain, data, presentation).
- **State Management**: Riverpod 3.0+ using ONLY functional `@riverpod` code generation.
- **Database**: Hive Community Edition (hive_ce) for local persistence.
  - **Reason**: Hive provides stable, native support for Flutter Web without external JS/Wasm dependencies, avoiding Isar's current dependency conflicts.
- **Models**: Use `@freezed` and `json_serializable` for all entities and data models.

## 2. Gemini AI Integration

- **Model**: `models/gemini-flash-latest` (Gemini 2.5).
- **SDK**: Use `firebase_ai` (since google_generative_ai is deprecated).
- **Data Format**: Strictly follow the minified JSON (Array-of-Arrays) mapping defined in `AI_STUDIO_INSTRUCTION.md`.
- **Default Target Language**: **English**. (The AI should provide results in English unless the user selects another language).

## 3. UI/UX Style

- **Aesthetic**: Delicate, clean, and slightly feminine feel (soft pastel colors, rounded corners).
- **Language**: All UI labels, buttons, hints, and navigation must be in **English**.
- **Home View Layout**: Must feature a 3-field input card:
  1. **Song Title** (TextField)
  2. **Artist Name** (TextField)
  3. **Target Language** (Dropdown, default: English).

## 4. Platform Specifics (Mobile Web App)

- **Deployment**: Optimized for Flutter Web (initially for GitHub Pages/Firebase Hosting).
- **Data Persistence**: Use Hive's web-compatible storage.
- **Export**: Priority on **TSV File Download** for Anki instead of native Android/iOS intents during the web phase.

## 5. Code Style & Formatting (Strict)

- **Trailing Commas**: ALWAYS include a trailing comma for arguments, parameters, and collection elements that span multiple lines. This is mandatory to satisfy the Dart Linter and ensure clean diffs.
- **Formatting**: Use the official Dart formatter (`dart format`) standards.
- **Lint Rules**: Follow `package:flutter_lints` or `package:lints` recommended rules.
