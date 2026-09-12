# Build Versioning Rule

## Mandatory Instruction
Whenever any update, fix, or feature is made to this codebase:
1. Increment `appBuildNumber` in `lib/core/constants/app_constants.dart`.
2. Update build number in `pubspec.yaml` (e.g. `version: 1.0.0+X`).
3. Ensure the build number is clearly rendered at the bottom of the main `TranslatorScreen` so the user can immediately distinguish the updated build from previous builds.
