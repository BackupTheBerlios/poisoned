//
//  PTextFieldCell.h
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

#import <Cocoa/Cocoa.h>

@interface PTextFieldCell : NSTextFieldCell
{
    @private
        NSImage	*image;
    	NSImage *searchFieldLeftImage;
	NSImage *searchFieldMiddleImage;
	NSImage *searchFieldRightImage;
	NSImage *searchFieldRightClearImage;
	NSImage *searchFieldRightClearPressedImage;
	NSImage *searchFieldProgLeftImage;
	NSImage *searchFieldProgMiddleImage;
	NSImage *searchFieldProgRightImage;
	NSImage *searchFieldProgRightClearImage;
	NSImage *searchFieldProgRightClearPressedImage;
        
        BOOL drawsFocusRing;
	BOOL clearButtonPressed;

	double maxValue;
	double minValue;
	double value;
	
	NSString *emptyString;
	
	NSTextField *parentTextField;
	
	unsigned int length;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

- (id)initWithTextField:(NSTextField *)textField;

- (NSRect)textRectForFrame:(NSRect)frame;

- (BOOL)drawsFocusRing;
- (void)setDrawsFocusRing:(BOOL)flag;

- (double)maxValue;
- (double)minValue;
- (void)setMaxValue:(double)newMaximum;
- (void)setMinValue:(double)newMinimum;
- (double)doubleValue;
- (void)setDoubleValue:(double)doubleValue;

- (NSString *)emptyString;
- (void)setEmptyString:(NSString *)str;

@end

@interface PTextFieldCell(Internal)

- (void)drawFocusRingWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawBaseImageWithFrame:(NSRect)cellFrame;
- (void)drawProgressIndicatorWithFrame:(NSRect)cellFrame;
- (void)drawEmptyStringWithFrame:(NSRect)cellFrame;

- (void)setLength:(unsigned int)theLength;
- (BOOL)clearButtonPressed;
- (void)setClearButtonPressed:(BOOL)flag;

@end