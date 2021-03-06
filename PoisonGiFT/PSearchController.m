//
// PSearchController.m
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

#import "PSearchController.h"
#import "PMainController.h"
#import "PTableMenu.h"

@implementation PSearchController

- (void)awakeFromNib
{    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (recentSearches = [userDefaults objectForKey:@"PRecentSearches"])
        recentSearches = [recentSearches mutableCopy];
    else recentSearches = [[NSMutableArray alloc] init];
    
    stop_img = [[NSImage imageNamed:@"stop_search.tiff"] retain];
    re_img = [[NSImage imageNamed:@"re_search.tiff"] retain];
    
    // setting up the search text field -------------------------------
    [search_field setImage:[NSImage imageNamed:@"search_field.tiff"]];
    [search_field setTarget:self];
    [search_field setDelegate:self];
    [search_field setAction:@selector(search:)];
    // ----------------------------------------------------------------
    
    // sources --------------------------------------------------------
    searches = [[NSMutableArray alloc] init];
    datasources = [[NSMutableDictionary alloc] init];
    current_src = nil;
    // ----------------------------------------------------------------
        
    [filter setDataSource:nil];
    
    // setting up the tables ------------------------------------------
    [s_table setRowHeight:30];
    [r_table setAutosaveName:@"PSearchTableAutoSave"];
    [r_table setAutosaveTableColumns:YES];
    [r_table setMenuDelegate:self];
    [r_table setRowHeight:16];
    [r_table setDrawsGrid:YES];
    [r_table setTarget:self];
    [r_table setDelegate:self];
    [r_table setDoubleAction:@selector(download:)];
    [s_table setDataSource:self];
    [s_table setDelegate:self];
    [s_table setTarget:self];
    [s_table setAction:@selector(loadResultTable)];
    NSArray *cols = [r_table tableColumns];
    int i, count=[cols count];
    for (i=0;i<count;i++) [[[cols objectAtIndex:i] dataCell] setDrawsBackground:NO];
    [r_table setOutlineTableColumn:[r_table tableColumnWithIdentifier:@"file"]];
    [r_table setAutoresizesOutlineColumn:NO];
    
    [[r_table tableColumnWithIdentifier:@"icon"] setDataCell:[[[NSImageCell alloc] init] autorelease]];
    [[r_table tableColumnWithIdentifier:@"PProtoIcon"] setDataCell:[[[NSImageCell alloc] init] autorelease]];
    [[r_table tableColumnWithIdentifier:@"PAvailability"] setDataCell:[[[NSImageCell alloc] init] autorelease]];
    
    NSButtonCell *button = [[[NSButtonCell alloc] init] autorelease];
    [button setButtonType:NSMomentaryChangeButton];
    [button setBordered:NO];
    [button setTarget:self];
    [button setAction:@selector(stop:)];
    [[s_table tableColumnWithIdentifier:@"button"] setDataCell:button];

    
    PSearchCell *searchCell = [[[PSearchCell alloc] init] autorelease];
    [[s_table tableColumnWithIdentifier:@"info"] setDataCell:searchCell];

 
    
	 
	 // Install Column Config Table Menu
	 [r_table setTableMenu:tableMenu];
	 
    // ----------------------------------------------------------------
    
    [[NSNotificationCenter defaultCenter] addObserver:r_table selector:@selector(reloadData) name:@"PTransferSetChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSearchTable) name:@"PFilterDeAcitivated" object:filter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findMoreSources:) name:@"PFindMoreSources" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected) name:@"PoisonConnectedToCore" object:NULL];

    [tc_fileicon retain];
    [tc_file retain];
    [tc_networkicon retain];
    [tc_user retain];
    [tc_size retain];
    [tc_bitrate retain];
    [tc_artist retain];
    [tc_album retain];
    [tc_availability retain];

    //tc_networkicon = [r_table tableColumnWithIdentifier:@"PProtoIcon"];
    //tc_album = [r_table tableColumnWithIdentifier:@"album"];
    //tc_availability = [r_table tableColumnWithIdentifier:@"album"];
    //[r_table addTableColumn:tc_fileicon];
    //[r_table addTableColumn:tc_file];
    //[r_table addTableColumn:tc_networkicon];
    //[r_table addTableColumn:tc_user];
    //[r_table addTableColumn:tc_size];
    //[r_table addTableColumn:tc_artist];
    //[r_table addTableColumn:tc_album];
    //[r_table addTableColumn:tc_availability];


	// table refresh timer
	_newItems = [[NSMutableArray alloc] init];
	_refreshTimer = NULL;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:r_table];


    [tc_fileicon release];
    [tc_file release];
    [tc_networkicon release];
    [tc_user release];
    [tc_size release];
    [tc_bitrate release];
    [tc_artist release];
    [tc_album release];
    [tc_availability release];
    
    [stop_img release];
    [re_img release];
    
    [recentSearches release];
    
    [searches release];
    [datasources release];
    [super dealloc];
}

// contextual menu ----------------------------------------------------------
- (IBAction)showhideTableColumn:(id)sender
{
    NSString *title = [sender title];
    NSTableColumn *col = nil;
    if ([title isEqualToString:@"File Icon"])		col = tc_fileicon;
    else if ([title isEqualToString:@"File"])		col = tc_file;
    else if ([title isEqualToString:@"Network Icon"])	col = tc_networkicon;
    else if ([title isEqualToString:@"User"])		col = tc_user;
    else if ([title isEqualToString:@"Size"])		col = tc_size;
    else if ([title isEqualToString:@"Bitrate"])	col = tc_bitrate;
    else if ([title isEqualToString:@"Artist"]) 	col = tc_artist;
    else if ([title isEqualToString:@"Album"])		col = tc_album;
    else if ([title isEqualToString:@"Availability"])   col = tc_availability;
    if (!col) return;
    if ([sender state]==NSOnState) [r_table removeTableColumn:col];
    else [r_table addTableColumn:col];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
    NSString *title = [menuItem title];
    if ([title isEqualToString:@"File Icon"]) {
        if ([r_table tableColumnWithIdentifier:@"icon"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"File"]) {
        [menuItem setState:NSOnState];
        return NO;
    }
    else if ([title isEqualToString:@"Network Icon"]) {
        if ([r_table tableColumnWithIdentifier:@"PProtoIcon"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"User"]) {
        if ([r_table tableColumnWithIdentifier:@"user"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Size"]) {
        if ([r_table tableColumnWithIdentifier:@"calcsize"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Bitrate"]) {
        if ([r_table tableColumnWithIdentifier:@"bitrate"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Artist"]) {
        if ([r_table tableColumnWithIdentifier:@"artist"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Album"]) {
        if ([r_table tableColumnWithIdentifier:@"album"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Availability"]) {
        if ([r_table tableColumnWithIdentifier:@"PAvailability"]) [menuItem setState:NSOnState];
        else [menuItem setState:NSOffState];
    }
    else if ([title isEqualToString:@"Download Selection(s)"]){
        if ([r_table numberOfSelectedRows]<=0) return NO;
        else
            return YES;
    }
    else if ([title isEqualToString:@"Pause/Resume"]){
        if ([s_table numberOfSelectedRows]<=0) return NO;
        else
            return YES;
    }
    else if ([title isEqualToString:@"Delete Search"]){
        if ([s_table numberOfSelectedRows]<=0) return NO;
        else
            return YES;
    }
    else if ([title isEqualToString:@"Browse Host..."]){
        if ([r_table numberOfSelectedRows]==1 && ![[r_table itemAtRow:[r_table selectedRow]] objectForKey:@"PExpandable"]) return YES;
        else return NO;
    }
    return YES;
}

- (NSMenu *)tableView:(NSOutlineView *)_table menuForTableColumn:(NSTableColumn *)_column row:(int)_row
{
    [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:_table];
    if (![_table isRowSelected:_row]) [_table selectRow:_row byExtendingSelection:NO];
    return contextualMenu;
}
// ----------------------------------------------------------------------------

- (void)setCommander:(PCommand *)_commander andController:(id)_controller
{
    controller=_controller;
    commander = _commander;
    [commander registerController:self forCommands:[NSArray arrayWithObjects:
        @"ITEM",nil]];
    // notification from PGiFTController, tells us user disconnected or giftd crashed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PConnectionClosedNotification" object:nil];
}

- (void)setDownloadingHashes:(NSSet *)_hashes
{
    downloading_hashes = _hashes;
}

// respond to PoisonToCore Notification
- (void)connected
{
    // if searches is not empty => giftd crashed
    // this means searches are already saved (including results)
    if ([searches count]>0) return;
    
    NSArray *oldSearches = [userDefaults arrayForKey:@"PSavedSearches"];
    int i, count = [oldSearches count];
    
    NSString *ticket;
    NSMutableDictionary *search;
    PResultSource *new;
    for (i=0;i<count;i++) {
        search	= [[oldSearches objectAtIndex:i] mutableCopy];
        
        // we need a new ticket, the old one was freed when we disconnected
        ticket = [[[commander getTicket] copy] autorelease];
        
        // create the result source for this search
        new 	= [[PResultSource alloc] initWithHashes:downloading_hashes andTable:r_table hidden:NO];
        [new setActive:NO];
        
        [search setObject:ticket forKey:@"ticket"];
        [search setObject:@"0" forKey:@"count"];
        
        // replace the old ticket in the query with the new one
        NSMutableArray *tmp = [[[search objectForKey:@"query"] componentsSeparatedByString:@")"] mutableCopy];
        [tmp replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"SEARCH(%@",ticket]];
        [search setObject:[tmp componentsJoinedByString:@")"] forKey:@"query"];
        [tmp release];
        
        [datasources setObject:new forKey:ticket];
        [searches addObject:search];
        
        [new release];
        [search release];
    }
    [s_table reloadData];
}

- (void)disconnected:(id)sender
{
    NSDictionary *userInfo = [(NSNotification *)sender userInfo];
    id crash = [userInfo objectForKey:@"crash"];
    if (crash) { // giftd crashed -> set all search inactive
        int i,count=[searches count];
        for (i=count-1;i>=0;i--) {
            [[datasources objectForKey:[[searches objectAtIndex:i] objectForKey:@"ticket"]]
                setActive:NO];
        }
        [s_table reloadData];
        [filter disconnected];
    }
    else { // -> remove all searches
        [self saveSearches];
        if (current_src) [current_src cleanUpTableHeaders];
        current_src = nil;
        int i,count=[searches count];
        for (i=count-1;i>=0;i--) {
            [commander freeTicket:[[searches objectAtIndex:i] objectForKey:@"ticket"]];
        }
        [searches removeAllObjects];
        [datasources removeAllObjects];
        [s_table reloadData];
        [r_table setDataSource:self];
        [r_table setDelegate:self];
        [r_table reloadData];
        [filter setDataSource:nil];
        [filter disconnected];
    }
}

- (void)saveSearches
{
    [userDefaults setObject:searches forKey:@"PSavedSearches"];
    [userDefaults setObject:recentSearches forKey:@"PRecentSearches"];
}

// process ITEM from the daemon
// --------------------------------------------------------------------------------------------------
- (oneway void)ITEM:(in NSArray *)data
{
    if (!data) return;
    NSString *ticket = [data objectAtIndex:1];			// get the command id
    if (!ticket) return;	
    BOOL hidden = [[datasources objectForKey:ticket] hidden];			

    if ([[data objectAtIndex:2] count]==0) {
        [[datasources objectForKey:ticket] setActive:NO];
        
        // find more sources has finished, we can delete this search now
        if (hidden) {
            [commander freeTicket:ticket];
            [datasources removeObjectForKey:ticket];
        }
        [s_table reloadData];
        return;
    }

    NSDictionary *tmp = [data objectAtIndex:2];
    NSString *hash = [tmp objectForKey:@"hash"];

    if (hash && [downloading_hashes containsObject:hash]) {
        NSString *query = [NSString stringWithFormat:@"ADDSOURCE user(%@) hash(%@) size(%@) url(%@) save(%@)",
            [commander prepare:[tmp objectForKey:@"user"]],
            [commander prepare:hash],
            [tmp objectForKey:@"size"],
            [commander prepare:[tmp objectForKey:@"url"]],
            [commander prepare:[tmp objectForKey:@"file"]]
            ];
        [commander cmd:query];
    }

    if (hidden) return; // we're looking for more sources...
    PResultSource *source = [datasources objectForKey:ticket];
    if (source)
	{
		// delay the refresh for 1 second to give a chance for more results to come in
		// this way we add items in chunks and the table gets refreshed less - jjt
		[_newItems addObject:data];
		if (![_refreshTimer isValid])
		{
			// the timer is not valid, so we need to schedule it
			_refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTimer:) userInfo:NULL repeats:NO] retain];
		}
	}
}
// --------------------------------------------------------------------------------------------------

- (void)refreshTimer:(NSTimer *)timer
{
	NSEnumerator *iter = [_newItems objectEnumerator];
	NSArray *data = NULL;
	while (data = [iter nextObject])
	{
		PResultSource *source = [datasources objectForKey:[data objectAtIndex:1]];
		[source addItem:data];
	}
	[_newItems removeAllObjects];
	[self gui_update:([((PMainController *)controller) currentView] == 1)];
	// this is a single shot timer, so after this fire, it isn't scheduled anymore
	[_refreshTimer release];
	_refreshTimer = NULL;
}

- (void)deleteEvent:(id)sender
{
    NSArray *selected = [[s_table selectedRowEnumerator] allObjects];
    int i, count = [selected count];
    NSString *ticket;
    for (i=count-1;i>=0;i--) {
        int row = [[selected objectAtIndex:i] intValue];
        ticket = [[searches objectAtIndex:row] objectForKey:@"ticket"];
        [commander cmd:[NSString stringWithFormat:@"SEARCH(%@) action(cancel)",ticket]];
        [commander freeTicket:ticket];
        [datasources removeObjectForKey:ticket];
        [searches removeObjectAtIndex:row];
    }
    [s_table reloadData];
    [self loadResultTable];
}

- (void)gui_update:(BOOL)activeView
{
    [self reloadSearchTable];
    if (activeView) [r_table reloadData];
}

- (void)clearRecentSearches
{
    [recentSearches removeAllObjects];
}

- (void)addRecentSearch:(NSString *)search withRealm:(NSString *)realm
{
    unsigned int max = [userDefaults integerForKey:@"PMaxRecentSearchesListCount"];
    // 0 -> menu item title (just needed for the menu item)
    // 1 -> search term
    // 2 -> realm
    NSMutableArray *item = [NSMutableArray array];
    if (realm) [item addObject:[NSString stringWithFormat:@"  %@ (%@)",search,realm]];
    else [item addObject:[NSString stringWithFormat:@"  %@",search]];
    [item addObject:search];
    if (realm) [item addObject:realm];
    
    // if this search is already stored in the list, remove it
    // and insert it again at the top of the list
    if ([recentSearches containsObject:item]) [recentSearches removeObject:item];
    [recentSearches insertObject:item atIndex:0];
    
    // check if the list is already bigger than allowed
    if ([recentSearches count]>max) [recentSearches removeObjectAtIndex:max];
}

- (void)reloadSearchTable
{
    int i,count = [searches count];
    for (i=0;i<count;i++) {
        NSString *_ticket = [[searches objectAtIndex:i] objectForKey:@"ticket"];
        NSString *_count  = [[datasources objectForKey:_ticket] r_count];
        [[searches objectAtIndex:i] setObject:_count forKey:@"count"];
    }
   [s_table reloadData];
}

- (NSView *)view
{	
    return view;
}

- (void)findMoreSources:(NSNotification *)notification
{
    NSString *hash = [[notification userInfo] objectForKey:@"hash"];
    NSString *ticket = [[[commander getTicket] copy] autorelease];

    NSString *query = [NSString stringWithFormat:@"LOCATE(%@) query(%@)",ticket,hash];
    [self search:query info:@"" ticket:ticket hidden:YES];
}

- (void)search:(NSString *)_query info:(NSString *)_info ticket:(NSString *)_ticket hidden:(BOOL)_hidden
{
    [commander cmd:_query];
    
    PResultSource *_new = [[PResultSource alloc] initWithHashes:downloading_hashes andTable:r_table hidden:_hidden];
    [datasources setObject:_new forKey:_ticket];
    if (!_hidden) {
        // insert the new search at the top of the list
        [searches insertObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                _ticket,@"ticket",
                _query,@"query",
                _info,@"info",
                @"0",@"count",nil
            ]
            atIndex:0];
    
        [s_table reloadData];
        // select the new search at the top of the list
        [s_table selectRow:0 byExtendingSelection:NO];
        [self loadResultTable];
    }
    [_new release];
}

- (IBAction)search:(id)sender
{
    if (![commander connected]) return;
    
    
    NSString *ticket = [[[commander getTicket] copy] autorelease];
    NSString *query;
    if ([[search_realm title] isEqualToString:@"Everything"]) {
        query = [NSString stringWithFormat:@"SEARCH(%@) query(%@)",
            ticket,
            [commander prepare:[search_field stringValue]]
            ];
        // add to the list of recent searches
        [self addRecentSearch:[sender stringValue] withRealm:nil];
    }
    else { 
        query = [NSString stringWithFormat:@"SEARCH(%@) query(%@) realm(%@)",
            ticket,
            [commander prepare:[search_field stringValue]],
            [[search_realm title] lowercaseString]
            ];
        // add to the list of recent searches
        [self addRecentSearch:[sender stringValue] withRealm:[search_realm title]];
    }
    [self search:query info:[search_field stringValue] ticket:ticket hidden:NO];
    [search_field selectText:self];
}

- (void)searchRecent:(id)sender
{
    NSArray *rep_obj = [[sender representedObject] retain];
    NSString *ticket = [[[commander getTicket] copy] autorelease];
    NSString *term = [rep_obj objectAtIndex:1];
    NSString *query;
    if ([rep_obj count]==3) {
        query = [NSString stringWithFormat:@"SEARCH(%@) query(%@) realm(%@)",
                    ticket,
                    [commander prepare:term],
                    [rep_obj objectAtIndex:2]
                ];
    }
    else {
        query = [NSString stringWithFormat:@"SEARCH(%@) query(%@)",
                    ticket,
                    [commander prepare:term]
                ];
    }

    // start the search
    [self search:query info:term ticket:ticket hidden:NO];
    
    // set the search field
    [search_field setStringValue:term];
    [search_field selectText:self];

    // finally move this search to the top of the recent searches list
    [recentSearches removeObject:rep_obj];
    [recentSearches insertObject:rep_obj atIndex:0];
    [rep_obj release];
}

- (IBAction)browse:(id)sender
{
    NSString *ticket = [[[commander getTicket] copy] autorelease];

    NSString *user = [[r_table itemAtRow:[r_table selectedRow]] objectForKey:@"user"];
    NSString *query = [NSString stringWithFormat:@"BROWSE(%@) query(%@)",ticket,user];
    [self search:query info:[NSString stringWithFormat:@"browse %@",user] ticket:ticket hidden:NO];
}

- (void)browsehost:(NSString *)user
{
    NSString *ticket = [[[commander getTicket] copy] autorelease];
    NSString *query = [NSString stringWithFormat:@"BROWSE(%@) query(%@)",ticket,user];
    [self search:query info:[NSString stringWithFormat:@"browse %@",user] ticket:ticket hidden:NO];
}

- (IBAction)download:(id)sender
{
    if ([r_table numberOfSelectedRows]==0) return;
    if ([userDefaults boolForKey:@"PSwitchToDownloads"]) [controller performSelector:@selector(switchToDownload:)];
    NSArray *sources = [current_src selectedItems];
    NSString *hash;
    int i, count=[sources count];
    NSDictionary *tmp;
    NSString *query;
    for (i=0;i<count;i++) {
        tmp = [sources objectAtIndex:i];
        hash = [tmp objectForKey:@"hash"];
        if (hash) {
            hash = [commander prepare:hash];
            query = [NSString stringWithFormat:@"ADDSOURCE user(%@) hash(%@) size(%@) url(%@) save(%@)",
                [commander prepare:[tmp objectForKey:@"user"]],
                [commander prepare:hash],
                [tmp objectForKey:@"size"],
                [commander prepare:[tmp objectForKey:@"url"]],
                [commander prepare:[tmp objectForKey:@"file"]]
                ];
        }
        else {
            query = [NSString stringWithFormat:@"ADDSOURCE user(%@) size(%@) url(%@) save(%@)",
                [commander prepare:[tmp objectForKey:@"user"]],
                [tmp objectForKey:@"size"],
                [commander prepare:[tmp objectForKey:@"url"]],
                [commander prepare:[tmp objectForKey:@"file"]]
                ];
        }
        NSLog(@"%@",query);
        [commander cmd:query];
    }
}

- (IBAction)stop:(id)sender
{
    int row = [s_table selectedRow];
    if (row>-1) {
        NSString *ticket = [[searches objectAtIndex:row] objectForKey:@"ticket"];
        if ([[datasources objectForKey:ticket] active]) {		// STOP SEARCH
            [commander cmd:[NSString stringWithFormat:@"SEARCH(%@) action(cancel)",ticket]];
            [[datasources objectForKey:ticket] setActive:NO];
        }
        else {							// RE-SEARCH
            [commander cmd:[[searches objectAtIndex:row] objectForKey:@"query"]];
            [[datasources objectForKey:ticket] setActive:YES];
        }
        [self reloadSearchTable];
    }
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    NSString *ident = [theItem itemIdentifier];
    if ([ident isEqualToString:@"searchDownload"])
        return ([r_table numberOfSelectedRows]>0);
    else if ([ident isEqualToString:@"searchBrowse"]) {
        return (([r_table numberOfSelectedRows]==1) && (![[r_table itemAtRow:[r_table selectedRow]] objectForKey:@"expandable"]));
    }
    else if ([ident isEqualToString:@"searchStop"]) {
        if ([s_table numberOfSelectedRows]!=1) return NO;
        int row = [s_table selectedRow];
        if (row>-1 && [[datasources objectForKey:[[searches objectAtIndex:row] objectForKey:@"ticket"]] active]) return YES;
        else return NO;
    }
    else if ([ident isEqualToString:@"iTMS"]) return [self validateBuyAtiTMS];
    else return YES;
    
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [searches count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSDictionary *item = [searches objectAtIndex:rowIndex];
    return [NSArray arrayWithObjects:
                [item objectForKey:@"info"],
                [item objectForKey:@"count"],
                nil];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // first deselect table column header
    NSTableColumn *selected = [r_table highlightedTableColumn];
    if (selected) {
        [r_table setIndicatorImage:nil inTableColumn:selected];
        [r_table setHighlightedTableColumn:nil];
    }
    
    int row = [s_table selectedRow];
    if (row>-1 && [s_table numberOfSelectedRows]==1) {
        current_src = [datasources objectForKey:[[searches objectAtIndex:row] objectForKey:@"ticket"]];
        [r_table setDataSource:current_src];
        [r_table setDelegate:current_src];
        [filter setDataSource:current_src];
        [current_src setTableHeaders];
    }
    else {
        [r_table setDataSource:self];
        [r_table setDelegate:self];
        [filter setDataSource:nil];
        current_src = nil;
    }
    [r_table reloadData];
    [s_table reloadData];
}

- (void)loadResultTable
{
    if ([s_table numberOfSelectedRows]==1)
        [controller performSelector:@selector(switchToSearch:)];
    [self tableViewSelectionDidChange:nil];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell 
 forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
 {
    if ([[aTableColumn identifier] isEqualToString:@"button"]) {
        if ([[datasources objectForKey:[[searches objectAtIndex:rowIndex] objectForKey:@"ticket"]] active])
            [aCell setImage:stop_img];
        else
            [aCell setImage:re_img];
    }
 }
 
 // dummy datasource for result table...
 - (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item 
{
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    return NO;
}

// search field delegate
- (NSMenu *)willPopUpMenuForTextField:(PTextField *)textfield
{   
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    /* set this menu small - ashton */
    [menu setMenuRepresentation: [[[NSMenuView alloc]
    initWithFrame: NSZeroRect] autorelease]];
    [[menu menuRepresentation] setFont: [NSFont menuFontOfSize:
    [NSFont smallSystemFontSize]]];
    [menu sizeToFit];
    /* end set small menu */
    NSMenuItem *mitem;
    int i, count = [recentSearches count];

    if (count==0) {
        [menu addItemWithTitle:@"No recent searches" action:nil keyEquivalent:@""];
        return menu;
    }
    
    [menu addItemWithTitle:@"Recent Searches" action:nil keyEquivalent:@""];
    
    for (i=0;i<count;i++) {
        mitem = [[NSMenuItem alloc] 
            initWithTitle:[[recentSearches objectAtIndex:i] objectAtIndex:0] 
            action:@selector(searchRecent:) 
            keyEquivalent:@""];
        [mitem setRepresentedObject:[recentSearches objectAtIndex:i]];
        [mitem setTarget:self];
        [menu addItem:mitem];
        [mitem release];
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    mitem = [[NSMenuItem alloc] initWithTitle:@"Clear Entries" action:@selector(clearRecentSearches) keyEquivalent:@""];
    [mitem setTarget:self];
    [menu addItem:mitem];
    [mitem release];
    
    
    return menu;
}

- (void)buyAtiTMS:(id)sender
{
    if ([r_table numberOfSelectedRows]!=1) return;
    NSString* artistTerm=@""; 		// empty string instead of (null)
    NSString* titleTerm=@""; 
    NSURL* url;
    NSRange beginRange, endRange;	
    NSDictionary *item = [r_table itemAtRow:[r_table selectedRow]];	// information on selected item

        // check for no meta tags
        if (![item objectForKey:@"artist"] && ![item objectForKey:@"title"]) 
        {
        
            // most mp3 files downloaded will have a - before the name of the song at the end of a file name
            // some have "02 <name of song>.mp3" due to itunes, the following 3 lines will work that all out.
            // all followed by a .mp3 extension which is worked out at the endRange
            
            beginRange = [[item objectForKey:@"file"] rangeOfString:@"-" options:NSBackwardsSearch];
            if ( beginRange.length==0 && 
                    [[[item objectForKey:@"file"] substringWithRange: NSMakeRange(0, 2)] intValue] ) 
                    beginRange = [[item objectForKey:@"file"] rangeOfString:@" "];

            endRange = [[item objectForKey:@"file"] rangeOfString:@"." options:NSBackwardsSearch];
            
            // parse the string for name of song and replace spaces for web sending. Now this is not perfect and some oddly named
            // files will be parsed improperly but there is no control over how people name files so no parser is perfect. This 
            // will get 90% of all files which do not have meta-tags or 99.9% of all files in total.
            
            titleTerm = (NSString*)CFURLCreateStringByAddingPercentEscapes(0,(CFStringRef)[
                        [item objectForKey:@"file"] substringWithRange:
                        NSMakeRange(beginRange.location+1,   		// eat the char we searched for, spaces ignored by itunes
                        (endRange.location-(beginRange.location+1)))
                        ],0,0,kCFStringEncodingISOLatin1);
            url = [NSURL URLWithString:[NSString stringWithFormat:
                @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?songTerm=%@", 
                titleTerm]];
        } 
        else 
        {
        
            // parsing meta tags spaces and adding them to the url string
            
            if ([item objectForKey:@"artist"])
                artistTerm = (NSString*)CFURLCreateStringByAddingPercentEscapes(0,(CFStringRef)
                    [item objectForKey:@"artist"],0,0,kCFStringEncodingISOLatin1);
            if ([item objectForKey:@"title"])
                titleTerm = (NSString*)CFURLCreateStringByAddingPercentEscapes(0,(CFStringRef)
                    [item objectForKey:@"title"],0,0,kCFStringEncodingISOLatin1);
    
            url = [NSURL URLWithString:[NSString stringWithFormat:
                @"itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?songTerm=%@&artistTerm=%@",
                titleTerm, artistTerm]];
        }
        
        // send url to system
        [[NSWorkspace sharedWorkspace] openURL:url];

}

- (BOOL)validateBuyAtiTMS
{
    if ([r_table numberOfSelectedRows]!=1) return NO;
    
    NSSet *ext = [NSSet setWithObjects:@"mp3",@"wav",@"ogg",@"m4u",@"m4a",@"wma",@"aif",@"aiff",nil];
    NSString *file_ext = [[[[r_table itemAtRow:[r_table selectedRow]] objectForKey:@"file"] pathExtension] lowercaseString];
    if ([ext containsObject:file_ext]) return YES;
    else return NO;
}

@end
