//
//  PSortedUploads.m
//  PoisonGiFTR2
//
//  Created by Julian Ashton on Sat Nov 08 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PSortedUploads.h"

@implementation PUploadSource (PSortedUploads)

- (void)insertObject:(NSArray *)dict source:(NSMutableArray *)_source
{
    if (YES) [self insertObjectAsc:dict source:_source];
    else [self insertObjectDesc:dict source:_source];
}

- (void)insertObjectAsc:(NSArray *)dict source:(NSMutableArray *)_source
{
    int tmpcount=[_source count];
    if (tmpcount==0) {
        [_source addObject:dict];
        return;
    }

    int start=0,current,end=tmpcount,order;
    BOOL inserted=NO;
    NSInvocation *sortingMethod = [NSInvocation invocationWithMethodSignature:[NSArray instanceMethodSignatureForSelector:sorting_selector]];

    while (!inserted) {
        current=(start+end)/2;

        [sortingMethod setSelector:sorting_selector];
        [sortingMethod setArgument:&dict atIndex:2];
        [sortingMethod invokeWithTarget:[_source objectAtIndex:current]];
        [sortingMethod getReturnValue:&order];
        
        if (current==start || current==end) {
            [self insertObjectAsc:dict order:order index:current count:tmpcount source:_source];
            return;
        }

        if (order == NSOrderedSame) {
            [self insertObjectAsc:dict order:order index:current count:tmpcount source:_source];
            return;
        }
        else if (order == NSOrderedAscending) {
            start=current;
        }
        else if (order == NSOrderedDescending) {
            end=current;
        }
    }
}

- (void)insertObjectDesc:(NSArray *)dict source:(NSMutableArray *)_source
{
    int tmpcount=[_source count];
    if (tmpcount==0) {
        [_source addObject:dict];
        return;
    }

    int start=tmpcount,current,end=0,order;
    BOOL inserted=NO;
    NSInvocation *sortingMethod = [NSInvocation invocationWithMethodSignature:[NSArray instanceMethodSignatureForSelector:sorting_selector]];

    while (!inserted) {
        current=(start+end)/2;

        [sortingMethod setSelector:sorting_selector];
        [sortingMethod setArgument:&dict atIndex:2];
        [sortingMethod invokeWithTarget:[_source objectAtIndex:current]];
        [sortingMethod getReturnValue:&order];
        
        if (current==start || current==end) {
            [self insertObjectDesc:dict order:order index:current count:tmpcount source:_source];
            return;
        }

        if (order == NSOrderedSame) {
            [self insertObjectDesc:dict order:order index:current count:tmpcount source:_source];
            return;
        }
        else if (order == NSOrderedDescending) {
            start=current;
        }
        else if (order == NSOrderedAscending) {
            end=current;
        }
    }
}

- (void)insertObjectAsc:(NSArray *)dict order:(int)order index:(int)current count:(int)tmpcount source:(NSMutableArray *)_source
{
    if (order==NSOrderedDescending) {
        if (current>0) [_source insertObject:dict atIndex:current-1];
        else [_source insertObject:dict atIndex:0];
    }
    else {
        if (current<tmpcount) {
            [_source insertObject:dict atIndex:current+1];
        }
        else [_source addObject:dict];
    }
}

- (void)insertObjectDesc:(NSArray *)dict order:(int)order index:(int)current count:(int)tmpcount source:(NSMutableArray *)_source
{
    if (order==NSOrderedDescending) {
        if (current>0) [_source insertObject:dict atIndex:current-1];
        else [_source insertObject:dict atIndex:0];
    }
    else {
        if (current<tmpcount) {
            [_source insertObject:dict atIndex:current+1];
        }
        else [_source addObject:dict];
    }
}
@end
