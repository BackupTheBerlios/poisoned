#import <Cocoa/Cocoa.h>


@interface PiTunesController : NSObject 
{
}

+ (void) handleCompletedFile: (id) thePath;

+ (BOOL) addSongToLibrary: (id) thePath;
+ (BOOL) addSongToPlaylist: (id) thePath;
+ (BOOL) addSongToPlaylist: (id) thePath andPruneToSize: (int) theSize;
+ (void) playSong: (id) thePath;
+ (void) playSongIfNotPlaying: (id) thePath;

+ (void) moveFileToTrash: (id) thePath;

@end