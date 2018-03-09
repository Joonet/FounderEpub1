//
//  SqliteInterface.h
//  CALayer
//
//  Created by Terry on 11-5-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
//#import "FMDatabase.h"
#import <FMDB/FMDB.h>
//#import "FMDatabaseAdditions.h"

@class FMDatabase;
@interface SqliteInterface : NSObject {
    
    FMDatabase *db;
}

@property (nonatomic, retain) FMDatabase *db;
+(SqliteInterface *) sharedSqliteInterface;
- (void) connectDB;
- (void) closeDB;

@end
