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

#import <Cocoa/Cocoa.h>
#import "PGiFTConf.h"
#import "PUIConf.h"
#import "POpenFTConf.h"

@interface PPreferencesController : NSWindowController
{
    IBOutlet NSPanel *prefWindow;
    IBOutlet NSView *daemonView;
    IBOutlet NSView *generalView;
    IBOutlet NSView *downloadView;
    IBOutlet NSView *uploadView;
    IBOutlet NSView *protoView;
    IBOutlet NSView *pluginView;
    
    IBOutlet NSTabView *tabView;
    
    NSToolbar *toolbar;
}

- (void)initTabView;

- (NSRect)calcFrame:(float)height;

- (void)switchToGeneral:(id)sender;
- (void)switchToDaemon:(id)sender;
- (void)switchToDownloads:(id)sender;
- (void)switchToUploads:(id)sender;
- (void)switchToProtos:(id)sender;
- (void)switchToPlugins:(id)sender;

@end
