//
// PgiFTController.h
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
#import "PControllerProto.h"
#import "PCommand.h"
#import "PgiFTCommands.h"
#import "PAppKit.h"
#import "PGiFTConf.h"
#import "PUIConf.h"
#import "POpenFTConf.h"
#import "PGnutellaConf.h"

@interface PgiFTController : NSObject <PControllerProto,PgiFTCommands>
{
    IBOutlet NSView *view;
        
    IBOutlet NSMenuItem *connectMenu;
    
    IBOutlet PSearchTableView *protocolTable;
    NSMutableArray *protocolSource;
    
    IBOutlet NSPanel *connectionSheet;
    IBOutlet NSTextField *remoteAddress;
    IBOutlet NSTextField *remotePort;
    IBOutlet NSMenuItem *remoteConnectMenu;
    
    IBOutlet NSImageView *statusImage;
        
    PCommand *commander;
    id controller;		// PMainController
    
    NSUserDefaults *userDefaults;
    
    NSTask *task;
    NSTimer *timer;		// timer for the STATS command
    NSString *attach;		// giFT & version
    
    PIconShop *icon_shop;	// protcol icons
        
    //BOOL shouldBeConnected;	// if this is YES and disconnected gets called -> giFT crashed
    //BOOL remoteDaemon;
    //BOOL _startDaemon;
	
    BOOL _protosSend;
    BOOL _synchronizing;
    
    // we need this when we get the PoisonConnectionClosed notification
    // YES -> the user closed the connection
    // NO  -> connection closed	=> error
    BOOL _userDisconnected;
    BOOL _startingDaemon;
    BOOL _remoteDaemon;
    BOOL _connectOnce;
}

- (void)periodicalUpdate;

- (void)gui_update:(BOOL)activeView;

- (void)connected;
- (void)connectionFailed;
// - (void)disconnected:(id)sender -> this is already defined in PControllerProto.h

- (IBAction)launch:(id)sender;			// startgift button
- (void)startDaemon;

- (IBAction)connect:(id)sender;			// connect button
- (BOOL)connectToLocalDaemon;

// remote connections
- (IBAction)runConnectionSheet:(id)sender;
- (IBAction)connectRemote:(id)sender;
- (IBAction)cancelSheet:(id)sender;

// conf files
- (void)checkConfFiles;
- (BOOL)check:(NSString *)path;

@end
