//
// PPrefDownloads.h
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

@interface PPrefDownloads : NSObject
{
    IBOutlet NSButton *removeCancelled;
    IBOutlet NSButton *removeCompleted;
    IBOutlet NSButton *importToiTunes;
    IBOutlet NSButton *importToPlaylist;
    IBOutlet NSButton *playFile;
    IBOutlet NSButton *playFileIfNoFile;
    IBOutlet NSButton *deleteFile;
    IBOutlet NSButton *switchToDownload;
    IBOutlet NSTextField *incoming;
    IBOutlet NSTextField *completed;
    IBOutlet NSButton *browseIn;
    IBOutlet NSButton *browseComp;

    NSUserDefaults *userDefaults;
    PGiFTConf *gift_conf;
    
}

- (void)readConfFiles;

- (void)enable;
- (void)disable;

- (IBAction)cancelledPrefsChanged:(id)sender;
- (IBAction)completedPrefsChanged:(id)sender;
- (IBAction)importPrefsChanged:(id)sender;
- (IBAction)importPlaylistChanged:(id)sender;
- (IBAction)playfilePrefsChanged:(id)sender;
- (IBAction)playFileIfNoFilePrefsChanged:(id)sender;
- (IBAction)deletefilePrefsChanged:(id)sender;
- (IBAction)switchToDownloadPrefsChanged:(id)sender;

- (IBAction)completedChanged:(id)sender;
- (IBAction)incomingChanged:(id)sender;
- (IBAction)browseIncoming:(id)sender;
- (IBAction)browseCompleted:(id)sender;

@end
