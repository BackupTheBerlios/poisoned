//
//  PIconShop.m
// -------------------------------------------------------------------------
// Copyright (C) 2003 Poisoned Project (http://www.poisonedproject.com/)
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

#import "PIconShop.h"


@implementation PIconShop

- (id)init
{
    if (self = [super init]) {
        icons = [[NSMutableDictionary alloc] init];
        protos = [[NSMutableDictionary alloc] init];
        [protos setObject:[NSImage imageNamed:@"OpenFT.tiff"] forKey:@"OpenFT"];
        [protos setObject:[NSImage imageNamed:@"OpenFT32.tiff"] forKey:@"OpenFT32"];
        [protos setObject:[NSImage imageNamed:@"Gnutella.tiff"] forKey:@"Gnutella"];
        [protos setObject:[NSImage imageNamed:@"Gnutella32.tiff"] forKey:@"Gnutella32"];
        [protos setObject:[NSImage imageNamed:@"FastTrack.tiff"] forKey:@"FastTrack"];
        [protos setObject:[NSImage imageNamed:@"FastTrack32.tiff"] forKey:@"FastTrack32"];
        [protos setObject:[NSImage imageNamed:@"OpenNap.tiff"] forKey:@"OpenNap"];
        [protos setObject:[NSImage imageNamed:@"OpenNap32.tiff"] forKey:@"OpenNap32"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"gift-donkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"gift-donkey32"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"gift-edonkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"gift-edonkey32"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"giFT-eDonkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"giFT-eDonkey32"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"giFT-Donkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"giFT-Donkey32"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"eDonkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"eDonkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey.tiff"] forKey:@"Donkey"];
        [protos setObject:[NSImage imageNamed:@"Donkey32.tiff"] forKey:@"Donkey"];
        /* availability icons - ashton */
        [icons setObject:[NSImage imageNamed:@"online.tiff"] forKey:@"availGood"];
        [icons setObject:[NSImage imageNamed:@"offline.tiff"] forKey:@"availBad"];
        
        unknown = [[NSImage imageNamed:@"unknown.tiff"] retain];
        unknown32 = [[NSImage imageNamed:@"unknown32.tiff"] retain];
        workspace = [NSWorkspace sharedWorkspace];
    }
    return self;
}

- (void)dealloc
{
    [icons release];
    [protos release];
    [unknown release];
    [unknown32 release];
    [super dealloc];
}

- (NSImage *)iconForFileType:(NSString *)filetype
{
    NSImage *img;
    if (img=[icons objectForKey:filetype]) return img;
    else {
        img = [workspace iconForFileType:filetype];
        [icons setObject:img forKey:filetype];
        return img;
    }
}

- (NSImage *)largeIconForProto:(NSString *)name
{
    NSImage *img;
    if (img=[protos objectForKey:[name stringByAppendingString:@"32"]]) return img;
    else return unknown32;
}

- (NSImage *)iconForProto:(NSString *)name
{
    NSImage *img;
    if (img=[protos objectForKey:name]) return img;
    else return unknown;
}
/* availability - ashton */
- (NSImage *)iconForAvail:(NSString *)num
{
    NSImage *img;
    if([num isEqualToString:@"0"])
    {
        num = @"availBad";
    }
    else
    {
        num = @"availGood";
    }
    if (img=[icons objectForKey:num]) return img;
    else return unknown;
}

@end
