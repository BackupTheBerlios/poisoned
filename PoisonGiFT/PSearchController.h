//
// PSearchController.h
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

#import <Cocoa/Cocoa.h>
#import "PControllerProto.h"
#import "PCommand.h"
#import "PResultSource.h"
#import "PAppKit.h"
#import "PSearchCommands.h"
#import "PSearchFilterController.h"

@interface PSearchController : NSObject <PControllerProto,PSearchCommands>
{
    IBOutlet NSView *view;
    IBOutlet PTextField *search_field;
    IBOutlet NSPopUpButton *search_realm;
        
    IBOutlet POutlineView *r_table;
    IBOutlet PSearchTableView *s_table;
    
    IBOutlet NSMenu *contextualMenu;
    IBOutlet NSMenu *tableMenu;

    
    //table colums
    IBOutlet NSTableColumn *tc_fileicon;
    NSTableColumn *tc_file;
    IBOutlet NSTableColumn *tc_networkicon;
    IBOutlet NSTableColumn *tc_user;
    IBOutlet NSTableColumn *tc_size;
    IBOutlet NSTableColumn *tc_bitrate;
    IBOutlet NSTableColumn *tc_artist;
    IBOutlet NSTableColumn *tc_album;
    IBOutlet NSTableColumn *tc_availability;
                
    PCommand *commander;
    id controller;

    NSMutableDictionary *datasources;
    NSMutableArray *searches;
    PResultSource *current_src;
    
    NSUserDefaults *userDefaults;
    
    NSImage *stop_img;
    NSImage *re_img;
    
    IBOutlet PSearchFilterController *filter;
    NSSet *downloading_hashes;
    
    NSMutableArray *recentSearches;

    NSMutableArray *_newItems;
    NSTimer *_refreshTimer;

    
}

- (void)saveSearches;
- (void)connected;

- (IBAction)showhideTableColumn:(id)sender;
- (NSMenu *)tableView:(NSOutlineView *)_table menuForTableColumn:(NSTableColumn *)_column row:(int)_row;

- (void)setDownloadingHashes:(NSSet *)_hashes;

- (void)loadResultTable;
- (IBAction)reloadSearchTable;

- (void)deleteEvent:(id)sender;

- (void)search:(NSString *)_query info:(NSString *)_info ticket:(NSString *)_ticket hidden:(BOOL)_hidden;
- (IBAction)search:(id)sender;
- (void)searchRecent:(id)sender;
- (IBAction)browse:(id)sender;
- (void)browsehost:(NSString *)user;
- (void)findMoreSources:(NSNotification *)notification;

- (IBAction)stop:(id)sender;
- (IBAction)download:(id)sender;

- (void)gui_update:(BOOL)activeView;

- (void)clearRecentSearches;
- (void)addRecentSearch:(NSString *)search withRealm:(NSString *)realm;

// FOR TESTING
- (void)buyAtiTMS:(id)sender;
- (BOOL)validateBuyAtiTMS;

@end
