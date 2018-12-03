Shell = new ActiveXObject("WScript.Shell");
//StartupPath = Shell.SpecialFolders("Startup"); NG now
//StartupPath = Shell.SpecialFolders("Desktop");
// 1->ProgramData\Microsoft\Windows\Start Menu
// 2->ProgramData\Microsoft\Windows\Start Menu\Programs
// 3->ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
// 4->User Desktop
// 5->User AppData\Roaming
// 6->User AppData\Roaming\Microsoft\Windows\Printer Shortcuts
// 7->User AppData\Roaming\Microsoft\Windows\Templates
// 8->Windows\Fonts
// 9->User AppData\Roaming\Microsoft\Windows\Network Shortcuts
// 10->User Desktop
// 11->User AppData\Roaming\Microsoft\Windows\Start Menu
// 12->User AppData\Roaming\Microsoft\Windows\SendTo
// 13->User AppData\Roaming\Microsoft\Windows\Recent
// 14->User AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
// 15->User Favorites
// 16->User Documents
// 17->User AppData\Roaming\Microsoft\Windows\Start Menu\Programs
StartupPath = Shell.SpecialFolders(14);

link = Shell.CreateShortcut(StartupPath + "\\myhotkey.lnk");
link.Description = "a firewall authentication script";
//link.HotKey = "CTRL+ALT+SHIFT+l";
//link.IconLocation = ".exe,1";
link.TargetPath = Shell.CurrentDirectory + "\\myhotkey.exe";
link.WorkingDirectory = Shell.CurrentDirectory
link.WindowStyle = 3;
link.Save();
WScript.Echo(StartupPath);
//WScript.Echo("OK");
