using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.Scripting.Python;
using UnityEngine;

namespace UniCamEx.Editor {
    public class MacXcodeProjPostProcess
    {
        // You must change your systemextension Bundle Identifier.
        private static string extensionBundleID = "jp.ikep.UniCamEx.Extension.systemextension";

        [PostProcessBuild (100)]
        public static void OnPostProcessBuild(BuildTarget buildTarget, string path)
        {
            if (buildTarget != BuildTarget.StandaloneOSX)
            {
                return;
            }
            var isCreateXcodePrjStr = EditorUserBuildSettings.GetPlatformSettings(BuildPipeline.GetBuildTargetName(BuildTarget.StandaloneOSX), "CreateXcodeProject");
            if(isCreateXcodePrjStr != "true") {
                UnityEngine.Debug.LogWarning(
                    "Post process build of UniCamEx is canceld.\n" + 
                    "Please turn on 'Create Xcode Project' in the build settings for running post process build of UniCamEx.");
                return;
            }

            var buildDirInfo = new DirectoryInfo(path);
            var xcodeprojDirs = buildDirInfo.GetDirectories("*.xcodeproj");
            if(xcodeprojDirs.Length <= 0) {
                UnityEngine.Debug.LogWarning(
                    "Post process build of UniCamEx is canceld because .xcodeproj file does not found.");
                return;
            }

            // get post process source data dir
            var flipMatPath = AssetDatabase.GetAssetPath(Resources.Load<Material>("Flip"));
            var uniCamExDirInfo = new DirectoryInfo(flipMatPath).Parent.Parent;
            var srcPostProcessDataDir = new DirectoryInfo(Path.Combine(uniCamExDirInfo.FullName, "PostProcessData~"));

            // get post process dst data dir
            var assetDir = new DirectoryInfo(Application.dataPath);
            var dstProstProcessDataDir = new DirectoryInfo(assetDir.Parent.FullName);

            // run `pip install` for python post process
            string shellPath = Path.Combine(srcPostProcessDataDir.FullName, "pip_install.sh");
            Process process = new Process();
            process.StartInfo.FileName = "/bin/bash";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.Arguments = shellPath + " " + dstProstProcessDataDir;
            process.Start();

            process.WaitForExit();
            process.Close();

            // save files
            var text = "{";
            text += "\"appName\": \"" + Application.productName + "\",";
            text += "\"buildDirPath\": \"" + buildDirInfo.FullName + "\",";
            text += "\"xcodeProjPath\": \"" + xcodeprojDirs[0].FullName + "\",";
            text += "\"entitlementsPath\": \"" + Path.Combine(srcPostProcessDataDir.FullName, "UniCamEx.entitlements") + "\",";
            text += "\"systemextensionextensionPath\": \"" + Path.Combine(srcPostProcessDataDir.FullName, extensionBundleID) + "\"";
            text += "}";
            File.WriteAllText(Path.Combine(dstProstProcessDataDir.FullName, "UniCamExPostProcessData.json"), text);

            PythonRunner.RunFile(Path.Combine(srcPostProcessDataDir.FullName, "PostprocessBuild.py"));
        }
    }
}
