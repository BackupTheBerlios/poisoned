//
//  PCParser.m
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

#import "PCParser.h"
#import <string.h>
#import "libgift/libgift.h"
#import "GPacket.h"

@implementation PCParser

- (id)init
{
	if (self=[super init])
	{
		libgift_init("Poisoned", GLOG_STDERR, NULL);
		buffer=nil;
		dispatcher = [[PCDispatcher alloc] init];
	}
	return self;
}

- (void)dealloc
{
	libgift_finish();
    //[buffer release];
    [dispatcher release];
    [super dealloc];
}

// REGISTER FOR DISPATCHER...
- (void)registerController:(id)controller forCommands:(NSArray *)cmd
{
    [dispatcher registerController:controller forCommands:cmd];
    return;
}

// GETTING THE DATA
- (void)processOutput:(const char *)data
{
	if (data)
	{
		[dispatcher processOutput:[self parse:data]];
		
		// TEST CODE - jjt
		Interface *interface = interface_unserialize(data, strlen(data));
		if (interface)
		{
			GPacket *pkt = [GPacket packetWithInterface:interface];
			NSLog(@"GPacket command: %@", [pkt command]);
		}
		else
			NSLog(@"interface parse error");
	}
}

- (NSArray *)parse:(const char *)data
{
    NSMutableArray *result = [NSMutableArray array];
    int bufferlen=0;
    if (buffer) {
        bufferlen=[buffer cStringLength];
    }
    char *parsing = (char *)malloc((strlen(data)+bufferlen)*sizeof(char *));
    if (bufferlen) {
        strcpy(parsing,[buffer cString]);
        strcat(parsing,data);
    } else {
        strcpy(parsing,data);
    }
    if (buffer) {
        [buffer release];
        buffer=nil;
    }
    
    int len=strlen(parsing);
    int loc=0;
    
    parseindex=0;
    NSArray *parsed;
    globalfinished=NO;
    do {
        cmdfinished = NO;
        loc += parseindex;
        parseindex=0;
        parsed = [self parseCommand:&parsing[loc] withLength:strlen(&parsing[loc]) sub:NO];
        if (parsed) {
            [result addObject:parsed];
        }
    } while (cmdfinished && loc<len);
    if (!globalfinished && !parsed && loc<len) {
        buffer = [[NSString alloc] initWithCString:&parsing[loc]];
    }
    free(parsing);
    return result;
}

- (NSMutableArray *)parseCommand:(const char *)data withLength:(int)datalen sub:(BOOL)subComm
{
    int skip;
    char arg[4096];
    char key[128];
    NSString *keystring;
    NSString *argstring;
    int keyindex=0;
    NSMutableArray *sub;
    
    NSMutableArray *parsed = [[[NSMutableArray alloc] initWithObjects:
        @"",					// COMMAND
        @"",					// COMMAND ARGS
        [NSMutableDictionary dictionary],	// key->args
        [NSMutableArray array],			// SUBCOMMANDS
        nil] autorelease];
           
    BOOL matched;
    BOOL finished=NO;
    BOOL cmd=YES;
    int test;
    while (!finished && parseindex<datalen) {
        test=parseindex;
        // skip whitespace
        arg[0] = 0;
        key[0] = 0;
        skip = strspn(&data[parseindex],"\r\n ");
        if (skip>0) parseindex+=skip;
        keyindex=parseindex; // set keyindex to the beginning of the command, in case this is a subcommand...
        
        if (data[parseindex]==';') {
                finished = YES;
                cmdfinished=YES; // set global variable to true, since finished command parsing
                globalfinished=YES;
                parseindex++;
                skip = strspn(&data[parseindex],"\r\n ");
                if (skip>0) parseindex+=skip;
                return parsed;
        }
        else if (data[parseindex]=='}') {
                finished = YES;
                parseindex++;
                skip = strspn(&data[parseindex],"\r\n ");
                if (skip>0) parseindex+=skip;
                return parsed;
        }
        skip=0;
        parseindex--;
        while(skip<=0) {
            parseindex++;
            skip = strspn(&data[parseindex],"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789");
           // if (skip<=0) parseindex++;
            if (parseindex>=datalen) return nil;
        }
        strncpy(key,&data[parseindex],skip);
        key[skip]=0;
        parseindex+=skip;
        
        char current;
        int i;
        for (i=0;i<2;i++) {
        
            // skip whitespace
            if (subComm&&cmd) {
                skip = strspn(&data[parseindex],"\r\n {");
                if (skip>0) parseindex+=skip;
            }
            else {
                skip = strspn(&data[parseindex],"\r\n ");
                if (skip>0) parseindex+=skip;
            }
            // --------------
            
            current = 0;
            current = data[parseindex];

            matched=NO;
            
            // look for argument
            if (current=='(') {
                parseindex++;
                int ai=0;
                while (!matched && parseindex<datalen) {
                    switch (data[parseindex]) {
                        case '\\':	parseindex++;
                                        if (parseindex<datalen) arg[ai++]=data[parseindex++];
                                        break;
                        case ')':	parseindex++;
                                        matched=YES;
                                        break;
                        default:	arg[ai++]=data[parseindex++];
                                        break;
                    }
                }
                arg[ai]=0;
            }
            // look for subcommand
            else if (current=='{') {
                parseindex=keyindex;
                sub = nil;
                sub = [self parseCommand:data withLength:datalen sub:YES];
                if (sub) [[parsed objectAtIndex:3] addObject:sub];
                else return nil;
            }
            if (parseindex>=datalen) i=10;
            // save parsed key/arg to array...
            if (cmd && key[0]) {
                cmd=NO;
                [parsed replaceObjectAtIndex:0 withObject:[NSString stringWithCString:key]];
                if (arg[0]) [parsed replaceObjectAtIndex:1 withObject:[NSString stringWithCString:arg]];
            }
            /*else if (key[0] && arg[0]) {
                [[parsed objectAtIndex:2] setObject:[NSString stringWithCString:arg] forKey:[NSString stringWithCString:key]];
            }*/
            else {
            if (key[0] && arg[0]) {
                keystring = [NSString stringWithCString:key];
                //argstring = [NSString stringWithCString:arg];
                
                // when using NSISOLatin1StringEncoding also umlauts etc. get displayed correctly in the results
                // it still could be the wrong encoding, but it seems to work best so far
                // this means no problems for me so far - rizzi
                argstring = [[[NSString alloc] 
                    initWithData:[NSData dataWithBytes:arg length:strlen(arg)]
                    encoding:NSISOLatin1StringEncoding
                ] autorelease];
                
               [[parsed objectAtIndex:2] setObject:argstring forKey:keystring];
                if ([keystring isEqualToString:@"size"])
                    [[parsed objectAtIndex:2] setObject:[self calcSize:argstring] forKey:@"calcsize"];
                else if ([keystring isEqualToString:@"file"])
                    [[parsed objectAtIndex:2] setObject:[argstring lastPathComponent] forKey:@"file"];
                else if ([keystring isEqualToString:@"bitrate"]) {
                    int bitrate = [argstring intValue];
                    if (bitrate<10000)
                        [[parsed objectAtIndex:2] 
                            setObject:[NSString stringWithFormat:@"%d kbps",bitrate]
                            forKey:@"bitrate"];
                    else if (bitrate<999999)
                        [[parsed objectAtIndex:2] 
                            setObject:[NSString stringWithFormat:@"%d kbps",bitrate/1000]
                            forKey:@"bitrate"];
                    else [[parsed objectAtIndex:2] setObject:@"" forKey:@"bitrate"];
                }

            }
            }
            keystring=nil;
            argstring=nil;

            key[0]=0;
            arg[0]=0;
            // ---------------------------------
            
            skip = strspn(&data[parseindex],"\r\n ");
            if (skip>0) parseindex+=skip;
        }
        if (test==parseindex) { // this should not happen (but it does from time to time ;)
            parseindex++;
        }
    }
    return nil;
}

- (NSString *)calcSize:(NSString *)size
{
    if (!size) return @"";
    long long s;
    [[NSScanner scannerWithString:size] scanLongLong:&s];
    if (s<1024) return [NSString stringWithFormat:@"%d B",(int)s];
    else if (s<1048576) return [NSString stringWithFormat:@"%d kB",(int)(s/1024)];
    else if (s<1073741824) return [NSString stringWithFormat:@"%.2f MB",(s/1048576.0)];
    else return [NSString stringWithFormat:@"%.2f GB",(s/1073741824.0)];
}

@end
