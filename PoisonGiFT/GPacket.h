//
//  PCParser.h
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

#import <Foundation/Foundation.h>
#import "libgift/libgift.h"

// simple wrapper around libgift interface.h

@interface GPacket : NSObject
{
	Interface *_ref;
}

+ (GPacket *)packetWithCommand:(const char *)command value:(const char *)value;
+ (GPacket *)packetWithInterface:(Interface *)interface;

- (GPacket *)initWithCommand:(const char *)command value:(const char *)value;
- (GPacket *)initWithInterface:(Interface *)interface;

- (NSString *)command;
- (NSString *)value;

- (void)setCommand:(const char *)command;
- (void)setValue:(const char *)value;

- (NSString *)getElement:(const char *)path;
- (BOOL)putElement:(const char *)path value:(const char *)value;

- (NSData *)serialize;

@end