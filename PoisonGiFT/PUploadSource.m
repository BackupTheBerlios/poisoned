//
//  PUploadSource.m
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

#import "PUploadSource.h"


@implementation PUploadSource
- (id)initWithTable:(PTableView *)_table
{
    if (self = [super init]) {
        table = _table;
        

        ascending = [NSImage imageNamed:@"NSAscendingSortIndicator"];
        descending = [NSImage imageNamed:@"NSDescendingSortIndicator"];
        
        source 	= [[NSMutableArray alloc] init];
        tickets = [[NSMutableDictionary alloc] init];
        
        iconShop = [[PIconShop alloc] init];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)dealloc
{	
    [iconShop release];
    [source release];
    [tickets release];
    [super dealloc];
}

- (void)setCommander:(id)_giftCommander
{
    giftCommander = _giftCommander;
}

- (void)disconnected
{
    [tickets removeAllObjects];
    [source removeAllObjects];
    [table reloadData];
}

- (id)itemAtRow:(int)row
{
    return [source objectAtIndex:row];
}

- (BOOL)validateDelSource
{
/*    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    while (num=[enumerator nextObject]) {
        if ([[table itemAtRow:[num intValue]] objectForKey:@"PExpandable"]) return NO;
    }*/
    return YES;
}

- (BOOL)validateCancel
{
    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [source objectAtIndex:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || ([[tmp objectForKey:@"PStatus"] intValue]<=1) ) return NO;
    }
    return YES;
}

- (BOOL)validatePause
{
    /*if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || [[tmp objectForKey:@"PStatus"] intValue] != PACTIVE) return NO;
    }*/
    return YES;
}

- (BOOL)validateResume
{
/*    if ([table numberOfSelectedRows]<=0) return NO;
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"] || [[tmp objectForKey:@"PStatus"] intValue] != PPAUSED) return NO;
    }*/
    return YES;
}

- (void)deleteEvent:(id)sender
{
    // this array stores the tickets of the deleted downloads
    // so we don't have to delete their sources, if they are selected too
    NSMutableArray *deletedUploads = [[[NSMutableArray alloc] init] autorelease];
        
    // we store all commands in one string, and send it at once
    NSMutableString *tmpcmd = [[[NSMutableString alloc] initWithString:@""] autorelease];
    
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSMutableDictionary *item;
    while (num=[enumerator nextObject]) {
        item = [source objectAtIndex:[num intValue]];
        [deletedUploads addObject:[item objectForKey:@"PTicket"]];
        if ([[item objectForKey:@"PStatus"] intValue]>1) {
            [deletedUploads addObject:[item objectForKey:@"PTicket"]];
            [tmpcmd appendString:[NSString stringWithFormat:@";\nTRANSFER(%@) action(cancel)",[item objectForKey:@"PTicket"]]];
        }
    }
    
    // now we just have to remove the deleted uploads from the table
    NSString *ticket;
    int i, count = [deletedUploads count];
    for (i=0;i<count;i++) {
        ticket = [deletedUploads objectAtIndex:i];
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
        item = [source objectAtIndex:[num intValue]];
        [commander performSelector:@selector(cmd:) withObject:[NSString stringWithFormat:@"TRANSFER(%@) action(cancel)",[item objectForKey:@"PTicket"]]];
        [item setObject:[NSNumber numberWithInt:PCANCELLED] forKey:@"PStatus"];
        [item setObject:[NSMutableArray arrayWithObjects:
            [NSNumber numberWithBool:YES],
            [NSNumber numberWithBool:NO],
            @"Cancelling...",nil]
        forKey:@"PProgress"];
        [table reloadData];
    }
}

- (void)pause:(id)commander
{
   /* NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    while (num=[enumerator nextObject]) {
        [commander cmd:[NSString stringWithFormat:@"TRANSFER(%@) action(pause)",[[table itemAtRow:[num intValue]] objectForKey:@"PTicket"]]];
    }*/
}

- (void)resume:(id)commander
{
   /* NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    while (num=[enumerator nextObject]) {
        [commander cmd:[NSString stringWithFormat:@"TRANSFER(%@) action(unpause)",[[table itemAtRow:[num intValue]] objectForKey:@"PTicket"]]];
    }*/
}

- (void)delsource:(id)commander
{
    /*NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSNumber *num;
    NSDictionary *tmp;
    NSString *tmpcmd=@"";
    while (num=[enumerator nextObject]) {
        tmp = [table itemAtRow:[num intValue]];
        if (![tmp objectForKey:@"PExpandable"])
            tmpcmd = [tmpcmd stringByAppendingString:[NSString stringWithFormat:@"\n;DELSOURCE(%@) url(%@)",[tmp objectForKey:@"PTicket"],[tmp objectForKey:@"url"]]];
    }
    [commander cmd:[tmpcmd substringFromIndex:2]];*/
}

- (void)browsehost:(id)commander
{
    //[commander cmd:[table itemAtRow:[table selectedRow]]
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

/*- (void)expand
{
    int i, count=[source count];
    for (i=0;i<count;i++) [table expandItem:[source objectAtIndex:i]];
}

- (void)collapse
{
    int i, count=[source count];
    for (i=0;i<count;i++) [table collapseItem:[source objectAtIndex:i]];
}*/

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
    if (!_size || !_throughput || !_elapsed) return @"";
    long long s,tr,t,e;
    [[NSScanner scannerWithString:_size] scanLongLong:&s];
    [[NSScanner scannerWithString:_transmit] scanLongLong:&tr];
    [[NSScanner scannerWithString:_throughput] scanLongLong:&t];
    [[NSScanner scannerWithString:_elapsed] scanLongLong:&e];
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
    long long s;
    [[NSScanner scannerWithString:size] scanLongLong:&s];
    if (s==0) return @"nothing";
    else if (s<1024) return @"0 B";
    else if (s<1048576) return [NSString stringWithFormat:@"%d kB",(int)(s/1024)];
    else if (s<1073741824) return [NSString stringWithFormat:@"%.2f MB",(s/1048576.0)];
    else return [NSString stringWithFormat:@"%.2f GB",(s/1073741824.0)];
}


- (void)ADDUPLOAD:(NSArray *)data
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
    [dict setObject:[NSMutableDictionary dictionary] forKey:@"PSources"];
    
    [source addObject:dict];
    [tickets setObject:dict forKey:ticket];
    [table reloadData];
    [self CHGUPLOAD:data];
}

- (void)CHGUPLOAD:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (!ticket) return;
    
    NSMutableDictionary *item	= [tickets objectForKey:ticket];			// already saved item...
    
    NSMutableDictionary *new	= [data objectAtIndex:2];
    NSMutableArray *sources	= [data objectAtIndex:3];				// new sources...
    int i,sourcescount		= [sources count];
    
    NSString *state		= [new objectForKey:@"state"];
    
    NSMutableDictionary* tmp;
    NSString *tmpstring;
    
    if ([[item objectForKey:@"PStatus"] intValue] <= PCANCELLED) return;	// PCANCELLED OR PCOMPLETED
    
    NSMutableArray *tmpsrc = [NSMutableArray array];
    for (i=0;i<sourcescount;i++) {
        tmp = [[sources objectAtIndex:i] objectAtIndex:2];
        [tmp setObject:ticket forKey:@"PTicket"];
        [tmpsrc addObject:tmp];
    }
    [item setObject:tmpsrc forKey:@"PSources"];

    if (sourcescount>0) {
        NSScanner *scanner = [NSScanner scannerWithString:[[[sources objectAtIndex:0] objectAtIndex:2] objectForKey:@"url"]];
        [scanner scanUpToString:@"://" intoString:&tmpstring];
        tmpstring = [tmpstring stringByAppendingString:@" - "];
        [[item objectForKey:@"PFileUser"] replaceObjectAtIndex:2 withObject:
            [NSString stringWithFormat:@"%@%@",tmpstring,[[[sources objectAtIndex:0] objectAtIndex:2] objectForKey:@"user"]]];
    }
    

    if ([state isEqualToString:@"Completed"]) { // clean up completed downloads...
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Completed",nil] forKey:@"PProgress"];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PTransfer"];
        [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:[item objectForKey:@"size"]]];
        [item setObject:[NSNumber numberWithInt:PCOMPLETED] forKey:@"PStatus"];
        for (i=0;i<sourcescount;i++) {
            tmp = [[sources objectAtIndex:i] objectAtIndex:2];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[tmp objectForKey:@"user"],nil] forKey:@"PFileUser"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PProgress"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PTransfer"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PSize"];
        }
        [table reloadData];
        return;
    }
    else if ([state isEqualToString:@"Paused"]) {
        [item setObject:[NSNumber numberWithInt:PPAUSED] forKey:@"PStatus"];
        if (tmpstring=[new objectForKey:@"transmit"])
            [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:tmpstring]];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],@"",@"",nil] forKey:@"PTransfer"];
        [item setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO],@"Paused",nil] forKey:@"PProgress"];
        for (i=0;i<sourcescount;i++) {
            tmp = [[sources objectAtIndex:i] objectAtIndex:2];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[tmp objectForKey:@"user"],nil] forKey:@"PFileUser"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PProgress"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PTransfer"];
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil]
                forKey:@"PSize"];
        }
        [table reloadData];
        return;
    }
    else [item setObject:[NSNumber numberWithInt:PACTIVE] forKey:@"PStatus"];
    
    BOOL downloading=NO;
    for (i=0;i<sourcescount;i++) {
        tmp = [[sources objectAtIndex:i] objectAtIndex:2];
        tmpstring = [tmp objectForKey:@"status"];
        if ([tmpstring isEqualToString:@"Active"]) {
            downloading=YES;
            [tmp setObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:YES],
                    [self transmit:[tmp objectForKey:@"transmit"] total:[tmp objectForKey:@"total"]],nil]
                forKey:@"PProgress"];
        }
        else {
            [tmp setObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    tmpstring,nil]
                forKey:@"PProgress"];
        }
        
        if (tmpstring=[tmp objectForKey:@"transmit"]) {
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],
                    [NSString stringWithFormat:@"%@ of %@",[self calcSize:tmpstring],[self calcSize:[tmp objectForKey:@"total"]]],nil]
                forKey:@"PSize"];
        }
        else {
            [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil] forKey:@"PSize"];
        }
        [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],@"",nil] forKey:@"PTransfer"];
        [tmp setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO],[tmp objectForKey:@"user"],nil] forKey:@"PFileUser"];
    }
    NSString *transmit		= [new objectForKey:@"transmit"];
    [[item objectForKey:@"PSize"] replaceObjectAtIndex:1 withObject:[self calcSize:transmit]];
    if (downloading) {
        NSString *size		= [new objectForKey:@"size"];
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
        [table reloadData];
}


- (void)DELUPLOAD:(NSArray *)data
{
    NSString *ticket = [data objectAtIndex:1];
    if (!ticket) return;
    NSMutableDictionary *item = [tickets objectForKey:ticket];
    
    // it's possible that we already removed the upload from the table
    // if the user cancelled with delete key
    if (!item) return;
    
    if ([[item objectForKey:@"PStatus"] intValue] == PCOMPLETED) {
        if ([userDefaults boolForKey:@"PRemoveCompletedUploads"]) {
            [source removeObject:[tickets objectForKey:ticket]];
            [tickets removeObjectForKey:tickets];
            [table reloadData];
            return;
        }
        else return;
    }
    
    if ([userDefaults boolForKey:@"PRemoveCancelledUploads"]) {
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
        [table reloadData];
}

- (void)ADDSOURCE:(NSArray *)data
{
}

- (void)DELSOURCE:(NSArray *)data
{
    /*NSString *ticket	= [data objectAtIndex:1];
    NSString *url	= [[data objectAtIndex:2] objectForKey:@"url"];
    if (!ticket || !url) return;
    NSMutableArray *sources = [[tickets objectForKey:ticket] objectForKey:@"PSources"];
    int i, count = [sources count];
    for (i=0;i<count;i++) {
        if ([[[sources objectAtIndex:i] objectForKey:@"url"] isEqualToString:url]) {
            [sources removeObjectAtIndex:i];
        }
    }
    count = [sources count];
    [[[tickets objectForKey:ticket] objectForKey:@"PFileUser"] replaceObjectAtIndex:2 withObject:[self stringForUsers:count]];
    [table reloadData];*/
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [source count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [[source objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn
{
    return NO;
}

@end
