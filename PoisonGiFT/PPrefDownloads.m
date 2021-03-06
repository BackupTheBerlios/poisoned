//
// PPrefDownloads.m
// -------------------------------------------------------------------------
// Copyright (C) 2003 Poisoned Project (http://www.poisonedproject.com/)
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

    /* if this key is not valid, we have to add it because of upgrades - ashton */
    if(![userDefaults objectForKey:@"PImportPlaylistName"])
       [userDefaults setObject:@"Poisoned" forKey:@"PImportPlaylistName"];
       
    
    if ([userDefaults boolForKey:@"PRemoveCompletedDownloads"]) [removeCompleted setState:NSOnState];
    else [removeCompleted setState:NSOffState];
    
    if ([userDefaults boolForKey:@"PRemoveCancelledDownloads"]) [removeCancelled setState:NSOnState];
    else [removeCancelled setState:NSOffState];    
    
    if ([userDefaults boolForKey:@"PImportToiTunes"]) [importToiTunes setState:NSOnState];
    else [importToiTunes setState:NSOffState];

    [self importPrefsChanged:NULL];
    
    if ([userDefaults boolForKey:@"PImportToPlaylist"]) [importToPlaylist setState:NSOnState];
    else [importToPlaylist setState:NSOffState];
	
    if ([userDefaults boolForKey:@"PPlayFile"]) [playFile setState:NSOnState];
    else [playFile setState:NSOffState];    
    
    if ([userDefaults boolForKey:@"PNoFilePlayFile"]) [playFileIfNoFile setState:NSOnState];
    else [playFileIfNoFile setState:NSOffState];    

    if ([userDefaults boolForKey:@"PDeleteFile"]) [deleteFile setState:NSOnState];
    else [deleteFile setState:NSOffState];   
    
    if ([userDefaults boolForKey:@"POggSupport"]) [oggSupport setState:NSOnState];
    else [oggSupport setState:NSOffState]; 
    
    if ([userDefaults boolForKey:@"PSwitchToDownloads"]) [switchToDownload setState:NSOnState];
    else [switchToDownload setState:NSOffState];

    [importPlaylistName setStringValue:[userDefaults objectForKey:@"PImportPlaylistName"]];
     
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
                [importPlaylistName setEnabled:YES];
                [labelPlaylist setEnabled:YES];
		[playFile setEnabled:YES];
                [playFileIfNoFile setEnabled:YES];
		[deleteFile setEnabled:YES];
                [oggSupport setEnabled:YES];
        }
	else
	{
		[userDefaults setBool:NO forKey:@"PImportToiTunes"];
		[importToPlaylist setEnabled:NO];
                [importPlaylistName setEnabled:NO];
                [labelPlaylist setEnabled:NO];
		[playFile setEnabled:NO];
                [playFileIfNoFile setEnabled:NO];
		[deleteFile setEnabled:NO];
                [oggSupport setEnabled:NO];
	}
}

- (IBAction)importPlaylistChanged:(id)sender
{
    if ([importToPlaylist state]==NSOnState)
    {
        [importPlaylistName setEnabled:YES];
        [labelPlaylist setEnabled:YES];
        [userDefaults setBool:YES forKey:@"PImportToPlaylist"];
    }
    else
    {
        [importPlaylistName setEnabled:NO];
        [labelPlaylist setEnabled:NO];
        [userDefaults setBool:NO forKey:@"PImportToPlaylist"];
    }
}

- (IBAction)playfilePrefsChanged:(id)sender
{
    if ([playFile state]==NSOnState) 
    {
        [userDefaults setBool:YES forKey:@"PPlayFile"];
        [playFileIfNoFile setEnabled:YES];
    } 
    else 
    {
        [userDefaults setBool:NO forKey:@"PPlayFile"];
        [playFileIfNoFile setEnabled:NO];
    }
}

- (IBAction)playFileIfNoFilePrefsChanged:(id)sender
{
    if ([playFileIfNoFile state]==NSOnState) [userDefaults setBool:YES forKey:@"PNoFilePlayFile"];
    else [userDefaults setBool:NO forKey:@"PNoFilePlayFile"];
}

- (IBAction)deletefilePrefsChanged:(id)sender
{
    if ([deleteFile state]==NSOnState) [userDefaults setBool:YES forKey:@"PDeleteFile"];
    else [userDefaults setBool:NO forKey:@"PDeleteFile"];
}

- (IBAction)oggSupportChanged:(id)sender
{
    if ([oggSupport state]==NSOnState) [userDefaults setBool:YES forKey:@"POggSupport"];
    else [userDefaults setBool:NO forKey:@"POggSupport"];
}

- (IBAction)importPlaylistNameChanged:(id)sender
{
    NSString *value = [importPlaylistName stringValue];
    if ([value isEqualToString:@""]) {
        value = @"Poisoned";
        [importPlaylistName setStringValue:value];
    }
    [userDefaults setObject:value forKey:@"PImportPlaylistName"];
    [self readConfFiles];
}

- (IBAction)switchToDownloadPrefsChanged:(id)sender
{
    if ([switchToDownload state]==NSOnState) [userDefaults setBool:YES forKey:@"PSwitchToDownloads"];
    else [userDefaults setBool:NO forKey:@"PSwitchToDownloads"];
}

- (IBAction)completedChanged:(id)sender
{
    [gift_conf setValue:[[sender stringValue] stringByAbbreviatingWithTildeInPath] forKey:@"completed"];
    [self readConfFiles];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PCompletedDirectoryChanged" object:self userInfo:nil];
}

- (IBAction)incomingChanged:(id)sender
{
    [gift_conf setValue:[[sender stringValue] stringByAbbreviatingWithTildeInPath] forKey:@"incoming"];
    [self readConfFiles];
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
