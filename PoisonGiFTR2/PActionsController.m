

#import "PActionsController.h"
#import "PMediaType.h"

#define userDefaults [NSUserDefaults standardUserDefaults]

@implementation PActionsController

+ (void) handleCompletedFile:(id)thePath;
{
    thePath = [thePath stringByExpandingTildeInPath];
    
    /* Move Files - ashton */
    switch (PMediaTypeForExtension([thePath pathExtension])) {
        case PImage:
            if ([userDefaults boolForKey: @"PMoveImages"])
                [self moveFile: thePath toFolder: @"~/Pictures/"];
            break;
            
        case PVideo:
            if ([userDefaults boolForKey: @"PMoveVideos"])
                [self moveFile: thePath toFolder: @"~/Movies/"];
            break;
            
        default:
            break;
    }
}

+ (void) moveFile:(id)thePath toFolder:(id) folderPath;
{
    id destPath = [folderPath stringByAppendingPathComponent:[thePath lastPathComponent]];
    [[NSFileManager defaultManager] movePath: thePath toPath: destPath handler:nil];
}

@end