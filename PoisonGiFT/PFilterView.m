//
// PFilterView.m
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

#import "PFilterView.h"

@implementation PFilterView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	return self;
}

- (void)drawRect:(NSRect)rect
{
    NSRect content = rect;
    if (rect.size.height == [self frame].size.height) {
        NSDrawGroove(rect,rect);
        content.origin.x +=0.5;
        content.size.width-=1;
        content.size.height-=1;
    }
    [[NSColor whiteColor] set];
    NSRectFill(content);
    [super drawRect:rect];
}

@end
