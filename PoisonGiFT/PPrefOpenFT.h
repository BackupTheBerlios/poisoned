//
// PPrefOpenFT.h
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

#import <Cocoa/Cocoa.h>
#import "POpenFTConf.h"

@interface PPrefOpenFT : NSObject
{
    IBOutlet NSTextField *alias;
    IBOutlet NSTextField *cacheSize;
    IBOutlet NSTextField *dbLocation;
    IBOutlet NSTextField *maxChilds;
    IBOutlet NSPopUpButton *nodeClass;
    IBOutlet NSButton *private_env;
    IBOutlet NSTabView *tabView;
    IBOutlet NSSlider *totalCacheSize;
    IBOutlet NSTextField *port;
    IBOutlet NSTextField *http_port;
    
    IBOutlet NSPanel *helpPanel;
    IBOutlet NSTextView *helpTextView;
        
    POpenFTConf *openft_conf;
}

- (void)readConfFiles;

- (void)disable;
- (void)enable;

- (void)displayHelp:(NSString *)file title:(NSString *)title;
- (IBAction)helpClasses:(id)sender;
- (IBAction)helpSEARCH:(id)sender;
- (IBAction)helpPorts:(id)sender;

- (IBAction)newAlias:(id)sender;

- (IBAction)newPort:(id)sender;
- (IBAction)newHTTP_port:(id)sender;

- (IBAction)newNodeClass:(id)sender;

// SEARCH node settings
- (IBAction)browseDBLocation:(id)sender;
- (IBAction)changeDBLocation:(id)sender;
- (IBAction)newMaxChilds:(id)sender;
- (IBAction)newPrivate:(id)sender;
- (IBAction)newTotalCacheSize:(id)sender;

@end
