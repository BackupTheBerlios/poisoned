//
//  PPrefPlugins.m
//  PoisonGiFT
//
//  Created by Jay Ashton on Tue Sep 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PPrefPlugins.h"
#import "PGiFTConf.h"


@implementation PPrefPlugins
- (void)awakeFromNib
{
    [self readConfFiles];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (plugins) [plugins release];
    [super dealloc];
}

- (void)enable
{
    [buttonOpenFT setEnabled:YES];
    [buttonGnutella setEnabled:YES];
    [buttonFastTrack setEnabled:YES];
    [buttonOpenNap setEnabled:YES];
}

- (void)disable
{
    [buttonOpenFT setEnabled:NO];
    [buttonGnutella setEnabled:NO];
    [buttonFastTrack setEnabled:NO];
    [buttonOpenNap setEnabled:NO];
}

- (void)readConfFiles
{
    if (gift_conf=[PGiFTConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }

    [gift_conf read];

    plugins = [[NSMutableArray alloc] init];

    plugins = [[gift_conf optionForKey:@"plugins"] mutableCopy];

    if ([plugins containsObject:@"OpenFT"])
        [buttonOpenFT setState:NSOnState];
    if ([plugins containsObject:@"Gnutella"])
        [buttonGnutella setState:NSOnState];
    if ([plugins containsObject:@"FastTrack"])
        [buttonFastTrack setState:NSOnState];
    if ([plugins containsObject:@"OpenNap"])
        [buttonOpenNap setState:NSOnState];
    //if (plugins) [plugins autorelease];

     
    
}

- (IBAction)buttonOpenFTChanged:(id)sender
{

    if (![plugins containsObject:@"OpenFT"]) {
        [plugins addObject:@"OpenFT"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"OpenFT"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
        
}

- (IBAction)buttonGnutellaChanged:(id)sender
{

    if (![plugins containsObject:@"Gnutella"]) {
        [plugins addObject:@"Gnutella"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"Gnutella"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}

- (IBAction)buttonFastTrackChanged:(id)sender
{

    if (![plugins containsObject:@"FastTrack"]) {
        [plugins addObject:@"FastTrack"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"FastTrack"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}

- (IBAction)buttonOpenNapChanged:(id)sender
{

    if (![plugins containsObject:@"OpenNap"]) {
        [plugins addObject:@"OpenNap"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"OpenNap"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}
@end
