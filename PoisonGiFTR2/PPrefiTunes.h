#import <Cocoa/Cocoa.h>


@interface PPrefiTunes : NSObject
{
    BOOL tempBool;
    int tempInt;
    id addSong;
    id addSongToPlaylist;
    id playlistShouldLimit;
    id playlistLimit;
    id playSong;
    id deleteAfterImport;
    IBOutlet NSTextField *importPlaylistName;
}

- (void) loadDefaults;
- (void) addSong: (id) sender;
- (void) addSongToPlayList: (id) sender;
- (void) playlistShouldLimit: (id) sender;
- (void) playlistLimit: (id) sender;
- (void) playSong: (id) sender;
- (void) deleteAfterImport: (id) sender;
- (IBAction) importPlaylistNameChanged:(id)sender;

@end