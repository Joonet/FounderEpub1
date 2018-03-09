//
//  SearchResultObject.m
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import "SearchResultObject.h"


@implementation SearchResultObject
@synthesize text;
@synthesize left;
@synthesize top;
@synthesize startIndex;
@synthesize chapterIndex;
@synthesize pageNum;



- (NSComparisonResult)compare: (SearchResultObject *)otherRecord
{
    NSNumber *number1 = [NSNumber numberWithInteger:self.pageNum];
    NSNumber *number2 = [NSNumber numberWithInteger:otherRecord.pageNum];
    
    NSComparisonResult result = [number1 compare:number2];
    
    return result == NSOrderedDescending; // 升序
    //    return result == NSOrderedAscending;  // 降序
}


@end
