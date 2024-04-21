# UniCamEx
![UniCamEx_demo](https://user-images.githubusercontent.com/34697515/243058841-e07ced4d-5d55-469f-bac0-0a88cdf6a90e.gif)

UniCamEx is a virtual camera for MacOS that can display textures output from Unity.

You can use in macOS 12.3 and later because UniCamEx use Apple's [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o).

## Usage
### Usage for Develop send textures from Unity Editor
This repository has the demo that send textures from Unity Editor.

Check a Unity [scene](https://github.com/creativeIKEP/UniCamEx/blob/v1.1.0/UniCamEx_Unity/Assets/Scenes/SampleScene.unity).

#### 1. Install
UniCamEx can be installed with Unity Package Manager.

UniCamEx can be installed from npm or GitHub URL.

##### Install from npm (Recommend)
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
"jp.ikep.unicamex": "1.2.0"
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
        "jp.ikep.unicamex": "1.2.0",
        ...
    }
}
```

##### Install from GitHub URL 
UniCamEx can be installed by adding below URL on the Unity Package Manager's window
```
https://github.com/creativeIKEP/UniCamEx.git?path=UniCamEx_Unity/Packages/UniCamEx#v1.2.0
```
or, adding below sentence to your manifest file(`Packages/manifest.json`) `dependencies` block. Example is below.
```
{
  "dependencies": {
    "jp.ikep.unicamex": "https://github.com/creativeIKEP/UniCamEx.git?path=UniCamEx_Unity/Packages/UniCamEx#v1.2.0",
    ...
  }
}

```

#### 2. Send textures from Unity Editor
You can send camera rendered images with adding a `UniCamExSender` component to camera in your scenes.
If you want to send any video, you can do so by directly using the `UniCamExPlugin` class.
Please refer to `UniCamExSender` class for usage instructions.

#### 3. Install an Auxiliary app for UniCamEx
Download `UniCamExExtensionInstaller.zip` for auxiliary app of UniCamEx from [release page](https://github.com/creativeIKEP/UniCamEx/releases/latest) and Open the zip file.

**Move `UniCamExExtensionInstaller.app` to `~/Applications` directory** and run `UniCamExExtensionInstaller.app`.

#### 4. Install UniCamEx Virtual Camera
Push `Install` button.

Allow using System Extension from the Mac setting if the dialog that blocked System Extension is displayed.

<img width="716" alt="UniCamExInstallerDialog" src="https://user-images.githubusercontent.com/34697515/243059855-6055772a-05f2-40e6-aa55-7ae249c787f7.png">

<img width="491" alt="UniCamExInstallerSecurityAllowDialog" src="https://user-images.githubusercontent.com/34697515/243059932-81f921eb-c410-4243-85e6-0a80a6716ab3.png">

Then, you can select the camera named "UniCamEx" with any camera appication and can see textures output from Unity Editor！

<img width="1172" alt="SendTextureFromUnityEditor" src="https://user-images.githubusercontent.com/34697515/243060010-18464804-4efb-4f04-b056-d3f7a9d57f6a.png">

### Usage for Build the Standalone App
You must enroll the [Apple Developer Program membership](https://developer.apple.com/programs/) for building the app used System Extension.

#### 1. Clone this repository
You must build UniCamEx project for embeding to your the Standalone App.
So, you need to clone this repository.

#### 2. Copy UniCamEx's Unity Package to Your Unity Project
Copy `UniCamEx/UniCamEx_Unity/Packages/UniCamEx` directory to `<Your Unity Project>/Packages` directory.

#### 3. Build UniCamEx Xcode Project with Your Custom Configuration.
1. Open `UniCamEx/UniCamEx/UniCamEx.xcodeproj`.
2. Change to your custom Bundle Identifier in `Extension` target and the name of the App Groups in the `Extension` target.
The name of the App Groups in the `Extension` target must start with the Bundle Identifier in the `Extension` target.
Also, sign in with your Apple developer account.
<img width="671" alt="3-2" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/b4d37c9a-1fb8-4b75-938d-f5081e58f432">

3. Change to your custom configuration in  `UniCamEx/UniCamEx/UniCamExConfig.swift`.
4. Set `Build Configuration` to `Release`, and build `Extension` and `UniCamExBundle` in targets.
<img width="814" alt="3-4" src="https://github.com/creativeIKEP/UniCamEx/assets/34697515/80939423-c129-4140-82ca-5c14fd7e706d">

#### 4. Integrate Your Custom Built Items to Unity.
1. Replace from `<Your Unity Project>/Packages/UniCamEx/PostProcessData~/jp.ikep.UniCamEx.Extension.systemextension` to your built `.systemextension`.
2. Replace from `<Your Unity Project>/Packages/UniCamEx/Plugins/macOS/UniCamExBundle.bundle` to your built `UniCamExBundle.bundle`.
3. Rewrite from `jp.ikep.UniCamEx.Extension.systemextension` to your built `.systemextension` file name in [`<Your Unity Project>/Packages/UniCamEx/Scripts/Editor/MacXcodeProjPostProcess.cs`](https://github.com/creativeIKEP/UniCamEx/blob/v1.1.0/UniCamEx_Unity/Packages/UniCamEx/Scripts/Editor/MacXcodeProjPostProcess.cs#L11-L12) and [`<Your Unity Project>/Packages/UniCamEx/PostProcessData~/PostprocessBuild.py`](https://github.com/creativeIKEP/UniCamEx/blob/v1.1.0/UniCamEx_Unity/Packages/UniCamEx/PostProcessData~/PostprocessBuild.py#L8-L9).

#### 5. Coding for Send textures from Unity
You can send camera rendered images with adding a `UniCamExSender` component to camera in your scenes.
Also, you can send textures using the `UniCamExPlugin.Send` method.

#### 6. Export Xcode Project with Unity
**Turn on "Create Xcode Project"** on the Build Settings window.

Also, **build from the "Clean Build..." button**.

Exporting Xcode Project can does the necessary settings for [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o).
Necessary settings for [Camera Extension with Core Media I/O](https://developer.apple.com/documentation/coremediaio/creating_a_camera_extension_with_core_media_i_o) is set with post process build of UniCamEx.
Post process build of UniCamEx may not work if you did not build from the "Clean Build..." button.

<img width="625" alt="UnityBuildSettings" src="https://user-images.githubusercontent.com/34697515/243060045-7342da5e-dc8f-48ea-b350-a2225d0d26ae.png">

#### 7. Build .app with Xcode
Open exported `.xcodeproj` file with Xcode and sign in with your Apple developer account.

You must enroll the [Apple Developer Program membership](https://developer.apple.com/programs/) for building the app used System Extension.

You can build an app after sign in with Apple developer account that enrolled Apple Developer Program membership.

#### 8. Run the Built App
**Move built app from build directory to `~/Applications` directory** and run your app.

Allow using System Extension from the Mac setting if the dialog that blocked System Extension is displayed.

<img width="255" alt="BuildAppDialog" src="https://user-images.githubusercontent.com/34697515/243060103-ffd8a674-a7a4-4b16-958a-a7d4162abdc4.png">

<img width="490" alt="BuildAppSecurityAllowDialog" src="https://user-images.githubusercontent.com/34697515/243060158-d4e271fa-f45a-41cf-ab1d-5aac8d44b9f2.png">

Then, you can select virtual camera with any camera appication and can see textures output from your app made with Unity！

![SendTextureFromBuildApp](https://user-images.githubusercontent.com/34697515/243060218-c4e6f9fc-ae49-48ed-ad8f-7559c22b6179.png)


## Author
[IKEP](https://ikep.jp)

## LICENSE
Copyright (c) 2023 IKEP

[MIT](/LICENSE.md)

## Others
- UniCamEx implementation is inspired by article below and I referenced it. Thanks!
  - https://qiita.com/fuziki/items/405c681a0cae702ad092