//
//  PGiFTConf.m
// -------------------------------------------------------------------------
// Copyright (C) 2003 Poisoned Project (http://gottsilla.net/software.php?site=poisoned)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// ---------------------------------------------------------------------------

#import "PGiFTConf.h"

static PGiFTConf *singleton;

@implementation PGiFTConf

+ (id)singleton
{
    BOOL test;
    test = [[NSFileManager defaultManager] fileExistsAtPath:
        [[PConfigurationEditor giFThome]
            stringByAppendingPathComponent:@"gift.conf"]
    ];
    if (!singleton && test) {
        singleton = [[PGiFTConf alloc] init];
    }
    if (test) return singleton;
    else {
        NSLog(@"gift.conf not found");
        return nil;
    }
}

- (NSString *)path
{
    return [[PConfigurationEditor giFThome] stringByAppendingPathComponent:@"gift.conf"];
}

- (id)init
{
    if (self = [super init]) {
        conf = [[NSMutableDictionary alloc] init];
        lines = [[NSMutableArray alloc] init];
        file_manager = [NSFileManager defaultManager];

        int_confs = [[NSArray alloc] initWithObjects:
            @"setup",
            @"client_port",
            @"follow_symlinks",
            @"max_peruser_uploads",
            @"hide_dot_files",
            @"max_uploads",
            @"auto_resync_interval",
            @"share_completed",
            @"downstream",
            @"upstream",
            nil];
        string_confs = [[NSArray alloc] initWithObjects:
            @"incoming",
            @"completed",
            nil];
        colon_confs = [[NSArray alloc] initWithObjects:
            @"plugins",
            @"root",
            nil];
        space_confs = [[NSArray alloc] initWithObjects:
            @"hosts_allow",
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

- (void)setup
{
    [self setValue:[NSNumber numberWithInt:1] forKey:@"setup"];
}

@end
