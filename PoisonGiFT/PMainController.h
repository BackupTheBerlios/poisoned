//
// PMainController.h
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
#import "PgiFTController.h"
#import "PSearchController.h"
#import "PDownloadController.h"
#import "PUploadController.h"
#import "PCommand.h"
#import "PPoisonCommands.h"
#import "PPreferencesController.h"

@interface PMainController : NSObject <PPoisonCommands>
{    
    IBOutlet PgiFTController *giFT;
    IBOutlet PSearchController *search;
    IBOutlet PDownloadController *download;
    IBOutlet PUploadController *upload;

    IBOutlet NSView *mainView;
    IBOutlet PMainTabView *contentView;    
    IBOutlet NSDrawer *drawer;
    
    IBOutlet NSView *navigation;
    IBOutlet NSImageView *navigationImage;
    IBOutlet NSButton *drawerButton;

    IBOutlet NSView *toolbarSearch;
    IBOutlet NSView *toolbarSearchRealm;
    
    IBOutlet NSTextField *transferField;
    
    IBOutlet NSView *globalSplit;	// this is the drawer view
    
    // -----------------------------------------------------------
    // this one is needed for the correct background in the drawer
    // - brushed -> no background
    // - aqua    -> draw background
    IBOutlet NSButton *dummyBackground;
    // -----------------------------------------------------------
    
    NSMutableArray *toolbarAllowedItems;
    NSMutableArray *toolbarDefaultItems;
        
    NSToolbar *toolbar;
    NSWindow *mainWindow;
    NSUserDefaults *userDefaults;
    
    PPreferencesController *prefs;
            
    PCommand *commander;
        
    int currentView;
    
    NSMutableDictionary *navImages;
    NSArray *currentNav;
    int navimg;
    NSMutableDictionary *toolbarImages;
    NSDictionary *currentTool;
}

- (void)controlTintChanged:(id)sender;

- (void)activate:(id)sender;
- (void)disconnected:(id)sender;

- (void)checkedForUpdate:(NSNotification *)notification;
- (void)checkVersion:(NSNumber *)currentversionpanel;
- (IBAction)versionCheck:(id)sender;
- (IBAction)openPrefs:(id)sender;

- (IBAction)switchAppearance:(id)sender;
- (IBAction)drawerAction:(id)sender;
- (IBAction)switchToDownload:(id)sender;
- (IBAction)switchToGiFT:(id)sender;
- (IBAction)switchToSearch:(id)sender;
- (IBAction)newSearch:(id)sender;
- (IBAction)switchToUpload:(id)sender;

- (IBAction)downbrowsehost:(id)sender;
- (IBAction)upbrowsehost:(id)sender;

- (IBAction)giFTViewer:(id)sender;

- (void)initWindow:(unsigned int)style;
- (void)initTabView;

- (IBAction)poisonWeb:(id)sender;
- (IBAction)giftWeb:(id)sender;

@end
