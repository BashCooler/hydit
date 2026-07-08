# Hydit

**HIDE IT!** I mean **Hydit** (as in **hy**drus e**dit**) is a lightweight feature rich Hydrus client for Android written in Flutter

## Screenshots

<table>
  <thead>
    <tr>
      <th>Home</th>
      <th>Viewer</th>
      <th>Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img width="240" height="536" alt="home" src="https://github.com/user-attachments/assets/ede6fec9-ddde-46c3-a0b2-e1171ebde82e" />
      </td>
      <td>
        <img width="240" height="536" alt="viewer" src="https://github.com/user-attachments/assets/158b45de-7865-4d9f-a14d-02a9ccbb5739" />
      </td>
      <td>
        <img width="240" height="536" alt="editor" src="https://github.com/user-attachments/assets/933852fd-476e-4f6e-9737-15530781e0c6" />
      </td>
    </tr>
  </tbody>
</table>

## Features

> *Note on URL import:* The import is considered successful when the link reaches Hydrus. To my knowledge, there's no consistent way to verify if the content was actually loaded afterward. If you know how to do it, let me know!

- **File and URL import** - via Android share menu
- **Tag search** - suggests, multiple tags, sorting options
- **Tag editor** - services, add/delete tags, one or multiple files
- **Swipe navigation** - like telegram

___

## Quick start

> *Reminder:* Before you start **BACK UP YOUR DATABASE!** Hydit is unlikely to break anything, but it definitely has the capability to do so

1. Install the latest version from [Releases](https://github.com/BashCooler/hydit/releases)
2. Enable API in your Hydrus client, follow these [instructions](https://hydrusnetwork.github.io/hydrus/client_api.html)
3. In your Hydrus client navigate to `services -> review services -> local -> client api`, add a new key with `permits everything` checked, copy the newly created access key
4. Open Hydit, navigate to settings, paste the key in `API Key` field, specify the Hydrus `URL`, press `Verify and save`. If everything is done properly you will see the success notification

## Contributing

Contributions are welcome! Just try to keep the codebase simple.

Feel free to ask any questions and share your ideas.

if you encounter a bug, report it in [Issues](https://github.com/BashCooler/hydit/issues). 

## See also

- [hydrui](https://hydrui.dev/en/) - a web-based client for Hydrus network
- [LoliSnatcher](https://github.com/NO-ob/LoliSnatcher_Droid) - a powerful multibooru client with support for batch downloading 

## Licence

Hydit is licensed under the MIT License
