/* PPrefFastTrack - j.ashton */

#import <Cocoa/Cocoa.h>
#import "PFastTrackConf.h"

@interface PPrefFastTrack : NSObject
{
    IBOutlet NSTextField *alias;
    IBOutlet NSButton *clearNodes;
    
    PFastTrackConf *fasttrack_conf;
}
- (void)readConfFiles;

- (void)disable;
- (void)enable;

- (IBAction)newAlias:(id)sender;
- (IBAction)clearNodesFile:(id)sender;

@end
