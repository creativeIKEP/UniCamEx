#!/usr/bin/env python

import os
import json
import shutil
from pbxproj import XcodeProject

with open("UniCamExPostProcessData.json") as f:
    data = json.load(f)

entitlementsFileName = data["appName"] + ".entitlements"
shutil.copyfile(data["entitlementsPath"], data["buildDirPath"] + "/" + entitlementsFileName)

extensionDir = data["buildDirPath"] + "/jp.ikep.UniCamEx.Extension.systemextension"
if os.path.isdir(extensionDir) is False:
    shutil.copytree(data["systemextensionextensionPath"], extensionDir)

project = XcodeProject.load(data["xcodeProjPath"] + '/project.pbxproj')
project.add_project_flags("ENABLE_HARDENED_RUNTIME", "YES")
project.add_project_flags('CODE_SIGN_ENTITLEMENTS', entitlementsFileName)

script = "\
mkdir $CODESIGNING_FOLDER_PATH/Contents/Library; \
mkdir $CODESIGNING_FOLDER_PATH/Contents/Library/SystemExtensions; \
cp -r $SCRIPT_INPUT_FILE_0 $SCRIPT_OUTPUT_FILE_0;"

project.add_run_script(script, target_name=data["appName"], input_files=["$(SRCROOT)/jp.ikep.UniCamEx.Extension.systemextension"], output_files=["$(CODESIGNING_FOLDER_PATH)/Contents/Library/SystemExtensions/jp.ikep.UniCamEx.Extension.systemextension"])

project.save()
