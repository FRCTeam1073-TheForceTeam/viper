---
name: viper-mobile-season
description: Port a web scouting season (www/<season>/scout.html, scout.js, scout.css) into the Flutter mobile app as a season module under app/lib/seasons/<season>/. Use when asked to replicate, port, mirror, or build the scouting form for a year or season in the mobile app, add a season to the Flutter app, or check that the mobile form matches the web form for a season.
---

Ports one web scouting season into the Flutter app. The web form is the spec. The extractor inventories it, and the Flutter season modules for `2026` and `2025-26` are the templates.

All paths are relative to the repo root, the directory that contains `.agents/`. The Flutter app is in `app/`.

## Season keys

The season key is the web folder name, the event ID prefix, and the Flutter folder name, all the same string:

- FRC: four digits, e.g. `2026`
- FTC: two years, e.g. `2025-26`

A season key does not guarantee the same game on both sides. Check the existing mobile module's fields against the web folder before you copy from it. Never copy one season's module into another season's folder.

## Step 1: Inventory the web season

```bash
node .agents/skills/viper-mobile-season/extract-web-season.mjs 2025-26
```

This prints JSON with these keys:

- `tabs`: the four tabs (`pre`, `auto`, `teleop`, `end`).
- `counters`: one entry per counter, with `name` as written, `section`, `period` (from the `auto_` or `tele_` prefix), `stem` (the rest of the name), and `button` (`image` when the button shows an icon, `text` when it shows a label).
- `checkboxes`: the checkboxes, with the section each sits in and its translation key.
- `textInputs`: hidden fields (`event`, `match`, `team`, `timeline`) and other text inputs in the season HTML.
- `sharedInjected`: fields the shared `www/scout.js` adds to every season's form (`scouter`, `review_requested`, `comments`, `created`, `modified`). They are not in the season HTML, so the static HTML scan misses them.
- `constants`: numeric values from `scout.js`, such as `HELD_MAX` and `AUTO_MS`.
- `seasonScoutJs`: whether the season folder has its own `scout.js`. It is optional.
- `sharedHooks`: the hooks the shared `www/scout.js` provides (`window.onStore`, `window.onInputChanged`, and so on).
- `hooksRegistered`: the hooks this season's `scout.js` registers handlers on.
- `timeouts`, `functions`, `i18nKeys`, `instructionFiles`, `images`.

For `2025-26` the output is 6 counters (3 auto, 3 teleop), 8 checkboxes, and 4 tabs. Check your port against the counts for the season you are porting.

## Step 1b: Find what is unique to this season

Every season has its own nuances, and past seasons are the examples for handling them. Do not assume the previous season is the closest match.

1. List the seasons that have an inventory:

   ```bash
   ls www | grep -E '^20[0-9]{2}(-[0-9]{2})?$'
   ```

   A season folder's `scout.js` is optional. Seasons `2020`, `2021`, and `2022` have none. The extractor still inventories them, but their counter controls are `<img class=count>` elements rather than buttons, so their counters have no `button` type.

2. Diff the season you are porting against each past season. Run it against several, not just one:

   ```bash
   node .agents/skills/viper-mobile-season/extract-web-season.mjs <season> --against <past season>
   ```

   For each kind of item (counters, checkboxes, constants, functions, translation keys, images, tabs, and so on), `onlyIn` lists what the season has and the other does not. `onlyInAgainst` lists the reverse.

3. Treat the `onlyIn` items as candidates for what is unique. For each one, find where it is used in the season's `scout.js` and read what it does. Do not decide from the name alone. The same concept is sometimes renamed between seasons, and the same name is sometimes reused for something different.

4. For each unique item, search the Flutter app for the same kind of behavior, in `app/lib/` and in the existing season modules. If the app already has it, reuse it. If not, the item is new, and it needs its own widget or provider.

5. Items in `onlyInAgainst` are features the season dropped. Do not port them, unless the season you are porting also has them.

6. Keep a list of each unique item and how you handled it. Put that list in your summary to the user.

## Step 2: Read the web behavior the inventory cannot show

The shared `www/scout.js` applies to every season, so read it first. It provides the counter behavior and the hooks. Then read the season's `www/<season>/scout.js` if it has one, and port the rules in it. Rules tend to fall into these kinds, and the inventory's `constants`, `timeouts`, and `functions` lists point at them:

- **Caps and gates.** A counter is blocked at a limit, or enabled only after a certain action. Look for limit constants and functions that toggle `.disabledOverlay`.
- **Timers.** A timing constant sets the auto period, and `setTimeout` calls set delays such as a prompt to move to teleop.
- **Alliance-dependent visuals.** Icons or colors that change with the alliance position in `pos`.
- **Timeline, undo, and the scouter field.** See the next section.

## Evergreen fields and the timeline

These are the same for every season. The shared `www/scout.js` provides most of them, plus the hooks that a season's `scout.js` registers on. The timeline recording, undo, and the scouter save check are registered by the season's `scout.js`, not by the shared file. A season without its own `scout.js` has no timeline recording from the shared file. Port the shared fields once, in shared Flutter code or the season module.

**Evergreen fields**

- `event`, `match`, `team` (hidden). The web reads them from the URL hash: `pos`, `team`, `match`, and the event ID. In Flutter they arrive as props: `eventId`, `matchNumber`, `teamNumber`.
- `scouter` (hidden). The value is one string, `"<team> <name>"`, such as `1234 Pat Q`. `combineScout` builds it from the visible team and name inputs. `parseScout` splits it back apart, and accepts either order (`Pat Q 1234`). The web remembers the last value in `localStorage` (`last_scouter`) and pre-fills it at the start of each scout. In Flutter, `ServerConfig.scouterName` stores it once per device.
- Save check. The season's `scout.js` `onStore` handler blocks saving without a scouter name, unless `no_show` is checked. The message uses the `required_missing` and `scout_name_question` strings.
- `comments` (textarea), `review_requested` (checkbox), `created`, and `modified` (hidden). `setTimeStamps` sets `created` once and `modified` on every save. Both are ISO-8601 UTC with `+00:00`.
- Storage key. The web stores each match under `${eventId}_${match}_${team}`. The CSV header row is stored under `${eventYear}_headers`.
- Flutter CSV. `CsvBuilder` writes headers by converting each camelCase field name to snake_case, and drops `id`, `synced`, and `syncedAt`. So each Flutter field must land on the same snake_case header as its web input. Compare the header row against a web CSV before you call the port done.

**Timeline**

- The recording and undo code is in the season's `scout.js`. Read it there.
- The hidden `timeline` input holds one space-separated string.
- Each entry is `<seconds>:<field>`. For a multi-step tap it is `<seconds>:<field>:<n>`, where `n` is the step size.
- `seconds` is measured from the first recorded tap of the match, and rounded.
- Auto and teleop share one timeline. The period is part of the field name (`auto_*` or `tele_*`).
- Unchecking a checkbox removes its entry from the string.
- Undo (`.undo` click) takes the last entry, removes it, and reverses that field. A counter goes back by `n`, and a checkbox is unchecked. When the timeline is empty, the match timer is reset.

Flutter:

- `app/lib/providers/timeline_provider.dart` defines `TimelineEvent`, with `timeSeconds`, `action` (the field name), and `value` (a string, default `'1'`).
- `TimelineEvent.formatTimeline` and `parseTimeline` implement the same string format as the web.
- `timelineProvider` is shared by the auto and teleop tabs.
- `undoLastAction` in each season's `providers/undo_coordinator.dart` uses the last event's `action` and `value`.

Check the timeline port with a round trip. Parse a web timeline string in Dart, format it again, and compare with the original. Add the test under `app/test/`.

## Step 3: Build the Flutter module

Use this step only when `app/lib/seasons/<season>/` does not exist yet. If it exists, follow Step 3b.

Model it on `app/lib/seasons/2025-26/` and `app/lib/seasons/2026/`. Create `app/lib/seasons/<season>/`:

- `module.dart`: a class that implements `SeasonModule` (`app/lib/seasons/season_module.dart`). Set `season`, `fieldImageAsset`, `autoPeriodMs`, `autoGapMs`, and `botPositions`. Take `botPositions` from the `#select-bot` buttons in `www/<season>/scout.html`.
- `providers/scouting_data_provider.dart`: a `MapDataModel` subclass. Register each counter and checkbox as a descriptor with `FieldDescriptor.createStatic(name: ..., autoValuesTableDescription: ...)` or `teleValuesTableDescription`. Names keep the web's `auto_*` and `tele_*` form.
- `providers/undo_coordinator.dart`: uses `undoLastAction(ref, context, key, getUndoPosition: ...)`, as in `app/lib/seasons/2026/providers/undo_coordinator.dart`.
- `screens/tabs/{pre_match,auto,teleop,end_game}_tab.dart`: one per web tab.
- `widgets/`: the counter table and the field overlay.

Then wire the module in:

1. In `app/lib/seasons/season_registry.dart`, import the module and add `'<season>': <Module class>()` to `seasonModules`.
2. In `app/pubspec.yaml`, add `assets/<season>/images/` and `assets/<season>/scouting-instructions*.md` under `flutter.assets`.
3. Copy the image files the inventory lists under `images` from `www/<season>/` into `app/assets/<season>/images/`. Copy the `scouting-instructions.*.md` files into `app/assets/<season>/`.
4. The field diagram may be missing. If `www/<season>/` has no field image, `fieldImageAsset` needs one. Ask the user for the image before writing that line.
5. Strings: the web keeps season strings in an `addI18n({...})` block in `scout.js`. Port the `i18nKeys` from the inventory with `AppLocalizations.addI18n` in the same way the 2026 module does. Keep the seven language codes: en, fr, pt, zh_tw, tr, he, es.

## Step 3b: Reconcile an existing Flutter module

Use this step when `app/lib/seasons/<season>/` already exists. The job is to bring it in line with the web season's changes. Do not rebuild it.

1. **Find what changed on the web.** Pick the most recent earlier season that has a `scout.html`, using the list from Step 1b. Diff the target against it:

   ```bash
   node .agents/skills/viper-mobile-season/extract-web-season.mjs <season> --against <previous season>
   ```

   The `onlyIn` lists are what the web added. The `onlyInAgainst` lists are what it removed. Use Step 1b to check each change in the web `scout.js`, not just the name.

2. **List what the Flutter module has.** Read its descriptor list in `providers/scouting_data_provider.dart`, its `module.dart` values, its `addI18n` keys, and its assets in `app/pubspec.yaml`. Compare them with the inventory.

3. **Match fields by CSV header, not by name.** Web names are snake_case. Flutter names can be camelCase, and `CsvBuilder` converts camelCase to snake_case. So a field matches when its snake_case name equals the web input name. Check a few by writing the header row, not by name alone.

4. **Sort each difference into one of these:**
   - Web added, Flutter missing: add it, the same way Step 3 adds a field.
   - Web removed, Flutter still has it: remove it, after checking no other code uses it.
   - Both have it, but the rule changed: update the rule in Flutter to match the web change.
   - Flutter has it and the web does not, and the web was never meant to have it: leave it alone and tell the user.

5. **Check the constants and assets too.** Compare `constants` and `timeouts` against `module.dart` values. Compare `images` against `app/assets/<season>/images/`, and the `scouting-instructions` files against `app/assets/<season>/`. Compare `i18nKeys` against the `addI18n` keys.

6. **Review the diff.** Run `git diff -- app/` and check that every change traces back to a line in the reconciliation list. Revert any changes you did not intend.

7. Put the reconciliation list in your summary to the user, with each item and how it was handled.

## Step 4: Verify

Run these from `app/`:

```bash
cd app
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Baseline as of this writing: `flutter analyze` reports one existing warning (`lib/providers/app_providers.dart:232`, `unawaited_return_in_try_block`), and `flutter test` passes all 400 tests. Stop and report any new analyzer issue or test failure. Do not claim the port works until both are clean apart from that baseline warning.

## Gotchas

- **Side effects in tracked files.** `flutter pub get` rewrites `app/pubspec.lock`. `build_runner` can rewrite `app/analysis_options.yaml` by adding analyzer excludes. Check `git status` after running them and restore any file you did not mean to change.
- **Generated files are gitignored.** `*.g.dart` is in `app/.gitignore`. Generated output does not show up in `git status`.
- **Season key collision.** Keep each season's files in its own folder. Never copy one season's module into another season's folder.
- **Counter button labels differ.** Most counter buttons show an image. A counter whose button shows the text `+1` is still a counter. It uses the same click handler and `.num` input as the others. Port it like any other counter, with a text label instead of an image.
- **The `+N` popup is a floater.** After any counter press, `animateChangeFloater` shows the change (`+1`, `-1`) over the button. It is not a control and not a counter. Flutter already has a floating popup mechanism in `app/lib/providers/floating_popup_provider.dart`.

