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

+ (void)initialize
{
    [PTextField setCellClass:[PTextFieldCell class]];
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self setBezelStyle:NSTextFieldRoundedBezel];
    }
    return self;
}

- (void)setImage:(NSImage *)image
{
  [[self cell] setImage:image];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (point.x<[[[self cell] image] size].width) {
        id <PTextFieldDelegate> delegate = [self delegate];
        if (delegate && [delegate respondsToSelector:@selector(willPopUpMenuForTextField:)])
            [delegate performSelector:@selector(willPopUpMenuForTextField:)];
            [NSMenu popUpContextMenu:[delegate willPopUpMenuForTextField:self] withEvent:theEvent forView:self];
    }
    else [super mouseDown:theEvent];
}

@end
