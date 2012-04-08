## What is SymSteam

SymSteam is for all you Mac SSD owners who like to play games (via Steam) on their computer too. Steam stores its games in a folder called SteamApps. Since this folder can get pretty big, people with SSDs like to put this folder on a external HDD and create a symbolic link to it where the folder used to be on the SSD. This is awesome for big games, but smaller, puzzle like games will be unplayable if you don't have your HDD on you. These are suited to being stored on your SSD since they're fairly small and lightweight. SymSteam manages two SteamApps folders. One of them is actually the symbolic link to your HDD's SteamApps folder, the other is a SteamApps folder stored on your local hard drive for smaller games. When a drive is plugged in, the local SteamApps folder is renamed to something else (like SteamAppsLoc) and the symbolic link is renamed to SteamApps, so you can play games off your HDD. When the HDD is unplugged, the symbolic link is renamed to something like SteamAppsSymb and the local SteamApps folder is renamed to SteamApps, so you can play games off of your internal SSD. It's pretty simple and can be quite handy. 

## Setup

Beta 1 (version 0.2) has significantly shortened the previously complicated set-up of SymSteam. 

1. Launch SymSteam, follow the onscreen instructions.  

## Known Bugs/Problems

There'll be bugs in there, mainly relating to logic issues. Fixing them's (touch wood) easy, it's finding them that's hard. Since I don't have a lot of time to test all the usage cases of SymSteam, if you could report any bugs, that'd be great! 

## To Do

- <del>Add the ability to specify what drive to scan so that SymSteam doesn't scan *every* drive you plug in.</del>✓
- <del>Add a preferences window so you can change the folder locations.</del>✓
- <del>Add Growl notifications so you can get an idea of what SymSteam is doing when a drive is plugged in.</del> ✓
- <del>Add autoupdate.</del>✓
- Test
- <del>Fix b</del>ugs (Partly done)
- Come up with some way to present errors to the user, possibly filing a GitHub issue in the process. 

## License

DWTFYWWTCJDBE licence (Do whatever the fuck you want with this code just don't be evil licence)