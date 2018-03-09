//
//  TeaRecordDAO.h
//  E-Publishing
//
//  Created by 李 雷川 on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "TeaRecord.h"
#import "BaseDao.h"
@interface TeaRecordDAO : BaseDao
{
    BOOL updateFlag;
}
@property BOOL updateFlag;

//插入一条新产生的学习记录


-(BOOL)insertNewTeaRecord:(TeaRecord *)teaRecord;

//删除一条学习记录
-(BOOL)deleteCurTeaRecord:(NSString *)teaRecordID;

//更新一条学习记录
-(BOOL)updateCurTeaRecord:(TeaRecord *)teaRecord;

-(BOOL)updateCurTeaRecordWithID:(NSString *)recordID andName:(NSString *)recordName;

-(BOOL)isHasCurTeaRecord:(NSString *)recordID;

-(BOOL)deleteUserTeaRecord;

-(BOOL)clearTeaRecord;

//通过ID获取一条学习记录
-(TeaRecord *)getTeaRecordWithID:(NSString *)recordID;


//获得教材内 指定页所有的学习记录
-(NSMutableArray *)getCurPageTeacRecords:(NSInteger)pageNum andBookID:(NSString *)bookID;

//获得教材内所有的学习记录
-(NSMutableArray *)getCurPageTeacRecordsWithBookID:(NSString *)bookID;

//获得教材内 指定页指定类型的所有学习记录
-(NSMutableArray *)getCurPageTeacRecords:(NSInteger)pageNum andBookID:(NSString *)bookID andType:(NSInteger)type;

-(NSMutableArray *)getCurBookTeacRecordsWithBookID:(NSString *)bookID andType:(NSInteger)type;

//获取阅读进度相关记录
-(NSMutableArray *)getProcessRecords;


//*********************************************************************************************************
//1.录音组件、文本框组件产生的衍生书据
//获得组件只能保存一次的学习记录
-(TeaRecord *)getCurExfcTeacRecord:(NSString *)exfcID andBookID:(NSString *)bookID;

//获得组件能保存多次的学习记录
-(NSMutableArray *)getCurExfcTeacRecords:(NSString *)exfcID andBookID:(NSString *)bookID;
//*********************************************************************************************************





//获得组件或素材下的书签
//课程下素材书签，bookID为课程的ID; mediaID表示素材ID
//教材下组件书签，bookID为教材的ID; mediaID表示组件ID

-(TeaRecord *)getPageBookmarkWithBookID:(NSString *)bookID withNum:(NSInteger)pageNum ;

-(NSMutableArray *)getExfcOrMaterialBookmarks:(NSString *)mediaID withBookID:(NSString *)bookID;

//markType = 0 表示为课程下书签， bookID为课程的ID; 此时需要添加筛选条件pageNum = -1
//markType = 1 表示课程下素材书签，bookID为教材的ID; 此时需要添加筛选条件exfc = -1
-(NSMutableArray *)getPageBookmarksWithBookID:(NSString *)bookID;

//根据教材id，页码，类型，获得书签。
-(NSMutableArray *)getCurPageTeacRecordsWithRecordType:(NSInteger )recordType BookID:(NSString *)bookID andPageNum:(NSInteger )pageNum;
//书签结束
//*********************************************************************************************************

//得到本页的批注
-(NSMutableArray *)getCurPageEndorseRecords:(NSInteger)pageNum andBookID:(NSString *)bookID andType:(NSInteger)type;
@end
