
#import "PMediaType.h"


PMediaType PMediaTypeForExtension(id theExtension)
{
    static NSSet* music = nil;
    static NSSet* video = nil;
    static NSSet* image = nil;
    static NSSet* document = nil;

    if (!music) {
        music = [[NSSet alloc] initWithObjects: @"mp3", @"ogg", @"wma", @"aiff", @"aif", @"au", @"mod", @"wav", @"mid", @"m4a", nil];
        video = [[NSSet alloc] initWithObjects: @"mp4", @"avi", @"mov", @"mpg", @"mpeg", @"asf", @"rm", @"ram", @"divx", @"wmv", nil];
        image = [[NSSet alloc] initWithObjects: @"gif", @"jpg", @"jpe", @"jpeg", @"png", @"tif", @"tiff", @"bmp", nil];
        document = [[NSSet alloc] initWithObjects: @"doc", @"pdf", @"rtf", @"rtfd", @"txt", @"htm", @"html", nil];
    }
    
    if ([music member: theExtension]) return PMusic;
    if ([video member: theExtension]) return PVideo;
    if ([image member: theExtension]) return PImage;
    if ([document member: theExtension]) return PDocument;
    return PFile;
}

BOOL isMusic(id theExtension) {
    return PMediaTypeForExtension(theExtension) == PMusic;
}

BOOL isImage(id theExtension) {
    return PMediaTypeForExtension(theExtension) == PImage;
}

BOOL isVideo(id theExtension) {
    return PMediaTypeForExtension(theExtension) == PVideo;
}

BOOL isDocument(id theExtension) {
    return PMediaTypeForExtension(theExtension) == PDocument;
}