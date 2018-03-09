//
//  TeaRecord.m
//  E-Publishing
//
//  Created by 李 雷川 on 12-11-22.
//
//

#import "TeaRecord.h"

@implementation TeaRecord
@synthesize ID,name,timeCreated,recordType,bookID,pageNum,exfcID,shareState,userID,meta,teaRecordFilePath;
-(id)init{
    self = [super init];
    if ([super init]) {
        shareState = 0;
        pageNum = -1;
    }
    return self;
    
}

- (NSComparisonResult)compare: (TeaRecord *)otherRecord
{
    NSNumber *number1 = [NSNumber numberWithInteger:self.pageNum];
    NSNumber *number2 = [NSNumber numberWithInteger:otherRecord.pageNum];
    
    NSComparisonResult result = [number1 compare:number2];
    
    return result == NSOrderedDescending; // 升序
    //    return result == NSOrderedAscending;  // 降序
}


@end
