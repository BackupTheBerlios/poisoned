//
// PUploadController.m
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

#import "PUploadController.h"

@implementation PUploadController

- (void)awakeFromNib
{
    dataSource = [[PUploadSource alloc] initWithTable:table];
    [table setMenuDelegate:self];
    [table setDataSource:dataSource];
    [table setDelegate:dataSource];
    
    [table setDrawsGrid:YES];
    NSArray *cols = [table tableColumns];
    int i, count=[cols count];
    for (i=0;i<count;i++) [[[cols objectAtIndex:i] dataCell] setDrawsBackground:NO];

    [table setRowHeight:34];
    [[table tableColumnWithIdentifier:@"PFileUser"] setDataCell:
        [[[PTableTitleDescriptionCell alloc] init] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PTransfer"] setDataCell:
        [[[PSizeCell alloc] initCenteredCell] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PSize"] setDataCell:
        [[[PSizeCell alloc] initCenteredCell] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PProgress"] setDataCell:
        [[[PTableProgressCell alloc] init] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PIcon"] setDataCell:
        [[[NSImageCell alloc] init] autorelease]
    ];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [dataSource release];
    [super dealloc];
}

- (void)setCommander:(PCommand *)_commander andController:(id)_controller
{
    controller=_controller;
    commander = _commander;
    [commander registerController:self forCommands:
        [NSArray arrayWithObjects:@"ADDUPLOAD",@"CHGUPLOAD",@"DELUPLOAD",nil]
    ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PoisonConnectionClosed" object:commander];
    // datasource needs the commander for cancelling uploads
    [dataSource setCommander:commander];
}

- (void)disconnected:(id)sender
{
    [dataSource disconnected];
}

- (void)gui_update:(BOOL)activeView
{
    //if (activeView) [table reloadData];
}

- (NSView *)view
{
    return view;
}

- (IBAction)cancel:(id)sender
{
    [dataSource cancel:commander];
}

- (IBAction)pause:(id)sender
{
    [dataSource pause:commander];
}

- (IBAction)resume:(id)sender
{
    [dataSource resume:commander];
}

- (IBAction)delsource:(id)sender
{
    [dataSource delsource:commander];
}

- (NSString *)browsehost;
{
    return [[[dataSource itemAtRow:[table selectedRow]] objectForKey:@"PFileUser"] objectAtIndex:2];
}

- (IBAction)upbrowsehost:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PUpBrowseHost" object:self userInfo:nil];
}


- (IBAction)cleanUp:(id)sender
{
    [dataSource cleanUp:commander];
}

- (IBAction)expand:(id)sender
{
//    [dataSource expand];
}

- (IBAction)collapse:(id)sender
{
//    [dataSource collapse];
}

- (int)speed
{
    return [dataSource speed];
}

- (oneway void)ADDUPLOAD:(in NSArray *)data 
{
    if (!data) return;
    [commander removeTicket:[data objectAtIndex:1]];
    [dataSource ADDUPLOAD:data];
}

- (oneway void)CHGUPLOAD:(in NSArray *)data
{
    if (!data) return;
    [dataSource CHGUPLOAD:data];
    [controller validate];
}

- (oneway void)DELUPLOAD:(in NSArray *)data
{
    if (!data) return;
    [commander freeTicket:[data objectAtIndex:1]];
    [dataSource DELUPLOAD:data];
    [controller validate];
}

- (void)ADDSOURCE:(NSArray *)data
{
    if (!data) return;
    [dataSource ADDSOURCE:data];
}

- (void)DELSOURCE:(NSArray *)data
{
    if (!data) return;
    [dataSource DELSOURCE:data];
}

- (NSMenu *)tableView:(NSTableView *)_table menuForTableColumn:(NSTableColumn *)_column row:(int)_row
{
    [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:_table];
    if (![_table isRowSelected:_row]) [_table selectRow:_row byExtendingSelection:NO];
    return contextualMenu;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    NSString *ident = [theItem itemIdentifier];
    if ([ident isEqualToString:@"upCancel"]) {
        return [dataSource validateCancel];
    }
    else if ([ident isEqualToString:@"upPause"]) {
        return [dataSource validatePause];
    }
    else if ([ident isEqualToString:@"upResume"]) {
        return [dataSource validateResume];
    }
    else if ([ident isEqualToString:@"upDelSource"]) {
        return [dataSource validateDelSource];
    }
    else if ([ident isEqualToString:@"upBrowseHost"]) {
        if (([table numberOfSelectedRows]==1)) return YES;
        else return NO;
    }
    else return YES;
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
    if (menuItem==m_cancel) {
        return [dataSource validateCancel];
    }
    else if (menuItem==m_browse) {
        if ([table numberOfSelectedRows]==1) return YES;
        else return NO;
    }
    else return YES;
}


@end
