//
//  Database.m
//  SQLiteSample
//
//  Created by wang xuefeng on 10-12-29.
//  Copyright 2010 www.5yi.com. All rights reserved.
//

#import "DB.h"

NSString *DB_NAME = @"TestSqlite.sqlite";

@implementation DB
@synthesize fmdb;

- (BOOL)initDatabase
{
	BOOL success;
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent: DB_NAME];
	
	success = [fm fileExistsAtPath:writableDBPath];
	
	if(!success){
		NSString *defaultDBPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: DB_NAME];
		NSLog(@"%@",defaultDBPath);
		success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if(!success){
			NSLog(@"error: %@", [error localizedDescription]);
		}
		success = YES;
	}
	
	if(success){
		fmdb = [FMDatabase databaseWithPath:writableDBPath];
		if ([fmdb open]) {
			[fmdb setShouldCacheStatements:YES];
		}else{
			NSLog(@"Failed to open database.");
			success = NO;
		}
	}
	
	return success;
}


- (void)closeDatabase
{
	[fmdb close];
}


- (FMDatabase *)getDatabase
{
	if ([self initDatabase]){
		return fmdb;
	}
	
	return NULL;
}

- (NSMutableArray *)selectSql:(NSString *)sql
{
    FMResultSet *rs = [fmdb executeQuery: sql];
	
	return [rs resultArray];
}

- (long)insertSql:(NSString *)sql
{
    long localid = -1;
    
    BOOL result = [fmdb executeUpdate: sql];
    
    if (result)
    {
        localid =  [fmdb lastInsertRowId];
    }
    
    return localid;
}

- (BOOL)updateSql:(NSString *)sql
{
    return [fmdb executeUpdate: sql];
}

- (BOOL)deleteSql:(NSString *)sql
{
    return [fmdb executeUpdate: sql];
}

- (void)dealloc
{
	[self closeDatabase];
}

@end
