//
//  POpenFTConf.m
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

#import "POpenFTConf.h"

static POpenFTConf *singleton;

@implementation POpenFTConf

+ (id)singleton
{
    BOOL test;
    test = [[NSFileManager defaultManager] fileExistsAtPath:
            [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"OpenFT"]
                stringByAppendingPathComponent:@"OpenFT.conf"]
            ];
    if (!singleton && test) {
        singleton = [[POpenFTConf alloc] init];
    }
    if (test) return singleton;
    else {
        NSLog(@"OpenFT.conf not found");
        return nil;
    }
}

- (NSString *)path
{
    return [[[PConfigurationEditor giFThome]
                stringByAppendingPathComponent:@"OpenFT"]
                stringByAppendingPathComponent:@"OpenFT.conf"];
}

- (id)init
{
    if (self = [super init]) {
        conf = [[NSMutableDictionary alloc] init];
        lines = [[NSMutableArray alloc] init];
        file_manager = [NSFileManager defaultManager];

        int_confs = [[NSArray alloc] initWithObjects:
            @"class",
            @"port",
            @"http_port",
            @"private",
            @"children",
            @"env_priv",
            @"lan_mode",
            nil];
        string_confs = [[NSArray alloc] initWithObjects:
            @"alias",
            @"env_path",
            @"env_cache",
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
