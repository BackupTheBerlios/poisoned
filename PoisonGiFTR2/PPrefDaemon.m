//
// PPrefDaemon.m
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

#import "PPrefDaemon.h"

@implementation PPrefDaemon

- (void)awakeFromNib
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self readConfFiles];


    //[path setStringValue:[userDefaults stringForKey:@"PGiFTPath"]];
    //[address setStringValue:[userDefaults stringForKey:@"PDaemonAddress"]];
    //[address setStringValue:@"127.0.0.1"];
    //[port setIntValue:[userDefaults integerForKey:@"PDaemonPort"]]; --> THIS IS NOW READ FROM gift.conf/ui.conf
    [timeout setIntValue:[userDefaults integerForKey:@"PConnectToDaemonTimeout"]];
    
    if ([userDefaults boolForKey:@"PStopGiFT"]) [stopGiFT setState:NSOnState];
    else [stopGiFT setState:NSOffState];
    if ([userDefaults boolForKey:@"PAutoConnect"]) [autoConnect setState:NSOnState];
    else [autoConnect setState:NSOffState];
    if ([userDefaults boolForKey:@"PAutoLaunch"]) [autoLaunch setState:NSOnState];
    else [autoLaunch setState:NSOffState];
    if ([userDefaults boolForKey:@"PRelaunchOnCrash"]) [relaunchOnCrash setState:NSOnState];
    else [relaunchOnCrash setState:NSOffState];

    if ([userDefaults boolForKey:@"PUseCustomDaemon"]) {
        [customDaemon setState:NSOnState];
        [path setStringValue:[userDefaults stringForKey:@"PGiFTPath"]];
        [path setEnabled:YES];
    }
    else {
        [customDaemon setState:NSOffState];
        [path setStringValue:@""];
        [path setEnabled:NO];
    }
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readConfFiles) name:@"PUpdateFromConfFiles" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)enable
{
    [port setEnabled:YES];
}

- (void)disable
{
    [port setEnabled:NO];
}

- (void)readConfFiles
{
    if (!gift_conf) gift_conf=[PGiFTConf singleton];
    if (!ui_conf) ui_conf = [PUIConf singleton];
    if ( (ui_conf = [PUIConf singleton]) && (gift_conf = [PGiFTConf singleton]) ) [self enable];
    else {
        [self disable];
        return;
    }

    [ui_conf read];
    [gift_conf read];
    
    [port setIntValue:[[ui_conf optionForKey:@"port"] intValue]];
    [address setStringValue:[ui_conf optionForKey:@"host"]];
}

- (IBAction)addressChanged:(id)sender
{
    /*NSString *a = [address stringValue];
    if ([a isEqualToString:@""]) {
        a = @"127.0.0.1";
        [address setStringValue:a];
    }
    [userDefaults setObject:[address stringValue] forKey:@"PDaemonAddress"];*/
}

- (IBAction)portChanged:(id)sender
{
    int p = [port intValue];
    if (p<=0) {
        p=1213;
        [port setIntValue:p];
    }
    [userDefaults setInteger:p forKey:@"PDaemonPort"];
    [gift_conf setValue:[NSNumber numberWithInt:p] forKey:@"client_port"];
    [ui_conf setValue:[NSNumber numberWithInt:p] forKey:@"port"];
    [self readConfFiles];
}

- (IBAction)pathChanged:(id)sender
{
    if (![userDefaults boolForKey:@"PUseCustomDaemon"]) return;
    [userDefaults setObject:[path stringValue] forKey:@"PGiFTPath"];
}

- (IBAction)stoppingPrefsChanged:(id)sender
{
    if ([stopGiFT state]==NSOnState) [userDefaults setBool:YES forKey:@"PStopGiFT"];
    else [userDefaults setBool:NO forKey:@"PStopGiFT"];
}

- (IBAction)timeoutChanged:(id)sender
{
    int to = [timeout intValue];
    if (to<=0) {
        [timeout setIntValue:3];
        to = 3;
    }
    else if (to>75) {
        [timeout setIntValue:75];
        to =75;
    }
    [userDefaults setInteger:to forKey:@"PConnectToDaemonTimeout"];
}

- (IBAction)autoLaunchPrefsChanged:(id)sender
{
    if ([autoLaunch state]==NSOnState) [userDefaults setBool:YES forKey:@"PAutoLaunch"];
    else [userDefaults setBool:NO forKey:@"PAutoLaunch"];
}

- (IBAction)autoConnectPrefsChanged:(id)sender
{
    if ([autoConnect state]==NSOnState) [userDefaults setBool:YES forKey:@"PAutoConnect"];
    else [userDefaults setBool:NO forKey:@"PAutoConnect"];
}

- (IBAction)relaunchOnCrashPrefsChanged:(id)sender
{
    if ([relaunchOnCrash state]==NSOnState) [userDefaults setBool:YES forKey:@"PRelaunchOnCrash"];
    else [userDefaults setBool:NO forKey:@"PRelaunchOnCrash"];
}

- (IBAction)customDaemonPrefsChanged:(id)sender
{
    if ([sender state]==NSOnState) {
        [userDefaults setBool:YES forKey:@"PUseCustomDaemon"];
        [path setEnabled:YES];
        [path setStringValue:[userDefaults stringForKey:@"PGiFTPath"]];
    }
    else {
        [userDefaults setBool:NO forKey:@"PUseCustomDaemon"];
        [path setStringValue:@""];
        [path setEnabled:NO];
    }
    [[NSNotificationCenter defaultCenter] // read from the conf files
        postNotificationName:@"PUpdateFromConfFiles" 
        object:self
        userInfo:nil
    ];
}

@end
