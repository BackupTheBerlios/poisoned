//
// PDownloadController.h
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
#import "PDownloadCommands.h"
#import "PControllerProto.h"
#import "PDownloadSource.h"

@interface PDownloadController : NSObject <PControllerProto,PDownloadCommands> 
{
    IBOutlet NSView *view;
    
    IBOutlet PDiffOutlineView *table;
    //IBOutlet NSTextField *infoField;
    //IBOutlet NSTextField *globalField;
    
    PDownloadSource *dataSource;
    
    PCommand *commander;
    id controller;
    
    NSMutableSet *hashes;
    
    IBOutlet NSMenu *contextualMenu;
    IBOutlet NSMenuItem *m_findsources;
    IBOutlet NSMenuItem *m_cancel;
    IBOutlet NSMenuItem *m_pause;
    IBOutlet NSMenuItem *m_resume;
    IBOutlet NSMenuItem *m_delsource;
    IBOutlet NSMenuItem *m_browse;
    IBOutlet NSMenuItem *m_cleanup;
    IBOutlet NSMenuItem *m_reveal;
}

- (NSSet *)hashes;

- (IBAction)cancel:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)delsource:(id)sender;
- (NSString *)browsehost;
- (IBAction)downbrowsehost:(id)sender;
- (IBAction)cleanUp:(id)sender;
- (IBAction)expand:(id)sender;
- (IBAction)collapse:(id)sender;

- (void)ADDSOURCE:(NSArray *)data;
- (void)DELSOURCE:(NSArray *)data;

- (void)gui_update:(BOOL)activeView;

- (int)speed;

- (IBAction)findMoreSources:(id)sender;

- (NSMenu *)tableView:(NSOutlineView *)_table menuForTableColumn:(NSTableColumn *)_column row:(int)_row;

@end
