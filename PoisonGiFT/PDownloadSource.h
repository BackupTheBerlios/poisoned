//
//  PTransferSource.h
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
#import "PAppKit.h"

#define PCOMPLETED	0
#define PCANCELLED	1
#define PPAUSED		2
#define PACTIVE		3
#define PPAUSING	10
#define PRESUMING	11

@interface PDownloadSource : NSObject
{

    PDiffOutlineView *table;
    
    NSTableColumn *selectedColumn;
    NSImage *ascending;
    NSImage *descending;
    
    PIconShop *iconShop;
    
    NSMutableArray *source;
    NSMutableDictionary *tickets;
    
    // this set stores the hashes of active or paused downloads
    NSMutableSet *hashes;
    
    NSUserDefaults *userDefaults;
    
    BOOL sortAscending;
    
    NSMenu *menu;
    
    id giftCommander;
    
    // we use an dictionary to store the timers for 'auto find more sources'
    // key is the hash of the file
    NSMutableDictionary *timers;

    NSString *completedCount; // for the badge - j.ashton
}

- (id)initWithTable:(PDiffOutlineView *)_table;

- (void)setCommander:(id)_giftCommander;
- (void)setHashes:(NSMutableSet *)_hashes;

- (void)ADDDOWNLOAD:(NSArray *)data;
- (void)CHGDOWNLOAD:(NSArray *)data;

- (void)DELDOWNLOAD:(NSArray *)data;
- (void)DEL:(NSArray *)data;

- (void)ADDSOURCE:(NSArray *)data;
- (void)DELSOURCE:(NSArray *)data;

- (void)findMoreSourcesTimer:(NSTimer *)timer;
- (void)findMoreSources:(NSString *)hash;

- (NSString *)stringForUsers:(int)users;
- (NSString *)timeStringFromInt:(int)sec;
- (NSString *)calcSize:(NSString *)size;
- (NSString *)throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed;
- (NSNumber *)transmit:(NSString *)_transmit total:(NSString *)_total;
- (NSString *)remainingWithTotalSize:(NSString *)_size transmit:(NSString *)_transmit throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed;

- (int)speed;
- (int)numberOfDownloads;

- (NSString *)hashForTicket:(NSString *)ticket;

- (void)disconnected;

- (void)deleteEvent:(id)sender;

- (void)cancel:(id)commander;
- (void)pause:(id)commander;
- (void)resume:(id)commander;
- (void)delsource:(id)commander;
- (void)browsehost:(id)commander;
- (void)cleanUp:(id)commander;

- (void)expand;
- (void)collapse;

- (BOOL)validateDelSource;
- (BOOL)validateCancel;
- (BOOL)validatePause;
- (BOOL)validateResume;
- (BOOL)validateFindMoreSources;

- (void)createDockBadgeIcon;  // j.ashton

@end
