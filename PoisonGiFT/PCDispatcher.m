//
//  PCDispatcher.m
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

#import "PCDispatcher.h"


@implementation PCDispatcher

- (id)init
{
    if (self = [super init]) {
        controllers = [[NSMutableDictionary alloc] init];
        registered=0;
    }
    return self;
}

- (void)dealloc
{
    [controllers release];
    [super dealloc];
}


- (void)processOutput:(NSArray *)data
{
  if (data) {
    NSArray *parsed;
    NSString *cmd;
    id controller;
    
    int i,count=[data count];
    
    for (i=0;i<count;i++) {
        parsed=[data objectAtIndex:i];
        cmd = [parsed objectAtIndex:0];
        //NSLog(cmd);
        if (controller=[controllers objectForKey:cmd]) {
            [controller performSelector:sel_getUid([[cmd stringByAppendingString:@":"] cString]) withObject:parsed];
        }
        else {
            [[controllers objectForKey:@"REMOVE_UNKNOWN_COMMAND_TICKET"] performSelector:@selector(REMOVE_UNKNOWN_COMMAND_TICKET:) withObject:parsed];
        }
    }
    [[controllers objectForKey:@"POISON_GUI_UPDATE"] performSelector:@selector(POISON_GUI_UPDATE:) withObject:nil];
  }
  return;
}

- (void)registerController:(id)controller forCommands:(NSArray *)cmd
{
    int i, count=[cmd count];
    for (i=0;i<count;i++) {
        [controller performSelector:sel_getUid([[[cmd objectAtIndex:i] stringByAppendingString:@":"] cString]) withObject:nil]; // dummy, doesn't work otherwise, WHY ???
        [controllers setObject:controller forKey:[cmd objectAtIndex:i]];
    }
    registered++;
    if (registered==4) [[controllers objectForKey:@"P_DO_SETUP"] performSelector:@selector(P_DO_SETUP:) withObject:[NSNumber numberWithBool:YES]];
}

@end
