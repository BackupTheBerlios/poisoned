//
//  PResultSource.m
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

#import "PResultSource.h"
#import "PSortedSearchResults.h"


/// THIS NEEDS SOME OMPTIMIZING... -> next release
@implementation PResultSource

- (id)initWithHashes:(NSSet *)_hashes andTable:(POutlineView *)_table hidden:(BOOL)_hidden
{
    if (self=[super init]) {
        table = _table;
        downloading_hashes = _hashes;
    
        source = [[NSMutableArray alloc] init];
        filtered = [[NSMutableArray alloc] init];
        current_src = source;
        hashes = [[NSMutableDictionary alloc] init];

        sorting_selector = nil;
        selected_column = nil;
        ascending = [[NSImage imageNamed:@"NSAscendingSortIndicator"] retain];
        descending = [[NSImage imageNamed:@"NSDescendingSortIndicator"] retain];
        downloading = [[NSImage imageNamed:@"downloading.tiff"] retain];
        
        protos = nil;
        keyword = nil;
        min_size = 0;
        max_size = 625;
        d_min_size = 0.0;
        d_max_size = 25.0;
        
        isFiltered	= NO;

        active=YES;	// new search creates new PResultSource instance => serach is active.
        
        icon_shop = [[PIconShop alloc] init];
        
        attr_users = [[NSMutableAttributedString alloc] initWithString:@"666 Users" attributes:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [[NSFontManager sharedFontManager] fontWithFamily:[[NSFont systemFontOfSize:11] familyName] traits:NSBoldFontMask weight:9 size:11.0],NSFontAttributeName,
                nil
            ]
        ];
        hidden = _hidden;

    }
    return self;
}

- (void)dealloc
{
    if (protos) [protos release];
    [source release];
    [filtered release];
    [hashes release];
    [ascending release];
    [descending release];
    [downloading release];
    [attr_users release];
    [icon_shop release];
    if (keyword) [keyword release];
    [super dealloc];
}


// add new item to the results
// --------------------------------------------------------------------------------------------------
- (void)addItem:(NSArray *)data
{
    if (!data || !active) return;
    NSMutableDictionary *item	= [data objectAtIndex:2];

    NSString *user		= [item objectForKey:@"user"];
    NSString *hash		= [item objectForKey:@"hash"];
    NSArray *meta		= [data objectAtIndex:3];
    //if ( ([meta count]>0) && (bitrate=[[[meta objectAtIndex:0] objectAtIndex:2] objectForKey:@"bitrate"]) )
    //    [item setObject:bitrate forKey:@"bitrate"];
    //else [item setObject:@"" forKey:@"bitrate"];
    NSString *meta_str;
    if ([meta count]>0) {
        if (meta_str=[[[meta objectAtIndex:0] objectAtIndex:2] objectForKey:@"bitrate"])
            [item setObject:meta_str forKey:@"bitrate"];
        if (meta_str=[[[meta objectAtIndex:0] objectAtIndex:2] objectForKey:@"artist"])
            [item setObject:meta_str forKey:@"artist"];
        if (meta_str=[[[meta objectAtIndex:0] objectAtIndex:2] objectForKey:@"album"])
            [item setObject:meta_str forKey:@"album"];
    }
        
    
    
    NSMutableDictionary *sources = [hashes objectForKey:hash];
    if ([sources objectForKey:user]) {		// already found from this user
        return;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:[item objectForKey:@"url"]];
    NSString *proto;
    [scanner scanUpToString:@"://" intoString:&proto];

    [item setObject:proto forKey:@"PProto"];
    BOOL matchesFilter = [self matchesFilter:item];

    if (sources) { //------------------------------------- new source for existing file
        NSMutableArray *sourcesArray = [sources objectForKey:@"array"];
        int sourceCount = [sourcesArray count];
        NSMutableDictionary *parent;
        NSMutableDictionary *parent_copy;
        
        if (sourceCount==1) {				// we now have multiple sources -> needs some setup
            parent = [sourcesArray objectAtIndex:0];
            parent_copy = [[parent mutableCopy] autorelease];
            [parent removeObjectForKey:@"icon"];
            [parent removeObjectForKey:@"PProtoIcon"];
            [parent_copy setObject:[NSString stringWithString:@"expandable"] forKey:@"expandable"];
            [sources setObject:parent_copy forKey:@"parent"];
            [sourcesArray insertObject:parent_copy atIndex:0];
        }
        

        parent = [sourcesArray objectAtIndex:0];
        [sourcesArray addObject:item];
        [[attr_users mutableString] setString:[NSString stringWithFormat:@"%d Users",([sourcesArray count]-1)]];
        [parent setObject:[[attr_users copy] autorelease] forKey:@"user"];

        [sources setObject:item forKey:user];

        if (selected_column && [[selected_column identifier] isEqualToString:@"user"]) {
            [source removeObject:sourcesArray];
            [self insertObject:sourcesArray source:source];
            // totally forgot to check here if the filter matches, should be here, fixed now
            if (matchesFilter && isFiltered) {
                [filtered removeObject:sourcesArray];
                [self insertObject:sourcesArray source:filtered];
            }
        }
    }
    else { //--------------------------------------------  new file
        [item setObject:[icon_shop iconForProto:proto] forKey:@"PProtoIcon"];
        [item setObject:[icon_shop iconForFileType:[[item objectForKey:@"file"] pathExtension]] forKey:@"icon"];
        NSMutableArray *newFileArray = [NSMutableArray arrayWithObjects:item,nil];
        NSMutableDictionary *newFile = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            newFileArray,@"array",
            item,@"parent",
            item,user,
            nil];
        // we have to test for a hash here since there isn't always one
        // this fixes the bug where searching doesn't work anymore, after this happened
        if (hash) [hashes setObject:newFile forKey:hash];
        
        [sources setObject:item forKey:user];
        
        if (sorting_selector) {
            [self insertObject:newFileArray source:source];
            if (matchesFilter) [self insertObject:newFileArray source:filtered];
        }
        else {
            [source addObject:newFileArray];
            if (matchesFilter) [filtered addObject:newFileArray];
        }
    }
}

// --------------------------------------------------------------------------------------------------


- (NSArray *)source
{
    return current_src;
}

- (NSString *)r_count
{
    if (isFiltered) return [NSString stringWithFormat:@"%d of %d",[filtered count],[source count]];
    else return [NSString stringWithFormat:@"%d",[source count]];
}

- (NSArray *)selectedItems
{
    NSMutableArray *_items = [NSMutableArray array];
    NSEnumerator *enumerator = [table selectedRowEnumerator];
    NSDictionary *item;
    NSNumber *index;
    while (index = [enumerator nextObject]) {
        item = [table itemAtRow:[index intValue]];
        if ([table levelForItem:item]==0 && [item objectForKey:@"expandable"]) {
            NSArray *sources = [[hashes objectForKey:[item objectForKey:@"hash"]] objectForKey:@"array"];
            int i,count=[sources count];
            for (i=1;i<count;i++) {
                [_items addObject:[sources objectAtIndex:i]];
            }
        }
        else {
            [_items addObject:item];
        }
    }
    return _items;
}

- (void)setActive:(BOOL)_active
{
    active=_active;
}

- (BOOL)active
{
    return active;
}

- (BOOL)hidden
{
    return hidden;
}

- (void)cleanUpTableHeaders
{
    if (selected_column) {
        [table setHighlightedTableColumn:nil];
        [table setIndicatorImage:nil inTableColumn:selected_column];
    }
}

- (void)setTableHeaders
{
    if (selected_column) {
        [table setHighlightedTableColumn:selected_column];
        if (sortAscending) [table setIndicatorImage:ascending inTableColumn:selected_column];
        else [table setIndicatorImage:descending inTableColumn:selected_column];
    }
}

// Setting Filters...
// --------------------------------------------------------------------------------------------------

- (BOOL)matchesFilter:(NSDictionary *)item
{
    if (isFiltered) {
        if (![self matchesKeyword:item]) return NO;
        if (![self matchesMinSize:item]) return NO;
        if (![self matchesMaxSize:item]) return NO;
        if (![self matchesProto:item]) return NO;
        return YES;
    }
    else return NO;
}

- (void)setFiltered:(BOOL)_filter
{
    isFiltered = _filter;
    if (isFiltered) {
        [filtered removeAllObjects];
        current_src=filtered;
        [self filter];
    }
    else {
        current_src=source;
        [table reloadData];
    }
}

- (void)setKeywordFilter:(NSString *)_key
{
    keyword = [_key copy];
    [self filter];
}

- (void)setMinSizeFilter:(double)_min
{
    d_min_size=_min;
    min_size=(int)_min*(int)_min;
    [self filter];
}

- (void)setMaxSizeFilter:(double)_max
{
    d_max_size=_max;
    max_size=(int)_max*(int)_max;
    [self filter];
}

- (void)setProtoFilter:(NSMutableArray *)_protos
{
    if (protos) [protos autorelease];
    protos = [_protos mutableCopy];
}

- (void)filterProtos
{
    [self filter];
}
// --------------------------------------------------------------------------------------------------


// getting filters...
// --------------------------------------------------------------------------------------------------

- (BOOL)isFiltered
{
    return isFiltered;
}

- (void)filter
{
    int i, count=[source count];
    [filtered removeAllObjects];
    for (i=0;i<count;i++) {
        NSArray *item = [source objectAtIndex:i];
        if ([self matchesFilter:[item objectAtIndex:0]]) [filtered addObject:item];
    }
    [table reloadData];
}

- (NSString *)keywordFilter
{
    return keyword;
}

- (double)minSizeFilter
{
    return d_min_size;
}

- (double)maxSizeFilter
{
    return d_max_size;
}

- (NSMutableArray *)protoFilter
{
    return protos;
}

- (BOOL)matchesKeyword:(NSDictionary *)item
{
    if (!keyword || [keyword length]==0) return YES;
    if ([[item objectForKey:@"file"] rangeOfString:keyword options:NSCaseInsensitiveSearch].location==NSNotFound) return NO;
    else return YES;
}

- (BOOL)matchesProto:(NSDictionary *)item
{
    return [protos containsObject:[item objectForKey:@"PProto"]];
}

- (BOOL)matchesMinSize:(NSDictionary *)item
{	
    if (min_size==0) return YES;
    return ([[item objectForKey:@"size"] intValue]>=min_size*1024*1024);
}

- (BOOL)matchesMaxSize:(NSDictionary *)item
{
    if (max_size==625) return YES;
    else if (max_size==0)return NO;
    return ([[item objectForKey:@"size"] intValue]<=max_size*1024*1024);
}

// --------------------------------------------------------------------------------------------------

// outline view datasource for the results table...
// --------------------------------------------------------------------------------------------------
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if (item==nil) return [[current_src objectAtIndex:index] objectAtIndex:0];
    else return [[[hashes objectForKey:[item objectForKey:@"hash"]] objectForKey:@"array"] objectAtIndex:index+1];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item objectForKey:@"expandable"]) return YES;
    else return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item==nil) return [current_src count];
    else return [[[item objectForKey:@"user"] string] intValue];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ident = [tableColumn identifier];
    if ([ident isEqualToString:@"icon"]) {
        if ([outlineView levelForItem:item]==0) {
            if ([downloading_hashes containsObject:[item objectForKey:@"hash"]]) return downloading;
            else return [item objectForKey:ident];
        }
        else return nil;
    }
    return [item objectForKey:ident];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    NSString *ident = [tableColumn identifier];
    if (selected_column) [outlineView setIndicatorImage:nil inTableColumn:selected_column];
    if (selected_column==tableColumn) sortAscending=!sortAscending;
    else if ([ident isEqualToString:@"calcsize"] || [ident isEqualToString:@"user"] || [ident isEqualToString:@"bitrate"]) sortAscending=NO;
    else sortAscending=YES;
    selected_column = tableColumn;
    [outlineView setHighlightedTableColumn:tableColumn];
    
    NSMutableArray *source1=nil; 
    NSMutableArray *source2=nil; 
    if (isFiltered) { 		// process the displayed source first (hopefully)
        source1 = filtered;
        source2 = source;
    }
    else {
        source1 = source;
        source2 = filtered;
    }
    
    if (sortAscending) {
        [outlineView setIndicatorImage:ascending inTableColumn:tableColumn];
        sorting_selector = sel_getUid([
            [NSString stringWithFormat:@"%@Asc:",ident] cString]);
        [source1 sortUsingSelector:sorting_selector];
        [outlineView reloadData];
        if (source2) [source2 sortUsingSelector:sorting_selector];
    }
    else {
        [outlineView setIndicatorImage:descending inTableColumn:tableColumn];
        sorting_selector = sel_getUid([
            [NSString stringWithFormat:@"%@Desc:",ident] cString]);
        [source1 sortUsingSelector:sorting_selector];
        [outlineView reloadData];
        if (source2) [source2 sortUsingSelector:sorting_selector];
    }
    return NO;
}
// --------------------------------------------------------------------------------------------------

@end
