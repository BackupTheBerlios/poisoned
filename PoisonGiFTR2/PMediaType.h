#import <Cocoa/Cocoa.h>

typedef enum {
    PMusic,
    PVideo,
    PImage,
    PDocument,
    PFile
} PMediaType;


PMediaType PMediaTypeForExtension(id theExtension);
BOOL isMusic(id theExtension);
BOOL isImage(id theExtension);
BOOL isVideo(id theExtension);