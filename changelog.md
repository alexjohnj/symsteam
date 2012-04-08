## Beta 1 (0.2)

### Sunday 8<sup>th</sup> of April

- Growl notifications for a variety of events in the application. 
- A total rewrite of the underlying application has taken place. SymSteam no longer scans drives, rather it will resolve the symbolic link you point it to and only scan at that path for the SteamApps folder. This makes SymSteam substantially faster now.
- The preferences window has been redesigned and now looks like a preferences window. The window also features a new about section with information about SymSteam and credits to those who made the libraries used in SymSteam. 
- An autoupdate system has been added to SymSteam. 
- The first run setup experience has been improved greatly. The instructions are now a lot clearer and SymSteam includes a small “wizard” to help create a symbolic link to the SteamApps folder on your external hard drive. 
- SymSteam will now attempt to repair any problems with the naming of your SteamApps folder when launched with limited success. 
- SymSteam will now detect if your external hard drive is connected and update the SteamApps folders accordingly on launch. 
- The majority of alerts and popups in SymSteam (mainly file open dialogues) are now sheets attached to a window. 
- If SymSteam is quit while a Steam drive is connected, it will revert the SteamApps folders so that is better prepared for when it's relaunched. 

## 0.1.5

- Added a basic, potentially buggy, preferences window that allows you to change the location of the local and symbolic SteamApps folders. 
- Improved drive management. SymSteam now keeps track of which drives aren't steam drives far better and won't rename the SteamApps folder if a non steam drive is unplugged whilst a steam drive is still plugged in. 
- Slightly sped up searching of drives for a SteamApps folder. 

## 0.1

First release