//
//  PFastTrackConf.m
//  PoisonGiFT
//
//  Created by j.ashton on Tue Sep 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PFastTrackConf.h"

static PFastTrackConf *singleton;

@implementation PFastTrackConf

+ (id)singleton
{
    BOOL test;
    test = [[NSFileManager defaultManager] fileExistsAtPath:
                [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"FastTrack"]
                stringByAppendingPathComponent:@"FastTrack.conf"] 
            ];
    if (!singleton && test) {
        singleton = [[PFastTrackConf alloc] init];
    }
    if (test) return singleton;
    else {
        NSLog(@"FastTrack.conf not found");
        return nil;
    }
}

- (NSString *)path
{
    return [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"FastTrack"]
                stringByAppendingPathComponent:@"FastTrack.conf"];
}

- (id)init
{
    if (self = [super init]) {
        conf = [[NSMutableDictionary alloc] init];
        lines = [[NSMutableArray alloc] init];
        file_manager = [NSFileManager defaultManager];
        
        string_confs = [[NSArray alloc] initWithObjects:
            @"alias",
            nil];
        colon_confs = [[NSArray alloc] initWithObjects:
            nil];
        space_confs = [[NSArray alloc] initWithObjects:
            nil];
    }
    return self;
}

- (void)dealloc
{	
    [string_confs release];
    [colon_confs release];
    [space_confs release];
    [super dealloc];
}

@end
