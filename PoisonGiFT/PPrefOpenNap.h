//
//  PPrefOpenNap.h
//  PoisonGiFT
//
//  Created by Jay Ashton on Sun Sep 14 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "POpenNapConf.h"


@interface PPrefOpenNap : NSObject {

    IBOutlet NSTextField *alias;
    IBOutlet NSButton *randomAlias;
    IBOutlet NSTextField *port;
    IBOutlet NSTextField *maxconn;
    IBOutlet NSButton *useNapigator;
    IBOutlet NSTextField *napigatorIP;

    POpenNapConf *opennap_conf;
}
- (void)readConfFiles;

- (void)disable;
- (void)enable;

- (IBAction)newAlias:(id)sender;
- (IBAction)randomAliasChanged:(id)sender;
- (IBAction)portChanged:(id)sender;
- (IBAction)maxconnChanged:(id)sender;
- (IBAction)useNapigatorChanged:(id)sender;
- (IBAction)napigatorIPChanged:(id)sender;

@end
