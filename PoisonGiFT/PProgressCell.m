//
//  PProgressCell.m
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

#import "PProgressCell.h"


@implementation PProgressCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{    
    BOOL isHighlighted = [self isHighlighted] && ([self highlightColorWithFrame:cellFrame inView:controlView]!=[NSColor secondarySelectedControlColor]);
    if ([[cellValue objectAtIndex:0] boolValue]) {
      if ([[cellValue objectAtIndex:1] boolValue]) {
        
      
        NSRect stroke = cellFrame;
        stroke.size.width	-= 4;
        stroke.size.height	-= 21;
        stroke.origin.x		+= 2;
        stroke.origin.y		+= 10.5;
        NSRect fill = stroke;
        fill.size.width		= (int)(fill.size.width*[[cellValue objectAtIndex:2] floatValue])+0.5;
        
        if (!isHighlighted) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:stroke];
            [[NSColor lightGrayColor] set];
            //[[NSColor colorWithDeviceWhite:0.8 alpha:1.0] set];
        }
        else [[NSColor whiteColor] set];

        [NSBezierPath fillRect:fill];
        
        if (isHighlighted) [[NSColor whiteColor] set];
        else [[NSColor lightGrayColor] set];
        [NSBezierPath strokeRect:stroke];
      }
      else {
        NSMutableParagraphStyle *paragraphStyle= [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [paragraphStyle setAlignment:NSCenterTextAlignment];
        NSDictionary *smallFont;
        if (isHighlighted) {
        smallFont =
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:10.0],NSFontAttributeName,
                [NSColor whiteColor],NSForegroundColorAttributeName,
                paragraphStyle,NSParagraphStyleAttributeName,
            nil];
        }
        else {
        smallFont =
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:10.0],NSFontAttributeName,
                [NSColor darkGrayColor],NSForegroundColorAttributeName,
                paragraphStyle,NSParagraphStyleAttributeName,
            nil];
        }
        NSPoint cellPoint = cellFrame.origin;
        NSSize cellSize = cellFrame.size;

        [controlView lockFocus];
        [[cellValue objectAtIndex:2] drawInRect:NSMakeRect(cellPoint.x, cellPoint.y+17, cellSize.width, cellSize.height) withAttributes:smallFont];
        [controlView unlockFocus];    
      }

    }
    else if ([[cellValue objectAtIndex:1] boolValue]) {
        NSRect stroke = cellFrame;
        stroke.size.width	-= 4;
        stroke.size.height	-= 5;
        stroke.origin.x		+= 2;
        stroke.origin.y		+= 2.5;
        NSRect fill = stroke;
        fill.size.width		= (int)(fill.size.width*[[cellValue objectAtIndex:2] floatValue])+0.5;
        
        if (!isHighlighted) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:stroke];
            [[NSColor lightGrayColor] set];
        }
        else [[NSColor whiteColor] set];
        [NSBezierPath fillRect:fill];
        
        if (isHighlighted) [[NSColor whiteColor] set];
        else [[NSColor lightGrayColor] set];
        [NSBezierPath strokeRect:stroke];
    }
    else {
        NSMutableParagraphStyle *paragraphStyle= [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [paragraphStyle setAlignment:NSCenterTextAlignment];
        NSDictionary *smallFont;
        if (isHighlighted) {
        smallFont =
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:10.0],NSFontAttributeName,
                [NSColor whiteColor],NSForegroundColorAttributeName,
                paragraphStyle,NSParagraphStyleAttributeName,
            nil];
        }
        else {
        smallFont =
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:10.0],NSFontAttributeName,
                [NSColor darkGrayColor],NSForegroundColorAttributeName,
                paragraphStyle,NSParagraphStyleAttributeName,
            nil];
        }
        NSPoint cellPoint = cellFrame.origin;
        NSSize cellSize = cellFrame.size;


    [controlView lockFocus];
        [[cellValue objectAtIndex:2] drawInRect:NSMakeRect(cellPoint.x, cellPoint.y+1, cellSize.width, cellSize.height) withAttributes:smallFont];
    [controlView unlockFocus];    
    }
}

- (void)setObjectValue:(id <NSCopying>)object
{
    cellValue = object;
}

@end
