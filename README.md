## What is SymSteam

SymSteam is for all you Mac SSD owners who like to play games (via Steam) on their computer too. Steam stores its games in a folder called SteamApps. Since this folder can get pretty big, people with SSDs like to put this folder on a external HDD and create a symbolic link to it where the folder used to be on the SSD. This is awesome for big games, but smaller, puzzle like games will be unplayable if you don't have your HDD on you. These are suited to being stored on your SSD since they're fairly small and lightweight. SymSteam manages to SteamApps folders. One of them is actually the symbolic link to your HDD's SteamApps folder, the other is a SteamApps folder stored on your local hard drive for smaller games. When a drive is plugged in, the local SteamApps folder is renamed to something else (like SteamAppsLoc) and the symbolic link is renamed to SteamApps, so you can play games off your HDD. When the HDD is unplugged, the symbolic link is renamed to something like SteamAppsSymb and the local SteamApps folder is renamed to SteamApps, so you can play games off of your internal SSD. It's pretty simple and can be quite handy. 

## Setup

At the moment, SymSteam requires a bit of a specific setup. This should change as more time is spent developing it. The full setup:

1. Copy your SteamApps folder (~/Library/Application Support/Steam/SteamApps) to an external hard drive. 
2. Create a symbolic link in ~/Library/Application Support/Steam to the SteamApps folder on your hard drive.
3. Rename the symbolic link folder to something other than SteamApps i.e *SteamAppsSymb*
4. Create a new folder in the ~/Library/Application Support/Steam folder and call it something like *SteamAppsLoc*, this is where the games on your SSD will be stored.
5. Launch SymSteam and follow the onscreen instructions. 
6. Plug in the drive with the SteamApps folder on and check that *SteamAppsSymb* gets renamed to *SteamApps*. 
7. Unplug the drive and check that:
	1. *SteamApps* (on your SSD) gets renamed to *SteamAppsSymb* (or whatever you called the folder). 
	2. *SteamAppsLoc* gets renamed to *SteamApps*.
8. You're ready to play games of your internal SSD now! 
9. Have some cake. If you're a developer, help fix bugs!

**Even if you don't follow the above procedure the application may work. I just can't guarantee!**
**Make sure you make a backup of your SteamApps folder!**

## Known Bugs/Problems

Find a bug? Post it on the issues page.

- If your hard drive has a lot of files on it, it will take a while for SymSteam to detect the SteamApps folder and hence rename the symbolic link. 
- There's no way of knowing what SymSteam is doing. 
- There's no (easy) way to change the paths to the local SteamApps folder and the symbolic link after the first run. To change them, delete the SymSteam plist file. 

## To Do

- Add the ability to specify what drive to scan so that SymSteam doesn't scan *every* drive you plug in.
- Add a preferences window so you can change the folder locations. 
- Add Growl notifications so you can get an idea of what SymbSteam is doing when a drive is plugged in. 
- Add autoupdate.
- Test
- Fix bugs

## License

DWTFYWWTCJDBE licence (Do whatever the fuck you want with this code just don't be evil licence)