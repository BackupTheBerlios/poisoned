//
// PgiFTController.m
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

#import "PgiFTController.h"

@implementation PgiFTController

- (void)awakeFromNib
{
    // first check if all needed files are in ~/Library/Application Support/Poisoned
    // if not copy them
    [self checkConfFiles];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    attach = nil;
    
    // for the protocol icons
    icon_shop = [[PIconShop alloc] init];
    
    // setup the table
    [protocolTable setDelegate:self];
    [protocolTable setDrawsGrid:YES];
    [protocolTable setRowHeight:34];
    [[protocolTable tableColumnWithIdentifier:@"protocol"] setDataCell:
        [[[PTableTitleDescriptionCell alloc] init] autorelease]
    ];
    [[protocolTable tableColumnWithIdentifier:@"icon"] setDataCell:
        [[[NSImageCell alloc] init] autorelease]
    ];

    // not connected at startup
    protocolSource = [[NSMutableArray alloc] init];
    [protocolSource addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"poisoned.tiff"],@"icon",
            [NSArray arrayWithObjects:
                [NSNumber numberWithBool:YES],@"Not connected.",@"",nil],@"protocol",
        nil]
    ];
    [protocolTable reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected) name:@"PoisonConnectedToCore" object:NULL];
    
    // getting ready for launching/connecting
    task = [[NSTask alloc] init];
    _synchronizing = NO;
    _startingDaemon = NO;
    _connectOnce=NO;
    
    // NOTE: i moved checking of PAutoConnect to setCommander:andController
    // because the commander is needed before it can attempt a connect - jjt
    // NOTE2: alsoe moved checking of PAutoLaunch, because i wasn't sure if it
    // could happen that we try to connect to the launched daemon when the
    // commander isn't set yet
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [icon_shop release];
    if (attach) [attach release];
    [protocolSource release];
    [task release];
    [super dealloc];
}

- (void)setCommander:(PCommand *)_commander andController:(id)_controller
{
    controller=_controller;
    commander = _commander;
    [commander registerController:self forCommands:
        [NSArray arrayWithObjects:
            @"ATTACH",
            @"STATS",
            @"SHARE",nil]
    ];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PoisonConnectionClosed" object:commander];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed) name:@"PoisonConnectionTimedOut" object:commander];

    if ([userDefaults boolForKey:@"PAutoLaunch"])
        [self launch:self];
    // now that we have the commander, we can attempt an auto connect
    else if ([userDefaults boolForKey:@"PAutoConnect"])
        [self connect:nil];
}

// return the content view, needed by PMainController
- (NSView *)view
{
    return view;
}

// this method gets invoked every 3 secs when we're connected to the daemon
- (void)periodicalUpdate
{
    [commander cmd:@"STATS"];
}

// this is called by a notification when a connection with the daemon is made
- (void)connected
{
    _connectOnce = NO;
    _startingDaemon = NO;
    
    // set all gui stuff
    [controller validate]; // validate toolbar items
    [statusImage setImage:[NSImage imageNamed:@"online.tiff"]];
    [statusImage setNeedsDisplay:YES];
    [connectMenu setAction:nil];
    [remoteConnectMenu setAction:nil];
    
    // attach the client
    _protosSend = NO; // see STATS:
    [commander cmd:[NSString stringWithFormat:@"ATTACH client(Poisoned) version(%@)",[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [commander cmd:@"STATS"];
    
    // setup periodical update (STATS)
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(periodicalUpdate)];
    NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
    [invoc setTarget:self];
    [invoc setSelector:@selector(periodicalUpdate)];
    [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invoc repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 invocation:invoc repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 invocation:invoc repeats:YES];
}

// this is called by a notification when the aonnection timed out
// this method also gets invoked in self, if something goes wrong while connecting
- (void)connectionFailed
{
    _connectOnce=NO;
    _startingDaemon = NO;
    
    // if we just launched giFT, it's possible that it isn't ready for a connection yet
    // => no error panel, instead we just try connecting again
    if ([task isRunning]) {
        [self connect:nil];
    }
    else {
        NSBeginCriticalAlertSheet(
            @"Connection failed.",
            @"OK", nil, nil,
            [[NSApplication sharedApplication] mainWindow],
            nil, nil, nil, nil,
            [NSString stringWithFormat:@"Make sure a giFT daemon is running."]);
            
        // just to make sure the right thing is displayed
        // need to implement disabling of toolbar buttons while (dis)connecting/launching/stopping - sr
        [protocolSource removeAllObjects];
        [protocolSource addObject:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSImage imageNamed:@"poisoned.tiff"],@"icon",
                [NSArray arrayWithObjects:
                    [NSNumber numberWithBool:YES],@"Not connected.",@"",nil],@"protocol",
            nil]
        ];
        [protocolTable reloadData];
    }
}

// this is called by a notification when the connection closed
- (void)disconnected:(id)sender
{
    // some setup for the next connection
    _synchronizing=NO;

    // don't send STATS anymore
    [timer invalidate];
    timer = nil;

    // first check if giFT crashed]
    if (!_connectOnce) {
        if ([userDefaults boolForKey:@"PRelaunchOnCrash"] && !_userDisconnected && !_remoteDaemon && ![task isRunning]) {
            [self launch:nil];	// giFT crashed....
            return;
        }
        else if ([task isRunning] && _startingDaemon) {
            [self connectToLocalDaemon];
            return;
   	}
    }
    
    if (!_userDisconnected) {
        [self connectionFailed];
    }
    _startingDaemon = NO;
    _connectOnce=NO;

    // update the gui
    [protocolSource removeAllObjects];
    [protocolSource addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"poisoned.tiff"],@"icon",
            [NSArray arrayWithObjects:
                [NSNumber numberWithBool:YES],@"Not connected.",@"",nil],@"protocol",
        nil]
    ];
    [protocolTable reloadData];
    [connectMenu setAction:@selector(connect:)];
    [remoteConnectMenu setAction:@selector(runConnectionSheet:)];
    [statusImage setImage:[NSImage imageNamed:@"offline.tiff"]];
    [statusImage setNeedsDisplay:YES];
}

- (IBAction)launch:(id)sender
{
    if ([commander connected]) {
        _userDisconnected=YES;
        _startingDaemon=NO;
        [commander cmd:@"QUIT"];
        //if ([task isRunning]) [task terminate];
        [protocolSource removeAllObjects];
        [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"stopgift.tiff"],@"icon",
            [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                @"Stopping giFT",
                @"This may take a while...",nil],@"protocol",nil]
        ];
        [protocolTable reloadData];
    }
    else {
        _userDisconnected=NO;
        //_startingDaemon=NO;
        //if (![self connectToLocalDaemon]) {
        [self startDaemon];
       // }
        [self connectToLocalDaemon];
    }
}

- (void)startDaemon
{
    [protocolSource removeAllObjects];
    [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSImage imageNamed:@"startgift.tiff"],@"icon",
        [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
            @"Starting giFT", 
            @"",nil],@"protocol",nil]
    ];
    [protocolTable reloadData];

    // if giFT is already running, just try to connect
    _startingDaemon = NO;
    if ([task isRunning]) {
        [self connectToLocalDaemon];
        return;
    }
    _startingDaemon = YES;

    NSString *launchPath;
    
    [task autorelease];
    task=nil;
    task = [[NSTask alloc] init];
    
    if ([userDefaults boolForKey:@"PUseCustomDaemon"])
		launchPath = [userDefaults stringForKey:@"PGiFTPath"];
	else
		launchPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"giFT"];
	
	[task setCurrentDirectoryPath:[launchPath stringByDeletingLastPathComponent]];
	[task setLaunchPath:launchPath];
	NS_DURING
		[task launch];
		_remoteDaemon = NO;
	NS_HANDLER
		NSBeginCriticalAlertSheet(
			@"Could not start the daemon.",
			@"OK", nil, nil,
			[[NSApplication sharedApplication] mainWindow],
			nil, nil, nil, nil,
			[NSString stringWithFormat:@"Make sure \"%@\" exists.",[userDefaults stringForKey:@"PGiFTPath"]]);
	NS_ENDHANDLER
}

- (IBAction)connect:(id)sender
{
    if ([commander connected]) {
        [protocolSource removeAllObjects];
        [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"disconnect.tiff"],@"icon",
            [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                @"Disconnecting from the daemon...",
                @"",nil],@"protocol",nil]
        ];
        [protocolTable reloadData];
        
        _userDisconnected=YES;
        [commander closeConnection];
        return;
    }
    
    [protocolSource removeAllObjects];
    [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSImage imageNamed:@"connect.tiff"],@"icon",
        [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
            @"Connecting to the daemon...",
            @"",nil],@"protocol",nil]
        ];
    [protocolTable reloadData];

    _userDisconnected=NO;
    _connectOnce=YES;
    if (![self connectToLocalDaemon]) {
        // there is no notification from PCommand
        // invoking connectionFailed makes sure there will be an error panel
        [self connectionFailed];
    }
}

- (BOOL)connectToLocalDaemon
{
    _remoteDaemon=NO;
    
    NSString *address;
    int port;
    PUIConf *ui_conf = [PUIConf singleton];
    if (!ui_conf)		{
        NSBeginCriticalAlertSheet(
            @"Connection failed.",
            @"OK", nil, nil,
            [[NSApplication sharedApplication] mainWindow],
            nil, nil, nil, nil,
            [NSString stringWithFormat:@"Poisoned was unable to find the giFT configuration files."]);
        // returning yes here, otherwise there would be two error panels
        return YES;
    }
    [ui_conf read];
    port = [[ui_conf optionForKey:@"port"] intValue];
    address = [ui_conf optionForKey:@"host"];

    return [commander connect:address withPort:port];
}

- (IBAction)connectRemote:(id)sender
{
    [protocolSource removeAllObjects];
    [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSImage imageNamed:@"connect.tiff"],@"icon",
        [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
            @"Connecting to the daemon...",
            @"",nil],@"protocol",nil]
    ];
    [protocolTable reloadData];

    _remoteDaemon=YES;
    _userDisconnected=NO;
    [self cancelSheet:nil];
    
    NSString *address = [remoteAddress stringValue];
    int port = [remotePort intValue];

    _connectOnce=YES;
    if (![commander connect:address withPort:port])
        [self connectionFailed];
    else {
        [userDefaults setObject:address forKey:@"PRemoteAddress"];
        if (port>0) [userDefaults setInteger:port forKey:@"PRemotePort"];
        else [userDefaults removeObjectForKey:@"PRemotePort"];
    }

}

- (IBAction)runConnectionSheet:(id)sender
{
    [connectMenu setAction:nil];
    [remoteConnectMenu setAction:nil];

    NSString *address;
    NSApplication *app = [NSApplication sharedApplication];
    if (address=[userDefaults stringForKey:@"PRemoteAddress"]) {
        [remoteAddress setStringValue:address];
        [remotePort setIntValue:[userDefaults integerForKey:@"PRemotePort"]];
    }
    [app beginSheet:connectionSheet modalForWindow:[app mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)cancelSheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:[[[NSApplication sharedApplication] mainWindow] attachedSheet]];
    [connectionSheet orderOut:self];

    [connectMenu setAction:@selector(connect:)];
    [remoteConnectMenu setAction:@selector(runConnectionSheet:)];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [protocolSource count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [[protocolSource objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    return NO;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    NSString *ident = [theItem itemIdentifier];
    BOOL connected = [commander connected];
    if ([ident isEqualToString:@"giFTConnect"]) {
        if (connected) {
            [theItem setLabel:@"Disconnect"];
            [theItem setPaletteLabel:@"Disconnect"];
            [theItem setToolTip:@"Disconnect from the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"disconnect.tiff"]];
            return YES;
        }
        else {
            [theItem setLabel:@"Connect"];
            [theItem setPaletteLabel:@"Connect"];
            [theItem setToolTip:@"Connect to the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"connect.tiff"]];
            return YES;
        }
    }
    else if ([ident isEqualToString:@"giFTLaunch"]) {
        if (connected) {
            [theItem setLabel:@"Stop giFT"];
            [theItem setPaletteLabel:@"Stop giFT"];
            [theItem setToolTip:@"Stop the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"stopgift.tiff"]];
            return YES;
        }
        else {
            [theItem setLabel:@"Start giFT"];
            [theItem setPaletteLabel:@"Start giFT"];
            [theItem setToolTip:@"Start the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"startgift.tiff"]];
            return YES;
        }
    }
    return YES;
}

- (void)checkConfFiles
{
    [self check:@""];	// -> ~/Library/Application Support/Poisoned
    [self check:@"/gift.conf"];
    [self check:@"/OpenFT"];
    [self check:@"/OpenFT/OpenFT.conf"];
    [self check:@"/Gnutella"];
    [self check:@"/Gnutella/Gnutella.conf"];
    [self check:@"/FastTrack"];
    [self check:@"/FastTrack/FastTrack.conf"];
    [self check:@"/ui"];
    [self check:@"/ui/ui.conf"];
}

- (void)check:(NSString *)path
{
    NSFileManager *manager = 	[NSFileManager defaultManager];
    
    NSString *gift =		[[[NSHomeDirectory() 
                                    stringByAppendingPathComponent:@"Library"]
                                    stringByAppendingPathComponent:@"Application Support"]
                                    stringByAppendingPathComponent:@"Poisoned"];
    NSString *shared = 		[[NSBundle mainBundle] sharedSupportPath];

    if (![manager fileExistsAtPath:[gift stringByAppendingString:path]]) {
        NSLog(@"%@ not found: copying...",[gift stringByAppendingString:path]);
        [manager 
            copyPath:[shared stringByAppendingString:path] 
            toPath:[gift stringByAppendingString:path] 
            handler:nil];
    }
}

- (void)gui_update:(BOOL)activeView
{

}

- (oneway void)ATTACH:(in NSArray *)data
{
    if (!data) return;
    NSDictionary *server = [data objectAtIndex:2];
    if (attach) [attach autorelease];
    NSString *_server = [server objectForKey:@"server"];
    NSString *_version = [server objectForKey:@"version"];
    if (_server && _version)
        attach = [[[_server stringByAppendingString:@" "]
                    stringByAppendingString:_version] copy];
    else attach = [[NSString alloc] initWithString:@""];
}

- (oneway void)STATS:(in NSArray *)data
{
    if (!data) return;
    NSMutableArray *tmpprotos = [NSMutableArray array];
    [protocolSource removeAllObjects];
    NSArray *protos = [data objectAtIndex:3];
    NSArray *tmp;
    double totalSize=0.0;
    long totalUsers=0;
    long totalFiles=0;
    int i, count=[protos count];
    NSString *shares = @"";
    for (i=0;i<count;i++) {
        tmp = [protos objectAtIndex:i];
        if ([[tmp objectAtIndex:2] objectForKey:@"users"]) {
            [tmpprotos addObject:[tmp objectAtIndex:0]]; // for the notification...
            totalSize += [[[tmp objectAtIndex:2] objectForKey:@"size"] doubleValue];
            totalUsers += (long)[[[tmp objectAtIndex:2] objectForKey:@"users"] intValue];
            totalFiles += (long)[[[tmp objectAtIndex:2] objectForKey:@"files"] intValue];
            [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [icon_shop largeIconForProto:[tmp objectAtIndex:0]],@"icon",
                [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                    [tmp objectAtIndex:0], // protocol name
                    [NSString stringWithFormat:@"%@ Users - %@ Files - %@ GB",
                        [[tmp objectAtIndex:2] objectForKey:@"users"],
                        [[tmp objectAtIndex:2] objectForKey:@"files"],
                        [[tmp objectAtIndex:2] objectForKey:@"size"]],
                nil],@"protocol",nil]
            ];
        }
        else {
            int files = [[[tmp objectAtIndex:2] objectForKey:@"files"] intValue];
            NSString *f;
            if (files==1) f=@"File";
            else f=@"Files";
            if (_synchronizing) shares = @"synchronizing... (this may take a while)";
            else shares = [[NSString stringWithFormat:@"%d %@ - ",files,f] stringByAppendingString:
                            [NSString stringWithFormat:@"%@ GB",[[tmp objectAtIndex:2] objectForKey:@"size"]]];
            [protocolSource insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSImage imageNamed:@"public.icns"],@"icon",
                    [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                        @"Sharing", // protocol name
                        shares,
                    nil],@"protocol",nil]
    
            atIndex:0];
        }
    }
    NSString *total = [NSString stringWithFormat:@"%d Users - %d Files - %.2f GB",totalUsers,totalFiles,totalSize];
    [protocolSource insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                    attach,	// giFT & version
                    total,	// total stats for all networks
                nil],@"protocol",nil]
    
    atIndex:1];
    [protocolSource insertObject:[NSDictionary dictionary] atIndex:1];
    [protocolTable reloadData];
    
    if (!_protosSend) {
        // send notification with availabe protocols, but only if we didn't do so yet
        // PSearchFilterController needs this for the protol filter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PStatsProtocolsAvailable" object:self
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:tmpprotos,@"protos",nil]];
        _protosSend=YES;
    }
}

- (oneway void)SHARE:(in NSArray *)data
{
    if (!data) return;
    NSDictionary *item = [data objectAtIndex:2];
    if (!item) return;
    NSString *action = [item objectForKey:@"action"];
    NSString *status = [item objectForKey:@"status"];
    if (action && status && [action isEqualToString:@"sync"]) {
        if ([status isEqualToString:@"Done"]) {
            _synchronizing=NO;
            // giFT finished synchronizing the shared files
            // so we need new STATS
            [commander cmd:@"STATS"];
        }
        else _synchronizing=YES;
    }
}

/*@implementation PgiFTController

- (void)awakeFromNib
{
	_startDaemon = NO;
    shouldBeConnected = NO;
    remoteDaemon = NO;
    [self checkConfFiles];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    icon_shop = [[PIconShop alloc] init];
    
    protocolSource = [[NSMutableArray alloc] init];
    [protocolSource addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"poisoned.tiff"],@"icon",
            [NSArray arrayWithObjects:
                [NSNumber numberWithBool:YES],@"Not connected.",@"",nil],@"protocol",
        nil]
    ];
    [protocolTable setRowHeight:34];
    [[protocolTable tableColumnWithIdentifier:@"protocol"] setDataCell:
        [[[PTableTitleDescriptionCell alloc] init] autorelease]
    ];
    [[protocolTable tableColumnWithIdentifier:@"icon"] setDataCell:
        [[[NSImageCell alloc] init] autorelease]
    ];
    [protocolTable setDrawsGrid:YES];
    [protocolTable setDelegate:self];
    
    protosSend=NO;
    synchronizing=NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected) name:@"PoisonConnectedToCore" object:NULL];
	
	if ([userDefaults boolForKey:@"PAutoLaunch"])
		[self startDaemon];
	// NOTE: i moved checking of PAutoConnect to setCommander:andController
	// because the commander is needed before it can attempt a connect - jjt
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [icon_shop release];
    if (attach) [attach release];
    [protocolSource release];
    [super dealloc];
}

- (void)setCommander:(PCommand *)_commander andController:(id)_controller
{
    controller=_controller;
    commander = _commander;
    [commander registerController:self forCommands:
        [NSArray arrayWithObjects:
            @"ATTACH",
            @"STATS",
            @"SHARE",nil]
    ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PoisonConnectionClosed" object:commander];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionTimedOut) name:@"PoisonConnectionTimedOut" object:commander];
	
	// now that we have the commander, we can attempt an auto connect
	if ([userDefaults boolForKey:@"PAutoConnect"])
		[self connectLocal:YES];
}

- (void)connectionTimedOut
{
    NSBeginCriticalAlertSheet(
        @"Connection failed.",
        @"OK", nil, nil,
        [[NSApplication sharedApplication] mainWindow],
        nil, nil, nil, nil,
        [NSString stringWithFormat:@"Make sure a giFT daemon is running."]);
}

- (void)disconnected:(id)sender
{
    synchronizing=NO;
    protosSend=NO;
    [timer invalidate];
    timer = nil;
    [protocolSource removeAllObjects];
    [protocolSource addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"poisoned.tiff"],@"icon",
            [NSArray arrayWithObjects:
                [NSNumber numberWithBool:YES],@"Not connected.",@"",nil],@"protocol",
        nil]
    ];
    [protocolTable reloadData];
    [connectMenu setAction:@selector(connect:)];
    [remoteConnectMenu setAction:@selector(runConnectionSheet:)];
    [statusImage setImage:[NSImage imageNamed:@"offline.tiff"]];
    [statusImage setNeedsDisplay:YES];
    if ([userDefaults boolForKey:@"PRelaunchOnCrash"] && shouldBeConnected && !remoteDaemon) 
        [self startDaemon];	// giFT crashed....
	else if (_startDaemon)
		[self startDaemon];
}

- (NSView *)view
{
    return view;
}

- (IBAction)runConnectionSheet:(id)sender
{
    [connectMenu setAction:nil];
    [remoteConnectMenu setAction:nil];

    NSString *address;
    NSApplication *app = [NSApplication sharedApplication];
    if (address=[userDefaults stringForKey:@"PRemoteAddress"]) {
        [remoteAddress setStringValue:address];
        [remotePort setIntValue:[userDefaults integerForKey:@"PRemotePort"]];
    }
    [app beginSheet:connectionSheet modalForWindow:[app mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)cancelSheet:(id)sender
{
    [[NSApplication sharedApplication] endSheet:[[[NSApplication sharedApplication] mainWindow] attachedSheet]];
    [connectionSheet orderOut:self];

    [connectMenu setAction:@selector(connect:)];
    [remoteConnectMenu setAction:@selector(runConnectionSheet:)];
}

- (IBAction)connectRemote:(id)sender
{
    remoteDaemon = YES;
    [self cancelSheet:self];
    [self connect:nil];
}

- (BOOL)connectLocal:(BOOL)local
{
    NSString *address=nil;
    int port=nil;
    BOOL remote;
    if (local)
	{
        PUIConf *ui_conf = [PUIConf singleton];
        if (!ui_conf)
		{
            NSBeginCriticalAlertSheet(
                @"Connection failed.",
                @"OK", nil, nil,
                [[NSApplication sharedApplication] mainWindow],
                nil, nil, nil, nil,
                [NSString stringWithFormat:@"Poisoned was unable to find the giFT configuration files."]);
                return YES;
        }
        [ui_conf read];
        port = [[ui_conf optionForKey:@"port"] intValue];
        address = [ui_conf optionForKey:@"host"];
        remote = NO;
    }
    else
	{
        address = [remoteAddress stringValue];
        port = [remotePort intValue];
        remote = YES;
    }
    if (![commander connect:address withPort:port])
	{
		// so the user will get an error message
		[self connectionTimedOut];
        return NO;
    }
    else
	{
		// we've started the connection process, so we SHOULD be connected
		shouldBeConnected=YES;
        if (remote)
		{
            [userDefaults setObject:address forKey:@"PRemoteAddress"];
            if (port>0) [userDefaults setInteger:port forKey:@"PRemotePort"];
            else [userDefaults removeObjectForKey:@"PRemotePort"];
        }
    }
    return YES;
}

// this is called by a notification when a connection with the daemon is made
- (void)connected
{
	// set _startDaemon to NO because the daemon is obviously already running
	_startDaemon = NO;
	shouldBeConnected=YES;
    [controller validate];
    [connectMenu setAction:nil];
    [remoteConnectMenu setAction:nil];
    [commander cmd:[NSString stringWithFormat:@"ATTACH client(Poisoned) version(%@)",[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [commander cmd:@"STATS"];
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(periodicalUpdate)];
    NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:sig];
    [invoc setTarget:self];
    [invoc setSelector:@selector(periodicalUpdate)];
    [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invoc repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 invocation:invoc repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 invocation:invoc repeats:YES];
    [statusImage setImage:[NSImage imageNamed:@"online.tiff"]];
    [statusImage setNeedsDisplay:YES];
}

- (IBAction)connect:(id)sender
{
    if ([commander connected])
	{
		// user wants to disconnect from the daemon
        shouldBeConnected=NO;
        [commander closeConnection];
        shouldBeConnected=NO;
        return;
    }
    
    BOOL _connected;
    if (sender)
		_connected = [self connectLocal:YES];
    else
		_connected = [self connectLocal:NO];    
}

- (void)periodicalUpdate
{
    [commander cmd:@"STATS"];
}

- (IBAction)launch:(id)sender
{
    if ([commander connected])
	{
        shouldBeConnected=NO;
        [commander cmd:@"QUIT"];
        [protocolSource removeAllObjects];
        [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSImage imageNamed:@"stopgift.tiff"],@"icon",
            [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                @"Stopping giFT", // protocol name
                @"This may take a while...",nil],@"protocol",nil]
        ];
        [protocolTable reloadData];
    }
    else
	{
		// first try to connect to the daemon
		// if we can't connect to the daemon then
		// it needs to be launched and we need to try to connect again
		_startDaemon = YES;
		[self connectLocal:YES];
    }
}

- (void)startDaemon
{
	// set _startDaemon to NO because we're trying to start it right now
	_startDaemon = NO;
	
	BOOL customDaemon = [userDefaults boolForKey:@"PUseCustomDaemon"];
	if (customDaemon && ![[NSFileManager defaultManager] contentsAtPath:[userDefaults stringForKey:@"PGiFTPath"]])
	{
		NSBeginCriticalAlertSheet(
			@"Could not start the daemon.",
			@"OK", nil, nil,
			[[NSApplication sharedApplication] mainWindow],
			nil, nil, nil, nil,
			[NSString stringWithFormat:@"Make sure \"%@\" exists.",[userDefaults stringForKey:@"PGiFTPath"]]);
		return;
	}
	
	NSTask *task = [[NSTask alloc] init];
	NSString *launchPath;
	
	if (customDaemon)
		launchPath = [userDefaults stringForKey:@"PGiFTPath"];
	else
		launchPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"giFT"];
	
	[task setCurrentDirectoryPath:[launchPath stringByDeletingLastPathComponent]];
	[task setLaunchPath:launchPath];
	NS_DURING
		[task launch];
		remoteDaemon = NO;
	NS_HANDLER
		NSBeginCriticalAlertSheet(
			@"Could not start the daemon.",
			@"OK", nil, nil,
			[[NSApplication sharedApplication] mainWindow],
			nil, nil, nil, nil,
			[NSString stringWithFormat:@"Make sure \"%@\" exists.",[userDefaults stringForKey:@"PGiFTPath"]]);
	NS_ENDHANDLER
	
	if (shouldBeConnected)
		[self connectLocal:YES];
}

- (void)gui_update:(BOOL)activeView
{

}

- (oneway void)ATTACH:(in NSArray *)data
{
    if (!data) return;
    NSDictionary *server = [data objectAtIndex:2];
    if (attach) [attach autorelease];
    NSString *_server = [server objectForKey:@"server"];
    NSString *_version = [server objectForKey:@"version"];
    if (_server && _version)
        attach = [[[_server stringByAppendingString:@" "]
                    stringByAppendingString:_version] copy];
    else attach = [[NSString alloc] initWithString:@""];
}

- (oneway void)STATS:(in NSArray *)data
{
    if (!data) return;
    NSMutableArray *tmpprotos = [NSMutableArray array];
    [protocolSource removeAllObjects];
    NSArray *protos = [data objectAtIndex:3];
    NSArray *tmp;
    double totalSize=0.0;
    long totalUsers=0;
    long totalFiles=0;
    int i, count=[protos count];
    NSString *shares = @"";
    for (i=0;i<count;i++) {
        tmp = [protos objectAtIndex:i];
        if ([[tmp objectAtIndex:2] objectForKey:@"users"]) {
            [tmpprotos addObject:[tmp objectAtIndex:0]]; // for the notification...
            totalSize += [[[tmp objectAtIndex:2] objectForKey:@"size"] doubleValue];
            totalUsers += (long)[[[tmp objectAtIndex:2] objectForKey:@"users"] intValue];
            totalFiles += (long)[[[tmp objectAtIndex:2] objectForKey:@"files"] intValue];
            [protocolSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [icon_shop largeIconForProto:[tmp objectAtIndex:0]],@"icon",
                [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                    [tmp objectAtIndex:0], // protocol name
                    [NSString stringWithFormat:@"%@ Users - %@ Files - %@ GB",
                        [[tmp objectAtIndex:2] objectForKey:@"users"],
                        [[tmp objectAtIndex:2] objectForKey:@"files"],
                        [[tmp objectAtIndex:2] objectForKey:@"size"]],
                nil],@"protocol",nil]
            ];
        }
        else {
            int files = [[[tmp objectAtIndex:2] objectForKey:@"files"] intValue];
            NSString *f;
            if (files==1) f=@"File";
            else f=@"Files";
            if (synchronizing) shares = @"synchronizing... (this may take a while)";
            else shares = [[NSString stringWithFormat:@"%d %@ - ",files,f] stringByAppendingString:
                            [NSString stringWithFormat:@"%@ GB",[[tmp objectAtIndex:2] objectForKey:@"size"]]];
            [protocolSource insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSImage imageNamed:@"public.icns"],@"icon",
                    [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                        @"Sharing", // protocol name
                        shares,
                    nil],@"protocol",nil]
    
            atIndex:0];
        }
    }
    NSString *total = [NSString stringWithFormat:@"%d Users - %d Files - %.2f GB",totalUsers,totalFiles,totalSize];
    [protocolSource insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                //[NSImage imageNamed:@"poisoned.tiff"],@"icon",
                [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                    attach, // protocol name
                    total,
                nil],@"protocol",nil]
    
    atIndex:1];
    [protocolSource insertObject:[NSDictionary dictionary] atIndex:1];
    [protocolTable reloadData];
    
    if (!protosSend) {
        // send notification with availabe protocols -> search controller (filter)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PStatsProtocolsAvailable" object:self
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:tmpprotos,@"protos",nil]];
        protosSend=YES;
    }
}

- (oneway void)SHARE:(in NSArray *)data
{
    if (!data) return;
    NSDictionary *item = [data objectAtIndex:2];
    if (!item) return;
    NSString *action = [item objectForKey:@"action"];
    NSString *status = [item objectForKey:@"status"];
    if (action && status && [action isEqualToString:@"sync"]) {
        if ([status isEqualToString:@"Done"]) {
            synchronizing=NO;
            [commander cmd:@"STATS"];
        }
        else synchronizing=YES;
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [protocolSource count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [[protocolSource objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    return NO;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    NSString *ident = [theItem itemIdentifier];
    BOOL connected = [commander connected];
    if ([ident isEqualToString:@"giFTConnect"]) {
        if (connected) {
            [theItem setLabel:@"Disconnect"];
            [theItem setPaletteLabel:@"Disconnect"];
            [theItem setToolTip:@"Disconnect from the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"disconnect.tiff"]];
            return YES;
        }
        else {
            [theItem setLabel:@"Connect"];
            [theItem setPaletteLabel:@"Connect"];
            [theItem setToolTip:@"Connect to the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"connect.tiff"]];
            return YES;
        }
    }
    else if ([ident isEqualToString:@"giFTLaunch"]) {
        if (connected) {
            [theItem setLabel:@"Stop giFT"];
            [theItem setPaletteLabel:@"Stop giFT"];
            [theItem setToolTip:@"Stop the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"stopgift.tiff"]];
            return YES;
        }
        else {
            [theItem setLabel:@"Start giFT"];
            [theItem setPaletteLabel:@"Start giFT"];
            [theItem setToolTip:@"Start the giFT daemon"];
            [theItem setImage:[NSImage imageNamed:@"startgift.tiff"]];
            return YES;
        }
    }
    return YES;
}

- (void)checkConfFiles
{
    [self check:@""];	// -> ~/.giFT
    [self check:@"/gift.conf"];
    [self check:@"/OpenFT"];
    [self check:@"/OpenFT/OpenFT.conf"];
    [self check:@"/Gnutella"];
    [self check:@"/Gnutella/Gnutella.conf"];
    [self check:@"/FastTrack"];
    [self check:@"/FastTrack/FastTrack.conf"];
    [self check:@"/ui"];
    [self check:@"/ui/ui.conf"];
}

- (void)check:(NSString *)path
{
    NSFileManager *manager = 	[NSFileManager defaultManager];
    //NSString *gift =		[NSHomeDirectory() stringByAppendingPathComponent:@".giFT"];
    
    NSString *gift =		[[[NSHomeDirectory() 
                                    stringByAppendingPathComponent:@"Library"]
                                    stringByAppendingPathComponent:@"Application Support"]
                                    stringByAppendingPathComponent:@"Poisoned"];
    NSString *shared = 		[[NSBundle mainBundle] sharedSupportPath];

    if (![manager fileExistsAtPath:[gift stringByAppendingString:path]]) {
        NSLog(@"%@ not found: copying...",[gift stringByAppendingString:path]);
        [manager 
            copyPath:[shared stringByAppendingString:path] 
            toPath:[gift stringByAppendingString:path] 
            handler:nil];
    }
}
*/
@end
