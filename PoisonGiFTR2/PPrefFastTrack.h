/* PPrefFastTrack - j.ashton */

#import <Cocoa/Cocoa.h>
#import "PFastTrackConf.h"

@interface PPrefFastTrack : NSObject
{
    IBOutlet NSTextField *alias;
    IBOutlet NSTextField *port;
    IBOutlet NSButton *clearNodes;
    IBOutlet NSButton *forwardPort;
    IBOutlet NSButton *enableBanList;
    
    PFastTrackConf *fasttrack_conf;
}
- (void)readConfFiles;

- (void)disable;
- (void)enable;

- (IBAction)newAlias:(id)sender;
- (IBAction)clearNodesFile:(id)sender;

- (IBAction)newPort:(id)sender;
- (IBAction)portForwardChanged:(id)sender;
- (IBAction)banListChanged:(id)sender;

@end
