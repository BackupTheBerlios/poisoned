//
// PPrefUploads.m
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

#import "PPrefUploads.h"

@implementation PPrefUploads

- (void)awakeFromNib
{
    share_completed = NO;
    NSArray *cols = [shareTable tableColumns];
    int i, count=[cols count];
    for (i=0;i<count;i++) [[[cols objectAtIndex:i] dataCell] setDrawsBackground:NO];
    [[shareTable tableColumnWithIdentifier:@"icon"] setDataCell:[[[NSImageCell alloc] init] autorelease]];

    shareSource = [[NSMutableArray alloc] init];

    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self readConfFiles];

    if ([userDefaults boolForKey:@"PRemoveCompletedUploads"]) [removeCompleted setState:NSOnState];
    else [removeCompleted setState:NSOffState];
    
    if ([userDefaults boolForKey:@"PRemoveCancelledUploads"]) [removeCancelled setState:NSOnState];
    else [removeCancelled setState:NSOffState];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedDirectoryChanged:) name:@"PCompletedDirectoryChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [shareSource release];
    [super dealloc];
}

- (void)completedDirectoryChanged:(NSNotification *)notification
{
    [self readConfFiles];
}

- (void)enable
{
    [addButton setEnabled:YES];
    [maxUploads setEnabled:YES];
    [maxPerUser setEnabled:YES];
}

- (void)disable
{
    [shareSource removeAllObjects];
    [shareTable reloadData];
    [addButton setEnabled:NO];
    [maxUploads setEnabled:NO];
    [maxPerUser setEnabled:NO];
}

- (void)readConfFiles
{
    if (gift_conf=[PGiFTConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }

    [gift_conf read];
    
    [shareSource autorelease];
    shareSource = [[gift_conf optionForKey:@"root"] mutableCopy];
    if ([shareSource count]==1 && [(NSString *)[shareSource objectAtIndex:0] length]==0) [shareSource removeObjectAtIndex:0];
    
    share_completed = NO;
    if ([[gift_conf optionForKey:@"share_completed"] intValue]) {
        share_completed = YES;
        [shareSource insertObject:
            [[[NSMutableAttributedString alloc] initWithString:[gift_conf optionForKey:@"completed"] attributes:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSColor darkGrayColor],NSForegroundColorAttributeName,
                nil]
            ] autorelease]
            atIndex:0
        ];
    }

    [shareTable reloadData];
    
    [maxUploads setIntValue:[[gift_conf optionForKey:@"max_uploads"] intValue]];
    
    [maxPerUser setIntValue:[[gift_conf optionForKey:@"max_peruser_uploads"] intValue]];
    
    [maxUpstream setIntValue:[[gift_conf optionForKey:@"upstream"] intValue]];
    
    [maxDownstream setIntValue:[[gift_conf optionForKey:@"downstream"] intValue]];
}

- (IBAction)cancelledPrefsChanged:(id)sender
{
    if ([removeCancelled state]==NSOnState) [userDefaults setBool:YES forKey:@"PRemoveCancelledUploads"];
    else [userDefaults setBool:NO forKey:@"PRemoveCancelledUploads"];
}

- (IBAction)completedPrefsChanged:(id)sender
{
    if ([removeCompleted state]==NSOnState) [userDefaults setBool:YES forKey:@"PRemoveCompletedUploads"];
    else [userDefaults setBool:NO forKey:@"PRemoveCompletedUploads"];
}

- (IBAction)addShare:(id)sender
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
        NSString *path = [[[open filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath];
        if (![shareSource containsObject:path]) {
            [shareSource addObject:path];
            NSMutableArray *tmp = [shareSource mutableCopy];
            if (share_completed) [tmp removeObjectAtIndex:0];
            [gift_conf setValue:tmp forKey:@"root"];
            [tmp autorelease];
            [self readConfFiles];
            [[NSNotificationCenter defaultCenter] // update the shares
                postNotificationName:@"PCommandNotification" 
                object:self
                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"SHARE action(sync)",@"cmd",nil]
            ];
        }
    }

}

- (IBAction)removeShare:(id)sender
{
    [shareSource removeObjectAtIndex:[shareTable selectedRow]];
    NSMutableArray *tmp = [shareSource mutableCopy];
    if (share_completed) [tmp removeObjectAtIndex:0];
    [gift_conf setValue:tmp forKey:@"root"];
    [tmp autorelease];
    [self readConfFiles];
    [[NSNotificationCenter defaultCenter] // update the shares
        postNotificationName:@"PCommandNotification" 
        object:self
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"SHARE action(sync)",@"cmd",nil]
    ];

}

- (IBAction)maxUploadsChanged:(id)sender
{
    [gift_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"max_uploads"];
    [self readConfFiles];
}

- (IBAction)maxPerUserChanged:(id)sender
{
    [gift_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"max_peruser_uploads"];
    [self readConfFiles];
}

- (IBAction)maxUploadSpeedChanged:(id)sender
{
    [gift_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"upstream"];
    [self readConfFiles];
}

- (IBAction)maxDownloadSpeedChanged:(id)sender
{
    [gift_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"downstream"];
    [self readConfFiles];
}


// ---------------------------------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [shareSource count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"icon"]) {
        if (rowIndex==0 && share_completed)
            return [[NSWorkspace sharedWorkspace] iconForFile:[[gift_conf optionForKey:@"completed"] stringByExpandingTildeInPath]];
        else return [[NSWorkspace sharedWorkspace] iconForFile:[[shareSource objectAtIndex:rowIndex] stringByExpandingTildeInPath]];
    }
    else return [shareSource objectAtIndex:rowIndex];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([shareTable selectedRow]>-1) [removeButton setEnabled:YES];
    else [removeButton setEnabled:NO];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    if (share_completed && rowIndex==0) return NO;
    else return YES;
}

- (BOOL)control:(NSControl *)control isValidObject:(id)object
{
    if (control==maxUploads) {
        if ([maxUploads intValue]>=-1) return YES;
        else return NO;
    }
    else {
        if ([maxPerUser intValue]>=1) return YES;
        else return NO;
    }
}

@end
