# GIPHY Anywhere

Sometimes you're composing a chat message or commenting on a pull request, and the need to insert a gif strikes, but opening a new browser window would totally break your flow. *GIPHY Anywhere* to the rescue!

*GIPHY Anywhere* is a status bar item which allows you to quickly browse GIPHY for gifs.

<p align=center>
<img src="https://raw.githubusercontent.com/bacongravy/giphy-anywhere/images/screenshot.gif">
</p>

## Installation

*GIPHY Anywhere* requires macOS, and is installed using [Homebrew](https://brew.sh):

```bash
brew cask install bacongravy/jxa/giphy-anywhere
```

The GIPHY icon will appear in your menu bar upon completion of installation.

*GIPHY Anywhere* automatically adds itself to your Login Items upon launch, and removes itself from your Login Items if you use the Quit menu item.

## Usage

Whenever the urge to gif strikes, open *GIPHY Anywhere* by clicking on the GIPHY icon in the system menu bar, search or browse for a gif to fit your mood, and then copy the URL of the found gif using one of the menu items. You can copy either the plain URL, ready for sending in a chat message, or the URL wrapped in Markdown, ready for insertion in a GitHub comment. Once you've copied, just paste and go.

## Acknowledgements

Huge thanks to GIPHY for providing a great service. This project is not affiliated with GIPHY in any way.

This project was inspired by https://github.com/cknadler/vim-anywhere, and by the rich gif culture at my place of work.

Additional references:

* https://gist.github.com/uchcode/be35f7b99ce4c6b74ad87aaf22e83835
* https://github.com/blackgate/cljs-jxa-starter

## Why?

I use the GIPHY keyboard on iOS every day, and I miss it whenever I'm using macOS. Seeing *vim-anywhere* on *Hacker News* gave me the motivation to solve my problem in a similar way. After prototyping a solution using an Automator workflow service and gathering feedback, I rewrote the project as a JavaScript for Automation applet to provide a more reliable and consistent user experience across applications. When JavaScript for Automation stopped working in Mojave, I rewrote the project in Swift 4.
