//
//  PSearchCell.m
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

#import "PSearchCell.h"


@implementation PSearchCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
 NSMutableParagraphStyle *paragraphStyle= [[[NSParagraphStyle 
 defaultParagraphStyle] mutableCopy] autorelease];
 [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
NSDictionary *boldFont;
NSDictionary *tinyFont;
if ([self isHighlighted] && ([self highlightColorWithFrame:cellFrame inView:controlView]!=[NSColor secondarySelectedControlColor])) {
    boldFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:11.0],NSFontAttributeName,
            [NSColor whiteColor],NSForegroundColorAttributeName,
            paragraphStyle,NSParagraphStyleAttributeName,
        nil];
    tinyFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:10.0],NSFontAttributeName,
            [NSColor whiteColor],NSForegroundColorAttributeName,
            paragraphStyle,NSParagraphStyleAttributeName,
        nil];
}
else {
    boldFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:11.0],NSFontAttributeName,
            paragraphStyle,NSParagraphStyleAttributeName,
        nil];
    tinyFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:10.0],NSFontAttributeName,
            [NSColor darkGrayColor],NSForegroundColorAttributeName,
            paragraphStyle,NSParagraphStyleAttributeName,
        nil];
}
    NSPoint cellPoint = cellFrame.origin;
    NSSize cellSize = cellFrame.size;


    [controlView lockFocus];

    [[cellValue objectAtIndex:0] drawInRect:NSMakeRect(cellPoint.x+5, cellPoint.y+1, cellSize.width-5, cellSize.height) withAttributes:boldFont];
    [[cellValue objectAtIndex:1] drawInRect:NSMakeRect(cellPoint.x+5, cellPoint.y+14, cellSize.width-5, cellSize.height) withAttributes:tinyFont];

    [controlView unlockFocus];
    
}

- (void)setObjectValue:(id <NSCopying>)object
{
    cellValue = object;
}

@end
