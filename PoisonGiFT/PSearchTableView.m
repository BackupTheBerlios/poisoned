//
// PSearchTableView.m
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

#import "PSearchTableView.h"

@implementation PSearchTableView

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *keys = [theEvent characters];
    if ([keys length]==1 && [keys characterAtIndex:0]==NSDeleteCharacter && [[self delegate] respondsToSelector:@selector(deleteEvent:)]) [[self delegate] performSelector:@selector(deleteEvent:)];
    else [super keyDown:theEvent];
}

- (void)drawGridInClipRect:(NSRect)aRect {
        NSRect rect = [self bounds];
	NSArray *columnsArray = [self tableColumns];
	int i, xPos = 0;
	for(i = 0 ; i < [columnsArray count] ; i++) { 
            xPos = xPos + [[columnsArray objectAtIndex:i] width] + [self intercellSpacing].width; 
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x - 0.5 + xPos,rect.origin.y)
                    toPoint:NSMakePoint(rect.origin.x - 0.5 + xPos,rect.size.height)];
	}
}

@end
