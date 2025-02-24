#define MyAppName "Activity Simulator"
#define MyAppVersion "1.0.0"
#define MyAppExeName "ActivitySimulator.exe"
#define MyAppGUID "A68AAEC1-5B59-4E9F-8EF9-46E0C4B1086C"  ; Generated unique GUID

[Setup]
; Basic Application Information
AppId={{{#MyAppGUID}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}

; User-level installation settings
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
; This will install to: C:\Users\<username>\AppData\Local\Activity Simulator
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Compression Settings
Compression=lzma
SolidCompression=yes

; Visual Settings
SetupIconFile=icon.ico
WizardStyle=modern

; Output Settings - Creates: ActivitySimulator_Setup.exe
OutputDir=Installer
OutputBaseFilename=ActivitySimulator_Setup

; Stealth Settings
AllowNoIcons=yes
CreateUninstallRegKey=no
UpdateUninstallLogAppName=no
; Minimize traces in system
SetupLogging=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
; Optional tasks during installation
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
Name: "startupicon"; Description: "Start with Windows"; Flags: unchecked

[Files]
; Main executable and all dependencies
Source: "dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Creates shortcuts if selected:
; Desktop: C:\Users\<username>\Desktop\Activity Simulator.lnk
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
; Startup: C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Activity Simulator.lnk
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startupicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Activity Simulator"; Flags: nowait postinstall skipifsilent