//
//  PSortedUploads.h
//  PoisonGiFTR2
//
//  Created by Julian Ashton on Sat Nov 08 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PUploadSource.h"

@interface PUploadSource (PSortedUploads)

- (void)insertObject:(NSArray *)dict source:(NSMutableArray *)source;

- (void)insertObjectAsc:(NSArray *)dict source:(NSMutableArray *)source;
- (void)insertObjectDesc:(NSArray *)dict source:(NSMutableArray *)source;

- (void)insertObjectAsc:(NSArray *)dict order:(int)order index:(int)current count:(int)tmpcount source:(NSMutableArray *)source;
- (void)insertObjectDesc:(NSArray *)dict order:(int)order index:(int)current count:(int)tmpcount source:(NSMutableArray *)source;


@end
