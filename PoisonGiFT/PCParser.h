//
//  PCParser.h
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

#import <Foundation/Foundation.h>
#import "PCDispatcher.h"

@interface PCParser : NSObject {
    
    NSString *buffer;
    
    // global position of the parser in the current data chunk...
    int parseindex;
    // command starts at index...
    int cmdindex;
    // if the parser successfully parsed a command is specified in...
    BOOL cmdfinished;
    BOOL globalfinished;
        
    // job done, dispatch the parsed data
    PCDispatcher *dispatcher;
    
    // custom autoreleasepool for parsing
    NSAutoreleasePool *pool;
}

- (void)registerController:(id)controller forCommands:(NSArray *)cmd;

- (void)processOutput:(const char *)data;
- (NSArray *)parse:(const char *)data;
- (NSMutableArray *)parseCommand:(const char *)data withLength:(int)datalen sub:(BOOL)subComm;

- (NSString *)calcSize:(NSString *)size;

@end
