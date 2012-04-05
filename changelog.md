## 0.2

- Growl notifications for a variety of events in the application. 
- Total rewrite of the underlying logic. The setup of SymSteam has been greatly simplified and the management of connected drives has been improved greatly. 
- Much faster scanning times for people with things other than a SteamApps folder on their external hard drive. A “shallow” scan is now performed first (only directories on the root of the drive are checked) before a “deep” scan is performed (where sub-directories are checked) if no SteamApps folder is found on the root of the drive. Previously only a deep scan was performed, which was very slow for people with folders other than the SteamApps folder on their external hard drive. 
- No longer scans hidden folders and package files when performing a deep scan. 

## 0.1.5

- Added a basic, potentially buggy, preferences window that allows you to change the location of the local and symbolic SteamApps folders. 
- Improved drive management. SymSteam now keeps track of which drives aren't steam drives far better and won't rename the SteamApps folder if a non steam drive is unplugged whilst a steam drive is still plugged in. 
- Slightly sped up searching of drives for a SteamApps folder. 

## 0.1

First release