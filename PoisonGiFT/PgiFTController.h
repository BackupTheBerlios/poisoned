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
#import "PUIConf.h"

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
    id controller;
    
    NSUserDefaults *userDefaults;
    
    NSTimer *timer;	// timer for the STATS command
    NSString *attach;
        
    PIconShop *icon_shop;
    
    BOOL protosSend;
    
    BOOL shouldBeConnected;	// if this is YES and disconnected gets called -> giFT crashed
    BOOL remoteDaemon;
    BOOL _startDaemon;
    BOOL _daemonLaunching;
    BOOL _userDisconnected;
	
    BOOL synchronizing;
}

- (void)periodicalUpdate;

- (void)gui_update:(BOOL)activeView;

- (BOOL)connectLocal:(BOOL)local;
- (void)connected;
- (void)connectionTimedOut;
- (void)startDaemon;

- (IBAction)connect:(id)sender;
- (IBAction)connectRemote:(id)sender;
- (IBAction)runConnectionSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (IBAction)launch:(id)sender;
- (void)disconnected:(id)sender;

- (void)checkConfFiles;
- (void)check:(NSString *)path;

@end
