//
//  BaseDao.h
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//
//自定义对数据库的数据访问对象基类
//==============================================================================
//	姓名			    修改时间				内容
//	李雷川			2011/08/31			定义了初始化连接数据库和SQL语句的模板
//
//==============================================================================


#import <Foundation/Foundation.h>
#import "SqliteInterface.h"
@interface BaseDao : NSObject {
	FMDatabase *db;
	
}
@property(nonatomic, retain) FMDatabase *db;

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table;
@end
