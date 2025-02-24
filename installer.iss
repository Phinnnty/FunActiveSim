[Setup]
AppName=Activity Simulator
AppVersion=1.0.0
DefaultDirName={pf}\Activity Simulator
DefaultGroupName=Activity Simulator
OutputDir=Output
OutputBaseFilename=ActivitySimulator_Setup
Compression=lzma
SolidCompression=yes
SetupIconFile=icon.ico

[Files]
Source: "dist\ActivitySimulator\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Activity Simulator"; Filename: "{app}\ActivitySimulator.exe"
Name: "{commondesktop}\Activity Simulator"; Filename: "{app}\ActivitySimulator.exe"

[Run]
Filename: "{app}\ActivitySimulator.exe"; Description: "Launch Activity Simulator"; Flags: postinstall nowait 