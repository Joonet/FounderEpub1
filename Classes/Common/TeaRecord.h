//
//  TeaRecord.h
//  E-Publishing
//
//  Created by 李 雷川 on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "ReadingDefine.h"
@interface TeaRecord : NSObject{
    NSString    *ID;    //个人记录所产生的唯一id
    NSString    *name;  //个人记录的名称
    NSDate      *timeCreated; //个人记录的创建时间
    ReadingRecordType   recordType;  //个人记录的种类:99:便签;1:书签;2:截屏;3:批注；4：录屏；5:添加素材;21:录音组件;6:键盘文本框;22:手写文本框 8:epub笔记
    NSString    *bookID;    //教材id
    NSInteger   pageNum;    //教材页码
    
    NSString   *exfcID;     //组件id
    NSInteger   shareState; //分享状态
    NSString    *userID;    //用户id
    NSString    *meta;      //扩展字段，根据recordType的不同，存储相关的描述信息
    NSString    *teaRecordFilePath;
}
@property(nonatomic, retain)  NSString    *ID;    //个人记录所产生的唯一id
@property(nonatomic, retain)  NSString    *name;  //个人记录的名称
@property(nonatomic, retain)  NSDate      *timeCreated; //个人记录的创建时间
@property(nonatomic, assign)  ReadingRecordType   recordType;  //99:便签;1:书签;2:截屏;3:批注；4：录屏；5:添加素材;21:录音组件;6:键盘文本框;22:手写文本框件;
@property(nonatomic, retain)  NSString    *bookID;    //教材id
@property(nonatomic, assign)  NSInteger   pageNum;    //教材页码
@property(nonatomic, retain)  NSString   *exfcID;     //组件id
@property(nonatomic, assign)  NSInteger   shareState; //分享状态
@property(nonatomic, retain)  NSString    *userID;    //用户id
@property(nonatomic, retain)  NSString    *meta;      //扩展字段，根据recordType的不同，存储相关的描述信息
@property(nonatomic, retain)  NSString    *teaRecordFilePath;


@end
