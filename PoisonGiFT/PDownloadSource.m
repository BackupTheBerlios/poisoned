//
//  PTransferSource.m
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

#import "PDownloadSource.h"
#import "PGiFTConf.h"

#include <unistd.h>

int iTunesPlaylistImport(const char *filenamewithpath, int playlistmode)
{
	NSString *scriptSource;

	if (playlistmode) 
        {
            scriptSource = [NSString stringWithFormat:[NSString stringWithCString:
            "tell application \"iTunes\"\n"
            "   launch\n"
            "   set Tester to \"0\"\n"
            "   set playlist_name to (\"Poisoned\")\n"
            "   repeat with i in playlists\n"
            "		set currentPlaylist to name of i as string\n"
            "		if currentPlaylist is equal to playlist_name then\n"
            "			set Tester to \"1\"\n"
            "		end if\n"
            "   end repeat\n"
            "   if Tester is equal to \"0\" then\n"
            "		set new_playlist to (make new playlist)\n"
            "		set name of new_playlist to playlist_name\n"
            "   end if\n"
            "   add POSIX file \"%s\" to playlist playlist_name\n"
            "end tell"], filenamewithpath];
        }
        else 
        {
            scriptSource = [NSString stringWithFormat:[NSString stringWithCString:
                "tell application \"iTunes\"\n"
                "   launch\n"
                "	add POSIX file \"%s\" to library playlist 1\n"
                "end tell"], filenamewithpath];
        }
        
    //    NSLog(@"scriptSource: %@", scriptSource);
    
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
	NSDictionary *status = NULL;
	NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&status];
	if ([descriptor descriptorType] == 'obj ')
		NSLog(@"Import to iTunes Playlist script run successfully");
	else if ([descriptor descriptorType] == typeNull)
	{
		NSLog(@"Import to iTunes Playlist is still running");
		return 0;
	}
	else
	{
		NSLog(@"Import to iTunes Playlist script returned error: %@", [status objectForKey: @"NSAppleScriptErrorMessage"]);
		return 0;
	}
	return 1;
}



void playsonginitunes(int playlistmode, int noplaywhenplaying)
{
	NSString *playstring;
	NSString *noplaystring;

	if (playlistmode) 
		playstring=@"playlist \"Poisoned\"";
	else 
		playstring=@"library playlist 1";
		
	if (noplaywhenplaying)
		noplaystring=@"if player state is not playing then\n";
	else 
		noplaystring=@"if stash is 0 then\n";
	
	NSString *scriptSource = [NSString stringWithFormat:[NSString stringWithCString:
	"set cd to (get current date)\n"
	"set stash to 0\n"
	"tell application \"iTunes\"\n"
	"launch\n"
	"%@"
	"set theLib to %@\n"
	"repeat with t from 1 to (count every track of theLib)\n"
	"	tell track t of theLib\n"
	"		set tDif to (cd - (get date added))\n"
	"		if stash is 0 or stash is greater than tDif then\n"
	"			copy tDif to stash\n"
	"			set theLoc to location\n"
	"		end if\n"
	"	end tell\n"
	"end repeat\n"
	"play theLoc\n"
        "end if\n"
	"end tell"], noplaystring, playstring];
        
    //    NSLog(@"scriptSource: %@", scriptSource);
        
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
	NSDictionary *status = NULL;
	NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&status];
	if ([descriptor descriptorType] == 'obj ')
		NSLog(@"Play in iTunes script run successfully");
	else if ([descriptor descriptorType] == typeNull)
	{
		NSLog(@"Play in iTunes script is still running");
	}
	else
	{
		NSLog(@"Play in iTunes script returned error: %@", [status objectForKey: @"NSAppleScriptErrorMessage"]);
	}
	// non destructive if error is returned so no need to check at this time
}

@implementation PDownloadSource

- (id)initWithTable:(PDiffOutlineView *)_table
{
    if (self = [super init])
	{
		table = _table;

        ascending = [NSImage imageNamed:@"NSAscendingSortIndicator"];
        descending = [NSImage imageNamed:@"NSDescendingSortIndicator"];
        
        source 	= [[NSMutableArray alloc] init];
        tickets = [[NSMutableDictionary alloc] init];
        
        iconShop = [[PIconShop alloc] init];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        menu = [[NSMenu alloc] init];
        
        timers = [[NSMutableDictionary alloc] init];
    }
	
    return self;
}

- (void)dealloc
{	
    [menu release];
    [iconShop release];
    [source release];
    [tickets release];
    [timers release];
    [super dealloc];
}

- (void)setCommander:(id)_giftCommander
{
    giftCommander = _giftCommander;
}

- (void)setHashes:(NSMutableSet *)_hashes
{
    hashes = _hashes;
}


- (void)disconnected
{
    // invalidate all timers
    NSEnumerator *keyEnumerator = [timers keyEnumerator];
    id key;
    while (key = [keyEnumerator nextObject]) {
        [[timers objectForKey:key] invalidate];
        [timers removeObjectForKey:key];
    }
    
    [tickets removeAllObjects];
    [source removeAllObjects];
    [table reloadData];
}


- (BOOL)validateFindMoreSources
{
    return [self validateCancel];
}

- (BOOL)validateDelSource
{
    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *selItem;
    while (num=[enumerator nextObject]) {
        selItem = [table itemAtRow:[num intValue]];
        if ([selItem objectForKey:@"PExpandable"]) return NO;
        if (![[[selItem objectForKey:@"PProgress"] objectAtIndex:1] boolValue] && [[[selItem objectForKey:@"PProgress"] objectAtIndex:2] isEqualToString:@""]) return NO;
    }
    return YES;
}

- (BOOL)validateCancel
{
    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || ([[tmp objectForKey:@"PStatus"] intValue]<=1) ) return NO;
    }
    return YES;
}

- (BOOL)validatePause
{
    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || [[tmp objectForKey:@"PStatus"] intValue] != PACTIVE) return NO;
    }
    return YES;
}

- (BOOL)validateResume
{
    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || [[tmp objectForKey:@"PStatus"] intValue] != PPAUSED) return NO;
    }
    return YES;
}

- (NSString *)hashForTicket:(NSString *)ticket
{
    return [[tickets objectForKey:ticket] objectForKey:@"hash"];
}

- (void)deleteEvent:(id)sender
{
    // this array stores the tickets of the deleted downloads
    // so we don't have to delete their sources, if they are selected too
    NSMutableArray *deletedDownloads = [[[NSMutableArray alloc] init] autorelease];
        
    // we store all commands in one string, and send it at once
    NSMutableString *tmpcmd = [[[NSMutableString alloc] initWithString:@""] autorelease];
    
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        
        // if it's a download -> cancel the download and remove it
        if ([item objectForKey:@"PExpandable"]) {
            [deletedDownloads addObject:[item objectForKey:@"PTicket"]];
            if ([[item objectForKey:@"PStatus"] intValue]>1) {
                [deletedDownloads addObject:[item objectForKey:@"PTicket"]];
                [tmpcmd appendString:[NSString stringWithFormat:@";\nTRANSFER(%@) action(cancel)",[item objectForKey:@"PTicket"]]];
                
                // we have to remove the hash form the hashes set.
                // if we wait for gift to send a DELDOWNLOAD: it could happen that
                // the cancelled download starts again if the user is doing 'find more sources'
                // and the hash is still in the hashes set...
                if ([item objectForKey:@"hash"]) [hashes removeObject:[item objectForKey:@"hash"]];
            }
        }
        // a source is selected...
        else if (![deletedDownloads containsObject:[item objectForKey:@"PTicket"]]) {
            [tmpcmd appendString:[NSString stringWithFormat:@";\nDELSOURCE(%@) url(%@)",
                [item objectForKey:@"PTicket"],
                [giftCommander prepare:[item objectForKey:@"url"]]]];
        }
    }
    
    // now we just have to remove the deleted downloads from the table
    // the source will be removed by DELSOURCE: as soon as gift removes the source
    NSString *ticket;
    int i, count = [deletedDownloads count];
    for (i=0;i<count;i++) {
        ticket = [deletedDownloads objectAtIndex:i];
        [source removeObject:[tickets objectForKey:ticket]];
        [tickets removeObjectForKey:tickets];
        [table reloadData];
    }
    if ([tmpcmd length]>2) [giftCommander performSelector:@selector(cmd:) withObject:[tmpcmd substringFromIndex:2]];
}

- (void)cancel:(id)commander
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        [commander performSelector:@selector(cmd:) withObject:[NSString stringWithFormat:@"TRANSFER(%@) action(cancel)",[item objectForKey:@"PTicket"]]];
        [item setObject:[NSNumber numberWithInt:PCANCELLED] forKey:@"PStatus"];
        [item setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithBool:YES],
            [NSNumber numberWithBool:NO],
            @"Cancelling...",nil]
        forKey:@"PProgress"];
        [table reloadItem:item reloadChildren:YES];
    }
}

- (void)pause:(id)commander
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        [commander performSelector:@selector(cmd:) withObject:[NSString stringWithFormat:@"TRANSFER(%@) action(pause)",[[table itemAtRow:[num intValue]] objectForKey:@"PTicket"]]];
        [item setObject:[NSNumber numberWithInt:PPAUSING] forKey:@"PStatus"];
        [item setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithBool:YES],
            [NSNumber numberWithBool:NO],
            @"Pausing...",nil]
        forKey:@"PProgress"];
        [table reloadItem:item reloadChildren:YES];
    }
}

- (void)resume:(id)commander
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [table itemAtRow:[num intValue]];
        [commander performSelector:@selector(cmd:) withObject:[NSString stringWithFormat:@"TRANSFER(%@) action(unpause)",[[table itemAtRow:[num intValue]] objectForKey:@"PTicket"]]];
        [item setObject:[NSNumber numberWithInt:PRESUMING] forKey:@"PStatus"];
        [item setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithBool:YES],
            [NSNumber numberWithBool:NO],
            @"Resuming...",nil]
        forKey:@"PProgress"];
        [table reloadItem:item reloadChildren:YES];
    }
}

- (void)delsource:(id)commander
{
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    NSString *tmpcmd=@"";
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"])
            // never forget to prepare a string, if it's possible that it contains characters that must
            // be escaped ->  \ { } [ ] ( )
            tmpcmd = [tmpcmd stringByAppendingString:[NSString stringWithFormat:@";\nDELSOURCE(%@) url(%@)",[tmp objectForKey:@"PTicket"],[commander prepare:[tmp objectForKey:@"url"]]]];
    }
    [commander performSelector:@selector(cmd:) withObject:[tmpcmd substringFromIndex:2]];
}

- (void)browsehost:(id)commander
{
}

- (void)cleanUp:(id)commander
{
    int i, count = [source count];
    NSDictionary *tmp;
    int state;
    for (i=0;i<count;i++) {
        tmp = [source objectAtIndex:i];
        state = [[tmp objectForKey:@"PStatus"] intValue];
        if (state==PCOMPLETED || state==PCANCELLED) {
            [tickets removeObjectForKey:[tmp objectForKey:@"PTicket"]];
            [source removeObject:tmp];
            [self cleanUp:commander];
            [table reloadData];
            return;
        }
    }
}

- (void)expand
{
    int i, count=[source count];
    for (i=0;i<count;i++) [table expandItem:[source objectAtIndex:i]];
}

- (void)collapse
{
    int i, count=[source count];
    for (i=0;i<count;i++) [table collapseItem:[source objectAtIndex:i]];
}

- (int)speed
{
    int i, count = [source count];
    float tmp, total=0.0;
    for (i=0;i<count;i++) {
        if (tmp=[[[[source objectAtIndex:i] objectForKey:@"PTransfer"] objectAtIndex:1] floatValue]) {
            total += tmp;
        }
    }
    return (int)total;
}

- (int)numberOfDownloads
{
    return [source count];
}

- (NSString *)stringForUsers:(int)users
{
    if (users==1) return @"1 User";
    else return [NSString stringWithFormat:@"%d Users",users];

}

- (NSString *)timeStringFromInt:(int)sec
{
    int h=0,m=0;
    if (sec>=3600) {
        h = sec/3600;
        sec = sec % 3600;
    }
    if (sec>=60) {
        m = sec/60;
        sec = sec%60;
    }
    return [NSString stringWithFormat:@"%d:%02d:%02d",h,m,sec];
}

- (NSString *)remainingWithTotalSize:(NSString *)_size transmit:(NSString *)_transmit throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed
{
    if (!_size ||!_transmit || !_throughput || !_elapsed) return @"";
    long long s,tr,t,e;
    [[NSScanner scannerWithString:_size] scanLongLong:&s];
    [[NSScanner scannerWithString:_transmit] scanLongLong:&tr];
    [[NSScanner scannerWithString:_throughput] scanLongLong:&t];
    [[NSScanner scannerWithString:_elapsed] scanLongLong:&e];
    int speed = t*1000/e;
    int sec = (int)(s-tr)/speed;
    return [self timeStringFromInt:sec];
}

- (NSNumber *)transmit:(NSString *)_transmit total:(NSString *)_total
{
    if (!_transmit || !_total) return [NSNumber numberWithFloat:0.0];
    long long tran,tot;
    [[NSScanner scannerWithString:_transmit] scanLongLong:&tran];
    [[NSScanner scannerWithString:_total] scanLongLong:&tot];
    return [NSNumber numberWithFloat:(float)tran/tot];
}

- (NSString *)throughput:(NSString *)_throughput elapsed:(NSString *)_elapsed
{
    if (!_throughput || !_elapsed) return @"";
    long long thr,elap;
    [[NSScanner scannerWithString:_throughput] scanLongLong:&thr];
    [[NSScanner scannerWithString:_elapsed] scanLongLong:&elap];
    return [NSString stringWithFormat:@"%.2f kB/s",(float)thr*1000/(elap*1024)];
}
    
- (NSString *)calcSize:(NSString *)size
{
    if (!size) return @"";
    long long s;
    [[NSScanner scannerWithString:size] scanLongLong:&s];
    if (s==0) return @"nothing";
    else if (s<1024) return @"0 B";
    else if (s<1048576) return [NSString stringWithFormat:@"%d kB",(int)(s/1024)];
    else if (s<1073741824) return [NSString stringWithFormat:@"%.2f MB",(s/1048576.0)];
    else return [NSString stringWithFormat:@"%.2f GB",(s/1073741824.0)];
}

// ADDDOWNLOAD, CHGDOWNLOAD, etc.
// is quite messed up right now, sorry ;)
// i changed it so that it doesn't rely anymore on duplicated data from CHGDOWNLOAD (size,start,total...). 
// this is only temporarily to ensure that poisoned works with a future version of gift,
// which doesn't include duplicated data anymore in CHGDOWNLOAD.
// - rizzi
- (void)ADDDOWNLOAD:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (![ticket intValue]) return;
    
    NSMutableDictionary *dict = [data objectAtIndex:2];
        
    [dict setObject:@"PExpandable" forKey:@"PExpandable"];
    [dict setObject:ticket forKey:@"PTicket"];
    [dict setObject:[iconShop iconForFileType:[[dict objectForKey:@"file"] pathExtension]] forKey:@"PIcon"];
    [dict setObject:[NSMutableArray arrayWithObjects:
        [NSNumber numberWithBool:YES],
        [dict objectForKey:@"file"],
        @"",nil]
        forKey:@"PFileUser"
    ];
    [dict setObject:[NSMutableArray arrayWithObjects:
                [NSNumber numberWithBool:YES],
                @"",
                [NSString stringWithFormat:@"of %@",[self calcSize:[dict objectForKey:@"size"]]],
            nil]
        forKey:@"PSize"];
        
    if ([[dict objectForKey:@"state"] isEqualToString:@"Paused"])
        [dict setObject:[NSNumber numberWithInt:PPAUSED] forKey:@"PStatus"];
    else
        [dict setObject:[NSNumber numberWithInt:PACTIVE] forKey:@"PStatus"];
    [dict setObject:[NSMutableArray array] forKey:@"PSources"];
    [dict setObject:[NSMutableDictionary dictionary] forKey:@"PSourcesDict"];
    
    [source addObject:dict];
    [tickets setObject:dict forKey:ticket];
    [table reloadData];
    [self CHGDOWNLOAD:data];

/* deactivate auto find more sources for this release (0.41), perhaps it's best to just drop this, because it looks like this will be implemented in giFT

    NSString *hash;
    if (hash=[dict objectForKey:@"hash"]) {
        // if the download is active we do a find more sources
        // this seems nice to have when you start up gift and old downloads get added
        if ([[dict objectForKey:@"PStatus"] intValue]==PACTIVE) {
            //NSLog(@"adddownload: find more sources");
            [self findMoreSources:hash];
        }
                
        //NSLog(@"fms: create timer");
        // create a timer for 'auto find more sources'
        NSTimer *fms_timer = [NSTimer
            scheduledTimerWithTimeInterval:1800	// 30 min
            target:self
            selector:@selector(findMoreSourcesTimer:)
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:ticket,@"ticket",nil]
            repeats:YES
        ];
        [timers setObject:fms_timer forKey:hash];
    }
*/
}


- (void)CHGDOWNLOAD:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (!ticket) return;
    
    NSMutableDictionary *item	= [tickets objectForKey:ticket];			// already saved item...
    NSNumber *_stateobj = [item objectForKey:@"PStatus"];
    int _state = 0;
    int importGood=0;
    if (_stateobj) _state=[_stateobj intValue];

    NSMutableDictionary *new	= [data objectAtIndex:2];
    NSMutableArray *sources	= [data objectAtIndex:3];
    //NSLog(@"%d",[sources count]);				// new sources...
    int i,sourcescount		= [sources count];
    
    NSString *state		= [new objectForKey:@"state"];
    
    NSString *tmpstring;
    
    if ([[item objectForKey:@"PStatus"] intValue] <= PCANCELLED) return;	// PCANCELLED OR PCOMPLETED
    
    //NSMutableArray *tmpsrc = [NSMutableArray array];
    //NSLog(@"%d",[tmpsrc count]);
    NSMutableDictionary *storedSource;
    NSMutableDictionary *updatedSource;
    NSMutableDictionary *sourcesDict = [item objectForKey:@"PSourcesDict"];
    for (i=0;i<sourcescount;i++) {
        updatedSource = [[sources objectAtIndex:i] objectAtIndex:2];
        storedSource  = [sourcesDict objectForKey:[updatedSource objectForKey:@"url"]];
        if ([updatedSource objectForKey:@"url"] && !storedSource) {
            [self ADDSOURCE:[NSArray arrayWithObjects:
                @"ADDSOURCE",
                ticket,
                updatedSource,
                nil]
            ];
        }
        if ([updatedSource objectForKey:@"total"]) {
            [storedSource setObject:[updatedSource objectForKey:@"total"] forKey:@"total"];
        }
    }

    if (sourcescount>0) {
        NSScanner *scanner = [NSScanner scannerWithString:[[[sources objectAtIndex:0] objectAtIndex:2] objectForKey:@"url"]];
        [scanner scanUpToString:@"://" intoString:&tmpstring];
        tmpstring = [tmpstring stringByAppendingString:@" - "];
    }
    else tmpstring=@"";
    [[item objectForKey:@"PFileUser"] replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@%@",tmpstring,[self stringForUsers:sourcescount]]];
    
    if ([state isEqualToString:@"Completed"])
	{ // clean up completed downloads...
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Completed",nil] forKey:@"PProgress"];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PTransfer"];
        [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:[item objectForKey:@"size"]]];
        [item setObject:[NSNumber numberWithInt:PCOMPLETED] forKey:@"PStatus"];
        for (i=0;i<sourcescount;i++) {
            updatedSource = [[sources objectAtIndex:i] objectAtIndex:2];
            storedSource  = [sourcesDict objectForKey:[updatedSource objectForKey:@"url"]];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PProgress"];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PTransfer"];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PSize"];
        }
        [table reloadItem:item reloadChildren:YES];
        
		PGiFTConf *gift_conf = [PGiFTConf singleton];
		[gift_conf read];
		// begin iTunes code
        if ([userDefaults boolForKey:@"PImportToiTunes"])
		{
			NSString *path = [gift_conf optionForKey:@"completed"];
			if (path)
			{
				NSString *fileName = [[item objectForKey:@"PFileUser"] objectAtIndex:1];
				path = [path stringByAppendingPathComponent:fileName];
				path = [path stringByStandardizingPath];
                                NSString *pathExtension = [[path pathExtension] lowercaseString];
				if ([pathExtension isEqualToString:@"mp3"] ||
					[pathExtension isEqualToString:@"wav"] ||
					[pathExtension isEqualToString:@"aac"] ||
					[pathExtension isEqualToString:@"aif"] ||
					[pathExtension isEqualToString:@"aiff"])
				{
					importGood=iTunesPlaylistImport([path fileSystemRepresentation], [userDefaults boolForKey:@"PImportToPlaylist"]);
					if (importGood && [userDefaults boolForKey:@"PPlayFile"]) 
						playsonginitunes([userDefaults boolForKey:@"PImportToPlaylist"], [userDefaults boolForKey:@"PNoFilePlayFile"]);
					if (importGood && [userDefaults boolForKey:@"PDeleteFile"])
					{
						if (unlink([path fileSystemRepresentation])==0)
							NSLog(@"deleting: %s", [path fileSystemRepresentation]);
						else
							NSLog(@"could not delete file: %s", [path fileSystemRepresentation]);
					}
				}
			}
        }
		// end iTunes code - jjt
		
		// notify the Finder and any other application using FNSubscribe API
		// that the download completed directory has changed - jjt
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[gift_conf optionForKey:@"completed"]];
		return;
    }
    else if ([state isEqualToString:@"Paused"]) {
        if (_state!=PRESUMING) { // if resuming... => don't display status as paused!!!
            [item setObject:[NSNumber numberWithInt:PPAUSED] forKey:@"PStatus"];
            [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Paused",nil] forKey:@"PProgress"];
        }
        if (tmpstring=[new objectForKey:@"transmit"])
            [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:tmpstring]];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PTransfer"];
        for (i=0;i<sourcescount;i++) {
            updatedSource = [[sources objectAtIndex:i] objectAtIndex:2];
            storedSource  = [sourcesDict objectForKey:[updatedSource objectForKey:@"url"]];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PProgress"];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PTransfer"];
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PSize"];
        }
        [table reloadItem:item reloadChildren:YES];
        return;
    }
    else {
        if (_state!=PPAUSING) [item setObject:[NSNumber numberWithInt:PACTIVE] forKey:@"PStatus"];
    }
    
    BOOL downloading=NO;
    for (i=0;i<sourcescount;i++) {
        updatedSource = [[sources objectAtIndex:i] objectAtIndex:2];
        storedSource  = [sourcesDict objectForKey:[updatedSource objectForKey:@"url"]];
        tmpstring = [updatedSource objectForKey:@"status"];
        if ([tmpstring isEqualToString:@"Active"]) {
            downloading=YES;
            [storedSource setObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:YES],
                    [self transmit:[updatedSource objectForKey:@"transmit"] total:[storedSource objectForKey:@"total"]],nil]
                forKey:@"PProgress"];
        }
        else {
            [storedSource setObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    tmpstring,nil]
                forKey:@"PProgress"];
        }
        
        if (tmpstring=[updatedSource objectForKey:@"transmit"]) {
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],
                    [NSString stringWithFormat:@"%@ of %@",[self calcSize:tmpstring],[self calcSize:[storedSource objectForKey:@"total"]]],nil]
                forKey:@"PSize"];
        }
        else {
            [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil] forKey:@"PSize"];
        }
        [storedSource setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil] forKey:@"PTransfer"];
    }
    NSString *transmit		= [new objectForKey:@"transmit"];
    [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:transmit]];
        
    if (_state==PPAUSING) ;
    else if (downloading) {
        NSString *size		= [item objectForKey:@"size"];
        NSString *transmit	= [new objectForKey:@"transmit"];
        NSString *throughput	= [new objectForKey:@"throughput"];
        NSString *elapsed	= [new objectForKey:@"elapsed"];
        
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES],[self transmit:transmit total:size],nil] forKey:@"PProgress"];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[self throughput:throughput elapsed:elapsed],[self remainingWithTotalSize:size transmit:transmit throughput:throughput elapsed:elapsed],nil]
            forKey:@"PTransfer"];
    }
    else {
        if ([[new objectForKey:@"state"] isEqualToString:@"Active"])
            [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Waiting",nil] forKey:@"PProgress"];
        else
            [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],[new objectForKey:@"state"],nil] forKey:@"PProgress"];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil]
            forKey:@"PTransfer"];
    }
    if (transmit) {
        [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:transmit]];
    }
    [table reloadItem:item reloadChildren:YES];
}


- (void)DELDOWNLOAD:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (!ticket) return;
    NSMutableDictionary *item = [tickets objectForKey:ticket];
    if (!item) return;
    
    NSString *hash;
    if (hash=[item objectForKey:@"hash"]) {
        //NSLog(@"fms: invalidate timer");
        // remove the timer from the timers dictionary
        [[timers objectForKey:hash] invalidate];
        [timers removeObjectForKey:hash];
    }
    
    if ([[item objectForKey:@"PStatus"] intValue] == PCOMPLETED) {
        if ([userDefaults boolForKey:@"PRemoveCompletedDownloads"]) {
            [source removeObject:[tickets objectForKey:ticket]];
            [tickets removeObjectForKey:tickets];
            [table reloadData];
            return;
        }
        else return;
    }
    
    if ([userDefaults boolForKey:@"PRemoveCancelledDownloads"]) {
        [source removeObject:[tickets objectForKey:ticket]];
        [tickets removeObjectForKey:tickets];
        [table reloadData];
        return;
    }
    else [self DEL:data];
}

- (void)DEL:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (!ticket) return;
    NSMutableDictionary *item = [tickets objectForKey:ticket];
    if ([[item objectForKey:@"PStatus"] intValue] == PCOMPLETED) return;
    // else download was cancelled...
    
    NSMutableArray *sources = [item objectForKey:@"PSources"];
    NSMutableDictionary *tmp;
    int i, count = [sources count];
    
    [item setObject:[NSNumber numberWithInt:PCANCELLED] forKey:@"PStatus"];
    [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Cancelled",nil] forKey:@"PProgress"];
    [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PTransfer"];
    [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PSize"];
    for (i=0;i<count;i++) {
        tmp = [sources objectAtIndex:i];
        [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PProgress"];
        [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PTransfer"];
        [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PSize"];
    }
    [table reloadItem:item reloadChildren:YES];
}

- (void)ADDSOURCE:(NSArray *)data
{
    NSString *ticket 		= [data objectAtIndex:1];
    NSMutableDictionary *new    = [data objectAtIndex:2];
    if (!ticket || !new) return;
    
    // getting the download where the source needs to be added
    NSMutableDictionary *item = [tickets objectForKey:ticket];
    if (!item) return;
    // the sources of the download
    NSMutableDictionary *sourcesDict = [item objectForKey:@"PSourcesDict"];
    NSMutableArray *sources = [item objectForKey:@"PSources"];
    if ([sourcesDict objectForKey:[new objectForKey:@"url"]]) return; // source already there
    
    [new setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[new objectForKey:@"user"],nil] forKey:@"PFileUser"];
    [new setObject:[item objectForKey:@"PTicket"] forKey:@"PTicket"];
    
    [sourcesDict setObject:new forKey:[new objectForKey:@"url"]];
    [[item objectForKey:@"PSources"] addObject:new];
    
    // users count
    NSString *tmpstring;
    int count = [sources count];
    if (count>0) {
        NSScanner *scanner = [NSScanner scannerWithString:[[sources objectAtIndex:0] objectForKey:@"url"]];
        [scanner scanUpToString:@"://" intoString:&tmpstring];
        tmpstring = [tmpstring stringByAppendingString:@" - "];
    }
    else tmpstring=@"";
    [[[tickets objectForKey:ticket] objectForKey:@"PFileUser"] replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@%@",tmpstring,[self stringForUsers:count]]];

    [table reloadItem:item reloadChildren:YES];
}

- (void)DELSOURCE:(NSArray *)data
{
    NSString *ticket	= [data objectAtIndex:1];
    NSString *url	= [[data objectAtIndex:2] objectForKey:@"url"];
    if (!ticket || !url) return;
    if (![tickets objectForKey:ticket])  return;
    NSMutableArray *sources = [[tickets objectForKey:ticket] objectForKey:@"PSources"];
    NSMutableDictionary *sourcesDict = [[tickets objectForKey:ticket] objectForKey:@"PSourcesDict"];
    int count = [sources count];

    NSString *tmpstring;
    if (count>0) {
        NSScanner *scanner = [NSScanner scannerWithString:[[sources objectAtIndex:0] objectForKey:@"url"]];
        [scanner scanUpToString:@"://" intoString:&tmpstring];
        tmpstring = [tmpstring stringByAppendingString:@" - "];
    }
    else tmpstring=@"";

    [sources removeObject:[sourcesDict objectForKey:url]];
    [sourcesDict removeObjectForKey:url];

    count = [sources count];
    [[[tickets objectForKey:ticket] objectForKey:@"PFileUser"] replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@%@",tmpstring,[self stringForUsers:count]]];

    [table reloadItem:[tickets objectForKey:ticket] reloadChildren:YES];
}

- (void)findMoreSourcesTimer:(NSTimer *)timer
{
    //NSLog(@"fms: fired");
    NSString *ticket = [[timer userInfo] objectForKey:@"ticket"];
    
    // only find more sources if the download is active
    if ([[[tickets objectForKey:ticket] objectForKey:@"PStatus"] intValue] != PACTIVE) return;
    
    [self findMoreSources:[[tickets objectForKey:ticket] objectForKey:@"hash"]];
}

- (void)findMoreSources:(NSString *)hash
{
    //NSLog(@"fms: send notification > %@",hash);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PFindMoreSources" object:self
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
            hash,@"hash",nil]];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if (item==nil) return [source objectAtIndex:index];
    else return [[item objectForKey:@"PSources"] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item objectForKey:@"PExpandable"]) return YES;
    else return NO;
    //return YES;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item==nil) return [source count];
    else return [[item objectForKey:@"PSources"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [item objectForKey:[tableColumn identifier]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    return NO;
    if (selectedColumn) [outlineView setIndicatorImage:nil inTableColumn:selectedColumn];
    if (selectedColumn==tableColumn) sortAscending=!sortAscending;
    else sortAscending=YES;
    selectedColumn = tableColumn;
    [outlineView setHighlightedTableColumn:tableColumn];
    
    if (sortAscending) {
        [outlineView setIndicatorImage:ascending inTableColumn:tableColumn];
    }
    else {
        [outlineView setIndicatorImage:descending inTableColumn:tableColumn];
    }
    [outlineView reloadData];
    return NO;
}

@end


 

