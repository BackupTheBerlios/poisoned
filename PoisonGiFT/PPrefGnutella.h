/* PPrefGnutella */

#import <Cocoa/Cocoa.h>
#import "PGnutellaConf.h"

@interface PPrefGnutella : NSObject
{
    IBOutlet NSTextField *port;
    IBOutlet NSTextField *proxy;
    
    PGnutellaConf *gnutella_conf;
}

- (void)readConfFiles;

- (void)disable;
- (void)enable;

- (IBAction)newPort:(id)sender;
- (IBAction)newProxy:(id)sender;
@end
