//
// PSearchFilterController.m
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

#import "PSearchFilterController.h"

@implementation PSearchFilterController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAvailableProtos:) name:@"PStatsProtocolsAvailable" object:nil];
    
    [keywordField setDelegate:self];
    
    [protoTable setIntercellSpacing:NSMakeSize(0,0)];
    
    NSButtonCell *check = [[[NSButtonCell alloc] init] autorelease];
    [check setButtonType:NSSwitchButton];
    [check setControlSize:NSSmallControlSize];
    [protoTable setTarget:self];
    [protoTable setAction:@selector(setProtos:)];
    [check setFont:[NSFont systemFontOfSize:10]];
    [check setContinuous:YES];
    [[protoTable tableColumnWithIdentifier:@"proto"] setDataCell:check];
    [minSize setToolTip:@"Use this slider to set the minimal size."];
    [maxSize setToolTip:@"Use this slider to set the maximale size."];
    [keywordField setToolTip:@"Keyword filter"];
    [de_activate setToolTip:@"Enable/disable filtering"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (protos) [protos release];
    [super dealloc];
}

- (void)disconnected
{

    if ([collexp state]==NSOnState) {
        [collexp setState:NSOffState];
        [self collexp:nil];
    }
    [collexp setEnabled:NO];

}

- (void)setDataSource:(PResultSource *)_datasource
{
    datasource = _datasource;
    [self setValues];
    [protoTable reloadData];
}

- (void)setValues
{
    if (datasource==nil) {
        [de_activate setState:NSOffState];
        [keywordField setEnabled:NO];
        [minSize setEnabled:NO];
        [maxSize setEnabled:NO];
        [info setStringValue:@"no search selected"];
    }
    else if ([datasource isFiltered]) {
        [de_activate setState:NSOnState];
        [info setStringValue:@"on"];
    }
    else {
        [de_activate setState:NSOffState];
        [info setStringValue:@"off"];
    }
    if (datasource) {
        if ([datasource protoFilter]==nil) [datasource setProtoFilter:protos];
        [keywordField setEnabled:YES];
        [minSize setEnabled:YES];
        [maxSize setEnabled:YES];
        [minText setTextColor:[NSColor blackColor]];
        [maxText setTextColor:[NSColor blackColor]];
        [minSize setDoubleValue:[datasource minSizeFilter]];
        [maxSize setDoubleValue:[datasource maxSizeFilter]];
        if ([datasource keywordFilter]) [keywordField setStringValue:[datasource keywordFilter]];
        else [keywordField setStringValue:@""];
    }
    else {
        [keywordField setStringValue:@""];
        [minSize setDoubleValue:[minSize minValue]];
        [maxSize setDoubleValue:[maxSize maxValue]];
        [minText setTextColor:[NSColor grayColor]];
        [maxText setTextColor:[NSColor grayColor]];
    }
}

- (void)setUpView
{
    int p_count = [protos count];
    int y=5,width = [[view superview] frame].size.width-40;
    NSScrollView *table = [protoTable enclosingScrollView];
    [view addSubview:keywordField];
    [view addSubview:sizeFilter];
    [view addSubview:table];
    NSRect k_rect = [keywordField frame];
    NSRect s_rect = [sizeFilter frame];
    NSRect p_rect = [table frame];
    y -= 10 + k_rect.size.height;
    k_rect.origin.x	= 20;
    k_rect.origin.y	= y;
    k_rect.size.width	= width;
    y -= 10 + s_rect.size.height;
    s_rect.origin.x	= 16;
    s_rect.origin.y	= y;
    s_rect.size.width	= width+11;
    p_rect.size.height	= p_count * 15+1;
    y -= 10 + p_rect.size.height;
    p_rect.origin.x	= 20;
    p_rect.origin.y	= y;
    p_rect.size.width	= width;
    [keywordField setFrame:k_rect];
    [sizeFilter setFrame:s_rect];
    [table setFrame:p_rect];
    [collexp setEnabled:YES];
    [view setNeedsDisplay:YES];
    view_height = -y +5;
}

- (void)setAvailableProtos:(NSNotification *)notification
{
    if (protos) [protos autorelease];
    protos = [[[notification userInfo] objectForKey:@"protos"] mutableCopy];
    [self setUpView];
}

- (IBAction)collexp:(id)sender
{
    int i, it, rest, step=20;
    it   = view_height/20;
    rest = view_height%20;
    if ([collexp state]==NSOffState) {
        step *= -1;
        rest *= -1;
    }
    NSRect s_frame = [searches frame];
    NSRect f_frame = [view frame];
    for (i=0;i<it;i++) {
        s_frame.size.height	-= step;
        f_frame.origin.y	-= step;
        f_frame.size.height	+= step;
        [searches setFrame:s_frame];
        [view setFrame:f_frame];
        [[searches superview] display];
    }
    s_frame.size.height	-= rest;
    f_frame.origin.y	-= rest;
    f_frame.size.height	+= rest;
    [searches setFrame:s_frame];
    [view setFrame:f_frame];
    [[searches superview] display];
}

- (void)activate
{
    [de_activate setState:NSOnState];
    if (![datasource isFiltered]) [self de_activate:nil];
}

- (IBAction)de_activate:(id)sender
{
    if (datasource==nil) {
        [de_activate setState:NSOffState];
        return;
    }
    BOOL act = [de_activate state]==NSOnState;
    if (act) [info setStringValue:@"on"];
    else [info setStringValue:@"off"];
    [datasource setFiltered:act];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFilterDeAcitivated" object:self userInfo:nil];
}

- (IBAction)setKeyword:(id)sender
{
    [self activate];
    [datasource setKeywordFilter:[keywordField stringValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFilterDeAcitivated" object:self userInfo:nil];
}

- (IBAction)maxSizeChanged:(id)sender
{
    [self activate];
    if ([sender doubleValue]<[minSize doubleValue]) [sender setDoubleValue:[minSize doubleValue]];
    [datasource setMaxSizeFilter:[sender doubleValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFilterDeAcitivated" object:self userInfo:nil];
}

- (IBAction)minSizeChanged:(id)sender
{
    [self activate];
    if ([sender doubleValue]>[maxSize doubleValue]) [sender setDoubleValue:[maxSize doubleValue]];
    [datasource setMinSizeFilter:[sender doubleValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFilterDeAcitivated" object:self userInfo:nil];
}

- (void)setProtos:(id)sender
{
    if (datasource==nil) return;
    [self activate];
    int row = [sender clickedRow];
    NSMutableArray *_protos = [datasource protoFilter];
    NSString *_item = [protos objectAtIndex:row];
    if ([_protos containsObject:_item]) [_protos removeObject:_item];
    else [_protos addObject:_item];
    [protoTable reloadData];
    [datasource filterProtos];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFilterDeAcitivated" object:self userInfo:nil];
}

// ------------------------------------------------------------
// DataSource for the protocol table...
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [protos count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [protos objectAtIndex:rowIndex];
}

// Delegate for the protocol table...
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    return NO;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    [aCell setTitle:[protos objectAtIndex:rowIndex]];
    if (datasource) {
        [aCell setEnabled:YES];
        if ([[datasource protoFilter] containsObject:[protos objectAtIndex:rowIndex]]) [aCell setState:NSOnState];
        else [aCell setState:NSOffState];
    }
    else {
        [aCell setEnabled:NO];
        [aCell setState:NSOnState];
    }
}
// ------------------------------------------------------------


// ------------------------------------------------------------
// keywordField delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self setKeyword:nil];
}
// ------------------------------------------------------------

@end
