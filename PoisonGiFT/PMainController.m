//
// PMainController.m
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

#import "PMainController.h"
#import "PToolbarCategory.h"

#define AQUAFIED (NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask)
#define TEXTURED (NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask|NSTexturedBackgroundWindowMask)

@implementation PMainController

- (void)awakeFromNib	// too long!!!
{
    BOOL firstRun;
    int style;
    float version;
    float currentVersion;

	[drawerButton retain];
    commander = [[PCommand alloc] init];
    
   
	// THIS IS TESTING - jjt
	//[self activate:NULL];
	
	// Notifications
    // ---------------------------------------------------------------
	// all objects have had awakeFromNib called
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activate:) name:NSApplicationDidFinishLaunchingNotification object:NULL];
    
    // disconnected notification...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected:) name:@"PoisonConnectionClosed" object:commander];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downbrowsehost:) name:@"PDownBrowseHost" object:download];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upbrowsehost:) name:@"PUpBrowseHost" object:upload];
    
    // control tint changed notification...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintChanged:) name:NSControlTintDidChangeNotification object:nil];
    
    // checked version notification...
    [[NSDistributedNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(checkedForUpdate:)
            name:@"PCheckedForUpdate"
            object:nil
            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    // ---------------------------------------------------------------


    // set up images which change when control tint changes...
    // ---------------------------------------------------------------
    navImages = [[NSMutableDictionary alloc] init];
    [navImages setObject:[NSArray arrayWithObjects:
        [NSImage imageNamed:@"giFT_aqua.tiff"],
        [NSImage imageNamed:@"search_aqua.tiff"],
        [NSImage imageNamed:@"downloads_aqua.tiff"],
        [NSImage imageNamed:@"uploads_aqua.tiff"],nil]
    forKey:@"blueControlTintColor"];
    [navImages setObject:[NSArray arrayWithObjects:
        [NSImage imageNamed:@"giFT_graphite.tiff"],
        [NSImage imageNamed:@"search_graphite.tiff"],
        [NSImage imageNamed:@"downloads_graphite.tiff"],
        [NSImage imageNamed:@"uploads_graphite.tiff"],nil]
    forKey:@"graphiteControlTintColor"];
    
    toolbarImages = [[NSMutableDictionary alloc] init];
    
    [toolbarImages setObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSImage imageNamed:@"drawer_aqua.tiff"],@"drawer",
        [NSImage imageNamed:@"cancel_aqua.tiff"],@"cancel",
        [NSImage imageNamed:@"pause_aqua.tiff"],@"pause",
        [NSImage imageNamed:@"resume_aqua.tiff"],@"resume",
        [NSImage imageNamed:@"download_aqua.tiff"],@"download",
        [NSImage imageNamed:@"stop_aqua.tiff"],@"stop",nil]
    forKey:@"blueControlTintColor"];
    [toolbarImages setObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSImage imageNamed:@"drawer_graphite.tiff"],@"drawer",
        [NSImage imageNamed:@"cancel_graphite.tiff"],@"cancel",
        [NSImage imageNamed:@"pause_graphite.tiff"],@"pause",
        [NSImage imageNamed:@"resume_graphite.tiff"],@"resume",
        [NSImage imageNamed:@"download_graphite.tiff"],@"download",
        [NSImage imageNamed:@"stop_graphite.tiff"],@"stop",nil]
    forKey:@"graphiteControlTintColor"];
    // ---------------------------------------------------------------


    // Preferences
    // ---------------------------------------------------------------
    userDefaults = [NSUserDefaults standardUserDefaults];

    // first time launching poisoned ?
    //BOOL firstRun;
    if (![userDefaults objectForKey:@"PFirstRun"]) firstRun=YES;
    else firstRun=NO;
    if (firstRun)[self setDefaults];

    // setting up the window
    // ---------------------------------------------------------------
    [self initTabView];
    [drawer setContentView:globalSplit];
    [drawer setDelegate:self];

    currentView =-1; // do not show the mainWindow
    if (style = [userDefaults integerForKey:@"PAppearance"]) {
        [self initWindow:style];
    }
    else [self initWindow:AQUAFIED];
    
    [toolbarSearch retain];
    [toolbarSearchRealm retain];

    [mainWindow setToolbar:toolbar];
    
    // switch through all tab views, possible fix for strange brushed metal bug (moving background)
    // that's the reason why currentView was set to -1
    // so this isn't visible
    [self switchToUpload:self];
    [self switchToDownload:self];
    [self switchToSearch:self];
    [self switchToGiFT:self];

    [self controlTintChanged:self];		// insert the right icons (depending on the control tint)

    [mainWindow makeKeyAndOrderFront:self];	// window setup finished -> make it visible
    [self setSavedDrawerSize];
    // ---------------------------------------------------------------


    // version specific stuff
    // ---------------------------------------------------------------
    version = [userDefaults floatForKey:@"PVersion"];
    currentVersion = [[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    // if the last version the user was using is 0.311 or smaller, we have to randomize port and http_port in OpenFT.conf
    if (version<=0.311f) {
        // probably this could be done better ;)
        [giFT checkConfFiles];
        POpenFTConf *openft_conf = [POpenFTConf singleton];
        [openft_conf setRandomValues];
    }
    if (version<=0.49f) {
        // there is a new Gnutella.conf => replace the old one
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager removeFileAtPath:[@"~/Library/Application Support/Poisoned/Gnutella/Gnutella.conf" stringByExpandingTildeInPath] handler:nil])
            NSLog(@"removed old Gnutella.conf");
        
        // OpenFT's local nodes cache must be replaced w/ the new default
        // one so that connection to the new network will not have to scan
        if ([manager removeFileAtPath:[@"~/Library/Application Support/Poisoned/OpenFT/nodes" stringByExpandingTildeInPath] handler:nil])
            NSLog(@"removed OpenFT nodes cache");

        /* update the fasttrack.conf to the new and improved - ashton */
        if ([manager removeFileAtPath:[@"~/Library/Application Support/Poisoned/FasttTrack/FasttTrack.conf" stringByExpandingTildeInPath] handler:nil])
            NSLog(@"removed old FastTrack.conf");

        // it wouldn't be necesseary to check all files again, but it the easiest way ;)
        [giFT checkConfFiles];
        
        // set max length for recent searches list to 15
        [userDefaults setInteger:15 forKey:@"PMaxRecentSearchesListCount"];
    }
    
    /* drawer open works best here - ashton */
    [drawer open];
    
    if (firstRun) {
        [giFT checkConfFiles];
        [self openPrefs:self];
        [userDefaults setFloat:currentVersion forKey:@"PVersion"];
    }
    else if (version<currentVersion) {
        [userDefaults setFloat:currentVersion forKey:@"PVersion"];

        if (version<=0.131f) { // user updated from version <= 0.131
            [userDefaults setBool:NO forKey:@"PSwitchToDownloads"];
        }
        // alert panel for new preferences
        /*int button = NSRunAlertPanel(@"First time running this version of Poisoned.",
            [NSString stringWithFormat:@"There are new Preferences. Would you like to open the Preferences Panel?", version], @"Open Preferences...", @"Cancel", nil);
        if (button==NSOKButton) [self openPrefs:self];*/
    }
    // ---------------------------------------------------------------


    // last thing to do -> check version
    // ---------------------------------------------------------------
    if ([userDefaults boolForKey:@"PAutoVersionCheck"]) 
        [NSThread detachNewThreadSelector:@selector(checkVersion:) toTarget:self withObject:[NSNumber numberWithBool:NO]];
    // ---------------------------------------------------------------

    if (![userDefaults boolForKey:@"PCheckedForOldGiFTFolder"] && [[NSFileManager defaultManager] fileExistsAtPath:[@"~/.giFT" stringByExpandingTildeInPath]]) {
        int button = NSRunAlertPanel(@"You have an invisible .giFT folder in your home directory.",
            @"The included giFT daemon doesn't use it anymore (new location is ~/Library/Application Support/Poisoned). This also means that you have to set your giFT preferences again (sorry for that).\nDo you want Poisoned to make this folder visible and rename to \"Old giFT Files\", so you can delete it? (Important: If you're also using other giFT clients or have compiled giFT yourself, you should leave it as it is.)", @"OK", @"Cancel", nil);
        if(NSOKButton == button)
            [[NSFileManager defaultManager] movePath:
                [NSHomeDirectory() stringByAppendingPathComponent:@".giFT"]
                toPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Old giFT Files"]
                handler:nil];
    }
    [userDefaults setBool:YES forKey:@"PCheckedForOldGiFTFolder"];

	// right now the timer just always fires, but really it should only start firing
	// after a PoisonConnectedToCore notification and disable itself after PoisonConnectionClosed
	// i can fix that in a later release - jjt
	[[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTransferFieldTimer:) userInfo:NULL repeats:YES] retain];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [mainWindow release];
    [toolbarSearch release];
    [toolbarSearchRealm release];
    [toolbar release];
    [navImages release];
    [toolbarImages release];
    [drawerButton release];
        
    // PToolbarCategory
    [toolbarAllowedItems release];
    [toolbarDefaultItems release];
    
    if (prefs) [prefs release];
    
    [super dealloc];
}

- (int)currentView
{
	return currentView;
}

- (void)controlTintChanged:(id)sender
{
    NSColor *controlTint = [NSColor colorForControlTint:NSDefaultControlTint];
    // get the images for the current control tint...
    currentNav = [navImages objectForKey:[controlTint colorNameComponent]];
    currentTool = [toolbarImages objectForKey:[controlTint colorNameComponent]];
    [navigationImage setImage:[currentNav objectAtIndex:navimg]];
    [drawerButton setAlternateImage:[currentTool objectForKey:@"drawer"]];
    [drawerButton display];
    [navigationImage display];
    [self switchToolbarConfigurationTo:0];	// dummy, doesn't change the images otherwise (???)
    [self switchToolbarConfigurationTo:navimg];
}


// DO is setup, so it's time to register some commands
// --------------------------------------------------------------------------------------------------
- (void)activate:(id)sender
{	
    [commander registerController:self forCommands:
        [NSArray arrayWithObjects:
            @"POISON_GUI_UPDATE",
            @"REMOVE_UNKNOWN_COMMAND_TICKET",
            @"ADDSOURCE",@"DELSOURCE",
        nil]
    ];
    [download setCommander:commander andController:self];
    [upload setCommander:commander andController:self];
    [search setCommander:commander andController:self];
    [giFT setCommander:commander andController:self];
    
    // currently being downloaded files (empty)
    [search setDownloadingHashes:[download hashes]];
}
// --------------------------------------------------------------------------------------------------


- (void)disconnected:(id)sender
{
    [self validate]; // update the toolbar
    [transferField setStringValue:@"DL 0 kB/s   UL 0 kB/s"];
}

- (oneway void)ADDSOURCE:(in NSArray *)data
{
    [download ADDSOURCE:data];
    [upload ADDSOURCE:data];
}

- (oneway void)DELSOURCE:(in NSArray *)data
{
    [download DELSOURCE:data];
    [upload DELSOURCE:data];
}

- (oneway void)POISON_GUI_UPDATE:(in id)sender
{
	// this is a very bad function, it was slowing down the entire app
	// by refreshing every item in the gui whenver any packet arrived
	// i have disabled it in an attempt to only update the parts of the
	// gui that need updating after a packet arrives - jjt
    /*
	int dl = [download speed];
    int ul = [upload speed];
    [transferField setStringValue:[NSString stringWithFormat:@"DL %d kB/s   UL %d kB/s",dl,ul]];
    [giFT gui_update:(currentView==0)];
    [search gui_update:(currentView==1)];
    [download gui_update:(currentView==2)];
    [upload gui_update:(currentView==3)];
	*/
}

- (void)updateTransferFieldTimer:(NSTimer *)inTimer
{
	if ([commander connected])
	{
		int dl = [download speed];
		int ul = [upload speed];
		[transferField setStringValue:[NSString stringWithFormat:@"DL %d kB/s   UL %d kB/s",dl,ul]];
	}
}

// unknown command with an id -> "mark" the id as used
// --------------------------------------------------------------------------------------------------
- (oneway void)REMOVE_UNKNOWN_COMMAND_TICKET:(in NSArray *)data
{
    if (!data) return;
    if ([data objectAtIndex:1]) [commander removeTicket:[data objectAtIndex:1]];
}
// --------------------------------------------------------------------------------------------------


// Init window with content...
// --------------------------------------------------------------------------------------------------
- (void)initWindow:(unsigned int)style
{
    NSRect frame = [[NSScreen mainScreen] frame];
    [drawer setParentWindow:nil];
    mainWindow = [[NSWindow alloc] 
        initWithContentRect:NSMakeRect(frame.origin.x+260,frame.size.height-560,735,500)
        styleMask:style
        backing:NSBackingStoreBuffered
        defer:YES];
    [mainWindow setMinSize:NSMakeSize(500,350)];
    [mainWindow setDelegate:self];
    [mainWindow setFrameUsingName:@"theMainWindow"];
    [mainWindow setExcludedFromWindowsMenu:YES];
    [mainWindow setReleasedWhenClosed:NO];
    if (style==TEXTURED) {
        [dummyBackground setTransparent:YES];
        [mainWindow setBottomCornerRounded:NO]; // DANGER, USING PRIVATE API HERE!!!
    }
    else [dummyBackground setTransparent:NO];	// fix the backgournd in the drawer!
    
    [self initToolbar];

    [mainWindow setContentView:mainView];

    if (currentView>-1) [mainWindow makeKeyAndOrderFront:self];
    [drawer setParentWindow:mainWindow];
    [self setSavedDrawerSize];
}

- (void)initTabView
{    
    NSTabViewItem *_giFT = [[NSTabViewItem alloc] initWithIdentifier:@"giFT"];
    NSTabViewItem *_search = [[NSTabViewItem alloc] initWithIdentifier:@"search"];
    NSTabViewItem *_download = [[NSTabViewItem alloc] initWithIdentifier:@"download"];
    NSTabViewItem *_upload = [[NSTabViewItem alloc] initWithIdentifier:@"upload"];
    [_giFT setView:[giFT view]];
    [_search setView:[search view]];
    [_download setView:[download view]];
    [_upload setView:[upload view]];
    [contentView addTabViewItem:_search];
    [contentView addTabViewItem:_download];
    [contentView addTabViewItem:_upload];
    [contentView addTabViewItem:_giFT];
    [contentView setDrawsBackground:NO];
    [_giFT release];
    [_search release];
    [_download release];
    [_upload release];
}


- (void)setSavedDrawerSize
{
    int drawer_width = [userDefaults integerForKey:@"PDrawerWidth"];
    int drawer_state = [userDefaults integerForKey:@"PDrawerState"];
    if (drawer_state) {
        NSSize d_size = [drawer contentSize];
        d_size.width=drawer_width;
        [drawer setContentSize:d_size];
        
        drawer_state--; // this is the actual value for the state since we increased it by 1 when saving
        if (drawer_state==NSDrawerOpenState) [drawer open];
        else [drawer close];
    }
}

// --------------------------------------------------------------------------------------------------



// --------------------------------------------------------------------------------------------------
// IBActions...
// --------------------------------------------------------------------------------------------------
- (void)checkedForUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *version;
    if ([userInfo objectForKey:@"PError"])
        NSRunCriticalAlertPanel(@"Poisoned was unable to connect to the Internet.",
            @"Please check your configuration and try again.",
            @"OK", nil, nil);
    else if (version=[userInfo objectForKey:@"PNewVersion"]) {
        int button = NSRunAlertPanel(@"A New Version is Available.",
            [NSString stringWithFormat:@"A new version of Poisoned is available (version %@). Would you like to download the new version now?", version], @"OK", @"Cancel", nil);
        if(NSOKButton == button)
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poisonedproject.com/poisoned.php"]];
    }
    else if ([userInfo objectForKey:@"PUpToDate"])
        NSRunAlertPanel(@"Your Software is up-to-date.",
            @"You have the most recent version of Poisoned.",
            @"OK", nil, nil);
}


// this is still not working correctly -> beachball under certain circumstances...
- (void)checkVersion:(NSNumber *)currentversionpanel
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *running = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://www.poisonedproject.com/version.xml"]];
    NSString *latest = [productVersionDict objectForKey:@"Poisoned"];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (!latest) {
        if ([currentversionpanel boolValue])
        [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"PError"];
    }
    else if ([latest floatValue]>[running floatValue]) {
        [userInfo setObject:latest forKey:@"PNewVersion"];
    }
    else if ([currentversionpanel boolValue])
        [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"PUpToDate"];
    
    [[NSDistributedNotificationCenter defaultCenter]
        postNotificationName:@"PCheckedForUpdate"
        object:nil
        userInfo:userInfo
        deliverImmediately:YES];
    [pool release];
    return;
}

- (IBAction)versionCheck:(id)sender
{
    [self checkVersion:[NSNumber numberWithBool:YES]];
}

- (IBAction)openPrefs:(id)sender
{
    if (prefs) {
        [prefs showWindow:self];
    }
    else {
        prefs = [[PPreferencesController alloc] init];
        [NSBundle loadNibNamed:@"Preferences" owner:prefs];
    }
}

- (IBAction)drawerAction:(id)sender
{
    if ([drawer state]==NSOffState) [drawer open];
    else [drawer close];
}

- (IBAction)switchAppearance:(id)sender
{
    NSString *tab;
    NSString *winTitle;
    int state = [drawer state];
    if ([mainWindow attachedSheet])
        [[NSApplication sharedApplication] endSheet:[mainWindow attachedSheet]];
    [drawer setParentWindow:nil];
    tab = [[contentView selectedTabViewItem] identifier];
    [contentView selectFirstTabViewItem:self];
    winTitle = [mainWindow title];
    [mainWindow saveFrameUsingName:@"theMainWindow"];
    [mainWindow orderOut:self];
    [mainWindow release];
    mainWindow = nil;
    [toolbar release];
    if ([userDefaults integerForKey:@"PAppearance"]==TEXTURED) {
        [self initWindow:TEXTURED];
    }
    else {
        [self initWindow:AQUAFIED];
    }
    [mainWindow setTitle:winTitle];
    [contentView selectTabViewItemWithIdentifier:tab];
    [[drawer contentView] display];
    if (state == NSDrawerOpenState) [drawer open];
    [drawer setContentView:globalSplit];
}

- (IBAction)switchToGiFT:(id)sender
{
    navimg=0;
    [navigationImage setImage:[currentNav objectAtIndex:navimg]];
    [navigationImage display];
    [self switchToolbarConfigurationTo:navimg];
    [contentView selectFirstTabViewItem:self];
    [contentView selectTabViewItemWithIdentifier:@"giFT"];
    [mainWindow setTitle:@"Poisoned - giFT"];
}

- (IBAction)switchToSearch:(id)sender
{
    if (navimg==1) return;
    navimg=1;
    [navigationImage setImage:[currentNav objectAtIndex:navimg]];
    [navigationImage display];
    [search gui_update:YES];
    [self switchToolbarConfigurationTo:navimg];
    [contentView selectFirstTabViewItem:self];
    [contentView selectTabViewItemWithIdentifier:@"search"];
    [mainWindow setTitle:@"Poisoned - Search"];
}

- (IBAction)newSearch:(id)sender
{
    if (currentView==1) {
        [[[toolbarSearch subviews] objectAtIndex:0] selectText:self];
    }
    else {
        [self switchToSearch:self];
        [[[toolbarSearch subviews] objectAtIndex:0] selectText:self];
    }
}

- (IBAction)downbrowsehost:(id)sender
{
    [self switchToSearch:self];
    [search browsehost:[download browsehost]];
}

- (IBAction)upbrowsehost:(id)sender
{
    [self switchToSearch:self];
    [search browsehost:[upload browsehost]];
}

- (IBAction)switchToDownload:(id)sender
{
    navimg=2;
    [navigationImage setImage:[currentNav objectAtIndex:navimg]];
    [navigationImage display];
    [self switchToolbarConfigurationTo:navimg];
    [contentView selectFirstTabViewItem:self];
    [contentView selectTabViewItemWithIdentifier:@"download"];
    [mainWindow setTitle:@"Poisoned - Downloads"];
}

- (IBAction)switchToUpload:(id)sender
{
    navimg=3;
    [navigationImage setImage:[currentNav objectAtIndex:navimg]];
    [navigationImage display];
    [self switchToolbarConfigurationTo:navimg];
    [contentView selectFirstTabViewItem:self];
    [contentView selectTabViewItemWithIdentifier:@"upload"];
    [mainWindow setTitle:@"Poisoned - Uploads"];
}

// ------------------------------------------------------------------------------
// Handling the mainWindow, delegates...
// ------------------------------------------------------------------------------

- (IBAction)giFTViewer:(id)sender; // "giFT Viewer cmd-N"
{
    [mainWindow makeKeyAndOrderFront:self];
}

- (BOOL)windowShouldClose:(id)sender
{
    [mainWindow saveFrameUsingName:@"theMainWindow"];
    return YES;
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    // this is a workaround for the drawer becoming white when we open the window...
    if ([drawer state]==NSDrawerOpenState) {
        [drawer close];
        [drawer open];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if ([userDefaults boolForKey:@"PStopGiFT"]&&[commander connected]) [commander cmd:@"QUIT"];
    
    // save the searches
    [search saveSearches];
    
    // saving the drawer's size and state
    [userDefaults setInteger:[drawer contentSize].width forKey:@"PDrawerWidth"];
    // we add 1 to the state so we always have values > 0
    // and 0 then just would mean that we don't have set this pref yet
    [userDefaults setInteger:([drawer state]+1) forKey:@"PDrawerState"];
    //* remove dock badge - j.ashton*//
    [NSApp setApplicationIconImage:[NSImage imageNamed: @"poison.icns"]];
    
    [mainWindow saveFrameUsingName:@"theMainWindow"];
    [self saveToolbarConfiguration];
    return NSTerminateNow;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [mainWindow makeKeyAndOrderFront:self];
    return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    switch (currentView) {
        case 2: return [download validateToolbarItem:theItem];
        case 3: return [upload validateToolbarItem:theItem];
        default: return YES;
    }
}

- (IBAction)poisonWeb:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poisonedproject.com/"]];
}

- (IBAction)giftWeb:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://giftproject.org"]];
}

- (void)drawerDidOpen:(NSNotification *)notification
{
    [drawerButton setState:NSOnState];
}

- (void)drawerDidClose:(NSNotification *)notification
{
    [drawerButton setState:NSOffState];
}

/* set our application defaults, used for first run or poisoned reset - ashton */
-(void)setDefaults
{
    [drawer setContentSize:NSMakeSize(138,138)];
    
    [userDefaults setBool:NO forKey:@"PFirstRun"];
    [userDefaults setInteger:AQUAFIED forKey:@"PAppearance"];

    [userDefaults setBool:YES forKey:@"PStopGiFT"];  // Automatically stop gift -> no
    [userDefaults setObject:@"127.0.0.1" forKey:@"PDaemonAddress"];	// this isn't really used
    [userDefaults setInteger:1213 forKey:@"PDaemonPort"];
    [userDefaults setObject:@"/usr/local/bin/giFT" forKey:@"PGiFTPath"];
    [userDefaults setInteger:3 forKey:@"PConnectToDaemonTimeout"];
    [userDefaults setBool:YES forKey:@"PAutoConnect"];
    [userDefaults setBool:YES forKey:@"PAutoLaunch"];
    [userDefaults setBool:YES forKey:@"PRelaunchOnCrash"];

    [userDefaults setBool:NO forKey:@"PUseCustomDaemon"];

    [userDefaults setBool:NO forKey:@"PRemoveCompletedDownloads"];
    [userDefaults setBool:NO forKey:@"PRemoveCancelledDownloads"];
    [userDefaults setBool:NO forKey:@"PImportToiTunes"];
    [userDefaults setBool:NO forKey:@"PImportToPlaylist"];
    [userDefaults setBool:NO forKey:@"PPlayFile"];
    [userDefaults setBool:NO forKey:@"PNoFilePlayFile"];
    [userDefaults setBool:NO forKey:@"PDeleteFile"];
    [userDefaults setBool:NO forKey:@"PSwitchToDownloads"];

    [userDefaults setBool:NO forKey:@"PRemoveCompletedUploads"];
    [userDefaults setBool:NO forKey:@"PRemoveCancelledUploads"];

    [userDefaults setBool:YES forKey:@"PAutoVersionCheck"];

    [userDefaults setObject:@"Poisoned" forKey:@"PImportPlaylistName"];

}

@end
