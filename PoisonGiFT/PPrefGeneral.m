//
// PPrefGeneral.m
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

#import "PPrefGeneral.h"

#define AQUAFIED (NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask)
#define TEXTURED (NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask|NSTexturedBackgroundWindowMask)

@implementation PPrefGeneral

- (void)awakeFromNib
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults integerForKey:@"PAppearance"]==TEXTURED) [appearance selectItemAtIndex:1];
    else [appearance selectItemAtIndex:0];
    
    if ([userDefaults boolForKey:@"PAutoVersionCheck"]) [autoVersion setState:NSOnState];
    else [autoVersion setState:NSOffState];
}

- (IBAction)switchAppearance:(id)sender
{
    if ([appearance indexOfSelectedItem]==0) [userDefaults setInteger:AQUAFIED forKey:@"PAppearance"];
    else [userDefaults setInteger:TEXTURED forKey:@"PAppearance"];
    
    [prefWindow setFloatingPanel:YES];
    [[[NSApplication sharedApplication] delegate] switchAppearance:self];
    [prefWindow setFloatingPanel:NO];
    [prefWindow makeKeyAndOrderFront:self];
}

- (IBAction)autoVersionPrefsChanged:(id)sender
{
    if ([autoVersion state]==NSOnState) [userDefaults setBool:YES forKey:@"PAutoVersionCheck"];
    else [userDefaults setBool:NO forKey:@"PAutoVersionCheck"];
}

@end
