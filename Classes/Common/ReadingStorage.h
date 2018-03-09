//
//  ReadingStorage.h
//  E-Publishing
//
//  Created by 李 雷川 on 13-12-12.
//
//

#import <Foundation/Foundation.h>
#import "ReadingDefine.h"

@interface ReadingStorage : NSObject

+(BOOL)saveReadingRecord:(NSDictionary *)readingDic;
+(BOOL)saveReadingRecord:(NSDictionary *)readingDic pagenum:(NSInteger)pagenum;
+(BOOL)saveReadingRecord:(NSDictionary *)readingDic bookID:(NSString*)bookid;

+(NSArray *)getReadingRecordWithEid:(NSString *)eid
                    withReadingType:(ReadingRecordType)readingType;



+(NSDictionary *)getCurPageBookMark;

+(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType;
+(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType pagenum:(NSInteger)pagenum;


+(NSDictionary *)getRecordInfoWithType:(ReadingRecordType)readingType;

+(NSDictionary *)getRecordInfoWithRecordID:(NSString *)recordID
                           withReadingType:(ReadingRecordType)readingType;

+(BOOL)deleteReadingReocrdWithID:(NSString *)recordID
                        withType:(ReadingRecordType)readingType;
+(NSArray *)getCurBookRecordArrayWithType:(ReadingRecordType)readingType;
+(NSArray *)getBookRecordArrayWithBookID:(NSString *)bookid
                                withType:(ReadingRecordType)readingType;
@end
