//
// PPrefUploads.h
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
#import "PTableView.h"
#import "PGiFTConf.h"

@interface PPrefUploads : NSObject
{
    IBOutlet NSButton *removeCancelled;
    IBOutlet NSButton *removeCompleted;
    IBOutlet PTableView *shareTable;
    IBOutlet NSButton *removeButton;
    IBOutlet NSButton *addButton;
    
    IBOutlet NSTextField *maxUploads;
    IBOutlet NSTextField *maxPerUser;
    IBOutlet NSTextField *maxUpstream;
    IBOutlet NSTextField *maxDownstream;
    
    NSUserDefaults *userDefaults;
    PGiFTConf *gift_conf;
    
    NSMutableArray *shareSource;
    
    BOOL share_completed;
}

- (void)readConfFiles;

- (void)enable;
- (void)disable;

- (IBAction)cancelledPrefsChanged:(id)sender;
- (IBAction)completedPrefsChanged:(id)sender;
- (IBAction)addShare:(id)sender;
- (IBAction)removeShare:(id)sender;
- (IBAction)maxUploadsChanged:(id)sender;
- (IBAction)maxPerUserChanged:(id)sender;
- (IBAction)maxUploadSpeedChanged:(id)sender;
- (IBAction)maxDownloadSpeedChanged:(id)sender;

- (void)completedDirectoryChanged:(NSNotification *)notification;

@end
