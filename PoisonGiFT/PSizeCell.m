//
// PSizeCell.m
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

#import "PSizeCell.h"

@implementation PSizeCell

- (id)initCenteredCell
{
    if (self=[super init]) {
        centered=YES;
    }
    return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
 NSMutableParagraphStyle *paragraphStyle= [[[NSParagraphStyle 
 defaultParagraphStyle] mutableCopy] autorelease];
 [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
 if (centered) [paragraphStyle setAlignment:NSCenterTextAlignment];
NSDictionary *boldFont;
NSDictionary *tinyFont;
NSDictionary *normalFont;
if ([self isHighlighted] && ([self highlightColorWithFrame:cellFrame inView:controlView]!=[NSColor secondarySelectedControlColor])) {
    boldFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:11.0],NSFontAttributeName,
            [NSColor whiteColor],NSForegroundColorAttributeName,
            paragraphStyle,NSParagraphStyleAttributeName,
        nil];
    normalFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:10.0],NSFontAttributeName,
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
    normalFont =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:10.0],NSFontAttributeName,
            [NSColor darkGrayColor],NSForegroundColorAttributeName,
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

    if ([[cellValue objectAtIndex:0] boolValue]) {
        [[cellValue objectAtIndex:1] drawInRect:NSMakeRect(cellPoint.x, cellPoint.y+4, cellSize.width, cellSize.height) withAttributes:boldFont];
        [[cellValue objectAtIndex:2] drawInRect:NSMakeRect(cellPoint.x, cellPoint.y+17, cellSize.width, cellSize.height) withAttributes:tinyFont];
    }
    else {
        [[cellValue objectAtIndex:1] drawInRect:NSMakeRect(cellPoint.x, cellPoint.y+1, cellSize.width, cellSize.height) withAttributes:normalFont];
    }
    
    [controlView unlockFocus];

}

- (void)setObjectValue:(id <NSCopying>)object
{
    cellValue = object;
}

@end
