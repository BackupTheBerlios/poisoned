//
// PSearchFilterController.h
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

#import <Cocoa/Cocoa.h>
#import "PResultSource.h"

@interface PSearchFilterController: NSObject
{
    IBOutlet NSButton *collexp;
    IBOutlet NSButton *de_activate;
    IBOutlet NSTextField *info;
    IBOutlet NSTextField *keywordField;
    IBOutlet NSView *sizeFilter;
    IBOutlet NSSlider *maxSize;
    IBOutlet NSSlider *minSize;
    IBOutlet NSTextField *minText;
    IBOutlet NSTextField *maxText;
    IBOutlet NSTableView *protoTable;
    IBOutlet NSView *view;
    IBOutlet NSView *searches;
    
    NSMutableArray *protos;
    PResultSource *datasource;
    int view_height;
}

- (void)disconnected;

- (void)setUpView;
- (void)setValues;

- (void)setDataSource:(PResultSource *)_datasource;

- (void)setAvailableProtos:(NSNotification *)notification;

- (IBAction)collexp:(id)sender;
- (void)activate;
- (IBAction)de_activate:(id)sender;
- (IBAction)setKeyword:(id)sender;
- (IBAction)maxSizeChanged:(id)sender;
- (IBAction)minSizeChanged:(id)sender;
- (void)setProtos:(id)sender;

@end
