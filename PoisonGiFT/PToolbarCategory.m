//
//  PToolbarCategory.m
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

#import "PToolbarCategory.h"

@implementation PMainController (PToolbarCategory)

- (void)initToolbar
{
    if (!toolbarDefaultItems) {
        toolbarDefaultItems = [[NSArray alloc] initWithObjects:
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",NSToolbarSeparatorItemIdentifier,
                @"giFTConnect",NSToolbarFlexibleSpaceItemIdentifier,@"giFTLaunch",nil],
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",NSToolbarSeparatorItemIdentifier,
                @"searchBrowse",@"searchRealm",@"searchDownload",@"searchField",@"searchStop",nil],
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",NSToolbarSeparatorItemIdentifier,
                @"downCancel",@"downPause",@"downResume",NSToolbarSeparatorItemIdentifier,
                @"downDelSource",@"downBrowseHost",NSToolbarSeparatorItemIdentifier,
                @"downClean",
                NSToolbarFlexibleSpaceItemIdentifier,@"downExpand",@"downCollapse",nil],
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",NSToolbarSeparatorItemIdentifier,
                @"upCancel",
                @"upBrowseHost",NSToolbarSeparatorItemIdentifier,
                @"upClean",nil],
            nil];
    }
    if (![userDefaults objectForKey:@"MyToolbarItems"]) {
        // if not yet configured, set default items...
        [userDefaults setObject:toolbarDefaultItems forKey:@"MyToolbarItems"];
    }
    if (!toolbarAllowedItems) {
        toolbarAllowedItems = [[NSArray alloc] initWithObjects:
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",
                @"giFTConnect",@"giFTLaunch",nil],
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",
                @"searchField",@"searchRealm",@"searchBrowse",@"searchDownload",@"searchStop",nil],
            [NSArray arrayWithObjects:@"navigation",@"drawer",
                @"downExpand",@"downCollapse",
                @"downCancel",@"downPause",@"downResume",@"downDelSource",@"downBrowseHost",@"downClean",nil],
            [NSArray arrayWithObjects:
                @"navigation",@"drawer",
                @"upCancel",@"upBrowseHost",@"upClean",nil],
            [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,
                                NSToolbarSpaceItemIdentifier,
                                NSToolbarSeparatorItemIdentifier,
                                nil],
            nil];
    }
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDelegate:self];
    if (currentView>-1) [mainWindow setToolbar:toolbar];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    if (currentView>-1) return
        [[NSArray arrayWithArray:[toolbarAllowedItems objectAtIndex:currentView]]
                arrayByAddingObjectsFromArray:[toolbarAllowedItems objectAtIndex:4]
        ];
    else return nil;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    if (currentView>-1) return [toolbarDefaultItems objectAtIndex:currentView];
    else return nil;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [item setEnabled:NO];
    if ([itemIdentifier isEqualToString:@"navigation"]) {
        [item setLabel:@"Navigation"];
        [item setPaletteLabel:@"Navigation"];
        [item setView:navigation];
        [item setMinSize:NSMakeSize(109,24)];
        [item setMaxSize:NSMakeSize(109,32)];
        [item setEnabled:YES];
    }
    if ([itemIdentifier isEqualToString:@"drawer"]) {
        [item setLabel:@"Drawer"];
        [item setPaletteLabel:@"Drawer"];
        [item setView:drawerButton];
        [item setMinSize:NSMakeSize(32,24)];
        [item setMaxSize:NSMakeSize(32,24)];
        [item setEnabled:YES];
        [item setToolTip:@"Toggle drawer"];
    }
    else if ([itemIdentifier isEqualToString:@"giFTConnect"]) {
        [item setLabel:@"Connect"];
        [item setPaletteLabel:@"Connect"];
        [item setToolTip:@"Connect to the giFT daemon"];
        [item setImage:[NSImage imageNamed:@"connect.tiff"]];
        [item setTarget:giFT];
        [item setAction:@selector(connect:)];
    }
    else if ([itemIdentifier isEqualToString:@"giFTLaunch"]) {
        [item setLabel:@"Launch giFT"];
        [item setPaletteLabel:@"Launch giFT"];
        [item setToolTip:@"Launch the giFT daemon"];
        [item setImage:[NSImage imageNamed:@"startgift.tiff"]];
        [item setTarget:giFT];
        [item setAction:@selector(launch:)];
    }
    else if ([itemIdentifier isEqualToString:@"searchField"]) {
        [item setLabel:@"Search"];
        [item setPaletteLabel:@"Search"];
        [item setView:toolbarSearch];
        [item setMinSize:NSMakeSize(100,24)];
        [item setMaxSize:NSMakeSize(2000,32)];
        [item setEnabled:YES];
    }
    else if ([itemIdentifier isEqualToString:@"searchRealm"]) {
        [item setLabel:@"Realm"];
        [item setPaletteLabel:@"Realm"];
        [item setView:toolbarSearchRealm];
        [item setMinSize:NSMakeSize(97,24)];
        [item setMaxSize:NSMakeSize(97,32)];
        [item setEnabled:YES];
    }
    else if ([itemIdentifier isEqualToString:@"searchDownload"]) {
        [item setLabel:@"Download"];
        [item setPaletteLabel:@"Download"];
        [item setImage:[currentTool objectForKey:@"download"]];
        [item setTarget:search];
        [item setAction:@selector(download:)];
        [item setToolTip:@"Download selected item(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"searchBrowse"]) {
        [item setLabel:@"Browse"];
        [item setPaletteLabel:@"Browse"];
        [item setImage:[NSImage imageNamed:@"browse.tiff"]];
        [item setTarget:search];
        [item setAction:@selector(browse:)];
        [item setToolTip:@"View shared files of the selected user"];
    }
    else if ([itemIdentifier isEqualToString:@"searchStop"]) {
        [item setLabel:@"Stop Search"];
        [item setPaletteLabel:@"Stop Search"];
        [item setImage:[currentTool objectForKey:@"stop"]];
        [item setTarget:search];
        [item setAction:@selector(stop:)];
        [item setToolTip:@"Stop the currently viewed search"];
    }
    else if ([itemIdentifier isEqualToString:@"downCancel"]) {
        [item setLabel:@"Cancel"];
        [item setPaletteLabel:@"Cancel"];
        [item setImage:[currentTool objectForKey:@"cancel"]];
        [item setTarget:download];
        [item setAction:@selector(cancel:)];
        [item setToolTip:@"Cancel selected download(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"downResume"]) {
        [item setLabel:@"Resume"];
        [item setPaletteLabel:@"Resume"];
        [item setImage:[currentTool objectForKey:@"resume"]];
        [item setTarget:download];
        [item setAction:@selector(resume:)];
        [item setToolTip:@"Resume selected download(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"downPause"]) {
        [item setLabel:@"Pause"];
        [item setPaletteLabel:@"Pause"];
        [item setImage:[currentTool objectForKey:@"pause"]];
        [item setTarget:download];
        [item setAction:@selector(pause:)];
        [item setToolTip:@"Pause selected download(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"downDelSource"]) {
        [item setLabel:@"Cancel Source"];
        [item setPaletteLabel:@"Cancel Source"];
        [item setImage:[NSImage imageNamed:@"delsource.tiff"]];
        [item setTarget:download];
        [item setAction:@selector(delsource:)];
        [item setToolTip:@"Cancel selected source(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"downBrowseHost"]) {
        [item setLabel:@"Browse Host"];
        [item setPaletteLabel:@"Browse Host"];
        [item setImage:[NSImage imageNamed:@"browse.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(downbrowsehost:)];
        [item setToolTip:@"View shared files of the selected user"];
    }
    else if ([itemIdentifier isEqualToString:@"downClean"]) {
        [item setLabel:@"Clean Up"];
        [item setPaletteLabel:@"Clean Up"];
        [item setImage:[NSImage imageNamed:@"clean.tiff"]];
        [item setTarget:download];
        [item setAction:@selector(cleanUp:)];
        [item setToolTip:@"Remove completed and cancelled downloads"];
    }
    else if ([itemIdentifier isEqualToString:@"downExpand"]) {
        [item setLabel:@"Expand All"];
        [item setPaletteLabel:@"Expand All"];
        [item setImage:[NSImage imageNamed:@"expand.tiff"]];
        [item setTarget:download];
        [item setAction:@selector(expand:)];
        [item setToolTip:@"Expand all items"];
    }
    else if ([itemIdentifier isEqualToString:@"downCollapse"]) {
        [item setLabel:@"Collapse All"];
        [item setPaletteLabel:@"Collapse All"];
        [item setImage:[NSImage imageNamed:@"collapse.tiff"]];
        [item setTarget:download];
        [item setAction:@selector(collapse:)];
        [item setToolTip:@"Collapse all items"];
    }
    else if ([itemIdentifier isEqualToString:@"upCancel"]) {
        [item setLabel:@"Cancel"];
        [item setPaletteLabel:@"Cancel"];
        [item setImage:[currentTool objectForKey:@"cancel"]];
        [item setTarget:upload];
        [item setAction:@selector(cancel:)];
        [item setToolTip:@"Cancel selected upload(s)"];
    }
    else if ([itemIdentifier isEqualToString:@"upBrowseHost"]) {
        [item setLabel:@"Browse Host"];
        [item setPaletteLabel:@"Browse Host"];
        [item setImage:[NSImage imageNamed:@"browse.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(upbrowsehost:)];
        [item setToolTip:@"View shared files of the selected user"];
    }
    else if ([itemIdentifier isEqualToString:@"upClean"]) {
        [item setLabel:@"Clean Up"];
        [item setPaletteLabel:@"Clean Up"];
        [item setImage:[NSImage imageNamed:@"clean.tiff"]];
        [item setTarget:upload];
        [item setAction:@selector(cleanUp:)];
        [item setToolTip:@"Remove completed and cancelled uploads"];
    }
    return [item autorelease];
}

- (void)switchToolbarConfigurationTo:(int)conf
{
    [self saveToolbarConfiguration];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[toolbar configurationDictionary]];
    [dict setObject:[[userDefaults arrayForKey:@"MyToolbarItems"] objectAtIndex:conf] forKey:@"TB Item Identifiers"];
    [toolbar setConfigurationFromDictionary:dict];
    currentView = conf;
}

- (void)saveToolbarConfiguration
{
    if (currentView==-1) return;
    NSMutableArray *conf = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"MyToolbarItems"]];
    [conf replaceObjectAtIndex:currentView withObject:[[toolbar configurationDictionary] objectForKey:@"TB Item Identifiers"]];
    [userDefaults setObject:conf forKey:@"MyToolbarItems"];
}

- (void)validate;
{
    [toolbar validateVisibleItems];
}

@end
