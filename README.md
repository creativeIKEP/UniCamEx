# UniCamEx[WIP]
UniCamEx is a virtual camera for MacOS that can display textures output with Unity.

You can use in macOS 12.3 and later because UniCamEx use Apple's [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o).

## Install
UniCamEx can be installed with Unity Package Manager.
UniCamEx can be installed by adding following sections to your manifest file (`Packages/manifest.json`).

To the `scopedRegistries` section:
```
{
  "name": "creativeikep",
  "url": "https://registry.npmjs.com",
  "scopes": [ "jp.ikep" ]
}
```
To the `dependencies` section:
```
"jp.ikep.unicamex": "1.0.0"
```
Finally, the manifest file looks like below:
```
{
    "scopedRegistries": [
        {
            "name": "creativeikep",
            "url": "https://registry.npmjs.com",
            "scopes": [ "jp.ikep" ]
        }
    ],
    "dependencies": {
        "jp.ikep.unicamex": "1.0.0",
        ...
    }
}
```

## Usage
This repository has the demo that send textures from Unity.

Check a Unity [scene](/UniCamEx_Unity/Assets/Scenes/SampleScene.unity) and [scripts](/UniCamEx_Unity/Assets/Scripts) in the ["/Assets"](/UniCamEx_Unity/Assets) directory.

Also check the wiki page.

## Author
[IKEP](https://ikep.jp)

## LICENSE
Copyright (c) 2023 IKEP

[MIT](/LICENSE.md)