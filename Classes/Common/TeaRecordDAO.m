//
//  TeaRecordDAO.m
//  E-Publishing
//
//  Created by 李 雷川 on 12-11-22.
//
//

#import "TeaRecordDAO.h"
//#import "ManageSycnFlow.h"
#import "UserInfo.h"
//#import "RecordSyncConstantDefine.h"
extern UserInfo *userInfo;
#define TABLE_NAME @"TeaRecord"

@implementation TeaRecordDAO
@synthesize updateFlag;

-(id)init{
	if(self = [super init])
	{
		updateFlag = YES;
	}
	
	return self;
}



//插入一条新产生的学习记录
-(BOOL)insertNewTeaRecord:(TeaRecord *)teaRecord{
    BOOL success = YES;
	[db executeUpdate:[self SQL:@"INSERT INTO %@ (ID,name,time_created,exfc_id,book_id,user_id,record_type,share_state,meta,page_num) VALUES (?,?,?,?,?,?,?,?,?,?)" inTable:TABLE_NAME],
     teaRecord.ID,
     teaRecord.name,
     [NSNumber numberWithDouble:[teaRecord.timeCreated timeIntervalSince1970]],
     teaRecord.exfcID,
     teaRecord.bookID,
     teaRecord.userID,
     [NSNumber numberWithInteger:teaRecord.recordType],
     [NSNumber numberWithInteger:teaRecord.shareState],
     teaRecord.meta,
     [NSNumber numberWithInteger:teaRecord.pageNum]];
    
    [self creatChangeFolderWithRecord:teaRecord];
    
    if ([db hadError]) {
		NSLog(@"Err%d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}

//删除一条学习记录
-(BOOL)deleteCurTeaRecord:(NSString *)teaRecordID{
    BOOL success = YES;
    if (updateFlag) {
        TeaRecord*teaRecord = [self getTeaRecordWithID:teaRecordID];
        double recordVersion = [teaRecord.timeCreated timeIntervalSince1970];
        NSString *stringVersion = [NSString stringWithFormat:@"%f",recordVersion];
//        ManageSycnFlow *manageflow = [ManageSycnFlow singleton];
        if(updateFlag)
        {
            if(teaRecord.shareState != 1)
            {
//                [manageflow creatDeleteJsonWithID:teaRecordID andTImeVersion:stringVersion];
            }
        }
    }
	[db executeUpdate:[self SQL:@"DELETE FROM %@ WHERE ID = ?" inTable:TABLE_NAME],teaRecordID];
    if ([db hadError])
    {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
    
    
    
    return success;
}

//更新一条学习记录
-(BOOL)updateCurTeaRecord:(TeaRecord *)teaRecord{
    BOOL success = YES;
    if(updateFlag == YES)
    {
        updateFlag = NO;
        [self deleteCurTeaRecord:teaRecord.ID];
        [self insertNewTeaRecord:teaRecord];
        updateFlag = YES;
    }
    else
    {
        [self deleteCurTeaRecord:teaRecord.ID];
        [self insertNewTeaRecord:teaRecord];
    }
    
    [self creatChangeFolderWithRecord:teaRecord];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        success = NO;
    }
	return success;
}
-(BOOL)updateCurTeaRecordWithID:(NSString *)recordID andName:(NSString *)recordName
{
    BOOL success = YES;
    NSLog(@"record is is %@ %@",recordID,recordName);
    TeaRecord *teaRecord =[self getTeaRecordWithID:recordID];
    teaRecord.name = [NSString stringWithString:recordName];
    teaRecord.timeCreated = [NSDate date];
    [self updateCurTeaRecord:teaRecord];
    
    [self creatChangeFolderWithRecord:teaRecord];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        success = NO;
    }
	return success;
}
-(BOOL)isHasCurTeaRecord:(NSString *)recordID{
    BOOL isHas = NO;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE ID = ?" inTable:TABLE_NAME],recordID];
	while ([rs next])
    {
        isHas = YES;
        break;
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
    return isHas;
}

-(BOOL)deleteUserTeaRecord{
    BOOL success = YES;
    [db executeUpdate:[self SQL:@"DELETE FROM %@" inTable:TABLE_NAME]];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
        
    }
    return success;
}

-(BOOL)clearTeaRecord{
    BOOL success = YES;
    [db executeUpdate:[self SQL:@"DELETE FROM %@ " inTable:TABLE_NAME]];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
        
    }
    return success;
}

-(TeaRecord *)getTeaRecordWithID:(NSString *)recordID
{
    TeaRecord *teaRecord  = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE ID = ?" inTable:TABLE_NAME],recordID];
	while ([rs next])
    {
        teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = [rs intForColumn:@"page_num"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = [rs stringForColumn:@"book_id"];
        teaRecord.userID = [rs stringForColumn:@"user_id"];
        teaRecord.meta = [rs stringForColumn:@"meta"];
        break;
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return teaRecord;
}

-(void)creatChangeFolderWithRecord:(TeaRecord *)record{
//    if (updateFlag) {
//        ManageSycnFlow *manageSyncFlow = [ManageSycnFlow singleton];
//        if(record.recordType != ReadingProcess)
//            [manageSyncFlow creatChangeFolderWithId:record.ID];
//        else
//             [manageSyncFlow creatProcessChangeFolderWithId:record.ID];
//    }
}

#pragma --mark--教材页码书签down
//--根据书签类型，教材和userID获得教材上面的页码的学习记录
-(NSMutableArray *)getCurPageTeacRecordsWithRecordType:(NSInteger )recordType BookID:(NSString *)bookID andPageNum:(NSInteger )pageNum
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE record_type = ? and book_id = ? and page_num = ?" inTable:TABLE_NAME],[NSNumber numberWithInteger:recordType],bookID,[NSNumber numberWithInteger:pageNum]];
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum =  [rs intForColumn:@"page_num"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
    
}

#pragma --mark--教材页码书签up

//判断当前显示页是否已经添加书签
-(TeaRecord *)getPageBookmarkWithBookID:(NSString *)bookID withNum:(NSInteger)pageNum{
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and page_num = ? and record_type = ? and exfc_id = -1" inTable:TABLE_NAME],bookID,[NSNumber numberWithInteger:pageNum],[NSNumber numberWithInteger:ReadingPageBookmark]];
    TeaRecord *teaRecord = nil;
	while ([rs next]) {
        teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum =  [rs intForColumn:@"page_num"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        break;
    }
    if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
    return teaRecord;
}

//获得组件只能保存一次的学习记录
-(TeaRecord *)getCurExfcTeacRecord:(NSString *)exfcID andBookID:(NSString *)bookID{
    TeaRecord *teaRecord  = nil;
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and exfc_id = ?" inTable:TABLE_NAME],bookID,exfcID];
	while ([rs next])
    {
        if (result == nil){
            result = [NSMutableArray arrayWithCapacity:0];
        }
        teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = [rs intForColumn:@"page_num"];
        teaRecord.exfcID = exfcID;
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
	}
    //如果数组里面的成员超过两个，那么就需要进行特殊处理保留最新的那个
    if(result.count  > 1)
    {
        double interVal = 0;
        for (NSInteger i = 0; i < result.count; i++) {
            TeaRecord *tempRecord = [result objectAtIndex:i];
            if(i == 0)
            {
                interVal = [tempRecord.timeCreated timeIntervalSince1970];
                teaRecord = tempRecord;
            }
            else
            {
                if([tempRecord.timeCreated timeIntervalSince1970] > interVal)
                {
                    interVal = [tempRecord.timeCreated timeIntervalSince1970];
                    [self deleteCurTeaRecord:teaRecord.ID];
                    teaRecord = tempRecord;
                }
                else
                {
                    [self deleteCurTeaRecord:tempRecord.ID];
                }
            }
        }
    }
    else if(result.count == 1)
    {
        teaRecord = [result objectAtIndex:0];
    }
    else
    {
        teaRecord = nil;
    }
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return teaRecord;
    
}


//获得组件能保存多次的学习记录
-(NSMutableArray *)getCurExfcTeacRecords:(NSString *)exfcID andBookID:(NSString *)bookID{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and exfc_id = ?" inTable:TABLE_NAME],bookID,exfcID];
	while ([rs next])
    {
        if (result == nil){
            result = [NSMutableArray arrayWithCapacity:0];
        }
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum = [rs intForColumn:@"page_num"];
        teaRecord.exfcID = exfcID;
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
    
}

-(NSMutableArray *)getCurPageTeacRecordsWithBookID:(NSString *)bookID
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? order by ABS(page_num)" inTable:TABLE_NAME],bookID];
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum =  [rs intForColumn:@"page_num"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
}
-(NSMutableArray *)getProcessRecords
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE record_type = ? order by ABS(page_num)" inTable:TABLE_NAME],[NSNumber numberWithInteger:ReadingProcess]];
    while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum =  [rs intForColumn:@"page_num"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = [rs stringForColumn:@"book_id"];
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];

    }
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [rs close];
    return result;
}

//获得教材内 指定页所有的学习记录
-(NSMutableArray *)getCurPageTeacRecords:(NSInteger)pageNum andBookID:(NSString *)bookID
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and page_num = ?" inTable:TABLE_NAME],bookID,[NSNumber numberWithInteger:pageNum]];
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.recordType = [rs intForColumn:@"record_type"];
        teaRecord.pageNum = pageNum;
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
        
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
    
}

//获得教材内 指定页指定类型的所有学习记录
-(NSMutableArray *)getCurPageTeacRecords:(NSInteger)pageNum andBookID:(NSString *)bookID andType:(NSInteger)type
{
    //    NSString *logString = [NSString stringWithFormat:@"bookid = %@,pagenum =%d,userid = %@,type = %d－－－－－－－－－－－－－－－－",bookID,pageNum,userID,type];
    //    NSLog(@"sql is %@",logString);
    //     NSLog(@"bookid = %@",bookID);
    //    NSLog(@"pagenum =%d",pageNum);
    //    NSLog(@"userid = %@",userID);
    //    NSLog(@"type = %d",type);
    
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and page_num = ? and record_type = ? order by ABS(share_state)" inTable:TABLE_NAME],bookID,[NSNumber numberWithInteger:pageNum],[NSNumber numberWithInteger:type]];
    
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = pageNum;
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.recordType = (ReadingRecordType)type;
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
        
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
}
-(NSMutableArray *)getCurBookTeacRecordsWithBookID:(NSString *)bookID andType:(NSInteger)type
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and record_type = ? order by ABS(time_created) desc" inTable:TABLE_NAME],bookID,[NSNumber numberWithInteger:type]];
    
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = [rs stringForColumn:@"page_num"].integerValue;
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.recordType = (ReadingRecordType)type;
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
        
	}
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
}
-(NSMutableArray *)getCurPageEndorseRecords:(NSInteger)pageNum andBookID:(NSString *)bookID andType:(NSInteger)type
{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and page_num = ? and record_type = ? order by ABS(share_state)" inTable:TABLE_NAME],bookID,[NSNumber numberWithInteger:pageNum],[NSNumber numberWithInteger:type]];
    
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
        TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = pageNum;
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.recordType = (ReadingRecordType)type;
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        if(teaRecord.shareState!=1)
            [result addObject:teaRecord];
	}
    if(type == ReadingEndorse)
    {
        if(result.count  > 1)
        {
            TeaRecord *teaRecord;
            double interVal = 0;
            for (NSInteger i = 0; i < result.count; i++) {
                TeaRecord *tempRecord = [result objectAtIndex:i];
                if(i == 0)
                {
                    interVal = [tempRecord.timeCreated timeIntervalSince1970];

                }
                else
                {
                    if([tempRecord.timeCreated timeIntervalSince1970] > interVal)
                    {
                        interVal = [tempRecord.timeCreated timeIntervalSince1970];
                        [self deleteCurTeaRecord:teaRecord.ID];
                
                    }
                    else
                    {
                        [self deleteCurTeaRecord:tempRecord.ID];
                    }
                }
            }
            if(result)
            {
                [result removeAllObjects];
                [result addObject:teaRecord];
            }
        }
        
        
    }
    if(result.count == 0)
    {
        result = nil;
    }
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
}



//获得所有书签
//获得组件或素材下的书签
//课程下素材书签，bookID为课程的ID; mediaID表示素材ID
//教材下组件书签，bookID为教材的ID; mediaID表示组件ID
-(NSMutableArray *)getExfcOrMaterialBookmarks:(NSString *)mediaID withBookID:(NSString *)bookID{
    NSMutableArray *result = nil;
    FMResultSet *rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and record_type = ? and exfc_id = ?" inTable:TABLE_NAME],bookID,[NSNumber numberWithInt:ReadingBookmark],mediaID];
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
		TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = [rs intForColumn:@"page_num"];
        teaRecord.bookID = bookID;
        teaRecord.recordType = ReadingBookmark;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
    }
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
	
}

-(NSMutableArray *)getPageBookmarksWithBookID:(NSString *)bookID{
    NSMutableArray *result = nil;
    FMResultSet *rs = nil;
    rs =[db executeQuery:[self SQL:@"SELECT * FROM %@ WHERE book_id = ? and record_type = ? order by page_num" inTable:TABLE_NAME],bookID,[NSNumber numberWithInt:ReadingPageBookmark]];
	while ([rs next])
    {
        if (result == nil)
            result = [NSMutableArray arrayWithCapacity:0];
		TeaRecord *teaRecord = [[TeaRecord alloc]init];
        teaRecord.ID= [rs stringForColumn:@"ID"];
        teaRecord.name = [rs stringForColumn:@"name"];
        teaRecord.exfcID = [rs stringForColumn:@"exfc_id"];
        teaRecord.timeCreated = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumn:@"time_created"]];
        teaRecord.shareState = [rs intForColumn:@"share_state"];
        teaRecord.pageNum = [rs intForColumn:@"page_num"];
        teaRecord.bookID = bookID;
        teaRecord.meta = [rs stringForColumn:@"meta"];
        [result addObject:teaRecord];
    }
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	[rs close];
	return result;
}

@end
