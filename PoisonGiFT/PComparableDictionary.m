//
//  PComparableDictionary.m
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

#import "PComparableDictionary.h"


@implementation NSArray (PComparableDictionary)

// SORT BY EXTENSION
- (NSComparisonResult)iconAsc:(NSArray *)dict
{
    return [[[[self objectAtIndex:0] objectForKey:@"file"] pathExtension] compare:[[[dict objectAtIndex:0] objectForKey:@"file"] pathExtension] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)iconDesc:(NSArray *)dict
{
    return (-1*[self iconAsc:dict]);
}


// SORT BY FILE NAME
- (NSComparisonResult)fileAsc:(NSArray *)dict
{
    return [[[self objectAtIndex:0] objectForKey:@"file"] compare:[[dict objectAtIndex:0] objectForKey:@"file"] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)fileDesc:(NSArray *)dict
{
    return (-1*[self fileAsc:dict]);
}

// SORT BY ARTIST NAME
- (NSComparisonResult)artistAsc:(NSArray *)dict
{
    NSString *str1 = [[self objectAtIndex:0] objectForKey:@"artist"];
    NSString *str2 = [[dict objectAtIndex:0] objectForKey:@"artist"];
    if (str1==nil && str2==nil) return NSOrderedSame;
    if (str1==nil) return NSOrderedDescending;
    else if (str2==nil) return NSOrderedAscending;
    else return [str1 compare:str2 options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)artistDesc:(NSArray *)dict
{
    NSString *str1 = [[self objectAtIndex:0] objectForKey:@"artist"];
    NSString *str2 = [[dict objectAtIndex:0] objectForKey:@"artist"];
    if (str1==nil && str2==nil) return NSOrderedSame;
    if (str1==nil) return NSOrderedDescending;
    else if (str2==nil) return NSOrderedAscending;
    return [str2 compare:str1 options:NSCaseInsensitiveSearch];
}

// SORT BY ALBUM NAME
- (NSComparisonResult)albumAsc:(NSArray *)dict
{
    NSString *str1 = [[self objectAtIndex:0] objectForKey:@"album"];
    NSString *str2 = [[dict objectAtIndex:0] objectForKey:@"album"];
    if (str1==nil && str2==nil) return NSOrderedSame;
    if (str1==nil) return NSOrderedDescending;
    else if (str2==nil) return NSOrderedAscending;
    else return [str1 compare:str2 options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)albumDesc:(NSArray *)dict
{
    NSString *str1 = [[self objectAtIndex:0] objectForKey:@"album"];
    NSString *str2 = [[dict objectAtIndex:0] objectForKey:@"album"];
    if (str1==nil && str2==nil) return NSOrderedSame;
    if (str1==nil) return NSOrderedDescending;
    else if (str2==nil) return NSOrderedAscending;
    else return [str2 compare:str1 options:NSCaseInsensitiveSearch];
}


// SORT BY USERNAME
- (NSComparisonResult)userAsc:(NSArray *)dict
{
    if ([NSStringFromClass([[[self objectAtIndex:0] objectForKey:@"user"] class]) isEqualToString:@"NSCFString"] && [NSStringFromClass([[[dict objectAtIndex:0] objectForKey:@"user"] class]) isEqualToString:@"NSCFString"]) {
        return [[[self objectAtIndex:0] objectForKey:@"user"] compare:[[dict objectAtIndex:0] objectForKey:@"user"] options:NSCaseInsensitiveSearch];
    }
    else if ([NSStringFromClass([[[self objectAtIndex:0] objectForKey:@"user"] class]) isEqualToString:@"NSCFString"]) {
        return NSOrderedAscending;
    }
    else if ([NSStringFromClass([[[dict objectAtIndex:0] objectForKey:@"user"] class]) isEqualToString:@"NSCFString"]) {
        return NSOrderedDescending;
    }
    else return [[NSNumber numberWithInt:[[[[self objectAtIndex:0] objectForKey:@"user"] string] intValue]] compare:[NSNumber numberWithInt:[[[[dict objectAtIndex:0] objectForKey:@"user"] string] intValue]]];
}

- (NSComparisonResult)userDesc:(NSArray *)dict
{
    return (-1*[self userAsc:dict]);
}


// SORT BY SIZE
- (NSComparisonResult)calcsizeAsc:(NSArray *)dict
{
    NSString *left = [[self objectAtIndex:0] objectForKey:@"size"];
    NSString *right = [[dict objectAtIndex:0] objectForKey:@"size"];
    int li = [left length];
    int ri = [right length];
    if (li>ri) return NSOrderedDescending;
    else if (ri>li) return NSOrderedAscending;
    else return [left compare:right];
}
- (NSComparisonResult)calcsizeDesc:(NSArray *)dict
{
    return (-1*[self calcsizeAsc:dict]);
}

// SORT BY BIT RATE
- (NSComparisonResult)bitrateAsc:(NSArray *)dict
{
    int l = [[[self objectAtIndex:0] objectForKey:@"bitrate"] intValue];
    int r = [[[dict objectAtIndex:0] objectForKey:@"bitrate"] intValue];
    if (l==0 && r==0) return NSOrderedSame;
    else if (l==0) return NSOrderedDescending;
    else if (r==0) return NSOrderedAscending;
    else if (l==r) return NSOrderedSame;
    else if (l<r) return NSOrderedAscending;
    else return NSOrderedDescending;
}

- (NSComparisonResult)bitrateDesc:(NSArray *)dict
{
    int l = [[[self objectAtIndex:0] objectForKey:@"bitrate"] intValue];
    int r = [[[dict objectAtIndex:0] objectForKey:@"bitrate"] intValue];
    if (l==0 && r==0) return NSOrderedSame;
    else if (l==0) return NSOrderedDescending;
    else if (r==0) return NSOrderedAscending;
    else if (l==r) return NSOrderedSame;
    else if (l<r) return NSOrderedDescending;
    else return NSOrderedAscending;
}

- (NSComparisonResult)PProtoIconAsc:(NSArray *)dict
{
    return [[[self objectAtIndex:0] objectForKey:@"PProto"] compare:[[dict objectAtIndex:0] objectForKey:@"PProto"] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)PProtoIconDesc:(NSArray *)dict
{
    return (-1*[self PProtoIconAsc:dict]);
}

// SORT BY BIT AVAILABILITY
- (NSComparisonResult)PAvailabilityAsc:(NSArray *)dict
{
    return [[[self objectAtIndex:0] objectForKey:@"PAvail"] compare:[[dict objectAtIndex:0] objectForKey:@"PAvail"] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)PAvailabilityDesc:(NSArray *)dict
{
    return (-1*[self PAvailabilityAsc:dict]);
}

@end
