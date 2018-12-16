# GIPHY Anywhere

Sometimes you're composing a chat message or commenting on a pull request, and the need to insert a gif strikes, but opening a new browser window would totally break your flow. *GIPHY Anywhere* to the rescue!

*GIPHY Anywhere* is a status bar item which allows you to quickly browse GIPHY for gifs.

<p align=center>
<img src="https://raw.githubusercontent.com/bacongravy/giphy-anywhere/images/screenshot.gif">
</p>

## Installation

*GIPHY Anywhere* requires macOS, and is installed using [Homebrew](https://brew.sh):

```bash
brew cask install bacongravy/tap/giphy-anywhere
```

Open *GIPHY Anywhere* and the GIPHY icon will appear in the system menu bar. It will remain there across logouts and restarts until the status bar item is quit.

## Usage

Whenever the urge to gif strikes, open *GIPHY Anywhere* by clicking on the GIPHY icon in the system menu bar, search or browse for a gif to fit your mood, and then copy the URL of the found gif using one of the menu items. You can copy either the plain URL, ready for sending in a chat message, or the URL wrapped in Markdown, ready for insertion in a GitHub comment. Once you've copied, just paste and go.

## Acknowledgements

Huge thanks to GIPHY for providing a great service. This project is not affiliated with GIPHY in any way.

This project was inspired by https://github.com/cknadler/vim-anywhere, and by the rich gif culture at my place of work.

## Why?

I use the GIPHY keyboard on iOS every day, and I miss it whenever I'm using macOS. Seeing *vim-anywhere* on *Hacker News* gave me the motivation to solve my problem in a similar way. After prototyping a solution using an Automator workflow service and gathering feedback, I rewrote the project as a JavaScript for Automation (JXA) applet to provide a more reliable and consistent user experience across applications. When JXA stopped working in Mojave, I rewrote the project in Swift 4.
