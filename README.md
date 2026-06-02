# Envy's Text Animator

Envy's Text Animator is a beta Lua tool for DaVinci Resolve that generates editable animated Fusion Title/Text+ clips from a simple script-menu UI. It supports character, word, and line followers, stackable animation in/out options, slide directions, easing choices, and custom animation length without manually building keyframes in Fusion.

## Install

For the easiest install, copy `dist/Envys_Text_Animator.lua` into DaVinci Resolve's Utility scripts folder:

```text
%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Utility
```

Restart Resolve, then run it from:

```text
Workspace > Scripts > Utility > Envys_Text_Animator
```

Optional: copy `assets/Envystalogo.png` into an `assets` folder beside the Lua file if you want the logo to appear. The script still works without the logo.

## Requirements

DaVinci Resolve with Fusion Lua scripting support. Resolve/Fusion 17 or newer is recommended. This beta is currently tested on the developer's Resolve setup and is released as `beta 0.0.3`.

## License

MIT. Use it, modify it, share it, just keep the copyright/license notice.

## Note

Resolve may split unlocked clips underneath when inserting a generated title. Lock the track underneath before placing text.
