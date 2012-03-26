## What is SymSteam

SymSteam is for all you Mac SSD owners who like to play games (via Steam) on their computer too. Steam stores its games in a folder called SteamApps. Since this folder can get pretty big, people with SSDs like to put this folder on a external HDD and create a symbolic link to it where the folder used to be on the SSD. This is awesome for big games, but smaller, puzzle like games will be unplayable if you don't have your HDD on you. These are suited to being stored on your SSD since they're fairly small and lightweight. SymSteam manages two SteamApps folders. One of them is actually the symbolic link to your HDD's SteamApps folder, the other is a SteamApps folder stored on your local hard drive for smaller games. When a drive is plugged in, the local SteamApps folder is renamed to something else (like SteamAppsLoc) and the symbolic link is renamed to SteamApps, so you can play games off your HDD. When the HDD is unplugged, the symbolic link is renamed to something like SteamAppsSymb and the local SteamApps folder is renamed to SteamApps, so you can play games off of your internal SSD. It's pretty simple and can be quite handy. 

## Setup

Version 0.2 has significantly shortened the previously complicated set-up of SymSteam. 

1. Make a copy of your SteamApps folder (~/Library/Application Support/Steam/SteamApps) on your external hard drive.
2. Create a symbolic link to the SteamApps folder (now located on your external hard drive) in the same directory as your SteamApps folder (on your internal drive). 
3. Launch SymSteam and choose the local and symbolic SteamApps folders in the first run window. 
4. That's it! So much easier. 
5. You may want to add SymSteam to your list of applications that launch on login. 

During setup, SymSteam will rename the symbolic SteamApps folder to "SteamAppsSymb" and, while your external Steam drive is connected, your local SteamApps folder will be renamed to "SteamAppsLoc".  

## Known Bugs/Problems

Find a bug? Post it on the issues page.

- If your hard drive has a lot of files on it, it will take a while for SymSteam to detect the SteamApps folder and hence rename the symbolic link. 
- There's no way of knowing what SymSteam is doing. 
- There's no (easy) way to change the paths to the local SteamApps folder and the symbolic link after the first run. To change them, delete the SymSteam plist file. 

## To Do

- Add the ability to specify what drive to scan so that SymSteam doesn't scan *every* drive you plug in.
- <del>Add a preferences window so you can change the folder locations.</del>✓
- <del>Add Growl notifications so you can get an idea of what SymSteam is doing when a drive is plugged in.</del> ✓
- Add autoupdate.
- Test
- <del>Fix b</del>ugs (Partly done)

## License

DWTFYWWTCJDBE licence (Do whatever the fuck you want with this code just don't be evil licence)