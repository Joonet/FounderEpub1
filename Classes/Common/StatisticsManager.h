//
//  StatisticsManager.h
//  EPUB
//
//  Created by YongjiSun on 2018/1/31.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BehaviorDefine.h"
#import "ReadingDefine.h"
@interface StatisticsManager : NSObject
+ (StatisticsManager *)sharedStatisticsManager;

-(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType;

-(NSDictionary *)getRecordInfoWithType:(ReadingRecordType)readingType;

-(BOOL)saveReadingRecord:(NSDictionary *)readingDic;

-(BOOL)saveReadingRecord:(NSDictionary *)readingDic pagenum:(NSInteger)pagenum;

-(NSDictionary *)getRecordInfoWithRecordID:(NSString *)recordID withReadingType:(ReadingRecordType)readingType;

-(BOOL)deleteReadingReocrdWithID:(NSString *)recordID
                        withType:(ReadingRecordType)readingType;

-(NSArray *)getCurBookRecordArrayWithType:(ReadingRecordType)readingType;

//! 存储阅读进度
-(BOOL)saveProcessInfoWithDic:(NSDictionary *)metaDic bookId:(NSString *)bookid;

//! 读取阅读进度
-(NSDictionary *)getPrecessInfoDicWithBookid:(NSString *)bookid;

-(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType page:(NSInteger)pagenum;



@end
