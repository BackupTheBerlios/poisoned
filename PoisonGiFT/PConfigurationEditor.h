//
//  PConfigurationEditor.h
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


@interface PConfigurationEditor : NSObject {
    NSMutableDictionary *conf;
    NSMutableArray *lines;
    NSFileManager *file_manager;
        
    NSArray *int_confs;
    NSArray *string_confs;
    NSArray *colon_confs;
    NSArray *space_confs;
}

+ (NSString *)giFThome;
- (NSString *)path;

- (void)read;

- (NSString *)skipWhitespace:(NSString *)_line;
- (void)readConfLine:(int)index;

- (id)optionForKey:(NSString *)option;
- (void)setValue:(id)value forKey:(NSString *)key;

- (void)updateArrayForKey:(NSString *)key;

- (NSArray *)colonToArray:(NSString *)string;
- (NSArray *)spaceToArray:(NSString *)string;

@end
