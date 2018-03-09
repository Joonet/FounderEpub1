//
//  BaseDao.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import "BaseDao.h"


@implementation BaseDao

@synthesize db;

-(id)init{
	if(self = [super init])
	{
		self.db = [[SqliteInterface sharedSqliteInterface] db];
	}
	
	return self;
}
	
-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
	return [NSString stringWithFormat:sql, table];
}


@end
