/* j.ashton */

#import "PPrefFastTrack.h"
#import "PFastTrackConf.h"

@implementation PPrefFastTrack
- (void)awakeFromNib
{
    [self readConfFiles];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)enable
{
    [alias setEnabled:YES];
}

- (void)disable
{
    [alias setEnabled:NO];
}

- (void)readConfFiles
{
    if (fasttrack_conf=[PFastTrackConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }
    
    [fasttrack_conf read];
    
    [alias setStringValue:[fasttrack_conf optionForKey:@"alias"]];
    [port setIntValue:[[fasttrack_conf optionForKey:@"port"]intValue]];
    [forwardPort setIntValue:[[fasttrack_conf optionForKey:@"forwarding"]intValue]];
    [enableBanList setIntValue:[[fasttrack_conf optionForKey:@"banlist_filter"]intValue]];
}

- (IBAction)newAlias:(id)sender
{
    [fasttrack_conf setValue:[sender stringValue] forKey:@"alias"];
    [self readConfFiles];
}

- (IBAction)clearNodesFile:(id)sender
{
 int button = NSRunAlertPanel(@"FastTrack Nodes File",
 @"Are you sure you want to clear the FastTrack Nodes File now?", @"OK", @"Cancel", nil);
    if(NSOKButton == button)
        {
            NSString *nodesFile = 
                    [[[PConfigurationEditor giFThome]
                    stringByAppendingPathComponent:@"FastTrack"]
                    stringByAppendingPathComponent:@"nodes"];
            NSFileManager *file_manager;
            file_manager = [NSFileManager defaultManager];
            if (![file_manager fileExistsAtPath:nodesFile])
                {
                    NSLog(@"nodes not found");
                    return;
                }
            [file_manager removeFileAtPath:nodesFile handler:nil];
            NSLog(@"nodes removed");
            }
            [self readConfFiles];
        }

- (IBAction)newPort:(id)sender
{
    [fasttrack_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"port"];
    [self readConfFiles];
}
- (IBAction)portForwardChanged:(id)sender
{
    if ([forwardPort state]==NSOnState)
    {
        [forwardPort setEnabled:NO];
    }
    else
    {
        [forwardPort setEnabled:YES];
    }

    [fasttrack_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"forwarding"];

    [self readConfFiles]; 
}
- (IBAction)banListChanged:(id)sender
{
    if ([enableBanList state]==NSOnState)
    {
        [enableBanList setEnabled:NO];
    }
    else
    {
        [enableBanList setEnabled:YES];
    }

    [fasttrack_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"banlist_filter"];

    [self readConfFiles];  
}
@end
