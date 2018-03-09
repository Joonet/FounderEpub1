//
//  ReadingStorage.m
//  E-Publishing
//
//  Created by 李 雷川 on 13-12-12.
//
//

#import "ReadingStorage.h"
#import "Catalog.h"
#import "UserInfo.h"
#import "UserState.h"
#import "TeaRecord.h"
#import "TeaRecordDAO.h"
#import "JSON.h"

extern UserInfo *userInfo;
@implementation ReadingStorage

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

+(BOOL)saveReadingRecord:(NSDictionary *)readingDic{
   return [self saveReadingRecord:readingDic pagenum:userInfo.userState.pageNum];
}
+(BOOL)saveReadingRecord:(NSDictionary *)readingDic bookID:(NSString*)bookid{
    return [self saveReadingRecord:readingDic pagenum:userInfo.userState.pageNum bookid:bookid];
}
+(BOOL)saveReadingRecord:(NSDictionary *)readingDic pagenum:(NSInteger)pagenum bookid:(NSString *)bookid{
    NSLog(@"readingDic is:%@",readingDic);
    BOOL success = NO;
    NSString  *recordID =  [readingDic objectForKey:@"recordID"];
    TeaRecordDAO *recordDao = [[TeaRecordDAO alloc]init];
    TeaRecord *newRecord = [recordDao getTeaRecordWithID:recordID];
    if(newRecord.shareState == 1)
        return YES;
    BOOL isUpdate = YES;
    if (!newRecord) {
        newRecord = [[TeaRecord alloc]init];
        isUpdate = NO;
        newRecord.timeCreated = [NSDate date];
        newRecord.bookID = bookid;
        newRecord.userID = userInfo.userID;
        newRecord.pageNum = pagenum;
        newRecord.ID = recordID;
    }
    ReadingRecordType type = (ReadingRecordType)[[readingDic objectForKey:@"type"]integerValue];
    newRecord.recordType = type;
    if ([readingDic objectForKey:@"name"]) {
        newRecord.name = [readingDic objectForKey:@"name"];
    }
    if ([readingDic objectForKey:@"meta"]) {
        NSDictionary *metaDic = [readingDic objectForKey:@"meta"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:metaDic];
        SBJSON *jsonPara = [[SBJSON alloc]init];
        [dic setValue:userInfo.name forKey:@"userName"];
        NSString *metaString = [jsonPara stringWithObject:dic];
        
        newRecord.meta = metaString;
        
    }
    else{
        NSDictionary *dic = @{@"userName":userInfo.name};
        SBJSON *jsonPara = [[SBJSON alloc]init];
        NSString *metaString = [jsonPara stringWithObject:dic];
        
        newRecord.meta = metaString;
    }
    switch (type) {
        case ReadingBookmark:{
            NSInteger subType = [[readingDic objectForKey:@"subType"]integerValue];
            if (subType == 1) {//组件组件
                newRecord.bookID = userInfo.userState.courseID;
            }
            NSString *mediaID = [readingDic objectForKey:@"exfcID"];
            newRecord.exfcID = mediaID;
        }
            break;
        case ReadingPageBookmark:{
            newRecord.exfcID = @"-1";
        }
            break;
        case ReadingNote:
            
        case ReadingCapture:
            break;
        case ReadingEndorse:{
            
        }
            break;
        case ReadingRecordEndorse:
            
            break;
        case ReadingResource:
            
            break;
        case ReadingKeyboard:{
        case ReadingHand:
        case ReadingRecorder:{
            newRecord.exfcID = [readingDic objectForKey:@"exfcID"];
            
        }
            break;
        default:
            break;
        }
    }
    
    if (isUpdate) {
        success = [recordDao updateCurTeaRecord:newRecord];
    }
    else{
        success = [recordDao insertNewTeaRecord:newRecord];
    }
    return success;
}

+(BOOL)saveReadingRecord:(NSDictionary *)readingDic pagenum:(NSInteger)pagenum{
    return [self saveReadingRecord:readingDic pagenum:pagenum bookid:userInfo.userState.textbookID];
}

+(NSArray *)getReadingRecordWithEid:(NSString *)eid
                    withReadingType:(ReadingRecordType)readingType{
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    NSArray *teaRecoredArr = nil;
    NSMutableArray *resultArr = nil;
    NSString *fileName = nil;
    NSString *exfcID = @"-1";
    switch (readingType) {
        case ReadingNote:{
            fileName = TEXTFRAME_FILE;
            teaRecoredArr = [teaRecordDAO getCurExfcTeacRecords:eid andBookID:userInfo.userState.textbookID];
        }
            break;
        case ReadingBookmark:{
            fileName = BOOKMARK_IMG;
            teaRecoredArr = [teaRecordDAO getExfcOrMaterialBookmarks:eid withBookID:userInfo.userState.textbookID];
        }
            break;
        case ReadingPageBookmark:{
            teaRecoredArr = [teaRecordDAO getPageBookmarksWithBookID:userInfo.userState.textbookID];
        }
            break;
        case ReadingCapture:
            
            break;
        case ReadingEndorse:
            
            break;
        case ReadingRecordEndorse:{
            
        }
            break;
        case ReadingResource:
            break;
        case ReadingKeyboard:{
            fileName = TEXTFRAME_FILE;
            teaRecoredArr = [teaRecordDAO getCurExfcTeacRecords:eid andBookID:userInfo.userState.textbookID];
        }
            break;
        case ReadingHand:{
            fileName = ENDORSE_SHAPES;
            teaRecoredArr = [teaRecordDAO getCurExfcTeacRecords:eid andBookID:userInfo.userState.textbookID];
        }
            break;
        case ReadingRecorder:{
            fileName = RECORD_AUDIO_FILENAME;
            teaRecoredArr = [teaRecordDAO getCurExfcTeacRecords:eid andBookID:userInfo.userState.textbookID];
        }
            break;
        default:
            break;
    }
    
    if (teaRecoredArr && teaRecoredArr.count > 0) {
        resultArr = [[NSMutableArray alloc]initWithCapacity:0];
        NSString *teaRecordPath = [Catalog getTeaRecordDirecotry];
        for (TeaRecord *teaRecored in teaRecoredArr) {
            NSString *fullFilePath = nil ;
            if (fileName) {
                fullFilePath = [[teaRecordPath stringByAppendingPathComponent:teaRecored.ID]stringByAppendingPathComponent:fileName];
                
            }
            else{
                fullFilePath = [teaRecordPath stringByAppendingPathComponent:teaRecored.ID];
                
            }
            if (!teaRecored.name) {
                teaRecored.name = @"无";
            }
            if (readingType == ReadingBookmark || readingType == ReadingRecorder || readingType == ReadingKeyboard || readingType == ReadingHand) {
                exfcID = teaRecored.exfcID;
            }
            
                 //meta json string 转化成nsdictionay
            NSString *meta =  teaRecored.meta ;
            NSData *metaData = [meta dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *metaDic = [NSJSONSerialization JSONObjectWithData:metaData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error];
            NSDictionary *recordDic = @{@"recordID":teaRecored.ID,@"filePath":fullFilePath,@"name":teaRecored.name,@"meta":metaDic,@"pageNum":[NSNumber numberWithInteger:teaRecored.pageNum],@"type":@(teaRecored.recordType),@"exfcID":exfcID};
            [resultArr addObject:recordDic];
        }
    }
    return  resultArr;
}


+(NSDictionary *)getCurPageBookMark{
    NSDictionary *recordDic =nil ;
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    TeaRecord *teaRecord = [teaRecordDAO getPageBookmarkWithBookID:userInfo.userState.textbookID withNum:userInfo.userState.pageNum];
    if (teaRecord) {
        recordDic =  @{@"recordID":teaRecord.ID,@"name":teaRecord.name,@"pageNum":[NSNumber numberWithInteger:teaRecord.pageNum]};
    }
    return recordDic;
}
+(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType pagenum:(NSInteger)pagenum
{
    NSDictionary *recordDic = nil;
    
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    NSMutableArray *recordArray = [teaRecordDAO getCurPageTeacRecordsWithRecordType:readingType BookID:userInfo.userState.textbookID andPageNum:pagenum];
    if(recordArray.count > 0)
    {
        TeaRecord *teaRecord = [recordArray objectAtIndex:0];
        if (teaRecord) {
            recordDic =  @{@"recordID":teaRecord.ID,@"name":teaRecord.name,@"pageNum":[NSNumber numberWithInteger:teaRecord.pageNum]};
        }
    }
    else
    {
        return nil;
    }
    return recordDic;
}

+(NSDictionary *)getCurPageBookRecordWithType:(ReadingRecordType)readingType{
    NSDictionary *recordDic = nil ;
    
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    NSMutableArray *recordArray = [teaRecordDAO getCurPageTeacRecordsWithRecordType:readingType BookID:userInfo.userState.textbookID andPageNum:userInfo.userState.pageNum];
    
    if(recordArray.count > 0)
    {
    TeaRecord *teaRecord = [recordArray objectAtIndex:0];
    if (teaRecord) {
        recordDic =  @{@"recordID":teaRecord.ID,@"name":teaRecord.name,@"pageNum":[NSNumber numberWithInteger:teaRecord.pageNum]};
    }
    }
    else
    {
        return nil;
    }
    return recordDic;
}
+(NSArray *)getCurBookRecordArrayWithType:(ReadingRecordType)readingType
{
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    NSMutableArray *recordArray = [teaRecordDAO getCurBookTeacRecordsWithBookID:userInfo.userState.textbookID andType:readingType];
    
    
    return recordArray;

}

+(NSArray *)getBookRecordArrayWithBookID:(NSString *)bookid
                                withType:(ReadingRecordType)readingType
{
    TeaRecordDAO *teaRecordDAO = [[TeaRecordDAO alloc]init];
    NSMutableArray *recordArray = [teaRecordDAO getCurBookTeacRecordsWithBookID:bookid andType:readingType];
    return recordArray;
}

+(NSDictionary *)getRecordInfoWithType:(ReadingRecordType)readingType{
    NSDictionary *dic = nil;
    NSString *recordID = [Catalog stringWithUUID:readingType];
    NSString *fullFilePath = [[Catalog getTeaRecordDirecotry]stringByAppendingPathComponent:recordID];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:fullFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = nil;
    switch (readingType) {
        case ReadingNote:
            fileName = NOTE_TEXT;
            break;
        case ReadingBookmark:
            fileName = BOOKMARK_IMG;
            break;
        case ReadingCapture:
            fileName = CAPTURE_BITMAPE;
            break;
        case ReadingEndorse:
            break;
        case ReadingRecordEndorse:
            
            break;
        case ReadingResource:
            break;
        case ReadingKeyboard:{
            fileName = TEXTFRAME_FILE;
        }
            break;
        case ReadingHand:{
            fileName = ENDORSE_SHAPES;
        }
            break;
        case ReadingRecorder:{
            fileName = RECORD_AUDIO_FILENAME;
        }
            break;
        default:
            break;
    }
    if (fileName) {
        fullFilePath = [fullFilePath stringByAppendingPathComponent:fileName];
    }
    dic = @{@"recordID":recordID,@"filePath":fullFilePath};
    return dic;
}

+(NSDictionary *)getRecordInfoWithRecordID:(NSString *)recordID
                           withReadingType:(ReadingRecordType)readingType{
    NSDictionary *dic = nil;
    NSString *fullFilePath = [[Catalog getTeaRecordDirecotry]stringByAppendingPathComponent:recordID];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:fullFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = nil;
    switch (readingType) {
        case ReadingNote:
            fileName = NOTE_TEXT;
            break;
        case ReadingBookmark:
            fileName = BOOKMARK_IMG;
            break;
        case ReadingCapture:
            fileName = CAPTURE_BITMAPE;
            break;
        case ReadingEndorse:
            break;
        case ReadingRecordEndorse:
            
            break;
        case ReadingResource:
            break;
        case ReadingKeyboard:{
            fileName = TEXTFRAME_FILE;
        }
            break;
        case ReadingHand:{
            fileName = ENDORSE_SHAPES;
        }
            break;
        case ReadingRecorder:{
            fileName = RECORD_AUDIO_FILENAME;
        }
            break;
        default:
            break;
    }
    if (fileName) {
        fullFilePath = [fullFilePath stringByAppendingPathComponent:fileName];
    }
    dic = @{@"recordID":recordID,@"filePath":fullFilePath};
    return dic;
    
}

+(BOOL)deleteReadingReocrdWithID:(NSString *)recordID
                        withType:(ReadingRecordType)readingType{
    TeaRecordDAO *recordDao = [[TeaRecordDAO alloc]init];
    BOOL success = [recordDao deleteCurTeaRecord:recordID];
    
    NSString *teaRecordPath = [Catalog getTeaRecordDirecotry];
    NSString *fullFilePath = nil;
    NSString *fileName = nil;
    switch (readingType) {
        case ReadingNote:
            fileName = NOTE_TEXT;
            break;
        case ReadingBookmark:
            fileName = BOOKMARK_IMG;
            break;
        case ReadingCapture:
            break;
        case ReadingEndorse:
            fileName = ENDORSE_SHAPES;
            break;
        case ReadingRecordEndorse:
            
            break;
        case ReadingResource:
            break;
        case ReadingKeyboard:
            fileName = TEXTFRAME_FILE;
            
            break;
        case ReadingHand:
            fileName = ENDORSE_SHAPES;
            
            break;
        case ReadingRecorder:{
            fileName = RECORD_AUDIO_FILENAME;
        }
            break;
        default:
            break;
    }
    if (fileName) {
        fullFilePath = [[teaRecordPath stringByAppendingPathComponent:recordID]stringByAppendingPathComponent:fileName];
        if (fullFilePath &&[[NSFileManager defaultManager]fileExistsAtPath:fullFilePath]) {
            [[NSFileManager defaultManager]removeItemAtPath:fullFilePath error:nil];
        }
    }
    return success;
}
@end
