//
// PTextField.m
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

#import "PTextField.h"

@protocol PTextFieldDelegate <NSObject>

- (void)willPopUpMenuForTextField:(PTextField *)textfield;

@end


@implementation PTextField

/*+ (void)initialize
{
    [PTextField setCellClass:[PTextFieldCell class]];
}*/


- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    clearButtonPressed = NO;
    if (point.x > NSWidth([self frame]) - 18) {
		[(PTextFieldCell *) searchCell setClearButtonPressed:YES];
		clearButtonPressed = YES;
		[self display];
	}
    else if (point.x <= 24) {
        id <PTextFieldDelegate> delegate = [self delegate];
        if (delegate && [delegate respondsToSelector:@selector(willPopUpMenuForTextField:)])
            [delegate performSelector:@selector(willPopUpMenuForTextField:)];
            [NSMenu popUpContextMenu:[delegate willPopUpMenuForTextField:self] withEvent:theEvent forView:self];
    }
    else [super mouseDown:theEvent];
    
}
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self) {
            NSCell * oldCell;
		clearButtonPressed = NO;
		attrDict =
			[[NSDictionary dictionaryWithObject:
				[NSFont fontWithName:@"Lucida Grande" size:12.0]
				forKey:NSFontAttributeName] retain];
	
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(windowDidBecomeKey:)
			name:NSWindowDidBecomeKeyNotification object:nil];
	
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(windowDidResignKey:)
			name:NSWindowDidResignKeyNotification object:nil];
	
		searchCell = [[PTextFieldCell alloc] initWithTextField:self];
                oldCell = [self cell];
		[searchCell setContinuous:[oldCell isContinuous]];
		[searchCell setSendsActionOnEndEditing:[oldCell sendsActionOnEndEditing]];
		[searchCell setEditable:[oldCell isEditable]];
		target = [oldCell target];
		action = [oldCell action];
		[self setCell:searchCell];
	}
	return self;
}

- (void)awakeFromNib
{
	target = [[self cell] target];
	action = [[self cell] action];
	[[self cell] setTarget:nil];
	[[self cell] setAction:nil];
}

- (void)dealloc
{
	[attrDict release];
	[super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	if ([aNotification object] == [self window]) {
		[[self window] display];
	}
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
	if ([aNotification object] == [self window]) {
		[[self window] display];
		[self display];
	}
}

- (void)textDidChange:(NSNotification *)aNotification
{
    NSString *str;
    NSSize strSize;
    NSSize cellSize;
    str = [self stringValue];
	[(PTextFieldCell *) searchCell setLength:[str length]];
        
        strSize = [str sizeWithAttributes:attrDict];
	cellSize = [searchCell cellSize];
	if (strSize.width > cellSize.width) {
		[[self window] display];
	}

}

- (BOOL)drawsFocusRing
{
	return [(PTextFieldCell *) searchCell drawsFocusRing];
}

- (void)setDrawsFocusRing:(BOOL)flag
{
	[(PTextFieldCell *) searchCell setDrawsFocusRing:flag];
}

- (double)maxValue
{
	return [(PTextFieldCell *) searchCell maxValue];
}

- (double)minValue
{
	return [(PTextFieldCell *) searchCell minValue];
}

- (void)setMaxValue:(double)newMaximum
{
	[(PTextFieldCell *) searchCell setMaxValue:newMaximum];
}

- (void)setMinValue:(double)newMinimum
{
	[(PTextFieldCell *) searchCell setMinValue:newMinimum];
}

- (double)doubleValue
{
	return [(PTextFieldCell *) searchCell doubleValue];
}

- (void)setDoubleValue:(double)doubleValue
{
	[(PTextFieldCell *) searchCell setDoubleValue:doubleValue];
}

- (NSString *)emptyString
{
	return [(PTextFieldCell *) searchCell emptyString];
}

- (void)setEmptyString:(NSString *)str
{
	[(PTextFieldCell *) searchCell setEmptyString:str];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (clearButtonPressed) {
		if (pos.x > NSWidth([self frame]) - 18) {
			if (![(PTextFieldCell *) searchCell clearButtonPressed]) {
				[(PTextFieldCell *) searchCell setClearButtonPressed:YES];
				[self display];
			}
		} else {
			if ([(PTextFieldCell *) searchCell clearButtonPressed]) {
				[(PTextFieldCell *) searchCell setClearButtonPressed:NO];
				[self display];
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (clearButtonPressed) {
		if (pos.x > NSWidth([self frame]) - 18) {
			[self setStringValue:@""];
			[(PTextFieldCell *) searchCell setLength:0];
		}
		[(PTextFieldCell *) searchCell setClearButtonPressed:NO];
		[self display];
	}
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(insertNewline:)) {
		[self fireAction];
	}
	return NO;
}

- (void)fireAction
{
    [target performSelector:action withObject:self];
}
@end
