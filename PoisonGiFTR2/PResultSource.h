//
//  PResultSource.h
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

#import <Foundation/Foundation.h>
#import "PAppKit.h"


@interface PResultSource : NSObject {

    NSMutableArray *source;	// contains all items
    NSMutableArray *filtered;	// filtered source
    NSArray *current_src;
    NSMutableDictionary *hashes;	// key is the hash, object value is the source item
    
    BOOL active;		// NO->search finished/stopped; YES->searching
    
    BOOL isFiltered;
    NSString *keyword;
    NSMutableArray *protos;
    int min_size;
    int max_size;
    double d_min_size;
    double d_max_size;
    
    PIconShop *icon_shop;
    
    NSMutableAttributedString *attr_users;
    
    SEL sorting_selector;
    NSTableColumn *selected_column;
    BOOL sortAscending;
    NSImage *ascending;
    NSImage *descending;
    
    NSImage *downloading;
    NSSet *downloading_hashes;
    POutlineView *table;
    
    BOOL hidden; // this is for find more sources
}

- (id)initWithHashes:(NSSet *)_hashes andTable:(POutlineView *)_table hidden:(BOOL)_hidden;

- (void)addItem:(NSArray *)data;
- (BOOL)matchesFilter:(NSDictionary *)item;

- (NSArray *)source;
- (NSArray *)selectedItems;
- (NSString *)r_count;

- (void)setActive:(BOOL)_active;
- (BOOL)active;
- (BOOL)hidden;

- (void)cleanUpTableHeaders;
- (void)setTableHeaders;

// Filter
- (void)setFiltered:(BOOL)_filter;
- (void)filter;
- (void)setKeywordFilter:(NSString *)_key;
- (void)setMinSizeFilter:(double)_min;
- (void)setMaxSizeFilter:(double)_max;
- (void)setProtoFilter:(NSMutableArray *)_protos;
- (void)filterProtos;

- (BOOL)isFiltered;
- (NSString *)keywordFilter;
- (double)minSizeFilter;
- (double)maxSizeFilter;
- (NSMutableArray *)protoFilter;

- (BOOL)matchesKeyword:(NSDictionary *)item;
- (BOOL)matchesProto:(NSDictionary *)item;
- (BOOL)matchesMinSize:(NSDictionary *)item;
- (BOOL)matchesMaxSize:(NSDictionary *)item;

@end
