//
// PTextFieldCell.m
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

#import "PTextFieldCell.h"

@implementation PTextFieldCell

- (id)initWithTextField:(NSTextField *)textField
{
	self = [super initTextCell:@""];
	if (self) {
		length = 0;
		clearButtonPressed = NO;
		parentTextField = textField;
		emptyString = [[NSString stringWithString:@"Begin Search Here"] retain];
		minValue = 0.0;
		maxValue = 100.0;
		value = 0.0;
		drawsFocusRing = YES;
		searchFieldLeftImage = [NSImage imageNamed:@"search_left"];
		searchFieldMiddleImage = [NSImage imageNamed:@"search_middle"];
		searchFieldRightImage = [NSImage imageNamed:@"search_right"];
		searchFieldRightClearImage = [NSImage imageNamed:@"search_right_clear"];
		searchFieldRightClearPressedImage = [NSImage imageNamed:@"search_right_clear_pressed"];
		searchFieldProgLeftImage = [NSImage imageNamed:@"search_prog_left"];
		searchFieldProgMiddleImage = [NSImage imageNamed:@"search_prog_middle"];
		searchFieldProgRightImage = [NSImage imageNamed:@"search_prog_right"];
		searchFieldProgRightClearImage = [NSImage imageNamed:@"search_prog_right_clear"];
		searchFieldProgRightClearPressedImage = [NSImage imageNamed:@"search_prog_right_clear_pressed"];
		[searchFieldLeftImage setFlipped:YES];
		[searchFieldMiddleImage setFlipped:YES];
		[searchFieldRightImage setFlipped:YES];
		[searchFieldRightClearImage setFlipped:YES];
		[searchFieldRightClearPressedImage setFlipped:YES];
		[searchFieldProgLeftImage setFlipped:YES];
		[searchFieldProgMiddleImage setFlipped:YES];
		[searchFieldProgRightImage setFlipped:YES];
		[searchFieldProgRightClearImage setFlipped:YES];
		[searchFieldProgRightClearPressedImage setFlipped:YES];
		[self setShowsFirstResponder:NO];
		[self setDrawsBackground:NO];
	}
	return self;
}

- (void)dealloc
{
	[emptyString release];
        [parentTextField release];
	[super dealloc];
}

- (BOOL)showsFirstResponder
{
    return NO;
}

- (BOOL)wraps
{
    return NO;
}

- (BOOL)isScrollable
{
    return YES;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Draw Focus Ring
	[self drawFocusRingWithFrame:cellFrame inView:controlView];

	// Draw Base Image
	[self drawBaseImageWithFrame:cellFrame];
	
	// Draw Empty String
	[self drawEmptyStringWithFrame:cellFrame];

	// Draw Remaining Things
	[super drawInteriorWithFrame:[self textRectForFrame:cellFrame] inView:controlView];
}

- (void)drawFocusRingWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSBezierPath *bezier;
	if ([super showsFirstResponder] &&
			[[controlView window] isKeyWindow] && drawsFocusRing) {
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		bezier = [NSBezierPath bezierPath];
		[bezier moveToPoint:NSMakePoint(12, 0)];
		[bezier lineToPoint:NSMakePoint(cellFrame.size.width-12, 0)];
		[bezier curveToPoint:NSMakePoint(cellFrame.size.width-12, 21)
				controlPoint1:NSMakePoint(cellFrame.size.width+4, 0.5)
				controlPoint2:NSMakePoint(cellFrame.size.width+4, 20.5)];
		[bezier lineToPoint:NSMakePoint(12, 21)];
		[bezier curveToPoint:NSMakePoint(12, 0)
				controlPoint1:NSMakePoint(-4, 20.5)
				controlPoint2:NSMakePoint(-4, 0.5)];
		[bezier fill];
		[NSGraphicsContext restoreGraphicsState];
    }
}

- (void)drawBaseImageWithFrame:(NSRect)cellFrame
{
	[searchFieldLeftImage
		drawAtPoint:NSMakePoint(0, 0)
		fromRect:NSMakeRect(0, 0, 24, 21)
		operation:NSCompositeSourceOver fraction:1.0];
	[searchFieldMiddleImage
		drawInRect:NSMakeRect(24, 0, cellFrame.size.width-24*2, 21)
		fromRect:NSMakeRect(0, 0, 32, 21)
		operation:NSCompositeSourceOver fraction:1.0];
	if (length > 0) {
		if (clearButtonPressed) {
			[searchFieldRightClearPressedImage
				drawAtPoint:NSMakePoint(cellFrame.size.width-24, 0)
				fromRect:NSMakeRect(0, 0, 24, 21)
				operation:NSCompositeSourceOver fraction:1.0];
		} else {
			[searchFieldRightClearImage
				drawAtPoint:NSMakePoint(cellFrame.size.width-24, 0)
				fromRect:NSMakeRect(0, 0, 24, 21)
				operation:NSCompositeSourceOver fraction:1.0];
		}
	} else {
		[searchFieldRightImage
			drawAtPoint:NSMakePoint(cellFrame.size.width-24, 0)
			fromRect:NSMakeRect(0, 0, 24, 21)
			operation:NSCompositeSourceOver fraction:1.0];
	}
}
- (void)drawEmptyStringWithFrame:(NSRect)cellFrame
{
    NSRect textRect = [self textRectForFrame:cellFrame];
	textRect.origin.x += 2;
	if ([emptyString length] > 0 &&
			length == 0 &&
			[[parentTextField window] firstResponder] != [parentTextField window] &&
			([[parentTextField window] firstResponder] != [parentTextField currentEditor] ||
			 ![[[self controlView] window] isKeyWindow])) {
		NSDictionary *attrDict = [NSDictionary dictionaryWithObjects:
			[NSArray arrayWithObjects:[NSColor grayColor],
				[NSFont fontWithName:@"Lucida Grande" size:12.0], nil]
			forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil]];
		[emptyString drawInRect:textRect withAttributes:attrDict];
	}
}
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
    [super editWithFrame:[self textRectForFrame:aRect]
		inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
    NSRect textRect = [self textRectForFrame:aRect];
    [super selectWithFrame:textRect
                    inView:controlView
                    editor:textObj
                  delegate:anObject
                     start:selStart
                    length:selLength];
}

- (void)resetCursorRect:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super resetCursorRect:[self textRectForFrame:cellFrame] inView:controlView];
}

- (NSRect)textRectForFrame:(NSRect)frame
{
    frame.origin.x += 24;
    frame.origin.y += 3;
    frame.size.width -= 24 + 19;
    return frame;
}

- (BOOL)drawsFocusRing
{
	return drawsFocusRing;
}

- (void)setDrawsFocusRing:(BOOL)flag
{
	drawsFocusRing = flag;
}

- (double)maxValue
{
	return maxValue;
}

- (double)minValue
{
	return minValue;
}

- (void)setMaxValue:(double)newMaximum
{
	maxValue = newMaximum;
}

- (void)setMinValue:(double)newMinimum
{
	minValue = newMinimum;
}

- (double)doubleValue
{
	return value;
}

- (void)setDoubleValue:(double)doubleValue
{
	value = doubleValue;
}

- (NSString *)emptyString
{
	return emptyString;
}

- (void)setEmptyString:(NSString *)str
{
	[emptyString release];
	emptyString = [str retain];
}

- (void)setLength:(unsigned int)theLength
{
	length = theLength;
}

- (BOOL)clearButtonPressed
{
	return clearButtonPressed;
}

- (void)setClearButtonPressed:(BOOL)flag
{
	clearButtonPressed = flag;
}

@end