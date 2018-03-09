//
//  SqliteInterface.m
//  CALayer
//
//  Created by Terry on 11-5-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SqliteInterface.h"


@implementation SqliteInterface

@synthesize  db;


+ (SqliteInterface *) sharedSqliteInterface
{
    
    static SqliteInterface *sharedSqliteInterface = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSqliteInterface = [[SqliteInterface alloc] init];
    });
    
    return sharedSqliteInterface;
}


- (void) connectDB
{
    
    
    NSString *dbRealPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"interface.db"];
    
    if (db == nil) {
        db = [[FMDatabase alloc] initWithPath:dbRealPath];
    }
    if (![db open]) {
        NSLog(@"Could not open database.");
    }else {
        [self initDBTable]; //初次安装应用
    }
    
    [db open];
    
    
}
- (void) closeDB
{
    if (db == nil) {
        return;
    }
    [db close];
    db= nil;
    NSLog(@"DataBase has already close");
}



-(BOOL)initDBTable{
    BOOL success = YES;
    
    BOOL result5 = [db executeUpdate:@"Create table if not exists UserState (ID text,login_state boolean,mute_state boolean,sync_state boolean,textbook_id text,course_id text,page_num integer,lockHand_state boolean)"];
    
    BOOL result7 = [db executeUpdate:@"Create table if not exists TeaRecord (ID text,name text,time_created double,exfc_id text,book_id text,user_id text,record_type integer,share_state boolean,meta text,page_num integer)"];
    success = result5 && result7;
    return success;
}




@end
