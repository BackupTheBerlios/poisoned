//
//  PIconShop.h
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

#import <Cocoa/Cocoa.h>


@interface PIconShop : NSObject {
    NSMutableDictionary *icons;
    NSMutableDictionary *protos;
    NSImage *unknown;
    NSImage *unknown32;
    NSWorkspace *workspace;
}

- (NSImage *)iconForFileType:(NSString *)filetype;
- (NSImage *)iconForProto:(NSString *)name;
- (NSImage *)largeIconForProto:(NSString *)name;

@end
