//
// PPrefOpenFT.m
// -------------------------------------------------------------------------
// Copyright (C) 2003 Poisoned Project (http://gottsilla.net/software.php?site=poisoned)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// ---------------------------------------------------------------------------

#import "PPrefOpenFT.h"

@implementation PPrefOpenFT

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
        [port setEnabled:YES];
        [http_port setEnabled:YES];
        [nodeClass setEnabled:YES];
}

- (void)disable
{
        [alias setEnabled:NO];
        [port setEnabled:NO];
        [http_port setEnabled:NO];
        [nodeClass setEnabled:NO];
        [tabView selectTabViewItemAtIndex:0];
}

- (void)readConfFiles
{
    if (openft_conf=[POpenFTConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }
    
    [openft_conf read];
    
    [alias setStringValue:[openft_conf optionForKey:@"alias"]];
    
    [port setIntValue:[[openft_conf optionForKey:@"port"] intValue]];
    [http_port setIntValue:[[openft_conf optionForKey:@"http_port"] intValue]];

    int class = [[openft_conf optionForKey:@"class"] intValue];
    switch (class) {
        case 1:
            [nodeClass selectItemWithTitle:@"USER"];
            [tabView selectTabViewItemAtIndex:0];
            break;
        case 3:
            [nodeClass selectItemWithTitle:@"SEARCH"];
            [tabView selectTabViewItemAtIndex:1];
            break;
        case 5:
            [nodeClass selectItemWithTitle:@"INDEX"];
            [tabView selectTabViewItemAtIndex:0];
            break;
        case 7:
            [nodeClass selectItemWithTitle:@"SEARCH & INDEX"];
            [tabView selectTabViewItemAtIndex:1];
            break;
        default:break;
    }
    
    [maxChilds setIntValue:[[openft_conf optionForKey:@"children"] intValue]];
    [dbLocation setStringValue:[openft_conf optionForKey:@"env_path"]];

    int priv = [[openft_conf optionForKey:@"env_priv"] intValue];
    if (priv==0) [private_env setState:NSOffState];
    else [private_env setState:NSOnState];
    
    
    long long cache;
    [[NSScanner scannerWithString:[openft_conf optionForKey:@"env_cache"]] scanLongLong:&cache];
    [cacheSize setStringValue:[NSString stringWithFormat:@"%d MB",(int)(cache/1024/1024)]];
    [totalCacheSize setIntValue:cache/1024];
}

- (void)displayHelp:(NSString *)file title:(NSString *)title
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:file ofType:@"rtf"];
    [helpTextView readRTFDFromFile:path];
    [helpPanel setTitle:title];
    [helpPanel makeKeyAndOrderFront:self];
}

- (IBAction)helpClasses:(id)sender
{
    [self displayHelp:@"OpenFTConfNodeClasses" title:@"OpenFT Help: Node Classes"];
}
- (IBAction)helpSEARCH:(id)sender
{
    [self displayHelp:@"OpenFTSEARCH" title:@"OpenFT Help: SEARCH Node"];
}
- (IBAction)helpPorts:(id)sender
{
    [self displayHelp:@"OpenFTPorts" title:@"OpenFT Help: Ports"];
}

// Had to change all actions for setAction: to newAction:
// more info here: http://cocoa.mamasam.com/MACOSXDEV/2002/09/2/46437.php
- (IBAction)newAlias:(id)sender
{
    [openft_conf setValue:[alias stringValue] forKey:@"alias"];
}

- (IBAction)newPort:(id)sender
{
    [openft_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"port"];
}

- (IBAction)newHTTP_port:(id)sender
{
    [openft_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"http_port"];
}

- (IBAction)newNodeClass:(id)sender
{
    [openft_conf setValue:[NSNumber numberWithInt:([nodeClass indexOfSelectedItem]*2+1)] forKey:@"class"];
    [self readConfFiles];
}

// SEARCH node settings
- (IBAction)browseDBLocation:(id)sender
{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    [open setCanChooseFiles:NO];
    [open setCanChooseDirectories:YES];
    int ret = [open 
        runModalForDirectory:NSHomeDirectory()
        file:nil
        types:nil
    ];
    if (ret==NSOKButton) {
        [openft_conf setValue:[[[open filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath] forKey:@"env_path"];
        [self readConfFiles];
    }
}

- (IBAction)changeDBLocation:(id)sender
{
        [openft_conf setValue:[sender stringValue] forKey:@"env_path"];
        [self readConfFiles];
}

- (IBAction)newMaxChilds:(id)sender
{
    [openft_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"children"];
    [self readConfFiles];
}

- (IBAction)newPrivate:(id)sender
{
    if ([sender state]==NSOnState) [openft_conf setValue:[NSNumber numberWithInt:1] forKey:@"env_priv"];
    else [openft_conf setValue:[NSNumber numberWithInt:0] forKey:@"env_priv"];
    [self readConfFiles];
}

- (IBAction)newTotalCacheSize:(id)sender
{
    int cache = [sender intValue];
    [totalCacheSize setIntValue:cache];
    [cacheSize setStringValue:[NSString stringWithFormat:@"%d MB",(int)(cache/1024)]];
    if ([[[NSApplication sharedApplication] currentEvent] type] != NSLeftMouseDown) //write to conf file on mouse up
    {
        [openft_conf setValue:[NSString stringWithFormat:@"%d",cache*1024] forKey:@"env_cache"];
        [self readConfFiles];
    }
}


@end
