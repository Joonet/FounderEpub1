//
//  EpubMarkObject.m
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import "EpubMarkObject.h"



@implementation EpubMarkObject
@synthesize content;
@synthesize date;
@synthesize chapterIndex;
@synthesize markJsIndex;
@synthesize pageNumDic;
@synthesize markId;
@synthesize title;
@synthesize pageNum;
@synthesize bookPageNum;

-(id)init{
    if(self = [super init])
    {
        pageNumDic = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

- (NSComparisonResult)compare: (EpubMarkObject *)otherRecord
{
    NSNumber *number1 = [NSNumber numberWithInteger:self.bookPageNum];
    NSNumber *number2 = [NSNumber numberWithInteger:otherRecord.bookPageNum];
    
    NSComparisonResult result = [number1 compare:number2];
    
    return result == NSOrderedDescending; // 升序
    //    return result == NSOrderedAscending;  // 降序
}


@end

