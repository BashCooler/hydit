# Hydit

**HIDE IT!** I mean **Hydit** (as in **hy**drus e**dit**) is a lightweight feature rich Hydrus client for Android written in Flutter

## Features

### Send URL, file or multiple files to Hydrus

> Sharing URL is not recommended. This operation is considered successful if the link reaches the Hydrus client. However, if the client tries to import the file with the provided URL and fails we really have no clue about it. Best practice is to send the file itself from your gallery or browser or whatever. This way we can be sure that the file is successfully added to Hydrus database

Use Android share menu to send a URL, a file or multiple files to Hydrus. Hydit will show you a notification with results

___

### Browse your Hydrus database

Search for one or multiple tags, sort results and get to browsing. Hydit has a built-in media viewer with support for gestures, zooming and quick navigation.

<table>
  <thead>
    <tr>
      <th>Gallery</th>
      <th>Viewer</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img width="240" height="536" alt="search" src="https://github.com/user-attachments/assets/23cc3731-cc5d-4c24-a6c8-7620d6c235cf" />
      </td>
      <td>
        <img width="240" height="536" alt="view" src="https://github.com/user-attachments/assets/b306ffd3-6981-488a-b9ca-c7e3411ed469" />
      </td>
    </tr>
  </tbody>
</table>

___

### Manage tags

Select one or multiple files, open tag editor, add new tags or remove existing tags

<table>
  <thead>
    <tr>
      <th>Single file</th>
      <th>Batch editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img width="240" height="536" alt="edit" src="https://github.com/user-attachments/assets/07c02c2e-1929-4ebf-84f1-db0002a892d9" />
      </td>
      <td>
        <img width="240" height="536" alt="batch" src="https://github.com/user-attachments/assets/b173d1b9-3abd-498e-b8cd-605735c62d49" />
      </td>
    </tr>
  </tbody>
</table>

## Quick start

> Before you start BACK UP YOUR DATABASE! Hydit is unlikely to break anything, but it definitely has the capability to do so. Keep an eye on your actual database

1. Install the latest version from [Releases](https://github.com/BashCooler/hydit/releases)
2. Enable API in your Hydrus client, follow these [instructions](https://hydrusnetwork.github.io/hydrus/client_api.html)
3. In your Hydrus client navigate to `services -> review services -> local -> client api`, add a new key with "permits everything" checked, copy the newly created access key
4. Open Hydit, navigate to settings, paste the key in `API Key` field, specify the Hydrus `URL`, press `Verify and save`. If everything is done properly you will see the success notification

## Roadmap

Planned features:
- ~~namespace sorting~~ I tried. It's like impossible to do with a lot of search results, too damn network heavy. So... we should do something like *comics view*? Simply make a quick way to navigate through chapters, pages and stuff. I'll try to think of something

## Contributing

Contributions are always welcome! Just try to keep the codebase simple

Feel free to ask any questions on how the things work if you want to improve something and don't know where to start or just out of curiosity

## See also

- [hydrui](https://hydrui.dev/en/) - a web-based client for Hydrus network
- [LoliSnatcher](https://github.com/NO-ob/LoliSnatcher_Droid) - a powerful multibooru client with support for batch downloading 

## Licence

Hydit is licensed under the MIT License
