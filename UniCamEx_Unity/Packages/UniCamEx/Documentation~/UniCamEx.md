# UniCamEx
![UniCamEx_demo](https://github.com/creativeIKEP/UniCamEx/assets/34697515/6820d6b0-cc97-48ff-8c67-acd7b0e15d2f)

UniCamEx is a virtual camera for MacOS that can display textures output from Unity.

You can use in macOS 12.3 and later because UniCamEx use Apple's [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o).

## Install
UniCamEx can be installed with Unity Package Manager.

UniCamEx can be installed from npm or GitHub URL.

### Install from npm (Recommend)
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

### Install from GitHub URL 
UniCamEx can be installed by adding below URL on the Unity Package Manager's window
```
https://github.com/creativeIKEP/UniCamEx.git?path=UniCamEx_Unity/Packages/UniCamEx#v1.0.0
```
or, adding below sentence to your manifest file(`Packages/manifest.json`) `dependencies` block. Example is below.
```
{
  "dependencies": {
    "jp.ikep.unicamex": "https://github.com/creativeIKEP/UniCamEx.git?path=UniCamEx_Unity/Packages/UniCamEx#v1.0.0",
    ...
  }
}

```

## Usage
### Demo Sample
This repository has the demo that send textures from Unity.

Check a Unity [scene](https://github.com/creativeIKEP/UniCamEx/blob/v1.0.0/UniCamEx_Unity/Assets/Scenes/SampleScene.unity) and [scripts](https://github.com/creativeIKEP/UniCamEx/blob/v1.0.0/UniCamEx_Unity/Assets/Scripts) in the ["/Assets"](https://github.com/creativeIKEP/UniCamEx/blob/v1.0.0/UniCamEx_Unity/Assets) directory.

### Usage for Develop send textures from Unity Editor
#### 1. Send textures from Unity
Send textures with the `UniCamExPlugin.Send` method.
https://github.com/creativeIKEP/UniCamEx/blob/v1.0.0/UniCamEx_Unity/Assets/Scripts/TextureSender.cs#L1-L13

#### 2. Install an Auxiliary app for UniCamEx
Download `UniCamExExtensionInstaller.zip` for auxiliary app of UniCamEx from [release page](https://github.com/creativeIKEP/UniCamEx/releases/latest) and Open the zip file.

**Move `UniCamExExtensionInstaller.app` to `~/Applications` directory** and run `UniCamExExtensionInstaller.app`.

#### 3. Install UniCamEx Virtual Camera
Push `Install` button.

Allow using System Extension from the Mac setting if the dialog that blocked System Extension is displayed.

<img width="716" alt="Screenshot 2023-06-03 at 0 18 19" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/a70734e5-8de6-4d36-9236-33f8e5c8f6a6">

<img width="491" alt="Screenshot 2023-06-03 at 0 18 54" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/b44d28b8-bf32-4c8d-b2ce-c466cf82195f">

Then, you can select the camera named "UniCamEx" with any camera appication and can see textures output from Unity Editor！

<img width="1172" alt="Screenshot 2023-06-03 at 0 41 56" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/11230393-f34c-443a-8b13-01b1a2ba328f">

### Usage for Build the Standalone App
#### 1. Send textures from Unity
Send textures with the `UniCamExPlugin.Send` method.
https://github.com/creativeIKEP/UniCamEx/blob/v1.0.0/UniCamEx_Unity/Assets/Scripts/TextureSender.cs#L1-L13

#### 2. Export Xcode Project with Unity
**Turn on "Create Xcode Project"** on the Build Settings window.

Also, **build from the "Clean Build..." button**.

Exporting Xcode Project can does the necessary settings for [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o).
Necessary settings for [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o) is set with post process build of UniCamEx.
Post process build of UniCamEx may not work if you did not build from the "Clean Build..." button.

<img width="625" alt="image" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/d0bb9d70-0582-45a2-a768-1a39645bcbec">

#### 3. Build .app with Xcode
Open exported `.xcodeproj` file with Xcode and sign in with your Apple developer account.

You must enroll the [Apple Developer Program membership](https://developer.apple.com/programs/) for building the app used System Extension.

You can build an app after sign in with Apple developer account that enrolled Apple Developer Program membership.

#### 4. Run the Builded App
**Move builded app from build directory to `~/Applications` directory** and run your app.

Allow using System Extension from the Mac setting if the dialog that blocked System Extension is displayed.

<img width="255" alt="Screenshot 2023-06-03 at 0 19 32" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/05a01ce7-c88f-4bfc-aefa-74b2fed24877">

<img width="490" alt="Screenshot 2023-06-03 at 0 20 04" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/d5890ee7-81e9-41c7-9c8d-d9a8848139bb">

Then, you can select the camera named "UniCamEx" with any camera appication and can see textures output from your app made with Unity！

![image](https://github.com/creativeIKEP/UniCamEx/assets/34697515/a2175ce5-bcd0-43af-9248-bb0167396ae5)


## Author
[IKEP](https://ikep.jp)

## LICENSE
Copyright (c) 2023 IKEP

[MIT](/LICENSE.md)

## Others
- UniCamEx implementation is inspired by article below and I referenced it. Thanks!
  - https://qiita.com/fuziki/items/405c681a0cae702ad092