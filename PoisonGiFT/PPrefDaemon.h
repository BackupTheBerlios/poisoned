//
// PPrefDaemon.h
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

@interface PPrefDaemon : NSObject
{
    IBOutlet NSTextField *address;
    IBOutlet NSTextField *path;
    IBOutlet NSTextField *port;
    IBOutlet NSButton *stopGiFT;
    IBOutlet NSTextField *timeout;
    
    IBOutlet NSButton *customDaemon;
    
    IBOutlet NSButton *autoConnect;
    IBOutlet NSButton *autoLaunch;
    IBOutlet NSButton *relaunchOnCrash;

    NSUserDefaults *userDefaults;
    PGiFTConf *gift_conf;
    PUIConf *ui_conf;
}

- (void)readConfFiles;

- (IBAction)addressChanged:(id)sender;
- (IBAction)pathChanged:(id)sender;
- (IBAction)portChanged:(id)sender;
- (IBAction)stoppingPrefsChanged:(id)sender;
- (IBAction)timeoutChanged:(id)sender;

- (IBAction)autoLaunchPrefsChanged:(id)sender;
- (IBAction)autoConnectPrefsChanged:(id)sender;
- (IBAction)relaunchOnCrashPrefsChanged:(id)sender;

- (IBAction)customDaemonPrefsChanged:(id)sender;

@end
