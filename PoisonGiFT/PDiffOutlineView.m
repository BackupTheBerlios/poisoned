//
// PDiffOutlineView.m
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

#import "PDiffOutlineView.h"

#define STRIPE_RED   (237.0 / 255.0)
#define STRIPE_GREEN (243.0 / 255.0)
#define STRIPE_BLUE  (254.0 / 255.0)
static NSColor *sStripeColor = nil;


@implementation PDiffOutlineView

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *keys = [theEvent characters];
    if ([keys length]==1 && [keys characterAtIndex:0]==NSDeleteCharacter && [[self delegate] respondsToSelector:@selector(deleteEvent:)]) [[self delegate] performSelector:@selector(deleteEvent:)];
    else [super keyDown:theEvent];
}

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

- (void)setSmallRowHeight:(int)_small
{
    smallHeight = _small;
}

- (int)smallRowHeight
{
    return smallHeight;
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
}

- (void) highlightSelectionInClipRect:(NSRect)rect {
    [self drawStripesInRect:rect];
    [super highlightSelectionInClipRect:rect];
}

- (NSRect)rectOfRow:(int)rowIndex
{
    NSRect rect = [super rectOfRow:rowIndex];
    if (NSEqualRects(rect,NSZeroRect)) return rect;
    int i;
    int diff = [self rowHeight] - [self smallRowHeight];
    for (i=1;i<rowIndex;i++) {
        if ([self levelForItem:[self itemAtRow:i]]==1) rect.origin.y -= diff;
    }
    if ([self levelForItem:[self itemAtRow:rowIndex]]==1) rect.size.height -= diff + [self intercellSpacing].height/2;
    return rect;
}

- (NSRect)frameOfCellAtColumn:(int)columnIndex row:(int)rowIndex
{
    NSRect superRect = [super frameOfCellAtColumn:columnIndex row:rowIndex];
    NSRect rect = [self rectOfRow:rowIndex];
    superRect.size.height=rect.size.height-[self intercellSpacing].height;
    superRect.size.width -= [self intercellSpacing].width;
    superRect.origin.y=rect.origin.y+[self intercellSpacing].height/2;
    superRect.origin.x += [self intercellSpacing].width/2;
    return superRect;
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

- (int)rowAtPoint:(NSPoint)aPoint
{
    int diff = [self rowHeight] - [self smallRowHeight];
    int numRows = [self numberOfRows];
    float fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
    float smallRowHeight = [self rowHeight] + [self intercellSpacing].height - diff;
    int i;
    int tmp=0;
    for (i=0;i<numRows;i++) {
        if ([self levelForItem:[self itemAtRow:i]]==0) tmp+=fullRowHeight;
        else tmp+=smallRowHeight;
        if (tmp > aPoint.y) {
            return i;
        }
    }
    return -1;
}

- (void) drawStripesInRect:(NSRect)clipRect {
    int diff = [self rowHeight] - [self smallRowHeight];
    clipRect = [self bounds];
    NSRect stripeRect;
    float fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
    float fullSmallRowHeight = [self smallRowHeight] + [self intercellSpacing].height;
    float clipBottom = NSMaxY(clipRect);
    int firstStripe = clipRect.origin.y / fullRowHeight;
    stripeRect.origin.x = clipRect.origin.x;
    stripeRect.origin.y = firstStripe * fullRowHeight;
    stripeRect.size.width = clipRect.size.width;
    stripeRect.size.height = fullRowHeight;
    if (sStripeColor == nil)
        sStripeColor = [[NSColor colorWithCalibratedRed:STRIPE_RED green:STRIPE_GREEN blue:STRIPE_BLUE alpha:1.0] retain];
    [sStripeColor set];
    BOOL fill=YES;
    while (stripeRect.origin.y < clipBottom && [self rowAtPoint:NSMakePoint(stripeRect.origin.x,stripeRect.origin.y)]>-1 ) {
        if ([self levelForItem:[self itemAtRow:[self rowAtPoint:NSMakePoint(stripeRect.origin.x,stripeRect.origin.y)]] ]==0) {
                fill=!fill;
                if (fill) NSRectFill(stripeRect);
                stripeRect.origin.y += fullRowHeight;
        }
        else {
            NSRect tmp = stripeRect;
            tmp.size.height -= diff;
            if (fill) NSRectFill(tmp);
            stripeRect.origin.y += fullSmallRowHeight;
        }

    }
    if (fill) stripeRect.origin.y += fullRowHeight;
    while (stripeRect.origin.y < clipBottom ) {
        NSRectFill(stripeRect);
        stripeRect.origin.y += fullRowHeight*2;
    }
}

@end
