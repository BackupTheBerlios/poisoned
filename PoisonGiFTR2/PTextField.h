//
// PTextField.h
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
#import "PTextFieldCell.h"

@interface PTextField : NSTextField
{
	//IBOutlet id delegate;

	@private
        id			target;
        SEL			action;
        NSTextFieldCell		*searchCell;
        NSDictionary		*attrDict;
        BOOL			clearButtonPressed;
}

// Gets/Sets whether this text field draws focus ring around. Notice that non-editable text field will not draw the focus ring.
- (BOOL)drawsFocusRing;
- (void)setDrawsFocusRing:(BOOL)flag;

// Gets the maximum value for the receiver or sets it to newMaximum.
- (double)maxValue;
- (void)setMaxValue:(double)newMaximum;

// Gets the minimum value for the receiver or sets it to newMinimum.
- (double)minValue;
- (void)setMinValue:(double)newMinimum;

// Gets the value that indicates the current extent of the receiver or sets it to doubleValue.
- (double)doubleValue;
- (void)setDoubleValue:(double)doubleValue;

// Gets/Sets the string which will be drawn when this text field does not have focus and the content string is empty.
- (NSString *)emptyString;
- (void)setEmptyString:(NSString *)str;

// Sets the name used to automatically save the history words in the defaults system to name. If name isn't the empty string (@""), the the history word list is saved as a user default each time the history changes.
- (NSString *)historyAutosaveName;
- (void)setHistoryAutosaveName:(NSString *)str;

- (NSString *)searchRealmName;
- (void)setSearchRealmName:(NSString *)str;

// Fires an action if target and action are set.
- (void)fireAction;


@end
