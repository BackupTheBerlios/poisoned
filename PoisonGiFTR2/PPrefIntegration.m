//
//  PPrefIntegration.m
//  PoisonGiFTR2
//
//  Created by Julian Ashton on Thu Nov 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PPrefIntegration.h"


@implementation PPrefIntegration

- (void)awakeFromNib
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![userDefaults objectForKey:@"PMoveImages"])
       [userDefaults setBool:1 forKey:@"PMoveImages"];
       
    if(![userDefaults objectForKey:@"PMoveVideos"])
       [userDefaults setBool:1 forKey:@"PMoveVideos"];
       
    [self readConfFiles];
  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)readConfFiles;
{
    tempBool = [userDefaults boolForKey: @"PMoveImages"];
    [moveImages setState: (tempBool) ? NSOnState : NSOffState];
    
    tempBool = [userDefaults boolForKey: @"PMoveVideos"];
    [moveVideos setState: (tempBool) ? NSOnState : NSOffState];
    
}

/* IB Actions */
- (IBAction)moveImages: (id)sender;
{
    [userDefaults setBool: [sender intValue] forKey: @"PMoveImages"];
}

- (IBAction)moveVideos: (id)sender;
{
    [userDefaults setBool: [sender intValue] forKey: @"PMoveVideos"];
}
@end
