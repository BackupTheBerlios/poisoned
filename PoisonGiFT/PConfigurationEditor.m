//
//  PConfigurationEditor.m
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

#import "PConfigurationEditor.h"


@implementation PConfigurationEditor

- (id)init
{
    if (self = [super init]) {
        conf = [[NSMutableDictionary alloc] init];
        lines = [[NSMutableArray alloc] init];
        file_manager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)dealloc
{	
    [lines release];
    [conf release];
    [super dealloc];
}

+ (NSString *)giFThome
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PUseCustomDaemon"])
        return [NSHomeDirectory() stringByAppendingPathComponent:@".giFT"];
    else
        return [[[NSHomeDirectory() 
                    stringByAppendingPathComponent:@"Library"]
                    stringByAppendingPathComponent:@"Application Support"]
                    stringByAppendingPathComponent:@"Poisoned"];
}

- (NSString *)path
{
    return @"";
}

- (void)read
{
    NSString *content = [NSString stringWithContentsOfFile:[self path]];
    
    [lines autorelease];
    lines = [[content componentsSeparatedByString:@"\n"] mutableCopy];
    
    int i,count = [lines count];
    NSString *_line;
    for (i=0;i<count;i++) {
        _line = [self skipWhitespace:[lines objectAtIndex:i]];
        [lines replaceObjectAtIndex:i withObject:_line];
        [self readConfLine:i];
    }
}

- (NSString *)skipWhitespace:(NSString *)_line
{
    while ([_line hasPrefix:@" "]) _line = [_line substringFromIndex:1];
    return _line;
}

- (void)readConfLine:(int)index
{
    NSString *line = [lines objectAtIndex:index];
    if ([line length]==0 || [line hasPrefix:@"#"] || [line hasPrefix:@"["]) return;
    NSArray *split = [line componentsSeparatedByString:@"="];
    NSString *key = [[split objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *value = [split objectAtIndex:1];
    if ([int_confs containsObject:key]) {
        [conf setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithInt:index],[NSNumber numberWithInt:[value intValue]],nil]
            forKey:key];
    }
    else if ([string_confs containsObject:key]) {
        // add space before trimming because of a bug in NSString's -stiringByTrimmingCharactersInSet
        [conf setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithInt:index],[[value stringByAppendingString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],nil]
            forKey:key];
    }
    else if ([colon_confs containsObject:key]) {
        [conf setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithInt:index],[self colonToArray:value],nil]
            forKey:key];
    }
    else if ([space_confs containsObject:key]) {
        [conf setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithInt:index],[self spaceToArray:value],nil]
            forKey:key];
    }
}

- (id)optionForKey:(NSString *)option
{
    if (![conf objectForKey:option]) return nil;
    return [[conf objectForKey:option] objectAtIndex:1];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *path = [self path];
    [self read];
    if (![conf objectForKey:key]) return;
    [[conf objectForKey:key] replaceObjectAtIndex:1 withObject:value];
    [self updateArrayForKey:key];
    
    NSDictionary *attr = [file_manager fileAttributesAtPath:path traverseLink:NO];
    [file_manager removeFileAtPath:path handler:nil];
    [file_manager createFileAtPath:path contents:nil attributes:attr];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle writeData:[[lines componentsJoinedByString:@"\n"] dataUsingEncoding:NSASCIIStringEncoding]];
    [handle closeFile];
}

- (void)updateArrayForKey:(NSString *)key
{
    NSString *value;

    if ([int_confs containsObject:key]) {
        value = [NSString stringWithFormat:@"%d",[[[conf objectForKey:key] objectAtIndex:1] intValue]];
    }
    else if ([string_confs containsObject:key]) {
        value = [[conf objectForKey:key] objectAtIndex:1];
    }
    else if ([colon_confs containsObject:key]) {
        value = [[[conf objectForKey:key] objectAtIndex:1] componentsJoinedByString:@":"];
    }
    else if ([space_confs containsObject:key]) {
        value = [[[conf objectForKey:key] objectAtIndex:1] componentsJoinedByString:@" "];
    }
    else return;
    
    [lines replaceObjectAtIndex:[[[conf objectForKey:key] objectAtIndex:0] intValue] withObject:
        [[key stringByAppendingString:@" = "] stringByAppendingString:value]];
}

- (NSArray *)colonToArray:(NSString *)string
{
    NSMutableArray *split = [[[string componentsSeparatedByString:@":"] mutableCopy] autorelease];
    int i, count=[split count];
    for (i=0;i<count;i++) {
        [split replaceObjectAtIndex:i withObject:
            [[[split objectAtIndex:i] stringByAppendingString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    return split;
}

- (NSArray *)spaceToArray:(NSString *)string
{
    NSMutableArray *split = [[[string componentsSeparatedByString:@" "] mutableCopy] autorelease];
    int i, count=[split count];
    for (i=0;i<count;i++) {
        [split replaceObjectAtIndex:i withObject:
            [[[split objectAtIndex:i] stringByAppendingString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    return split;
}

@end
