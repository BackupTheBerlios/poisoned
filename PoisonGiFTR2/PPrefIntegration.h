//
//  PPrefIntegration.h
//  PoisonGiFTR2
//
//  Created by Julian Ashton on Thu Nov 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPrefIntegration : NSObject
{
    NSUserDefaults *userDefaults;
    
    BOOL tempBool;
    
    IBOutlet id moveImages;
    IBOutlet id moveVideos;
}

- (void)readConfFiles;

- (IBAction)moveImages:(id)sender;
- (IBAction)moveVideos:(id)sender;

@end
