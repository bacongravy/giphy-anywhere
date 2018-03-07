# GIPHY Anywhere...

Sometimes you're composing a chat message or closing a PR, and the need to insert a gif strikes, but opening a new browser menu would break your flow. GIPHY Anywhere... to the rescue!

## Installation

You can either install via the CLI, or the GUI.

#### CLI install

1. Install the service:
```bash
cp -R 'GIPHY Anywhere....workflow' ~/Library/Services/
```

2. Set the keyboard shortcut (Command-Control-G) for invoking the service:
```bash
defaults write pbs NSServicesStatus \
  -dict-add '"(null) - GIPHY Anywhere... - runWorkflowAsService"' \
  '"key_equivalent" = "@^g";'
```

#### GUI install

1. Install the service by opening the "GIPHY Anywhere....workflow" document in the Finder and then choosing the "Install" option in the dialog that appears.

2. Set the keyboard shortcut for invoking the service by navigating to System Preferences > Keyboard > Shortcuts > Services and finding "GIPHY Anywhere..." in the "Text" section near the bottom of the list of services.

## Usage

Whenever the urge to gif strikes, just hit Command-Control-G, find a gif to fit your mood, and press OK. The URL of the last-viewed gif will be inserted into the currently focused text area.

## Known issues

The popover window doesn't have focus when it appears, so the first click on the window focuses the window instead of taking an action.

## Acknowledgements

This project was inspired by https://github.com/cknadler/vim-anywhere, and by the rich gif culture at my place of work.

## Why?

The GIPHY keyboard is great on iOS, and I miss it whenever I'm using macOS. Seeing vim-anywhere gave me the motivation to solve my problem in a similar way.
