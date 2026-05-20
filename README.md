# Hydit

**HIDE IT!**

I mean **Hydit** (as in **hy**drus e**dit**) is a lightweight feature rich Hydrus client for Android written in Flutter

## Features

### Browse your Hydrus database

Search for one or multiple tags, sort results and get to browsing



### View images and videos

Hydit has a built-in media viewer with support for gestures, zooming and quick navigation



### Manage tags

Select one or more files, open tag editor, add new tags or remove existing tags

## Supported platforms

- Android

*Note:* This app is developed for Android, so a lot of features is gesture based and designed for a small screen. It is possible to bring this app to other platforms, it's just that I don't have IOS devices and on desktop you can use the original Hydrus client or something like [hydrui](https://hydrui.dev/en/).

## Quick start

> Before you start BACK UP YOUR DATABASE! Hydit is unlikely to break anything, but it definitely has the capability to do so. Remember that I'm not a professional dev and I can mess things up. So, backup your stuff and keep an eye on your actual database

1. Install the latest version from [Releases](https://github.com/BashCooler/hydit/releases)
2. Enable API in your Hydrus client, follow these [instructions](https://hydrusnetwork.github.io/hydrus/client_api.html)
3. In your Hydrus client navigate to `services -> review services -> local -> client api`, add a new key with "permits everything" checked, copy the newly created access key
4. Open Hydit, navigate to settings, paste the key in `API Key` field, specify the Hydrus `URL`, press `Verify and save`. If everything is done properly you will see the success notification

## Roadmap

The next big feature is uploading files from your Android device to Hydrus

## Contributing

Contributions are always welcome!

Feel free to ask any questions on how the things work if you want to improve something and don't know where to start or just out of curiosity.

Notes on submitting a PR:
- Try to keep the codebase simple
- Don't overuse the AI. I'm fine with using something like Codex as a tool, but 1000+ lines of unreadable undocumented mess will not be appreciated and may be rejected even if it works
