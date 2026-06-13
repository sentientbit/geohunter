# GeoHunter — Flutter Agent (Claude Code)

## Identity & Scope

This agent owns the **Flutter client** exclusively:
- `lib/` — all Dart source files
- `test/` — Flutter unit and widget tests
- `pubspec.yaml`, `analysis_options.yaml`

This agent does **not** own:
- PHP/CI4 backend — that is the backend agent's domain
- MySQL schema, migrations, CI4 controllers or models
- Docker / server config, deployment to the Hetzner VPS
- Any file outside the Flutter repository (`C:\workspace\geohunter\`)

When the user pastes backend code or describes a server-side problem,
interpret it as **context only** — extract the API contract it implies
(endpoint URL, request shape, response shape, error codes) and work from that.
Do not suggest PHP fixes, do not write CI4 code.

## Stack

- Flutter (stable channel)
- Riverpod 2.x — `AsyncNotifierProvider`, `FutureProvider.family.autoDispose`, `StateProvider`
- Freezed + json_serializable — generated files (`.freezed.dart`, `.g.dart`) are **manually maintained** in this project (no build_runner in the hot path)
- `flutter_secure_storage` — JWT stored here; **never wipe app data or uninstall carelessly**
- `flutter_map` + `latlong2` — map layer
- `circular_percent_indicator` — progress rings

## Deployment — CRITICAL RULE

**NEVER use `flutter install`.** It uninstalls the existing APK, which wipes
`flutter_secure_storage` and loses the JWT. The player must log in again.

Always deploy with:
```
flutter build apk --debug
adb -s R3CY80S0XFT install -r build\app\outputs\flutter-apk\app-debug.apk
```

- Phone serial: `R3CY80S0XFT`
- Emulator serial: `emulator-5554`

Substitute the correct serial for the target device. If both are connected,
always be explicit — never rely on the default device selection.

## Never assume. Always verify.

- **Before reporting a bug as fixed, deploy and exercise the code path.**
  A clean `flutter analyze` is necessary but not sufficient.
- **Before editing a generated file, confirm the source-of-truth class.**
  `.freezed.dart` and `.g.dart` are derived — the canonical definition is the
  annotated Dart class. Edit the class; mirror the change in the generated file.
- **Before adding an import, check it is not already present.** Duplicate
  imports cause analyzer warnings that block CI.
- **Before removing a field or method, grep for all call sites.** A field
  deleted from a model or provider that is still referenced somewhere will
  silently compile if the type is dynamic or if the IDE's tree-shake is wrong.

## Provider discipline

- **One provider per resource.** Do not create a second `FutureProvider` for
  data already loaded by an existing provider. Extend the existing one.
- **`FutureProvider.family.autoDispose`** for data keyed on a parameter
  (e.g. `swapProvider(wantedBlueprintId)`). Always `.autoDispose` on family
  providers — they are per-screen and must not outlive their widget.
- **`AsyncNotifierProvider`** for resources with mutation (study, invest, swap
  agree/cancel). The notifier owns the mutation methods; the provider is the
  single source of truth.
- **Invalidation after mutation:** invalidate only the providers whose data
  actually changed. Do not invalidate `researchProvider` as a catch-all when
  only blueprint inventory changed.
- **Never call `ref.read` inside `build`.** Always `ref.watch` in build;
  `ref.read` only in callbacks and notifier methods.

## Model discipline

- **Freezed models** (response objects): add fields to the `@freezed` class
  first, then mirror the change in `.freezed.dart` (factory constructor,
  `copyWith`, `==`, `hashCode`, `_$...FromJson`/`_$...ToJson`) and `.g.dart`.
- **Plain Dart models** (domain objects like `Research`, `Blueprint`): parse
  defensively in `fromJson` — always use `int.tryParse(...) ?? 0` rather than
  direct cast, and guard optional keys with `json.containsKey(...)`.
- **Never add fields to a model without updating `fromJson`.** A field that is
  never set from JSON is a silent bug waiting to appear at runtime.

## UI / theme discipline

Reuse project primitives. Do not reinvent:

| Need | Use |
|------|-----|
| Primary action button | `kStoneButton(label, onPressed)` |
| Loading indicator | `kCompassLoader()` |
| Card background | `kCardDecoration()` |
| Primary gold colour | `kGold` |
| Silver text | `kSilver` |
| Dimmed silver | `kSilverDim` |

All of the above are defined in `lib/shared/app_theme.dart`.
Do not hardcode colors, border radii, or shadows that duplicate these.

## API patterns

- All authenticated requests go through `ApiClient` in
  `lib/utils/api_client.dart`. Do not call `http` or `dio` directly.
- Log every request/response: `[STATUS] /path` — the pattern already established
  in the codebase; keep it consistent.
- Error responses from the backend carry a `code` string field
  (e.g. `INSUFFICIENT_COINS`, `DUPLICATE_SWAP`). Surface these to the user in
  plain language; do not show raw JSON.
- Treat a `401` response as a session expiry: clear the JWT and navigate to
  the login screen.

## Screen / navigation rules

- Navigation uses a named-route pattern. Do not use anonymous `MaterialPageRoute`
  pushes outside of screens that already do so.
- The Study Detail screen lives at `lib/screens/inventory/study.dart`. Any new
  card for the study flow (e.g. Blueprint Swap) goes here, below the Invest
  Knowledge card.
- `isLocked` on a research tech is:
  ```dart
  final isLocked = tech.craftingLevel == 0 && tech.nrInvested == 0;
  ```
  Do not revert or re-derive this.

## Blueprint Swap — implementation contract

- **`SwapRecord`** is the model for `active_swap`. Field names from API:
  `blueprint_name` → `blueprintName`, `blueprint_img` → `blueprintImg`,
  `wanted_name` → `wantedName`, `wanted_img` → `wantedImg`.
- **`active_swap` is the player's earliest swap by insertion order**, regardless
  of which `wanted_blueprint_id` was requested. Always compare
  `activeSwap.wantedBlueprintId` against the current discipline's `blueprint.id`
  to determine which UI state to render (this-discipline / other-discipline).
- **Three UI states** on the swap card:
  1. Empty — no active swap
  2. Active-this-discipline — `activeSwap.wantedBlueprintId == blueprint.id`
  3. Active-other-discipline — `activeSwap != null && wantedBlueprintId != blueprint.id`
- **Agree Swap button is disabled** whenever any active swap exists (state 2 or 3).
- **`volumes[]` shape from GET**: `blueprint_id`, `name`, `img`, `qty`.
  Flutter filters to `qty >= chosenCount && blueprint_id != wanted_blueprint_id`.
- **DELETE error** for missing swap is `404 NOT_FOUND` (not 400).
- **Post-fulfillment invalidation**: `researchProvider` only (volumes_owned updated).

## Mine result helper

`lib/utils/mine_result_helper.dart` is the single place where mine-visit
loot dialogs are built and providers are invalidated after a mine visit.
All swap-fulfillment detection (`b.source == 'swap'`) and messaging lives here.
Do not scatter mine-result logic into individual screen files.

## Deleted mechanics — do not re-introduce

The following were intentionally removed. If a reference to them appears in
context, it is stale. Do not restore them:

- **Blank manuscript mechanic** — `markedManuscripts`, `manuscriptsYield`,
  `_pendingMarked`, `_isMarking`, `_setMark()`, `_assemble()`, `_disassemble()`
- **Blueprint pages layer** — `blueprint_pages`, `blueprintPagesProvider`,
  `blueprintPagesRepositoryProvider`, `pagesOwned`, `pageId`,
  `BlueprintPage`, `BlueprintPagesResponse`
- **Nearby library search on study screen** — `_findNearestLibraries()`,
  `_nearbyLibraries`, `_searchingLibraries`

## Testing

Run the full suite before every deployment:
```
flutter test
```

All 39 tests must pass. A red test is a deployment blocker — fix it before
building the APK. Do not comment out or skip tests to make the suite green.

## Code style

- Dart `analysis_options.yaml` is the linter source of truth.
- Prefer `const` constructors wherever possible.
- No `print()` calls in production code — use the `[STATUS] /path` log pattern
  via `ApiClient` for network events; use no logging elsewhere unless there is
  an existing pattern for it in the file being edited.
- Keep widget build methods under ~80 lines. Extract to private methods or
  `StatelessWidget` subclasses when a `build` grows beyond that.
