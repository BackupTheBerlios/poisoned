//
//  POpenNapConf.m
//  PoisonGiFT
//
//  Created by Jay Ashton on Sun Sep 14 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "POpenNapConf.h"

static POpenNapConf *singleton;

@implementation POpenNapConf

+ (id)singleton
{
    BOOL file;
    file = [[NSFileManager defaultManager] fileExistsAtPath:
        [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"OpenNap"]
                stringByAppendingPathComponent:@"OpenNap.conf"]
        ];
    if (!singleton && file) {
        singleton = [[POpenNapConf alloc] init];
    }
    if (file) return singleton;
    else {
        NSLog(@"OpenNap.conf not found");
        return nil;
    }
}

- (NSString *)path
{
    return [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"OpenNap"]
                stringByAppendingPathComponent:@"OpenNap.conf"];
}

- (id)init
{
    if (self = [super init]) {
        conf = [[NSMutableDictionary alloc] init];
        lines = [[NSMutableArray alloc] init];
        file_manager = [NSFileManager defaultManager];

        int_confs = [[NSArray alloc] initWithObjects:
            @"dataport",
            @"max_connections",
            @"random_alias",
            @"use_napigator",
            @"napigator_ip",
            nil];
        
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
    [int_confs release];
    [string_confs release];
    [colon_confs release];
    [space_confs release];
    [super dealloc];
}
@end
