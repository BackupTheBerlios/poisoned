//
//  PPrefPlugins.h
//  PoisonGiFT
//
//  Created by Jay Ashton on Tue Sep 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PGiFTConf.h"


@interface PPrefPlugins : NSObject {

    IBOutlet NSButton *buttonOpenFT;
    IBOutlet NSButton *buttonGnutella;
    IBOutlet NSButton *buttonFastTrack;
    IBOutlet NSButton *buttonOpenNap;

    PGiFTConf *gift_conf;

    NSMutableArray *plugins;
    
}
- (void)readConfFiles;

- (void)enable;
- (void)disable;

- (IBAction)buttonOpenFTChanged:(id)sender;
- (IBAction)buttonGnutellaChanged:(id)sender;
- (IBAction)buttonFastTrackChanged:(id)sender;
- (IBAction)buttonOpenNapChanged:(id)sender;

@end
