#import <Cocoa/Cocoa.h>

@interface PActionsController : NSObject 
{
}

+ (void) handleCompletedFile: (id) thePath;
+ (void) moveFile: (id) thePath toFolder: (id) folderPath;
+ (void) openFile: (id) thePath;

@end