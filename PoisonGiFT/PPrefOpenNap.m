//
//  PPrefOpenNap.m
//  PoisonGiFT
//
//  Created by Jay Ashton on Sun Sep 14 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PPrefOpenNap.h"
#import "POpenNapConf.h"

@implementation PPrefOpenNap
- (void)awakeFromNib
{
    [self readConfFiles];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

    /*if (randomAlias == 1) {
        [alias setState:NSOnState];
        [randomAlias setState:NSOnState];
    }
    else{
        [alias setState:NSOffState];
        [randomAlias setState:NSOnState];
    }*/

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [alias dealloc];
    [randomAlias dealloc];
    [port dealloc];
    [maxconn dealloc];
    [useNapigator dealloc];
    [napigatorIP dealloc];
    [super dealloc];
}


- (void)enable
{
    [alias setEnabled:YES];
    [randomAlias setEnabled:YES];
    [port setEnabled:YES];
    [maxconn setEnabled:YES];
    [useNapigator setEnabled:YES];
    [napigatorIP setEnabled:YES];
}

- (void)disable
{
    [alias setEnabled:NO];
    [randomAlias setEnabled:NO];
    [port setEnabled:NO];
    [maxconn setEnabled:NO];
    [useNapigator setEnabled:NO];
    [napigatorIP setEnabled:NO];
}

- (void)readConfFiles
{
    if (opennap_conf=[POpenNapConf singleton]) [self enable];
    else {
        [self disable];
        return;
    }

    [opennap_conf read];

    [alias setStringValue:[opennap_conf optionForKey:@"alias"]];

    [randomAlias setIntValue:[[opennap_conf optionForKey:@"random_alias"]intValue]];
    [port setIntValue:[[opennap_conf optionForKey:@"dataport"]intValue]];
    [maxconn setIntValue:[[opennap_conf optionForKey:@"max_connections"]intValue]];
    [useNapigator setIntValue:[[opennap_conf optionForKey:@"use_napigator"]intValue]];
    [napigatorIP setStringValue:[opennap_conf optionForKey:@"napigator_ip"]];

   

}

- (IBAction)newAlias:(id)sender
{
    //[opennap_conf setValue:[NSString stringWithFormat:@"\"%@\"",[sender stringValue] optionForKey:@"alias"]];

    [opennap_conf setValue:[sender stringValue] forKey:@"alias"];
    
    [self readConfFiles];
}

- (IBAction)randomAliasChanged:(id)sender
{
    if ([randomAlias state]==NSOnState)
    {
        [alias setEnabled:NO];
    }
    else
    {
        [alias setEnabled:YES];
    }

     [opennap_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"random_alias"];
    
    [self readConfFiles];
}

- (IBAction)portChanged:(id)sender
{
    [opennap_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"dataport"];
    [self readConfFiles];
}
- (IBAction)maxconnChanged:(id)sender
{
    [opennap_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"max_connections"];
    [self readConfFiles];
}
- (IBAction)useNapigatorChanged:(id)sender
{
    if ([useNapigator state]==NSOnState)
    {
        [napigatorIP setEnabled:NO];
    }
    else
    {
        [napigatorIP setEnabled:YES];
    }

    [opennap_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"use_napigator"];
    
    [self readConfFiles];
}
- (IBAction)napigatorIPChanged:(id)sender
{
    [opennap_conf setValue:[NSNumber numberWithInt:[sender intValue]] forKey:@"napigator_ip"];
    [self readConfFiles];
}

@end
