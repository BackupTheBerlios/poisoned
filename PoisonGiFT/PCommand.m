//
//  PCommand.m
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

#import "PCommand.h"

@interface PCommand(Private)
- (void)doConnected;
- (void)doConnectionTimedOut;
- (void)doDisconnected;
@end

@implementation PCommand

- (id)init
{
    if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] 
            addObserver:self 
            selector:@selector(command:) 
            name:@"PCommandNotification" 
            object:nil];
        ticketCenter = [[PTicketCenter alloc] init];
        ticketCenter = [[PTicketCenter alloc] init];
		
		[NetSocket ignoreBrokenPipes];
		socket = [[NetSocket alloc] init];
		[socket setDelegate:self];
		parser = [[PCParser alloc] init];
	}
    return self;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ticketCenter release];
    [parser release];
	[socket release];
    [super dealloc];
}

- (NSString *)getTicket
{
    return [ticketCenter get];
}

- (void)removeTicket:(NSString *)ticket
{
    if (ticket) [ticketCenter remove:ticket];
}

- (void)freeTicket:(NSString *)ticket
{
    if (ticket) [ticketCenter free:ticket];
}

- (void)registerController:(id)controller forCommands:(NSArray *)cmd
{
	[parser registerController:controller forCommands:cmd];
}

- (void)registerSearchController:(id)controller forCommands:(NSArray *)cmd
{
    [self registerController:controller forCommands:cmd];
}

- (BOOL)connect:(NSString *)address withPort:(int)port
{
	NSArray *args = [NSArray arrayWithObjects:address, [NSNumber numberWithInt:port], NULL];
	[NSThread detachNewThreadSelector:@selector(networkThread:) toTarget:self withObject:args];
	return YES;
}

- (void)networkThread:(NSArray *)inArgs
{
    // NSAutoreleasePool prevents these "just leaking" errors
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[socket open];
	[socket scheduleOnCurrentRunLoop];
	if ([socket connectToHost: [inArgs objectAtIndex:0]
		port:[[inArgs objectAtIndex:1] intValue]
		timeout:(NSTimeInterval)[[NSUserDefaults standardUserDefaults] integerForKey:@"PConnectToDaemonTimeout"]])
	{
		[[NSRunLoop currentRunLoop] run];
	}
	else
	{
		[self netsocketDisconnect:socket];
	}
    [pool release];
    return;
}

- (void)closeConnection
{
    [self cmd:@"DETACH"];
	[socket close];
	// closing a socket doesn't call the disconnect delegate method
	// so we do this manually right now
	[self netsocketDisconnected:socket];
}

- (BOOL)connected
{
	return [socket isConnected];
}

- (NSString *)prepare:(NSString *)arg
{
    NSMutableString *s = [NSMutableString stringWithString:arg];
    [s replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@";" withString:@"\\;" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"(" withString:@"\\(" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@")" withString:@"\\)" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"{" withString:@"\\{" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"}" withString:@"\\}" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"[" withString:@"\\[" options:nil range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"]" withString:@"\\]" options:nil range:NSMakeRange(0,[s length])];
    return s;
}

- (void)cmd:(NSString *)cmd
{
	// TODO: is this string encoding correct? - jjt
    [socket writeString:[cmd stringByAppendingString:@";\n"] encoding:NSASCIIStringEncoding];
}

- (void)command:(NSNotification *)notification
{
    NSString *cmd = [[notification userInfo] objectForKey:@"cmd"];
    [self cmd:cmd];
}

- (void)netsocketConnected:(NetSocket*)inNetSocket
{
	[self performSelectorOnMainThread:@selector(doConnected) withObject:NULL waitUntilDone:NO];
}

- (void)netsocket:(NetSocket*)inNetSocket connectionTimedOut:(NSTimeInterval)inTimeout
{
	[self performSelectorOnMainThread:@selector(doConnectionTimedOut) withObject:NULL waitUntilDone:NO];
}

- (void)netsocketDisconnected:(NetSocket*)inNetSocket
{
	[self performSelectorOnMainThread:@selector(doDisconnected) withObject:NULL waitUntilDone:NO];
}

- (void)netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount
{
	// TODO: fix this malloc stuff because it could leak memory if an exception occured - jjt
	char *buffer = malloc(inAmount + 1);
	[socket read:buffer amount:inAmount];
	buffer[inAmount] = 0;
	[parser processOutput:buffer];
	free(buffer);
}

- (void)doConnected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PoisonConnectedToCore" object:self];
}

- (void)doConnectionTimedOut
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PoisonConnectionTimedOut" object:self];
}

- (void)doDisconnected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PoisonConnectionClosed" object:self];
}

@end
