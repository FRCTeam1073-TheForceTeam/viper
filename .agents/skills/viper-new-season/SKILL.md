# Viper New Season Setup

This skill documents all the development work needed to prepare Viper for a new FRC or FTC season.

## Overview

Each competition season requires a new season-specific directory with customized scouting forms, scoring logic, and documentation. The work involves:
- Creating season directories and files
- Setting up scouting forms tailored to the year's game rules
- Implementing scoring/aggregation logic for the new game
- Creating internationalized documentation
- Updating application references to support the new season

## Directory Naming Conventions

- **FRC seasons**: `/www/YYYY/` (e.g., `/www/2026/`, `/www/2025/`)
- **FTC seasons**: `/www/YYYY-YY/` spanning two calendar years (e.g., `/www/2025-26/`, `/www/2024-25/`)

## Files Required for Each Season

### Required Files
- `scout.html` - Match scouting form for collecting per-match robot performance data
- `scout.js` - JavaScript for match scouting form behavior, validation, and data handling
- `scout.css` - CSS styling for match scouting form
- `aggregate-stats.js` - Defines stat categories, names, and calculations for the game year

### Optional Files
Pit scouting and subjective scouting are optional and should only be created if the team needs them. Ask the user before creating these files:

#### Pit Scouting (Optional)
- `pit-scout.html` - Pit scouting form for pre-competition robot analysis
- `pit-scout.js` - JavaScript for pit scouting form behavior
- `pit-scout.css` - CSS styling for pit scouting form

#### Subjective Scouting (Optional)
- `subjective-scout.html` - Subjective scouting form for qualitative observations
- `subjective-scout.js` - JavaScript for subjective scouting form behavior
- `subjective-scout.css` - CSS styling for subjective scouting form

### Documentation Files (Required)
- `scouting-instructions.md` - English user documentation for scouts
- `scouting-instructions.fr.md` - French translation
- `scouting-instructions.pt.md` - Portuguese translation
- `scouting-instructions.zh_tw.md` - Traditional Chinese translation
- `scouting-instructions.tr.md` - Turkish translation
- `scouting-instructions.he.md` - Hebrew translation

These files supplement the base files (`/www/scout.js`, `/www/pit-scout.js`, `/www/subjective-scout.js`, and corresponding CSS files) with season-specific rules, styles, and scoring logic.

### Statistics & Aggregation
- `aggregate-stats.js` - Defines stat categories, names, and calculations for the game year. Used to label graphs, reports, and analysis dashboards.

## Workflow: Setting Up a New Season

### Phase 1: Understand the File Architecture
Before starting, understand how base and year-specific files work together:

- **Base files** (shared across all seasons):
  - `/scout.js` — Universal form handling, i18n, validation, callbacks, timeline tracking
  - `/scout.css` — Base styling for all forms (buttons, inputs, layout, accessibility)
  - `/pit-scout.js`, `/pit-scout.css` — Base pit scouting infrastructure
  - `/subjective-scout.js`, `/subjective-scout.css` — Base subjective scouting infrastructure
  - NO base `.html` files exist

- **Year-specific files**:
  - **HTML files are completely year-specific** — Each season must have its own full `/YYYY/scout.html`, `/YYYY/pit-scout.html`, `/YYYY/subjective-scout.html`
  - **JavaScript files EXTEND the base** via callbacks — `/YYYY/scout.js` adds game logic to `/scout.js` without duplicating base functionality
  - **CSS files ADD styling** — `/YYYY/scout.css` adds game-specific styling on top of `/scout.css` base styles
  - **aggregate-stats.js is purely game-specific** — `/YYYY/aggregate-stats.js` defines stats and calculations for the game

### Phase 2: Create Directory and Create Files from Template

**Set up the season directory and copy template files** (replace YYYY or YYYY-YY with the actual season):

1. **Create the directory**:
   - Use `create_directory` to create `/www/YYYY/` for FRC or `/www/YYYY-YY/` for FTC

2. **List the template files**:
   - Use `list_dir` to view the files in `/templates/frc-season-template/` or `/templates/ftc-season-template/`

3. **Read each template file**:
   - Use `read_file` to read the content of each template file you need to copy

4. **Create the season files**:
   - Use `create_file` to create each file in the new season directory with the template content as a starting point

### Phase 3: Interactively Design Match Scouting Form

⚠️ **IMPORTANT** — Phase 2 should already be complete (template files created). This phase is about designing what goes INTO those files. Complete ALL 8 steps before implementing any code in Phase 4. Do NOT skip or compress this phase.

**Overview**: You will work interactively with the user through 8 focused design steps. After each step, confirm the information before proceeding. If a user's answer is vague or incomplete, ask clarifying follow-up questions until you have enough detail. Track all decisions in a running design document.

---

#### **Step 1: Collect Game Rules Information**

**Purpose**: Understand the game's fundamental mechanics to determine if counters need to be organized by game element.

**Ask the user**:
> "Let's start with the game pieces. How do game pieces work in this year's game?"

Then follow up with specific questions:
- "How many different types of game pieces are there?" (e.g., "Is it just balls, or are there multiple types like coral and algae?")
- "For each type, how many can a robot hold at once?" (e.g., "Can a robot hold 4 coral at once, or just 1?")
- "Are there storage or capacity limits scouts need to track?" (e.g., "Does a robot have a limited hopper size?")

**How to handle responses**:
- If the user says "it's complicated," ask them to describe one game piece type fully before moving to the next
- If they're unsure about limits, ask them to look up the game rules
- Record exact limits (not approximations) — this affects form validation

**Example recording**:
```
Game Pieces:
- Coral: Robot can hold up to 4 at once
- Algae: Robot can hold up to 1 at once
- Special state: Algae becomes "removed" once placed (scouts need to track)
```

**Checkpoint**: Once you've recorded game pieces and holding limits, summarize it back to the user: *"So I'm understanding the game has coral (max 4) and algae (max 1). Is that right?"* Wait for confirmation before moving to Step 2.

---

#### **Step 2: Collect Pre-Match Data Requirements**

**Purpose**: Understand what data scouts need to enter before the match starts (when there's no time pressure).

**Ask the user**:
> "Before each match starts, what information do scouts need to record?"

**Provide context** with common examples:
- "For example, does the robot start from a specific position on the field? Does a scout need to record that?"
- "Does the scout need to note if the robot has game pieces pre-loaded?"
- "Do we track no-shows (matches where the team didn't show up)?"
- "Is there any robot configuration that changes match-to-match (like intake deployed or not)?"

**How to handle responses**:
- If they give vague answers like "standard stuff," ask specifically about position, pre-load, and no-show
- If they mention many fields, list them back and confirm priority (which are essential vs optional?)
- Record the exact name for each field (e.g., "robot starting position" not just "position")

**Example recording**:
```
Pre-Match Data:
- Robot starting position (required)
- Pre-loaded game pieces: coral count, algae count (required)
- No-show checkbox (required)
- Robot mechanism state: intake deployed yes/no (optional)
```

**Checkpoint**: Summarize and confirm: *"So scouts need to record starting position, pre-loaded pieces, and track no-shows. Anything else you want to add?"* Proceed only when user confirms.

---

#### **Step 3: Collect Autonomous Period Data Requirements**

**Purpose**: Define what scouts observe during the auto period (15 seconds typically). Note: AUTO PERIOD HAS STRICT CONSTRAINTS — all UI must fit on one screen, only single-press interactions allowed.

**Ask the user**:
> "What should scouts watch and record during the autonomous period?"

**Provide context** with game-specific examples:
- "For example: Did the robot leave the starting zone? Did it collect/place pieces? Score points?"
- "What counts as a successful auto action vs a failure?"

**How to handle responses**:
- If autonomous seems simple, keep list short (long lists don't fit on one screen)
- If they want to track many things, challenge them: *"The auto period is only 15 seconds and scouts can't scroll. Can we narrow this to the 3-4 most important observations?"*
- Record which actions are yes/no (checkbox), counters (tally buttons), or mutual-choice (radio button)

**Key constraint reminder**: All auto fields must use ONLY single-press interactions (buttons, checkboxes, radio buttons). NO scrolling, NO text entry, NO modals.

**Example recording**:
```
Autonomous Period:
- Mobility: Did robot leave starting zone? (checkbox)
- Pieces collected: Coral count, Algae count (counter buttons)
- Successful placement: yes/no (radio button)
- Auto score: total points (visible but calculated, not entered)
```

**Checkpoint**: Confirm it fits on screen: *"These fields would display as: mobility checkbox, two counter buttons for coral/algae, placement yes/no. All on one screen without scrolling. Does that work?"* If they want more fields, go back and priorities ruthlessly.

---

#### **Step 4: Collect Teleop Period Data Requirements**

**Purpose**: Define what scouts track during driver-controlled period (typically 2+ minutes). Same screen-fit and single-press constraints as autonomous.

**Ask the user**:
> "During teleop, what are the most important actions scouts should record?"

**Provide context**:
- "For example: pieces collected, placed, zone locations, penalties, successful cycles?"
- "What's different from autonomous that scouts should specifically track during teleop?"

**How to handle responses**:
- Similar to Step 3: if list is too long, ask *"If scouts could only track 5-6 key things during teleop, what would matter most for alliance selection?"*
- Record whether each field is a counter, checkbox, or choice
- Ask about cycles or repeated actions: *"Do scouts track each individual placement, or just a total count?"*

**Key constraint**: Same as autonomous — one screen, no scrolling, only single-press.

**Example recording**:
```
Teleop Period:
- Pieces collected: Coral count, Algae count (counter buttons)
- Pieces placed: Coral placements, Algae placements (counter buttons)
- Penalties: Red card, Yellow card, Foul (checkboxes)
- Zone where robot played: Reef, Processor, Barge (radio button)
```

**Checkpoint**: Confirm: *"Teleop would show coral/algae collect and place counters, penalty checkboxes, and zone selection. Does this capture what you need?"*

---

#### **Step 5: Collect End-Game Period Data Requirements**

**Purpose**: Define what scouts record in the final portion of the match (30-45 seconds typically). Less constrained than auto/teleop — allows scrolling and some complexity.

**Ask the user**:
> "In the last 30-45 seconds, what end-game actions need to be recorded?"

**Provide context**:
- "For example: climbing, parking, final scoring, hang success, trap positioning?"
- "Can be more detailed here since time pressure is lower"

**How to handle responses**:
- End-game can include checkboxes, counters, text fields for notes, long-form checkboxes
- Record all end-game attributes they mention

**Example recording**:
```
End-Game:
- Climb attempt: yes/no (checkbox)
- Climb level reached: 1, 2, 3, None (radio button or counter)
- Parking position: description (text)
- Robot disabled or stuck: yes/no (checkbox)
- Scout name: text field (required)
- Comments: textarea (optional)
```

**Checkpoint**: Confirm: *"End-game would include climb attempt, climb level, parking notes, and scouter info. Anything else?"*

---

#### **Step 6: Choose Layout for Autonomous and Teleop**

**Purpose**: Decide whether auto/teleop UI shows a visual field map with positioned buttons or a text-based table layout.

**Ask the user**:
> "For autonomous and teleop, how should scouts interact with the form? Do you want:"

**Present both options clearly**:

**Option A: Visual Field Map**
- Display a game field diagram with interactive buttons positioned on the field
- Scouts click directly on the field position where an action happened
- Example: Coral placement buttons positioned at coral level 1, 2, 3, 4 locations on the reef
- Pros: Intuitive, scouts see what actually happened on the field spatially
- Cons: Requires field image, careful CSS positioning, only works if layout matches field geometry
- Used in: 2025/2026 seasons

**Option B: Table/Grid Layout**
- Organize actions into labeled rows (game elements) and columns (actions)
- Compact, text-based, works on any screen size
- Example: Rows for "Coral", "Algae"; Columns for "Collected", "Placed", "Dropped"
- Pros: No image needed, scales to many items, simpler CSS
- Cons: Less spatial intuition, higher cognitive load to interpret
- Used in: 2024 and earlier seasons

**Recommended follow-up**:
- If they choose visual map: *"What field diagram or image will we use? Do we need to create one, or can we adapt an existing game manual image?"*
- If they choose table: *"How should we organize the rows and columns? What makes most sense for the scouts?"*

**Example recording**:
```
Layout Decision:
- Autonomous: Visual Field Map (with reef diagram)
- Teleop: Visual Field Map (with reef diagram)
- Field diagram source: 2025 game manual page 20
```

**Checkpoint**: Confirm: *"So we'll use a visual field layout for both auto and teleop, with the reef positioned on the field. Correct?"*

---

#### **Step 7: Choose Counter Interaction Method**

**Purpose**: Decide how scouts correct mistakes when tallying counters.

**Ask the user**:
> "When a scout accidentally taps a counter button, how should they fix it?"

**Present both options**:

**Option A: Decrement Buttons**
- Each counter has both `+` and `-` buttons
- Scout clicks `-` to undo the mistake immediately
- Pros: Explicit and visual
- Cons: Takes up more space on the form
- Used in: 2024-2026 seasons

**Option B: Global Undo Button**
- Counters only have `+` buttons (cleaner layout)
- One "Undo" button at the top reverts the last action
- Pros: Less visual clutter
- Cons: Only fixes the very last action, scouts must remember what they just tapped
- Used in: Earlier seasons, pit scouting

**How to handle responses**:
- If unsure, recommend Option A for this year (most recent practice)
- If they're worried about form clutter on tablets, Option B might reduce scrolling

**Example recording**:
```
Counter Interaction:
- Chosen: Decrement Buttons (+ and - on each counter)
- Rationale: Mobile tablets have space, scouts get immediate visual feedback
```

**Checkpoint**: Confirm: *"Each counter will have + and - buttons. Is that your preference?"*

---

#### **Step 8: Summary and Validation Checkpoint**

**Purpose**: Consolidate all design decisions and get final approval before implementing.

**Create and present a comprehensive design summary**:

```
═══════════════════════════════════════════════════════════════
MATCH SCOUTING DESIGN SUMMARY FOR [YYYY]
═══════════════════════════════════════════════════════════════

GAME MECHANICS:
- Game pieces: [coral max 4, algae max 1, etc.]
- Key constraints: [storage limits, state changes, etc.]

PRE-MATCH DATA:
- [list all pre-match fields]

AUTONOMOUS PERIOD (single screen, click-only):
- [list all auto fields]
- Layout: [Visual Field Map / Table]
- Counter method: [+/- buttons / Undo button]

TELEOP PERIOD (single screen, click-only):
- [list all teleop fields]
- Layout: [Visual Field Map / Table]
- Counter method: [+/- buttons / Undo button]

END-GAME PERIOD (can scroll, text allowed):
- [list all end-game fields]

═══════════════════════════════════════════════════════════════
```

**Present it to the user**:
> "Here's what we've designed. Please review each section carefully."

**Ask validation questions**:
- "Is the pre-match data complete?"
- "Does the autonomous period capture what scouts need to see?"
- "Is the teleop period list manageable on one screen?"
- "Does end-game have everything for the final 30 seconds?"
- "Are you happy with the layout choice (visual map vs table)?"
- "Are you happy with the counter correction method?"

**If they find gaps or want changes**:
- *"Let's go back to [Step X] and add/modify that."* — Return to the relevant step
- Update the design summary
- Re-confirm the full summary

**When fully approved**:
- **Record this summary in a version control comment or design document** — You'll reference it heavily during Phase 4 implementation
- Mark Phase 3 as COMPLETE

**Checkpoint validation checklist** (confirm all before proceeding):
- [ ] All 8 steps have user-confirmed answers
- [ ] No undecided or vague answers remain
- [ ] Game pieces and constraints documented
- [ ] All four match periods have defined fields
- [ ] Layout approach decided (Visual Map or Table)
- [ ] Counter interaction method decided (+/- or Undo)
- [ ] User has reviewed and approved full design summary

**Only when ALL checkboxes are checked**, proceed to Phase 4: Build Match Scouting Form HTML.


### Phase 4: Build Match Scouting Form HTML and Implement Logic

⚠️ **ONLY START PHASE 4 IF PHASE 3 IS COMPLETE** — Verify that:
- [ ] All 8 steps of Phase 3 are done
- [ ] Design summary is approved by the user
- [ ] Game piece types and constraints are documented
- [ ] Layout approach is decided (Visual Map or Table)
- [ ] Counter interaction approach is decided (Decrement or Undo)

**Reference: Choosing Input Types for Attributes**

Based on the requirements gathered in Phase 3, use these guidelines to implement the appropriate HTML input types:

- **Binary actions** (did it happen or not?): `<input type="checkbox">` — scouts toggle yes/no
- **Single numeric value** (count, score, code): `<button class=count data-input=name>` with `<input type=text class=num name=name>` — scouts use single-press increment buttons to tally quickly; implement based on Phase 3 Step 6 decision
- **Mutually exclusive choices** (one of several options): `<input type="radio">` — scouts select one choice from a group
- **Text/notes** (observations, comments): `<input type="text">` or `<textarea>` — scouts enter written data (only in pre-match and end-game; not allowed in auto/teleop)
- **Mobile-friendly select** (choose from many options): For auto/teleop, avoid `<select>` dropdowns; use radio buttons or buttons instead. For pre-match/end-game, `<select>` is acceptable.

**Key constraint**: Auto and teleop must fit on one screen with only single-press interactions (no modals, no text entry, no multi-step workflows).

**Using Count Inputs for Numeric Counters:**

The `count` class pattern enables single-press increment/decrement buttons that link to a text input field which displays the current count. This is used throughout match scouting for quick tallies:

1. **Create the text input field** (visible on the form, displays the count):
   ```html
   <input type=text class=num value=0 name=game_piece_collect size=1 disabled max=9>
   ```
   - `class=num` — Marks as numeric counter display
   - `value=0` — Initial count (usually 0), displays on the form as a read-only number
   - `name=game_piece_collect` — Unique field identifier
   - `disabled` — Prevents manual typing (click-only), but value remains visible
   - `max=N` — Maximum allowed value (auto-hides increment button at limit)
   - `min=N` — Minimum allowed value (auto-hides decrement button at limit)
   - This field appears on the scout form showing the current tally; scouts read it to see their progress

2. **Create button(s) or image(s)** with `class=count` that link to the input:
   ```html
   <button class=count data-input=game_piece_collect>
       <img src=game-piece-collect.png>
   </button>
   ```
   - `class=count` — Enables automatic increment/decrement behavior
   - `data-input=field_name` — Links button to the input field by name
   - `data-value=N` — Specifies custom increment value (default: 1). Example: `data-value=3` increments by 3
   - Each click increments/decrements the value visible in the text input above

3. **Organizing counters by game element**:
   - Add data attributes like `data-element=game-piece-a` or `data-element=game-piece-b` to group related counters
   - Add `data-provides=1` or `data-accepts=1` to track inflow/outflow of game pieces
   - They can affect functionality such as showing and hiding placement buttons based on whether the buttons for picking up game pieces have been pressed
   - This approach is particularly useful when there is more than one game piece in a game or when there are limits on how many game pieces robots can hold at once.

The JavaScript handler (`countHandler` in `/www/scout.js`) automatically:
- Detects clicks on any `.count` element
- Finds the linked input field via `data-input` name
- Increments/decrements the value while enforcing min/max bounds
- Shows/hides +/- buttons based on current value and limits
- Displays a floating change indicator showing the increment amount during clicks

Based on the design decisions and attributes gathered in Phase 3, create the match scouting form HTML files and implement their supporting JavaScript and CSS.

1. **Create match scouting form HTML** (`/www/YYYY/scout.html`):
   - Structure the form with separate sections for each game phase: pre-match, autonomous, teleop, end-game
   - For autonomous and teleop periods: ensure all UI fits on a single screen without scrolling and uses only single-press interactions
   - For pre-match and end-game: allow scrolling, multi-step interactions, and text entry as needed
   - Implement the layout approach chosen in Phase 3 Step 5:
     - **Visual map approach**: Display field diagram with interactive buttons positioned on the map for actions
     - **Table layout approach**: Organize actions into structured rows/columns with clear labels
   - For numeric counters, implement the approach chosen in Phase 3 Step 6:
     - **Decrement buttons approach**: Include both `+` and `-` buttons for each counter
     - **Undo button approach**: Include only `+` buttons, with a global "Undo" button to revert last action
   - Use appropriate input types from Phase 3's reference guide (checkboxes, count inputs, radio buttons, text fields)

2. **Build match scouting JavaScript** (`scout.js`):
   - Implement the **undo functionality** based on the decision from Phase 3 Step 6:
     - **If decrement buttons chosen**: Ensure count buttons work correctly with both increment and decrement; bind countHandler to all `.count` buttons
     - **If global undo chosen**: Implement an undo button that stores action history (each button click or counter increment) and reverts to previous state
   - Add field-specific validation logic:
     - Numeric fields (counters): validate ranges and ensure counts stay within min/max bounds
     - Checkboxes/radio buttons: ensure valid selections
     - Required fields: prevent submission without critical data
   - Implement field dependencies (conditional visibility):
     - Show/hide fields based on other selections (e.g., "if autonomous success, show autonomous points")
     - Cascade changes when a field changes
   - Add embedded calculations for user feedback:
     - Real-time match score preview showing running total
     - Validation messages (e.g., "Team number required")
   - Implement data serialization for upload:
     - Convert form fields to a standardized data format (JSON)
     - Include metadata (match number, team number, scout name, timestamp)
   - Add translation objects for all form field labels and descriptions:
     - All six languages: `en:`, `fr:`, `pt:`, `zh_tw:`, `tr:`, `he:`
     - Example pattern:
       ```javascript
       {
         en: "Auto Climb Points",
         fr: "Points d'Escalade Automatique",
         pt: "Pontos de Escalada Automática",
         zh_tw: "自動爬升分數",
         tr: "Otomatik Tırmanış Puanları",
         he: "נקודות טיפוס אוטומטיים"
       }
       ```

3. **Update match scouting CSS** (`scout.css`):
   - If using visual field map layout (Phase 3 Step 5): Style the field diagram and position interactive buttons precisely with absolute positioning
   - If using table layout (Phase 3 Step 5): Style table structure for clarity and organization
   - Style counters based on chosen interaction approach:
     - **Decrement buttons**: Style both + and - buttons clearly, make them large for touch screens
     - **Undo button**: Style the counter display and add a prominent undo button
   - Style new form fields for clarity and usability on mobile
   - Use single-line selectors/properties when possible to minimize file size
   - Ensure inputs are large enough for tablet touch interaction
   - Add visual feedback (colors, borders) for validation states
   - Ensure responsive layout works on tablets in both portrait and landscape orientations

4. **Add undo button HTML** (if chosen in Phase 3 Step 6):
   ```html
   <button class=undo id=undo-button>Undo</button>
   ```
   - Bind click handler to undo button that pops from action history and reverts UI state

**Note**: Pit and subjective scouting HTML/JavaScript/CSS are implemented later as needed. Finish match scouting thoroughly first.

### Phase 5: Implement Statistics and Aggregation
1. **Define stat categories and calculations** (`aggregate-stats.js`):
   - Map the data fields from `scout.html` to meaningful statistics for analysis
   - Define all statistics that will appear on analysis dashboards
   - Group stats into logical categories for organization:
     - Autonomous period stats
     - Teleop period stats
     - End-game stats
     - Overall match performance stats
   - Implement calculation functions for derived stats:
     - Simple averages (e.g., average points per match)
     - Probability metrics (e.g., likelihood of successful climbing)
     - Complex aggregations (e.g., consistency scores, reliability ratings)
   - Data flow: `scout.html` form fields → `aggregate-stats.js` calculations → dashboard display

2. **Test calculations**:
   - Create test datasets with known statistics
   - Verify calculations produce expected results
   - Test edge cases (zero data, missing fields, outliers)
   - Ensure stats are meaningful for alliance selection decisions

### Phase 6: Create Match Scouting Documentation
1. **Write English instructions** (`scouting-instructions.md`):
   - Explain the purpose of match scouting for alliance selection
   - Describe each field in the match scouting form and what scouts should record
   - Explain the game phases (autonomous, teleop, end-game) and provide context
   - Provide tips for accurate data collection:
     - When to start recording (match start signal)
     - How to handle disruptions or unusual situations
     - Common mistakes to avoid
   - Include game-specific context to help scouts understand what they're observing
   - Keep language clear and concise (scouts are reading this at events)

2. **Translate documentation** (create all 6 language versions):
   - Create `scouting-instructions.fr.md` - French
   - Create `scouting-instructions.pt.md` - Portuguese
   - Create `scouting-instructions.zh_tw.md` - Traditional Chinese
   - Create `scouting-instructions.tr.md` - Turkish
   - Create `scouting-instructions.he.md` - Hebrew

   **Note**: Professional volunteers or AI translation tools help with this. Ensure someone fluent in each language reviews the translations for accuracy and clarity.

**Note**: Documentation for pit and subjective scouting forms is created later as those features are added.

### Phase 7: Verify Translation Completeness (Match Scouting)
1. **Verify all form field translations in `scout.js`**:
   - After Phase 4, check that all newly added form fields have complete translation objects
   - Ensure each translation object includes all six languages: `en:`, `fr:`, `pt:`, `zh_tw:`, `tr:`, `he:`
   - Look for any fields with missing translations (incomplete language sets)
   - Use grep/search to find any new field labels that might have been added without translations
   - Make a pass through `scout.js` to catch any missed labels or descriptions

2. **Review translation quality**:
   - Confirm technical terms are accurate across languages
   - Check that abbreviations/units are consistent (e.g., "points" vs "pts")
   - Ensure descriptions are clear and understandable

**Note**: Pit and subjective scouting translation verification happens later when those forms are implemented.

### Phase 8: Test and Deploy Match Scouting
1. **Test match scouting on mobile devices**:
   - Verify the form renders correctly and is usable on tablets (portrait and landscape)
   - Test all input types work as expected (checkboxes, number inputs, radio buttons)
   - Test data submission and end-to-end upload to server
   - Verify statistics calculations work with test data
   - Test language selector switches all fields to each language correctly
   - Check that scouting-instructions documentation displays properly on the device

2. **Test with real match scenarios**:
   - Simulate scouting during a match (record a few test matches)
   - Verify data is transmitted and stored correctly
   - Confirm uploaded data appears correctly in stats/analysis views

3. **Update season selector** (if applicable):
   - Ensure the application can navigate to the new season
   - Update any hardcoded season references in global files
   - Test switching between seasons works correctly

4. **Database schema** (if using database):
   - The `/script/db-schema.pl` script **automatically** generates database columns from scouting form HTML files
   - When you add new form fields, the schema is generated automatically
   - Usually no manual schema modifications needed

### Phase 9: Deploy and Monitor Match Scouting
1. **Deploy match scouting to production**:
   - Run `./script/install.sh` to apply any configuration updates
   - Scripts are idempotent - safe to rerun
   - Verify new season is accessible in production with match scouting available

2. **Monitor initial event with match scouting**:
   - Check that scouts can access the match scouting form
   - Verify data submission works reliably
   - Collect feedback on form usability, field clarity, and data quality
   - Address any critical issues discovered in the field

3. **Iterate and improve match scouting**:
   - After first event(s), gather feedback from scouts and analysts
   - Make form adjustments if scouts report confusion about fields
   - Refine stat definitions based on what proves useful for alliance selection
   - Fix any calculation errors discovered in stats
   - Optimize form layout based on real-world experience

**After match scouting is stable**, follow the same workflow (Phases 2-9) for implementing pit scouting and subjective scouting as needed for your team's strategy.

## Checklist

Use this checklist to ensure match scouting is complete. Pit scouting and subjective scouting checklists follow after those features are implemented.

### Directory Setup
- [ ] Season directory created (`/www/YYYY/` or `/www/YYYY-YY/`)
- [ ] Template files copied to new season directory
- [ ] Previous game's image preload tags removed from `scout.html`
- [ ] All game-specific field-action buttons and mechanics removed from `scout.html`
- [ ] All game-specific content removed from `scout.js` (i18n, callbacks, calculations)
- [ ] All game-specific selectors and styling removed from `scout.css`
- [ ] All game-specific stats and calculations removed from `aggregate-stats.js`
- [ ] Previous game content cleared from all `scouting-instructions.*.md` files (ready for new game content)
- [ ] Stripped state committed to git as checkpoint

### Match Scouting HTML Form
- [ ] `scout.html` updated with game-specific input fields
- [ ] Form organized by game phases (autonomous, teleop, end-game)
- [ ] All input fields use appropriate types (checkbox, number, radio, select, text)
- [ ] Field labels and descriptions are clear and concise
- [ ] Mobile-friendly layout verified
- [ ] Team number and match number fields included

### Match Scouting JavaScript
- [ ] `scout.js` has validation logic for new form fields
- [ ] Field dependencies and conditional visibility implemented (if needed)
- [ ] Real-time score/validation feedback added
- [ ] Data serialization for upload works correctly
- [ ] All form field labels translated to six languages in translation objects
- [ ] Translation objects follow consistent format (en:, fr:, pt:, zh_tw:, tr:, he:)

### Match Scouting CSS
- [ ] `scout.css` styled appropriately for new form fields
- [ ] Mobile responsiveness verified (portrait and landscape)
- [ ] Input fields appropriately sized for tablet touch
- [ ] Validation state visual feedback (colors, borders)
- [ ] File size minimized (single-line selectors/properties where possible)

### Statistics & Aggregation
- [ ] `aggregate-stats.js` defines all match scouting stats
- [ ] Stats organized into logical categories
- [ ] Calculation functions implemented for derived stats
- [ ] Test calculations with sample data
- [ ] Edge cases handled (zero data, missing fields)

### Match Scouting Documentation
- [ ] `scouting-instructions.md` written (English) for match scouting
- [ ] Translations created for all five other languages
- [ ] Explains purpose of match scouting for alliance selection
- [ ] Each field described with scouting tips
- [ ] Game phase context explained
- [ ] Documentation reviewed for accuracy

### Translation Verification
- [ ] All scout.js field labels have complete six-language translations
- [ ] No missing language codes in translation objects
- [ ] Technical terms are consistent across languages
- [ ] Translations reviewed for accuracy

### Testing & Deployment (Match Scouting)
- [ ] Forms render and function on tablets (portrait and landscape)
- [ ] Data submission and upload works end-to-end
- [ ] Statistics calculations verified correct with test data
- [ ] Language selector tested with all six languages
- [ ] Documentation displays properly
- [ ] Production deployment successful with match scouting functional
- [ ] Test matches recorded and verified in analysis views

**Note**: After match scouting is complete and tested, move on to implementing pit scouting and subjective scouting forms using the task breakdown pattern above.

## Later Phases: Adding Pit Scouting and Subjective Scouting

After match scouting is stable and deployed, you may want to add pit scouting and/or subjective scouting to collect additional data. Each follows the same workflow pattern:

**Pit Scouting** (pre-competition analysis):
- Add input fields to `pit-scout.html` for pre-match team information (wheel type, mechanisms, capabilities)
- Implement `pit-scout.js` and `pit-scout.css` with form behavior and styling
- Add pit scouting stats to `aggregate-stats.js` if needed
- Create pit scouting documentation (`scouting-instructions.md` updates)
- Translate all pit scouting field labels to six languages
- Test and deploy pit scouting using the same methodology as match scouting

**Subjective Scouting** (qualitative observations):
- Add fields to `subjective-scout.html` for scouts to record observations (driver skill, mechanical issues, etc.)
- Implement `subjective-scout.js` and `subjective-scout.css`
- Optionally add subjective metrics to `aggregate-stats.js`
- Create and translate subjective scouting documentation
- Test and deploy using the same pattern

Each additional form can be implemented independently when your team determines it's needed. You can start with match scouting alone and add pit/subjective scouting later without disrupting the match scouting workflow.

## Related Skills

- **viper-overview**: Comprehensive project structure and technology overview

## FAQ

**Q: Can I start from scratch without copying from a template?**
A: Yes, but it's slower. Copying from the FRC or FTC season templates allows you to modify existing code rather than write it entirely new.

**Q: What if the game rules change the scoring system significantly?**
A: The game always changes significantly with very different scoring for each season. A few things remain the same: games are 2 vs 2 for FTC and vs 3 for FRC, there are autonomous and teleop periods, and there are usually end-game mechanics. The specific scoring actions and field layouts change every year, so you must design new forms and logic for each season.

**Q: How do I handle a brand new game concept (not similar to previous years)?**
A: Map the new game's scoring/mechanics to form fields. Study the game rules thoroughly, design forms that capture all relevant metrics, implement the stat calculations, and test extensively.

**Q: Do I need to modify `/script/db-schema.pl`?**
A: Usually not. The script automatically generates database schema from your HTML form fields. Just ensure your form fields have the correct `name` attributes.
