//
//  PComparableDictionary.h
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


@interface NSArray (PComparableDictionary)

- (NSComparisonResult)iconAsc:(NSArray *)dict;
- (NSComparisonResult)iconDesc:(NSArray *)dict;

- (NSComparisonResult)fileAsc:(NSArray *)dict;
- (NSComparisonResult)fileDesc:(NSArray *)dict;

- (NSComparisonResult)artistAsc:(NSArray *)dict;
- (NSComparisonResult)artistDesc:(NSArray *)dict;

- (NSComparisonResult)albumAsc:(NSArray *)dict;
- (NSComparisonResult)albumDesc:(NSArray *)dict;

- (NSComparisonResult)userAsc:(NSArray *)dict;
- (NSComparisonResult)userDesc:(NSArray *)dict;

- (NSComparisonResult)calcsizeAsc:(NSArray *)dict;
- (NSComparisonResult)calcsizeDesc:(NSArray *)dict;

- (NSComparisonResult)bitrateAsc:(NSArray *)dict;
- (NSComparisonResult)bitrateDesc:(NSArray *)dict;

- (NSComparisonResult)PProtoIconAsc:(NSArray *)dict;
- (NSComparisonResult)PProtoIconDesc:(NSArray *)dict;

@end
