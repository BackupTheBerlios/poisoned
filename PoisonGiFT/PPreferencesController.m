//
// PPreferencesController.h
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

#import "PPreferencesController.h"

@implementation PPreferencesController

- (void)awakeFromNib
{
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"prefToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
    [prefWindow setToolbar:toolbar];
    [prefWindow setDelegate:self];
    
    [self initTabView];
    
    [self switchToGeneral:self];

    [prefWindow makeKeyAndOrderFront:self];
}

- (void)dealloc
{
    [toolbar release];
    [super dealloc];
}

- (void)initTabView
{
    NSTabViewItem *_general = [[NSTabViewItem alloc] initWithIdentifier:@"general"];
    NSTabViewItem *_daemon = [[NSTabViewItem alloc] initWithIdentifier:@"daemon"];
    NSTabViewItem *_download = [[NSTabViewItem alloc] initWithIdentifier:@"download"];
    NSTabViewItem *_upload = [[NSTabViewItem alloc] initWithIdentifier:@"upload"];
    NSTabViewItem *_protos = [[NSTabViewItem alloc] initWithIdentifier:@"protos"];
    [_general setView:generalView];
    [_daemon setView:daemonView];
    [_download setView:downloadView];
    [_upload setView:uploadView];
    [_protos setView:protoView];
    [tabView addTabViewItem:_general];
    [tabView addTabViewItem:_daemon];
    [tabView addTabViewItem:_download];
    [tabView addTabViewItem:_upload];
    [tabView addTabViewItem:_protos];
    
    [tabView setDrawsBackground:NO];
    
    [_general release];
    [_daemon release];
    [_download release];
    [_upload release];
    [_protos release];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        @"general",@"download",@"upload",@"protos",@"daemon",
        nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        @"general",@"download",@"upload",@"protos",@"daemon",
        nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    if ([itemIdentifier isEqualToString:@"general"]) {
        [item setLabel:@"General"];
        [item setPaletteLabel:@"General"];
        [item setImage:[NSImage imageNamed:@"general.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(switchToGeneral:)];
    }
    else if ([itemIdentifier isEqualToString:@"daemon"]) {
        [item setLabel:@"Daemon"];
        [item setPaletteLabel:@"Daemon"];
        [item setImage:[NSImage imageNamed:@"daemon.icns"]];
        [item setTarget:self];
        [item setAction:@selector(switchToDaemon:)];
    }
    else if ([itemIdentifier isEqualToString:@"download"]) {
        [item setLabel:@"Downloads"];
        [item setPaletteLabel:@"Downloads"];
        [item setImage:[NSImage imageNamed:@"pref_download.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(switchToDownloads:)];
    }
    else if ([itemIdentifier isEqualToString:@"upload"]) {
        [item setLabel:@"Uploads"];
        [item setPaletteLabel:@"Uploads"];
        [item setImage:[NSImage imageNamed:@"pref_upload.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(switchToUploads:)];
    }
    else if ([itemIdentifier isEqualToString:@"protos"]) {
        [item setLabel:@"Protocols"];
        [item setPaletteLabel:@"Protocols"];
        [item setImage:[NSImage imageNamed:@"protos.tiff"]];
        [item setTarget:self];
        [item setAction:@selector(switchToProtos:)];
    }
    return [item autorelease];
}

- (NSRect)calcFrame:(int)height
{
    NSRect frame = [prefWindow frame];
    NSRect content = [[prefWindow contentView] frame];
    int dif = frame.size.height-content.size.height;
    frame.origin.y = frame.origin.y+content.size.height-height;
    frame.size.height = height+dif;
    return frame;
}

- (void)switchToGeneral:(id)sender
{
    [prefWindow setTitle:@"General"];
    NSRect frame = [self calcFrame:91];
    [tabView selectFirstTabViewItem:self];
    [prefWindow setFrame:frame display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:@"general"];
}

- (void)switchToDaemon:(id)sender
{
    [prefWindow setTitle:@"Daemon"];
    NSRect frame = [self calcFrame:409];
    [tabView selectFirstTabViewItem:self];
    [prefWindow setFrame:frame display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:@"daemon"];
}

- (void)switchToDownloads:(id)sender
{
    [prefWindow setTitle:@"Downloads"];
    NSRect frame = [self calcFrame:311];
    [tabView selectFirstTabViewItem:self];
    [prefWindow setFrame:frame display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:@"download"];
}

- (void)switchToUploads:(id)sender
{
    [prefWindow setTitle:@"Uploads"];
    NSRect frame = [self calcFrame:373];
    [tabView selectFirstTabViewItem:self];
    [prefWindow setFrame:frame display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:@"upload"];
}

- (void)switchToProtos:(id)sender
{
    [prefWindow setTitle:@"Protocols"];
    NSRect frame = [self calcFrame:316];
    [tabView selectFirstTabViewItem:self];
    [prefWindow setFrame:frame display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:@"protos"];

}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    PGiFTConf *gift_conf = [PGiFTConf singleton];
    PUIConf *ui_conf = [PUIConf singleton];

    NSString *ident = [theItem itemIdentifier];
    if ([ident isEqualToString:@"general"] || [ident isEqualToString:@"daemon"]) return YES;
    else return (ui_conf!=nil) && (gift_conf!=nil);
}	

- (BOOL)windowShouldClose:(id)sender
{
    return YES;
}

@end
