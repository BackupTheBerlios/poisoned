#import "PiTunesController.h"
#define userDefaults [NSUserDefaults standardUserDefaults]


@implementation PiTunesController

/* Main API Entry */

    + (void) _handleCompletedFile: (id) thePath;
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        NS_DURING

        if ([userDefaults boolForKey: @"PAddSong"])
        {
            BOOL success = NO;
            
            if ([userDefaults boolForKey: @"PAddSongToPlaylist"]) {
                if ([userDefaults boolForKey: @"PPlaylistShouldLimit"]) {
                    success = [PiTunesController addSongToPlaylist: thePath andPruneToSize: [userDefaults integerForKey: @"PPlaylistLimit"]];
                } else {
                    success = [PiTunesController addSongToPlaylist: thePath];
                }
            } else {
                success = [PiTunesController addSongToLibrary: thePath];
            }
            
            switch ([userDefaults integerForKey: @"PPlaySong"])
            {
                case 0:
                    break;

                case 1:
                    [PiTunesController playSong: thePath];
                    break;

                case 2:
                    [PiTunesController playSongIfNotPlaying: thePath];
                    break;
            }

            if (success && [userDefaults boolForKey: @"PDeleteAfterImport"]) {
                [PiTunesController moveFileToTrash: thePath];
            }
        }

        NS_HANDLER
        
            NSLog(@"PiTunesController: %@", localException);
        
        NS_ENDHANDLER

        [pool release];
    }

    + (void) handleCompletedFile: (id) thePath; {
        thePath = [thePath stringByExpandingTildeInPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath: thePath])
            [PiTunesController _handleCompletedFile: thePath];
    }


/* AppleScript */

    + (void) moveFileToTrash: (id) thePath;
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                              \n\
            tell application \"Finder\"                                     \n\
                    move POSIX file \"%@\" as alias to trash                \n\
            end tell                                                        \n\
            ", thePath];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        
        if (error) {
            NSLog(source);
            NSLog(@"PiTunesController: moveFileToTrash: %@", error);
        }
    }

    + (BOOL) addSongToLibrary: (id) thePath; 
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                              \n\
            tell application \"iTunes.app\"                                 \n\
                    add POSIX file \"%@\" as alias to first source          \n\
            end tell                                                        \n\
            ", thePath];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        
        if (error) {
            NSLog(source);
            NSLog(@"PTunesController: addSongToLibrary: %@", error);
            return NO;
        } else {
            return YES;
        }
    }
    
    + (BOOL) addSongToPlaylist: (id) thePath; 
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                                                              \n\
            tell application \"iTunes.app\"                                                                 \n\
                                                                                                            \n\
                    if not (exists playlist \"%@\") then                                                    \n\
                            set plist to make new playlist                                                  \n\
                            set the name of plist to the \"%@\"                                             \n\
                    else                                                                                    \n\
                            set plist to playlist \"%@\"                                                    \n\
                    end if                                                                                  \n\
                                                                                                            \n\
                    set nfile to add POSIX file \"%@\" as alias to first source                             \n\
                    set fileExists to no                                                                    \n\
                    set pCount to (get count of every track of plist)                                       \n\
                                                                                                            \n\
                    repeat with i from 1 to pCount                                                          \n\
                            if (nfile's database ID is equal to database ID of track i of plist) then       \n\
                                    set fileExists to yes                                                   \n\
                            end if                                                                          \n\
                    end repeat                                                                              \n\
                                                                                                            \n\
                    if fileExists is equal to no then                                                       \n\
                        add POSIX file \"%@\" as alias to playlist \"%@\"                                   \n\
                    end if                                                                                  \n\
                                                                                                            \n\
            end tell                                                                                        \n\
            ",[userDefaults objectForKey:@"PImportPlaylistName"],[userDefaults objectForKey:@"PImportPlaylistName"],[userDefaults objectForKey:@"PImportPlaylistName"], thePath, thePath,[userDefaults objectForKey:@"PImportPlaylistName"]];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        
        if (error) {
            NSLog(source);
            NSLog(@"PTunesController: addSongToPlaylist: %@", error);
            return NO;
        } else {
            return YES;
        }
    }

    + (BOOL) addSongToPlaylist: (id) thePath andPruneToSize: (int) theSize;
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                                                              \n\
            tell application \"iTunes.app\"                                                                 \n\
                                                                                                            \n\
                    if not (exists playlist \"@%\") then                                           \n\
                            set plist to make new playlist                                                  \n\
                            set the name of plist to the \"@%\"                                    \n\
                    else                                                                                    \n\
                            set plist to playlist \"@%\"                                           \n\
                    end if                                                                                  \n\
                                                                                                            \n\
                    set nfile to add POSIX file \"%@\" as alias to first source                             \n\
                                                                                                            \n\
                    -- prune playlist to defined size                                                       \n\
                                                                                                            \n\
                    set pCount to (get count of every track of plist)                                       \n\
                                                                                                            \n\
                    if pCount is greater than %i then                                                       \n\
                            repeat with i from 1 to pCount - %i                                             \n\
                                    delete track 1 of plist                                                 \n\
                            end repeat                                                                      \n\
                    end if                                                                                  \n\
                                                                                                            \n\
                    -- check if the file already exists                                                     \n\
                                                                                                            \n\
                    set fileExists to no                                                                    \n\
                    set pCount to (get count of every track of plist)                                       \n\
                                                                                                            \n\
                    repeat with i from 1 to pCount                                                          \n\
                            if (nfile's database ID is equal to database ID of track i of plist) then       \n\
                                    set fileExists to yes                                                   \n\
                            end if                                                                          \n\
                    end repeat                                                                              \n\
                                                                                                            \n\
                    if fileExists is equal to no then                                                       \n\
                        add POSIX file \"%@\" as alias to playlist \"@%\"                                   \n\
                    end if                                                                                  \n\
                                                                                                            \n\
            end tell                                                                                        \n\
            ",[userDefaults objectForKey:@"PImportPlaylistName"],[userDefaults objectForKey:@"PImportPlaylistName"],[userDefaults objectForKey:@"PImportPlaylistName"], thePath, theSize+1, theSize+1, thePath, [userDefaults objectForKey:@"PImportPlaylistName"]];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        
        if (error) {
            NSLog(source);
            NSLog(@"PiTunesController: addSongToPlaylist: %@", error);
            return NO;
        } else {
            return YES;
        }
    }
    
    + (void) playSong: (id) thePath;
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                  \n\
            tell application \"iTunes.app\"                     \n\
                    play POSIX file \"%@\" as alias             \n\
            end tell                                            \n\
            ", thePath];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        NSLog(thePath);
        if (error) {
            NSLog(source);
            NSLog(@"PiTunesController: playSong: %@", error);
        }
    }
    
    + (void) playSongIfNotPlaying: (id) thePath;
    {
        NSDictionary* error = nil;
    
        id source = [NSString stringWithFormat:
            @"                                                  \n\
            tell application \"iTunes.app\"                     \n\
                    if player state is not playing then         \n\
                            play POSIX file \"%@\" as alias     \n\
                    end if                                      \n\
            end tell                                            \n\
            ", thePath];
    
        id as = [[[NSAppleScript alloc] initWithSource: source] autorelease];
        [as executeAndReturnError: &error];
        
        if (error) {
            NSLog(source);
            NSLog(@"PiTunesController: playSongIfNotPlaying: %@", error);
        }
    }

@end