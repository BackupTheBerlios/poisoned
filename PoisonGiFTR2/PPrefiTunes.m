
#import "PPrefiTunes.h"

#define userDefaults [NSUserDefaults standardUserDefaults]

@implementation PPrefiTunes

- (void)awakeFromNib
{
    [self loadDefaults];
}

/* Register Defaults */

    - (void) registerDefaults; 
    {
        id dict = [[[NSMutableDictionary alloc] init] autorelease];
    
        [dict setObject: @"1"		forKey: @"PAddSong"];
        [dict setObject: @"1"		forKey: @"PAddSongToPlaylist"];
        //[dict setObject: @"1"		forKey: @"PPlaylistShouldLimit"];
        //[dict setObject: @"2"		forKey: @"PPlaylistLimit"];
        [dict setObject: @"0"		forKey: @"PPlaySong"];
        [dict setObject: @"0"		forKey: @"PDeleteAfterImport"];
        [dict setObject: @"Poisoned"    forKey: @"PImportPlaylistName"];
            
        [userDefaults registerDefaults: dict];
    }


/* Load Defaults */

    - (void) loadDefaults; 
    {
        /* Add Song */
        
            tempBool = [userDefaults boolForKey: @"PAddSong"];
            [addSong setState: (tempBool) ? NSOnState : NSOffState];

            [addSongToPlaylist setEnabled: tempBool];
            [playSong setEnabled: tempBool];
            [deleteAfterImport setEnabled: tempBool];
            [importPlaylistName setEnabled: tempBool];

        /* Add Song to Playlist */
        
            tempBool = [userDefaults boolForKey: @"PAddSongToPlaylist"];
            [addSongToPlaylist setState: (tempBool) ? NSOnState : NSOffState];
            
            [playlistShouldLimit setEnabled: tempBool && [addSongToPlaylist isEnabled]];
            
        /* Should Limit Playlist Length */
        
            tempBool = [userDefaults boolForKey: @"PPlaylistShouldLimit"];
            [playlistShouldLimit setState: (tempBool) ? NSOnState : NSOffState];

            [playlistLimit setEnabled: tempBool && [playlistShouldLimit isEnabled]];

        /* Playlist Limit */

            tempInt = [userDefaults integerForKey: @"PPlaylistLimit"];
            [playlistLimit selectItemAtIndex: tempInt];

        /* Play Song */
            
            tempInt = [userDefaults integerForKey: @"PPlaySong"];
            [playSong selectCellAtRow: tempInt column: 0];

        /* Delete After Import */
            
            tempBool = [userDefaults boolForKey: @"PDeleteAfterImport"];
            [deleteAfterImport setState: (tempBool) ? NSOnState : NSOffState];
            
        /* Import playlist name */
        [importPlaylistName setStringValue:[userDefaults objectForKey:@"PImportPlaylistName"]];
    }


/* Mutate Defaults */

    - (void) addSong: (id) sender; {
        tempBool = [sender intValue];
        [userDefaults setBool: tempBool forKey: @"PAddSong"];
        [self loadDefaults];
    }
    
    - (void) addSongToPlayList: (id) sender; {
        tempBool = [sender intValue];
        [userDefaults setBool: tempBool forKey: @"PAddSongToPlaylist"];
        [self loadDefaults];
    }

    - (void) playlistShouldLimit: (id) sender; {
        tempBool = [sender intValue];
        [userDefaults setBool: tempBool forKey: @"PPlaylistShouldLimit"];
        [self loadDefaults];
    }
    
    - (void) playlistLimit: (id) sender; {
        [userDefaults setInteger: [sender indexOfSelectedItem] forKey: @"PPlaylistLimit"];
        [self loadDefaults];
    }
    
    - (void) playSong: (id) sender; {
        [userDefaults setInteger: [sender selectedRow] forKey: @"PPlaySong"];
        [self loadDefaults];
    }

    - (void) deleteAfterImport: (id) sender; {
        tempBool = [sender intValue];
        [userDefaults setBool: tempBool forKey: @"PDeleteAfterImport"];
        [self loadDefaults];
    }
    
    - (IBAction) importPlaylistNameChanged:(id)sender; {
        /*NSString *value = [importPlaylistName stringValue];
        if ([value isEqualToString:@""]) {
            value = @"Poisoned";
            [importPlaylistName setStringValue:value];
        }*/
        [userDefaults setObject: [sender stringValue] forKey:@"PImportPlaylistName"];
        [self loadDefaults];
    }

@end