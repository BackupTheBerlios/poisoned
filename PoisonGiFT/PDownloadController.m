//
// PDownloadController.m
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

#import "PDownloadController.h"
#import "PGiFTConf.h"

@implementation PDownloadController

- (void)awakeFromNib
{
    NSArray *cols;
    int i, count;
    
    hashes = [[NSMutableSet alloc] init];

    dataSource = [[PDownloadSource alloc] initWithTable:table];
    [table setMenuDelegate:self];
    [table setDataSource:dataSource];
    [table setDelegate:dataSource];
    [table setDrawsGrid:YES];
    cols = [table tableColumns];
    count=[cols count];
    for (i=0;i<count;i++) [[[cols objectAtIndex:i] dataCell] setDrawsBackground:NO];
    [table setOutlineTableColumn:[cols objectAtIndex:1]];
    [table setAutoresizesOutlineColumn:NO];
    
    [table setSmallRowHeight:16];
    [table setRowHeight:34];
    [[table tableColumnWithIdentifier:@"PFileUser"] setDataCell:
        [[[PTitleDescriptionCell alloc] init] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PTransfer"] setDataCell:
        [[[PSizeCell alloc] initCenteredCell] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PSize"] setDataCell:
        [[[PSizeCell alloc] initCenteredCell] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PProgress"] setDataCell:
        [[[PProgressCell alloc] init] autorelease]
    ];
    [[table tableColumnWithIdentifier:@"PIcon"] setDataCell:
        [[[NSImageCell alloc] init] autorelease]
    ];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hashes release];
    [dataSource release];
    [super dealloc];
}

- (void)setCommander:(PCommand *)_commander andController:(id)_controller
{
    controller =_controller;
    commander = _commander;
    [commander registerController:self forCommands:
        [NSArray arrayWithObjects:@"ADDDOWNLOAD",@"CHGDOWNLOAD",@"DELDOWNLOAD",nil]
    ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PoisonConnectionClosed" object:commander];
}

- (NSView *)view
{
    return view;
}

- (void)disconnected:(id)sender
{
    [hashes removeAllObjects];
    [dataSource disconnected];
}

- (void)gui_update:(BOOL)activeView
{
    //if (activeView) [table reloadData];
}

- (IBAction)cancel:(id)sender
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        [hashes removeObject:[item objectForKey:@"hash"]];
    }

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
    return [[[table itemAtRow:[table selectedRow]] objectForKey:@"PFileUser"] objectAtIndex:1];
}

- (IBAction)downbrowsehost:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PDownBrowseHost" object:self userInfo:nil];
}

- (IBAction)cleanUp:(id)sender
{
    [dataSource cleanUp:commander];
}

- (IBAction)reveal:(id)sender
{
	int status = [[[table itemAtRow:[table selectedRow]] objectForKey:@"PStatus"] intValue];
	if (status == PCOMPLETED)
	{
		PGiFTConf *gift_conf = [PGiFTConf singleton];
		[gift_conf read];
		NSString *path = [gift_conf optionForKey:@"completed"];
		if (path)
		{
			NSString *fileName = [[[table itemAtRow:[table selectedRow]] objectForKey:@"PFileUser"] objectAtIndex:1];
			path = [path stringByAppendingPathComponent:fileName];
			[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:NULL];
		}
	}
}

- (IBAction)expand:(id)sender
{
    [dataSource expand];
}

- (IBAction)collapse:(id)sender
{
    [dataSource collapse];
}

- (int)speed
{
    return [dataSource speed];
}

- (NSSet *)hashes
{
    return hashes;
}

- (oneway void)ADDDOWNLOAD:(in NSArray *)data 
{
    NSString *hash;
    if (!data) return;
    hash = [[data objectAtIndex:2] objectForKey:@"hash"];
    [commander removeTicket:[data objectAtIndex:1]];
    [dataSource ADDDOWNLOAD:data];
    if (hash) {
        [hashes addObject:[[hash copy] autorelease]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PTransferSetChanged" object:self];
    }
    [controller validate];
}

- (oneway void)CHGDOWNLOAD:(in NSArray *)data
{
    if (!data) return;
    [dataSource CHGDOWNLOAD:data];
    [controller validate];
}

- (oneway void)DELDOWNLOAD:(in NSArray *)data
{
    NSString *hash;
    if (!data) return;
    hash = [dataSource hashForTicket:[data objectAtIndex:1]];
    [commander freeTicket:[data objectAtIndex:1]];
    [dataSource DELDOWNLOAD:data];
    if (hash) {
        [hashes removeObject:hash];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PTransferSetChanged" object:self];
    }
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

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    NSString *ident = [theItem itemIdentifier];
    if ([ident isEqualToString:@"downCancel"]) {
        return [dataSource validateCancel];
    }
    else if ([ident isEqualToString:@"downPause"]) {
        return [dataSource validatePause];
    }
    else if ([ident isEqualToString:@"downResume"]) {
        return [dataSource validateResume];
    }
    else if ([ident isEqualToString:@"downDelSource"]) {
        return [dataSource validateDelSource];
    }
    else if ([ident isEqualToString:@"downBrowseHost"]) {
        if ([table numberOfSelectedRows]==1 && ![[table itemAtRow:[table selectedRow]] objectForKey:@"PExpandable"]) return YES;
        else return NO;
    }
    else return YES;
}

- (NSMenu *)tableView:(NSOutlineView *)_table menuForTableColumn:(NSTableColumn *)_column row:(int)_row
{
    [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:_table];
    if (![_table isRowSelected:_row]) [_table selectRow:_row byExtendingSelection:NO];
    return contextualMenu;
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
    if (menuItem==m_findsources) {
        return [dataSource validateFindMoreSources];
    }
    else if (menuItem==m_cancel) {
        return [dataSource validateCancel];
    }
    else if (menuItem==m_pause) {
        return [dataSource validatePause];
    }
    else if (menuItem==m_resume) {
        return [dataSource validateResume];
    }
    else if (menuItem==m_delsource) {
        return [dataSource validateDelSource];
    }
    else if (menuItem==m_browse) {
        if ([table numberOfSelectedRows]==1 && ![[table itemAtRow:[table selectedRow]] objectForKey:@"PExpandable"]) return YES;
        else return NO;
    }
	else if (menuItem==m_reveal)
	{
		int status = [[[table itemAtRow:[table selectedRow]] objectForKey:@"PStatus"] intValue];
		if ( (status == PCOMPLETED) && ([table numberOfSelectedRows]>0) )
			return YES;
		else
			return NO;
	}
    else return YES;
}

- (IBAction)findMoreSources:(id)sender;
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    NSString *hash;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        if (hash=[item objectForKey:@"hash"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PFindMoreSources" object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:hash,@"hash",nil]];
        }
    }
}

@end
