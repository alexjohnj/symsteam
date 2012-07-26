//
//  SymbolicLinkCreator.m
//  SymSteam
//
//  Created by Alex Jackson on 12/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SymbolicLinkCreator.h"

@implementation SymbolicLinkCreator

- (id)initWithSymbolicLinkDestination:(NSURL *)sDir{
    self = [super init];
    if(self){
        _symbolicLinkDestination = sDir;
    }
    return self;
}

- (id)init{
    return [self initWithSymbolicLinkDestination:nil];
}

- (BOOL)createSymbolicLink:(NSError **)error{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    if(self.symbolicLinkDestination == nil){
        if(error != NULL){
            NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey : @"No destination was provided for the symbolic link." };
            *error = [[NSError alloc] initWithDomain:@"com.simplecode.symsteam"
                                                code:1
                                            userInfo:errorDetails];
        }
        return NO;
    }
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDirectory, YES); // get the user's application support directory. 
    NSString *applicationSupportDirectoryPath = directories[0];
    
    // build the path to the symbolic link
    NSString *symbolicLinkPath = [[applicationSupportDirectoryPath stringByAppendingPathComponent:@"Steam"] stringByAppendingPathComponent:@"SteamAppsSymb"];
    
    NSError *symbolicLinkCreationError;
    BOOL success = [fManager createSymbolicLinkAtPath:symbolicLinkPath 
                                  withDestinationPath:self.symbolicLinkDestination.path 
                                                error:&symbolicLinkCreationError];
    if(success)
        return YES;
    
    else{
        if(*error != NULL)
            *error = symbolicLinkCreationError;
        
        return NO;
    }
}

@end
