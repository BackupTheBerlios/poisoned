#import "PPrefGnutella.h"

@implementation PPrefGnutella

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
        [port setEnabled:YES];
        [proxy setEnabled:YES];
}

- (void)disable
{
        [port setEnabled:NO];
        [proxy setEnabled:NO];
}

- (void)readConfFiles
{
    if (gnutella_conf=[PGnutellaConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }
    
    [gnutella_conf read];
        
    [port setIntValue:[[gnutella_conf optionForKey:@"port"] intValue]];
    [proxy setStringValue:[gnutella_conf optionForKey:@"proxy"]];
}

- (IBAction)newPort:(id)sender
{
    [gnutella_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"port"];
    [self readConfFiles];
}

- (IBAction)newProxy:(id)sender
{
    [gnutella_conf setValue:[sender stringValue] forKey:@"proxy"];
    [self readConfFiles];
}

@end
