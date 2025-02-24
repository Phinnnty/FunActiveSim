#define MyAppName "Activity Simulator"
#define MyAppVersion "1.1.0"
#define MyAppExeName "ActivitySimulator.exe"

[Setup]
; Basic Application Information
AppId={{YOUR-UNIQUE-GUID-HERE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}

; Important: These settings make it a user-level install
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
; Install in user's AppData folder instead of Program Files
DefaultDirName={userappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Compression Settings
Compression=lzma
SolidCompression=yes

; Visual Settings
SetupIconFile=icon.ico
WizardStyle=modern

; Output Settings
OutputDir=Installer
OutputBaseFilename=ActivitySimulator_Setup

; Additional Settings
AllowNoIcons=yes
; Don't create uninstall registry entries
CreateUninstallRegKey=no
; Don't show up in Add/Remove Programs
UpdateUninstallLogAppName=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
Name: "startupicon"; Description: "Start with Windows"; Flags: unchecked

[Files]
Source: "dist\ActivitySimulator\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\ActivitySimulator\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startupicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Activity Simulator"; Flags: nowait postinstall skipifsilent