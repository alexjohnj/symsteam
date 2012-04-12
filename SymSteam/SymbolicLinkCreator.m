//
//  SymbolicLinkCreator.m
//  SymSteam
//
//  Created by Alex Jackson on 12/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SymbolicLinkCreator.h"

@implementation SymbolicLinkCreator

@synthesize symbolicLinkDestination = _symbolicLinkDestination;

-(id)initWithSymbolicLinkDestination:(NSURL *)sDir{
    self = [super init];
    if(self){
        _symbolicLinkDestination = sDir;
    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        _symbolicLinkDestination = [[NSURL alloc] initWithString:@"/"];
    }
    
    return self;
}

-(BOOL)createSymbolicLink:(NSError **)error{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    NSString *symbolicLinkPath = [[NSString alloc] initWithFormat:@"%@/Library/Application Support/Steam/SteamAppsSymb", NSHomeDirectory()];
    
    NSError *symbolicLinkCreationError;
    BOOL success = [fManager createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:self.symbolicLinkDestination.path error:&symbolicLinkCreationError];
    
    if(success)
        return YES;
    
    else{
        *error = symbolicLinkCreationError;
        return NO;
    }
    
}

@end
