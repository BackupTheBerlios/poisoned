//
// POutlineView.m
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

#import "POutlineView.h"

#define STRIPE_RED   (237.0 / 255.0)
#define STRIPE_GREEN (243.0 / 255.0)
#define STRIPE_BLUE  (254.0 / 255.0)
static NSColor *sStripeColor = nil;

@implementation POutlineView

- (void)setMenuDelegate:(id)new_menu_delegate
{
    _menu_delegate = new_menu_delegate;
}

-(NSMenu*)menuForEvent:(NSEvent*)evt 
{
    NSPoint point = [self convertPoint:[evt locationInWindow] fromView:NULL];
    int column = [self columnAtPoint:point];
    int row = [self rowAtPoint:point];
    if ([_menu_delegate respondsToSelector:@selector(tableView:menuForTableColumn:row:)] )
	return [_menu_delegate tableView:self
            menuForTableColumn:[[self tableColumns] objectAtIndex:column]
            row:row];
    else return NULL;
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
}

- (void) highlightSelectionInClipRect:(NSRect)rect {
    [self drawStripesInRect:rect];
    [super highlightSelectionInClipRect:rect];
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


- (void) drawStripesInRect:(NSRect)clipRect {
    NSRect stripeRect;
    float fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
    float clipBottom = NSMaxY(clipRect);
    int firstStripe = clipRect.origin.y / fullRowHeight;
    if (firstStripe % 2 == 0)
        firstStripe++;			
        
    stripeRect.origin.x = clipRect.origin.x;
    stripeRect.origin.y = firstStripe * fullRowHeight;
    stripeRect.size.width = clipRect.size.width;
    stripeRect.size.height = fullRowHeight;
    if (sStripeColor == nil)
        sStripeColor = [[NSColor colorWithCalibratedRed:STRIPE_RED green:STRIPE_GREEN blue:STRIPE_BLUE alpha:1.0] retain];
    [sStripeColor set];
    while (stripeRect.origin.y < clipBottom) {
        NSRectFill(stripeRect);
        stripeRect.origin.y += fullRowHeight * 2.0;
    }
}

@end
