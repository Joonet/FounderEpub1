//
//  StatisticsManager.m
//  EPUB
//
//  Created by YongjiSun on 2018/1/31.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import "StatisticsManager.h"
#import "ReadingStorage.h"
#import "TeaRecord.h"
#import "JSON.h"

@implementation StatisticsManager
+ (StatisticsManager *)sharedStatisticsManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}

-(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType{
    
    return [ReadingStorage getCurPageBookRecordWithType:readingType];
}

-(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType page:(NSInteger)pagenum{
    
    return [ReadingStorage getCurPageBookRecordWithType:readingType pagenum:pagenum];
}

-(NSDictionary *)getRecordInfoWithType:(ReadingRecordType)readingType{
    return [ReadingStorage getRecordInfoWithType:readingType];
}

-(BOOL)saveReadingRecord:(NSDictionary *)readingDic{
    return [ReadingStorage saveReadingRecord:readingDic];
}

-(BOOL)saveReadingRecord:(NSDictionary *)readingDic pagenum:(NSInteger)pagenum{
    return [ReadingStorage saveReadingRecord:readingDic pagenum:pagenum];
}

-(NSDictionary *)getRecordInfoWithRecordID:(NSString *)recordID withReadingType:(ReadingRecordType)readingType{
    return [ReadingStorage getRecordInfoWithRecordID:recordID withReadingType:readingType];
}

-(BOOL)deleteReadingReocrdWithID:(NSString *)recordID
                        withType:(ReadingRecordType)readingType{
    return [ReadingStorage deleteReadingReocrdWithID:recordID withType:readingType];
}
-(NSArray *)getCurBookRecordArrayWithType:(ReadingRecordType)readingType{
    return [ReadingStorage getCurBookRecordArrayWithType:readingType];
}

//! 存储阅读进度
-(BOOL)saveProcessInfoWithDic:(NSDictionary*)metaDic bookId:(NSString *)bookid{
    NSString *recordID = nil;
    NSArray *recordArray = [ReadingStorage getBookRecordArrayWithBookID:bookid withType:ReadingProcess];
    if(recordArray.count >0)
    {
        TeaRecord *record = [recordArray objectAtIndex:0];
        recordID = record.ID;
    }
    else
    {
        NSDictionary *recordInfoDic = [ReadingStorage getRecordInfoWithType:ReadingProcess];
        recordID = [recordInfoDic objectForKey:@"recordID"];
    }
    NSDictionary *readingDic = @{@"recordID":recordID,@"type":[NSNumber numberWithInteger:ReadingProcess],@"meta":metaDic};
    return [ReadingStorage saveReadingRecord:readingDic bookID:bookid];
}

//! 读取阅读进度
-(NSDictionary *)getPrecessInfoDicWithBookid:(NSString *)bookid{
    NSArray *recordArray = [ReadingStorage getBookRecordArrayWithBookID:bookid withType:ReadingProcess];
    if(recordArray.count >0)
    {
        TeaRecord *record = [recordArray objectAtIndex:0];
        return record.meta.JSONValue;
    }
    return nil;
}



@end
