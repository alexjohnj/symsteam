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
    return [self initWithSymbolicLinkDestination:nil];
}

-(BOOL)createSymbolicLink:(NSError **)error{
    NSFileManager *fManager = [[NSFileManager alloc] init];
    
    if(self.symbolicLinkDestination == nil){
        if(error != NULL){
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No destination was provided for the symbolic link." forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"com.simplecode.symsteam"
                                                code:1
                                            userInfo:errorDetails];
        }
        return NO;
    }
    
    NSString *symbolicLinkPath = [[NSString alloc] initWithFormat:@"%@/Library/Application Support/Steam/SteamAppsSymb", NSHomeDirectory()];
    
    NSError *symbolicLinkCreationError;
    BOOL success = [fManager createSymbolicLinkAtPath:symbolicLinkPath withDestinationPath:self.symbolicLinkDestination.path error:&symbolicLinkCreationError];
    
    if(success)
        return YES;
    
    else{
        if(*error != NULL)
            *error = symbolicLinkCreationError;
        
        return NO;
    }
    
}

@end
