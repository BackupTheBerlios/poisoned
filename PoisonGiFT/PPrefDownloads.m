//
// PPrefDownloads.m
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

#import "PPrefDownloads.h"

@implementation PPrefDownloads

- (void)awakeFromNib
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    gift_conf = [PGiFTConf singleton];    
    
    [self readConfFiles];
    
    if ([userDefaults boolForKey:@"PRemoveCompletedDownloads"]) [removeCompleted setState:NSOnState];
    else [removeCompleted setState:NSOffState];
    
    if ([userDefaults boolForKey:@"PRemoveCancelledDownloads"]) [removeCancelled setState:NSOnState];
    else [removeCancelled setState:NSOffState];    
    
    if ([userDefaults boolForKey:@"PImportToiTunes"]) [importToiTunes setState:NSOnState];
    else [importToiTunes setState:NSOffState];

    [self importPrefsChanged:NULL];
	
    if ([userDefaults boolForKey:@"PPlayFile"]) [playFile setState:NSOnState];
    else [playFile setState:NSOffState];    

    if ([userDefaults boolForKey:@"PDeleteFile"]) [deleteFile setState:NSOnState];
    else [deleteFile setState:NSOffState];   
    
    if ([userDefaults boolForKey:@"PSwitchToDownloads"]) [switchToDownload setState:NSOnState];
    else [switchToDownload setState:NSOffState];   
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)enable
{
    [incoming setEnabled:YES];
    [completed setEnabled:YES];
}

- (void)disable
{
    [incoming setEnabled:NO];
    [completed setEnabled:NO];
}

- (void)readConfFiles
{
    if (gift_conf = [PGiFTConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }

    [gift_conf read];
    NSString  *_in = [gift_conf optionForKey:@"incoming"];
    NSString *_comp = [gift_conf optionForKey:@"completed"];
    if (_in) [completed setStringValue:_comp];
    if (_comp) [incoming setStringValue:_in];
}

- (IBAction)cancelledPrefsChanged:(id)sender
{
    if ([removeCancelled state]==NSOnState) [userDefaults setBool:YES forKey:@"PRemoveCancelledDownloads"];
    else [userDefaults setBool:NO forKey:@"PRemoveCancelledDownloads"];
}

- (IBAction)completedPrefsChanged:(id)sender
{
    if ([removeCompleted state]==NSOnState) [userDefaults setBool:YES forKey:@"PRemoveCompletedDownloads"];
    else [userDefaults setBool:NO forKey:@"PRemoveCompletedDownloads"];
}

- (IBAction)importPrefsChanged:(id)sender
{
    if ([importToiTunes state]==NSOnState)
	{
		[userDefaults setBool:YES forKey:@"PImportToiTunes"];
		[importToPlaylist setEnabled:YES];
		[playFile setEnabled:YES];
		[deleteFile setEnabled:YES];
    }
	else
	{
		[userDefaults setBool:NO forKey:@"PImportToiTunes"];
		[importToPlaylist setEnabled:NO];
		[playFile setEnabled:NO];
		[deleteFile setEnabled:NO];
	}
}

- (IBAction)importPlaylistChanged:(id)sender
{
    if ([importToPlaylist state]==NSOnState) [userDefaults setBool:YES forKey:@"PImportToPlaylist"];
    else [userDefaults setBool:NO forKey:@"PImportToPlaylist"];
}

- (IBAction)playfilePrefsChanged:(id)sender
{
    if ([playFile state]==NSOnState) [userDefaults setBool:YES forKey:@"PPlayFile"];
    else [userDefaults setBool:NO forKey:@"PPlayFile"];
}

- (IBAction)deletefilePrefsChanged:(id)sender
{
    if ([deleteFile state]==NSOnState) [userDefaults setBool:YES forKey:@"PDeleteFile"];
    else [userDefaults setBool:NO forKey:@"PDeleteFile"];
}

- (IBAction)switchToDownloadPrefsChanged:(id)sender
{
    if ([switchToDownload state]==NSOnState) [userDefaults setBool:YES forKey:@"PSwitchToDownloads"];
    else [userDefaults setBool:NO forKey:@"PSwitchToDownloads"];
}

- (IBAction)browseIncoming:(id)sender
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
        [gift_conf setValue:[[[open filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath] forKey:@"incoming"];
        [self readConfFiles];
    }
}

- (IBAction)browseCompleted:(id)sender
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
        [gift_conf setValue:[[[open filenames] objectAtIndex:0] stringByAbbreviatingWithTildeInPath] forKey:@"completed"];
        [self readConfFiles];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PCompletedDirectoryChanged" object:self userInfo:nil];
    }
}

@end
