//
//  PUploadSource.h
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

#import <Foundation/Foundation.h>
#import "PAppKit.h"

#define PCOMPLETED	0
#define PCANCELLED	1
#define PPAUSED		2
#define PACTIVE		3

@interface PUploadSource : NSObject{

    PTableView *table;
    
    NSTableColumn *selectedColumn;
    NSImage *ascending;
    NSImage *descending;
    
    PIconShop *iconShop;
    
    NSMutableArray *source;
    NSMutableDictionary *tickets;
    
    NSUserDefaults *userDefaults;
    
    BOOL sortAscending;
    
    id giftCommander;
}

- (id)initWithTable:(PTableView *)_table;

- (void)setCommander:(id)_giftCommander;

- (id)itemAtRow:(int)row;

- (void)ADDUPLOAD:(NSArray *)data;
- (void)CHGUPLOAD:(NSArray *)data;

- (void)DELUPLOAD:(NSArray *)data;
- (void)DEL:(NSArray *)data;

- (void)ADDSOURCE:(NSArray *)data;
- (void)DELSOURCE:(NSArray *)data;

- (NSString *)stringForUsers:(int)users;
- (NSString *)timeStringFromInt:(int)sec;
- (NSString *)calcSize:(NSString *)size;
- (NSString *)throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed;
- (NSNumber *)transmit:(NSString *)_transmit total:(NSString *)_total;
- (NSString *)remainingWithTotalSize:(NSString *)_size transmit:(NSString *)_transmit throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed;

- (int)speed;
- (int)numberOfDownloads;

- (void)disconnected;

// respond to delete key...
- (void)deleteEvent:(id)sender;

- (void)cancel:(id)commander;
- (void)pause:(id)commander;
- (void)resume:(id)commander;
- (void)delsource:(id)commander;
- (void)browsehost:(id)commander;
- (void)cleanUp:(id)commander;

//- (void)expand;
//- (void)collapse;

- (BOOL)validateDelSource;
- (BOOL)validateCancel;
- (BOOL)validatePause;
- (BOOL)validateResume;


@end
