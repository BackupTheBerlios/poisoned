//
// PTextField.m
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

#import "PTextField.h"

@implementation PTextField

- (void)setImage:(NSImage *)image
{
  [self setEnabled:NO];
  if (image) {
    if ([[self cell] isMemberOfClass:[PTextFieldCell class]]) {
        [[self cell] setImage:image];
    }
    else {
        PTextFieldCell *cell = [[PTextFieldCell alloc] init];
        [cell setBordered:NO];
        [cell setBezeled:YES];
        [cell setBezelStyle:NSTextFieldRoundedBezel];
        [cell setStringValue:@""];
        [cell setEditable:YES];
        [cell setScrollable:YES];
        [cell setImage:image];
        [self setCell:cell];
        [cell release];
    }
  }
  else {
        NSTextFieldCell *cell = [[NSTextFieldCell alloc] init];
        [cell setBordered:NO];
        [cell setBezeled:YES];
        [cell setBezelStyle:NSTextFieldRoundedBezel];
        [cell setStringValue:@""];
        [cell setEditable:YES];
        [cell setScrollable:YES];
        [cell setImage:image];
        [self setCell:cell];
        [cell release];
  }
  [self setEnabled:YES];
}

@end
