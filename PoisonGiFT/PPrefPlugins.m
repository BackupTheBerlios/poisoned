//
//  PPrefPlugins.m
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


#import "PPrefPlugins.h"
#import "PGiFTConf.h"


@implementation PPrefPlugins
- (void)awakeFromNib
{
    [self readConfFiles];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (plugins) [plugins release];
    [super dealloc];
}

- (void)enable
{
    [buttonOpenFT setEnabled:YES];
    [buttonGnutella setEnabled:YES];
    [buttonFastTrack setEnabled:YES];
    [buttonOpenNap setEnabled:YES];
}

- (void)disable
{
    [buttonOpenFT setEnabled:NO];
    [buttonGnutella setEnabled:NO];
    [buttonFastTrack setEnabled:NO];
    [buttonOpenNap setEnabled:NO];
}

- (void)readConfFiles
{
    if (gift_conf=[PGiFTConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }

    [gift_conf read];

    plugins = [[NSMutableArray alloc] init];

    plugins = [[gift_conf optionForKey:@"plugins"] mutableCopy];

    if ([plugins containsObject:@"OpenFT"])
        [buttonOpenFT setState:NSOnState];
    if ([plugins containsObject:@"Gnutella"])
        [buttonGnutella setState:NSOnState];
    if ([plugins containsObject:@"FastTrack"])
        [buttonFastTrack setState:NSOnState];
    /* not till opennap works! - ashton */
    //if ([plugins containsObject:@"OpenNap"])
    //[buttonOpenNap setState:NSOnState];
    //if (plugins) [plugins autorelease];
        [buttonOpenNap setEnabled:NO]; /* until opennap works this remains - ashton */

     
    
}

- (IBAction)buttonOpenFTChanged:(id)sender
{

    if (![plugins containsObject:@"OpenFT"]) {
        [plugins addObject:@"OpenFT"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"OpenFT"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
        
}

- (IBAction)buttonGnutellaChanged:(id)sender
{

    if (![plugins containsObject:@"Gnutella"]) {
        [plugins addObject:@"Gnutella"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"Gnutella"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}

- (IBAction)buttonFastTrackChanged:(id)sender
{

    if (![plugins containsObject:@"FastTrack"]) {
        [plugins addObject:@"FastTrack"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"FastTrack"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}

- (IBAction)buttonOpenNapChanged:(id)sender
{

    if (![plugins containsObject:@"OpenNap"]) {
        [plugins addObject:@"OpenNap"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
    else
    {
        [plugins removeObject:@"OpenNap"];
        NSMutableArray *tmp = [plugins mutableCopy];
        [gift_conf setValue:tmp forKey:@"plugins"];
        [tmp autorelease];
    }
}
@end
