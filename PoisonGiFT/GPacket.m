//
//  PCParser.h
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

#import "GPacket.h"

@implementation GPacket

+ (GPacket *)packetWithCommand:(const char *)command value:(const char *)value
{
	return [[[GPacket alloc] initWithCommand:command value:value] autorelease];
}

+ (GPacket *)packetWithInterface:(Interface *)interface
{
	return [[[GPacket alloc] initWithInterface:interface] autorelease];
}

- (id)init
{
	return [self initWithCommand:NULL value:NULL];
}

- (GPacket *)initWithCommand:(const char *)command value:(const char *)value
{
	self = [super init];
	
	_ref = interface_new(command, value);
	
	return self;
}

- (GPacket *)initWithInterface:(Interface *)interface
{
	self = [super init];
	
	_ref = interface;
	//if (_ref == NULL)
	//	_ref = interface_new(NULL, NULL);
	
	return self;
}

- (void)dealloc
{
	interface_free(_ref);
	[super dealloc];
}

- (NSString *)command
{
	return [NSString stringWithCString:_ref->command];
}

- (NSString *)value
{
	return [NSString stringWithCString:_ref->value];
}

- (void)setCommand:(const char *)command
{
	interface_set_command(_ref, command);
}

- (void)setValue:(const char *)value
{
	interface_set_value(_ref, value);
}

- (NSString *)getElement:(const char *)path
{
	char *value = interface_get(_ref, path);
	if (value)
		return [NSString stringWithCString:value];
	else
		return NULL;
}

- (BOOL)putElement:(const char *)path value:(const char *)value
{
	return interface_put(_ref, path, value);
}

- (NSData *)serialize
{
	String *str = interface_serialize(_ref);
	NSData *data = [NSData dataWithBytes:str->str length:str->len];
	string_free(str);
	return data;
}

@end
