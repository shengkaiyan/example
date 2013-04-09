//
//  Database.h
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

extern NSString *DB_NAME;

@interface DB : NSObject {
	FMDatabase *fmdb;
}

@property (nonatomic, strong) FMDatabase *fmdb;

- (BOOL)initDatabase;
- (void)closeDatabase;
- (FMDatabase *)getDatabase;


- (NSMutableArray *)selectSql:(NSString *)sql;
- (long)insertSql:(NSString *)sql;
- (BOOL)updateSql:(NSString *)sql;
- (BOOL)deleteSql:(NSString *)sql;

@end
