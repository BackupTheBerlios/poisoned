//
//  PTicketCenter.m
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

#import "PTicketCenter.h"


@implementation PTicketCenter

- (id)init
{
    if (self=[super init]) {
        tickets = [[NSMutableArray alloc] init];
        int i;
        // 1024 tickets/id's should be enough...
        for (i=1;i<=1024;i++) [tickets addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return self;
}

- (NSString *)get
{
    NSString *hereyougo = [[tickets objectAtIndex:0] copy];
    [tickets removeObjectAtIndex:0];
    return [hereyougo autorelease];
}

- (void)free:(NSString *)freeTicket
{
    if (![tickets containsObject:freeTicket]) [tickets addObject:freeTicket];
}

- (void)remove:(NSString *)coreTicket
{
    if (coreTicket) [tickets removeObject:coreTicket];
}

@end
