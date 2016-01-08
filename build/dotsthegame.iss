[Setup]
AppName=DotsTheGame
AppVersion=1.0
DefaultDirName={userappdata}\DotsTheGame
DefaultGroupName=DotsTheGame
OutputDir=..\build
OutputBaseFilename=DotsTheGameInstaller
VersionInfoCompany=Alexander Zhevzhyk

[Icons]
Name: "{commondesktop}\Dots The Game"; Filename: "{app}\dotsthegame.exe"
Name: "{group}\Dots The Game"; Filename: "{app}\dotsthegame.exe"
Name: "{group}\Uninstall Dots The Game"; Filename: "{uninstallexe}"

[Files]
Source: "../source/media/fonts/*.*"; DestDir: "{app}/src/media/fonts"
Source: "../source/media/icons/*.*"; DestDir: "{app}/src/media/icons"
Source: "../source/config/*.json"; DestDir: "{app}/src/config"