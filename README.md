# SWTOR.app

Star Wars: The Old Republic app for macOS, working out of the box.

## How to install?

1. Download SWTOR-standalone.tar.gz from the [latest release](https://github.com/imanel/swtor-app/releases)
2. Decompress it (if you're using Safari it may do it for you)
3. Move SWTOR.app to /Applications folder
4. Run like any other app

## FAQ:

**I see a weird message for a second during first time running the app, what should I do?**

```
The Wine configuration in /Applications/SWTOR.app/Contents/Resources/prefix is being updated, please wait...
```

Please ignore this message, this is popping only during first boot and should not appear any further.
It's a side effect of the way the application is built and have no negative effects.
In theory it could be avoided by running application once before packaging it and providing to you, but that could
resoult in even different side effects, so it was left alone.

**Just after launching the first time the launcher updates itself several times, is that normal?**

Yes, the launcher that is downloadable is known to be quite old and with every new installation it will go into
update-restart cycle for several times. This should be a one-time case, and in future it will update only when needed.

**After logging in I see "PLAY" button active, but I cannot press it**

Please wait a moment - for some reason it takes couple seconds for launcher to figure out that it need to download
full game (or future update), it should start updating automatically soon.

**Application is not starting/application crashed**

Please create [an issue](https://github.com/imanel/swtor-app/issues) and provide your Mac model, macOS version,
and content of `~/Library/Logs/SWTOR.log` file.

**What is lite version?**

SWTOR-standalone is all-in-one package with no dependencies, including [Wine Crossover](https://github.com/Gcenx/homebrew-wine).
If you want to install you own version of Wine then SWTOR-lite is for you - no Wine inside and it will pick up any
version that is installed via homebrew and available via `/opt/homebrew/bin/wine`.
Please note that due to changes in macOS since Catalina win32 versions of binaries are not supported, which mean that
standard Wine (including wine-7.0) will not work - you need to use Crossover version, i.e one that is bundled with
standalone package version.

## How to build it by myself?

1. Make sure that you have homebrew installed
2. Check that you don't have any other Wine version installed (we're using [wine-crossover](https://github.com/Gcenx/homebrew-wine))
3. Run `./build.sh` to create Wine Prefix in `prefix` folder
4. Run `./package.sh` to create SWTOR.app and package it
5. You can find both lite and standalone version in `dist` folder

## Acknowledgment

This app would not be possible without [excellend script written by AgentRG](https://github.com/AgentRG/swtor_on_mac),
as well as [pre-compiled Crossover Wine provided by Gcenx](https://github.com/Gcenx/homebrew-wine).

## Support

If you like my work then consider supporting me:

[![Donate with Bitcoin](https://en.cryptobadges.io/badge/small/bc1qmxfc703ezscvd4qv0dvp7hwy7vc4kl6currs5e)](https://en.cryptobadges.io/donate/bc1qmxfc703ezscvd4qv0dvp7hwy7vc4kl6currs5e)

[![Donate with Ethereum](https://en.cryptobadges.io/badge/small/0xA7048d5F866e2c3206DC95ebFa988fF987c0BccB)](https://en.cryptobadges.io/donate/0xA7048d5F866e2c3206DC95ebFa988fF987c0BccB)
