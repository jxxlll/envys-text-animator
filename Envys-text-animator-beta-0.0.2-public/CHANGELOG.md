Envy's Text Animator - Development Changelog
Current checkpoint: beta 0.0.2a
Last updated: 2026-06-01

Project source location in this repository:
src\EnvysTextAnimator

Current Resolve launcher files:
Create_Envys_Text_Animator_UI_Modular.lua
Envys_Text_Animator.lua

Current main modules:
modules\config.lua
modules\generator.lua
modules\animations_in.lua
modules\animations_out.lua
modules\followers.lua
modules\easing.lua
modules\title_insert.lua
modules\utils.lua


================================================================================
PROJECT IDEA
================================================================================

The project started as a custom DaVinci Resolve Lua script to generate animated
Text+ titles without manually building keyframes in Fusion.

Core design goals:
- Simple run-from-script-menu workflow.
- User types text and chooses animation settings from a small UI.
- Script creates a Fusion Title/Text+ setup automatically.
- Follower modifier controls whether animation happens by character, word, or line.
- Animation modifiers can be stacked.
- Animation in and animation out can be chosen separately.
- Generated title remains editable from the Edit page inspector.
- Keep the tool basic, modular, and difficult to break.


================================================================================
EARLY PROTOTYPE PHASE
================================================================================

Initial prototype:
- Created a Text+/Fusion clip at the current playhead.
- Used a placeholder text value: "Your Text Here".
- Default duration was planned as 5 seconds.
- Target workflow was script menu -> UI -> Place Text.

Early problems discovered:
- Python was not the right target for this workflow because the user expected
  Resolve Lua script support.
- Early generated Fusion comps had broken or messy node connections.
- The script initially created clips without a proper UI.
- Generated nodes sometimes did not connect correctly to MediaOut.
- Edit page inspector controls were missing or unreliable.

Important lesson:
- Resolve is very sensitive to how Fusion titles are inserted. A generated node
  tree can work in Fusion but still fail as an editable Edit-page title.


================================================================================
UI PROTOTYPE PHASE
================================================================================

Built a Lua UI inspired by the user's mockup:
- Large text input area.
- Follower controls.
- Animation controls.
- Place Text button.
- Debug/status output.

Initial UI controls:
- Follower buttons: Word, Character, Line.
- Animation buttons: Blur, Fade, Slide Up, Slide Down, Slide Left, Slide Right,
  Rotate, Scale.
- Animation In and Animation Out sections.
- Easing dropdowns.

Later UI refactor:
- Follower buttons were replaced with a dropdown.
- Animation buttons were replaced with checkboxes.
- Slide direction was moved into dropdown controls instead of separate slide
  buttons.
- Animation In and Animation Out were arranged into compact two-column layouts.
- Debug/status summary was turned into a proper append-only Debug Log.
- Preview panel and Preview Animation button were later removed because preview
  was not implemented yet and wasted space.


================================================================================
MODULARIZATION PHASE
================================================================================

The project moved from one large Lua file toward a folder-based modular setup.

Reason:
- Easier debugging.
- Easier future GitHub packaging.
- Avoid giant fragile one-file edits.

Current module structure:
- config.lua
  Stores app name, version, default timing, default text, title paths, and timing
  helpers.

- generator.lua
  Builds the Fusion .setting/.comp text for the generated title.

- animations_in.lua
  Generates animation-in follower inputs, splines, paths, blur logic, slide,
  scale, rotate, and fade behavior.

- animations_out.lua
  Generates animation-out behavior and combined in/out curves.

- followers.lua
  Maps follower modes to Resolve follower fields and defaults.

- easing.lua
  Stores easing curve templates.

- title_insert.lua
  Handles writing the generated title, inserting into the timeline, duration,
  and fallback behavior.

- utils.lua
  File and string helper utilities.

Important result:
- Modular version became the main working direction after earlier single-file
  experiments became too fragile.


================================================================================
FOLLOWER SYSTEM
================================================================================

Follower modes:
- Character
- Word
- Line

Current default:
- Character

Changes made:
- Follower dropdown order changed to:
  Character, Word, Line
- Follower fallback aligned to character so UI default and engine fallback match.
- Default follower delay changed to 0.6.
- Line follower delay adjusted to 0 for line behavior where needed.

Workflow logic:
- Character mode uses character follower inputs.
- Word mode uses word follower inputs.
- Line mode uses line follower inputs.
- The selected follower mode applies to all enabled animations.


================================================================================
ANIMATION SYSTEM
================================================================================

Supported animation-in options:
- Fade
- Blur
- Slide
- Scale
- Rotate

Supported animation-out options:
- Fade
- Blur
- Slide
- Scale
- Rotate

Stacking behavior:
- Multiple animation options can be enabled together.
- Animation In and Animation Out are separate.
- Slide direction can be selected independently for In and Out.

Slide directions:
- Up
- Down
- Left
- Right
- Up Left
- Up Right
- Down Left
- Down Right

Important animation work:
- Started from user-provided Fusion .setting examples.
- Used Text+ StyledTextFollower as the main animation driver.
- Character/line blur uses Text+ soften behavior.
- Word blur uses a masked blur method from the user reference, not simple
  follower soften blur.
- Word fade also uses mask-based visibility behavior where appropriate.
- Blur was changed to Fast Gaussian / Gaussian-style blur behavior based on the
  user's preference.
- Word mask ExtendHorizontal was adjusted to -0.151 based on the reference.


================================================================================
EASING SYSTEM
================================================================================

Easing dropdowns:
- Easing In
- Easing Out

Options:
- Default
- Ease In
- Ease Out
- Ease In Out
- Back
- Bounce
- Elastic

Changes made:
- Added easing module.
- Added easing cache busting during hot reload.
- Added user-provided easing references for Default, Smooth, and Linear.
- Easing is applied by generating different BezierSpline handle shapes.

Known limitation:
- Easing differences may be subtle depending on selected animation and follower.
- Custom Bezier editor is not implemented yet.


================================================================================
TIMING SYSTEM
================================================================================

Original plan:
- User-facing Duration field.
- Duration defaults to 5 seconds.
- Keyframe stretcher idea was introduced to avoid recalculating all keyframes.

Final current direction:
- Timeline clip duration remains based on default title duration.
- Animation length controls the in/out animation length, not the whole clip.
- User can stretch the generated title in the Edit page.

Key timing model:
- Design baseline: 24 fps.
- Default animation length: 10 frames at 24 fps = 0.4167 seconds.
- Animation length range: 0.1s to 1.5s.
- The same animation length controls both animation in and animation out.

Timing structure:
- In animation starts at frame 0.
- Hold section is protected by KeyframeStretcher.
- Out animation starts after the hold section.
- Tail padding is preserved after out animation.

Baseline timing values:
- StretchStart = 40
- StretchEnd = 90
- Tail padding = 22 frames at 24 fps

Important fix:
- KeyStretcher SourceEnd uses the out animation end frame, not out end + tail.
- Using out end + tail caused Resolve errors near the end of the comp, including:
  MediaOut1 cannot get Parameter for Input
  KeyframeStretcher1 cannot get Parameter for Keyframes

Current UI:
- Animation Length slider + manual text input.
- Slider range maps to 0.1s through 1.5s.
- Manual field sits beside the slider.

Planned future work:
- Confirm 24/30/60fps timing behavior in real Resolve projects.
- Add clearer debug logs for detected FPS and generated timing frames.


================================================================================
INSERTION / TIMELINE BEHAVIOR
================================================================================

Several insertion methods were tested:

1. InsertFusionCompositionIntoTimeline + ImportFusionComp
- Gives Fusion-page controls.
- Does not expose controls properly in the Edit page inspector.
- Kept only as fallback.

2. MediaPool ImportMedia + AppendToTimeline
- Attempted to avoid cutting tracks underneath.
- Caused Edit inspector controls to disappear.
- Removed from active path.

3. InsertFusionTitleIntoTimeline
- Golden working path.
- Restores Edit-page inspector controls.
- Current active insertion method.

Known Resolve behavior:
- Inserting a title can cut/split unlocked clips on tracks underneath.
- Practical workaround: lock the track underneath before placing text.
- A visible note was added to the UI:
  "Tip: lock the track underneath before placing text."

Planned 0.0.2b idea:
- Detect tracks with clips under the playhead.
- Temporarily lock/protect lower tracks during title placement.
- Restore previous lock state afterward if Resolve API supports it reliably.


================================================================================
EDIT PAGE INSPECTOR CONTROLS
================================================================================

Goal:
- Generated title should expose useful controls in the Edit page inspector.

Exposed controls include:
- Styled Text
- Font
- Style
- Color
- Size
- Position
- Follower Delay

Important discoveries:
- Group InstanceInput controls are only useful in the Edit inspector when the
  generated title is inserted as a Fusion Title template.
- Raw Fusion composition insertion exposes controls only in the Fusion page.
- MediaPool append/import path hid the inspector controls.

Current status:
- InsertFusionTitleIntoTimeline is restored.
- Edit-page controls should be available again.


================================================================================
LOGO / BRANDING
================================================================================

Project name changed to:
- Envy's Text Animator

Logo:
- Loaded from:
  assets\Envystalogo.png

Changes made:
- Added logo to UI.
- Moved logo above the text input.
- Adjusted size after user feedback that it was too small.
- Made layout more responsive so the logo does not disappear or sit awkwardly.

Current layout:
- Logo at top.
- Text input below logo.


================================================================================
TEXT INPUT UX
================================================================================

Original behavior:
- Text box contained actual text "Your Text Here".
- User had to delete it before typing.

Current behavior:
- Text box starts empty.
- "Your Text Here" is used as placeholder text.
- Placeholder appears greyed out if supported by Resolve UIManager.
- User can type directly.
- If user leaves it empty, generator falls back to Config.defaultText.


================================================================================
DEBUG LOG
================================================================================

Debug Log was kept and improved.

Current behavior:
- Append-only during runtime.
- Logs UI loaded.
- Logs selected follower.
- Logs enabled animation in/out options.
- Logs slide directions.
- Logs easing choices.
- Logs animation length.
- Logs placement success/failure.

Planned improvements:
- Startup line with version/build.
- Startup line with detected timeline FPS.
- Log generated timing frames.
- Possibly add About/version debug line for testers.


================================================================================
DRFX / PRESET PACKAGING EXPERIMENT
================================================================================

DRFX packaging was attempted.

Result:
- Generated DRFX was not accepted by Resolve as a valid template bundle.
- Manual copy/install approach remained more reliable.

Decision:
- Keep script/module workflow for now.
- Packaging/install guide can be handled later around release candidate stage.


================================================================================
VERSION CHECKPOINTS
================================================================================

Initial golden working checkpoint
- First reliable modular checkpoint.
- Working title insertion path.
- Used as the main recovery point after fragile experiments.

beta 0.0.1
- Marked first working beta checkpoint.
- Basic modular generator working.
- Follower and animation system functional.

beta 0.0.1a
- UI layout improvement with logo/text input changes.
- Logo moved and resized.
- Cleaner top area.

beta 0.0.1b
- Inspector controls cleanup checkpoint.
- Prepared for timing/keyframe stretcher work.

beta 0.0.2
- Stability update.
- Removed hardcoded script root.
- Fixed module cache bust behavior.
- Aligned follower fallback to character.
- Cleaned unused timing config/log.
- Added FPS-aware timing foundation.
- Added custom animation length UI and engine support.
- Added slider/manual input for animation length.

beta 0.0.2a
- Current checkpoint.
- Restored Fusion Title insertion path after append/raw insert experiments.
- Edit-page inspector controls restored.
- Added visible "lock track underneath" note.
- Changed text input to real placeholder behavior.
- Kept custom animation length and FPS-aware timing work from 0.0.2.


================================================================================
BACKUP NOTE
================================================================================

During development, local backups were created before risky Resolve insertion,
timing, and UI changes. Those backup folders are intentionally excluded from the
public repository. The first public checkpoint is beta 0.0.2a.


================================================================================
CURRENT KNOWN ISSUES
================================================================================

1. Resolve may cut/split unlocked clips underneath the generated title.
   Workaround: lock the track underneath before placing text.

2. Full timeline-safe insertion is not solved yet.
   Planned approach: temporary track locking if Resolve API supports it cleanly.

3. FPS-aware timing is implemented but still needs practical testing in 24, 30,
   and 60fps projects.

4. Custom Bezier editor is not implemented.

5. DRFX packaging is not solved.


================================================================================
PLANNED ROADMAP
================================================================================

0.0.2b - Timeline Safety + Debug Cleanup
- Auto-protect occupied lower video tracks during placement, then restore locks.
- Add version/build debug line.
- Add detected FPS debug line.
- Add animation length debug line.
- Log generated timing frames.
- Remove dead MediaPool append experiment code if fully unused.
- Keep raw comp fallback only for emergency fallback.

0.0.3 - UI Redesign
- Darker layered panels, less flat grey.
- Logo section with better breathing room.
- Section headers with accent border.
- Place Text button as dominant CTA.
- Remove any leftover preview panel concepts.
- Reclaim preview space for cleaner layout.
- Collapsible debug log.

0.1.0 - Feature Drop
- Preset save/load system.
- Recent animations list.
- Custom Bezier editor.

0.2.0 - Release Candidate
- Final UI polish.
- Install guide / README.
- Gumroad listing, Pay What You Want.
- 30 second demo video.
- Post on Resolve forum and Reddit.


================================================================================
SUMMARY
================================================================================

Envy's Text Animator is currently a working modular Lua tool for DaVinci Resolve.
The current beta 0.0.2a can generate editable Fusion Titles from a UI, with
stackable animation in/out options, follower modes, slide directions, easing
choices, and custom animation length.

The project has survived several Resolve-specific insertion issues. The main
rule learned so far:

For Edit-page inspector controls, insert as a Fusion Title template using
InsertFusionTitleIntoTimeline. For timeline safety, lock the lower track before
placing text until an automatic protection system is implemented.
