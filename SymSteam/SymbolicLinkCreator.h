//
//  SymbolicLinkCreator.h
//  SymSteam
//
//  Created by Alex Jackson on 12/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SymbolicLinkCreator : NSObject

@property (strong) NSURL *symbolicLinkDestination;

-(id)initWithSymbolicLinkDestination:(NSURL *)sDir;

-(BOOL)createSymbolicLink:(NSError **)error;

@end
