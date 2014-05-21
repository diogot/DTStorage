//
//  DTStorageTests.m
//  DTStorageTests
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DTSManager_Private.h"
#import "DTSObject_Private.h"
#import <FMDB.h>

@interface ObjectTest : DTSObject

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;

@end

@implementation ObjectTest

+ (NSDictionary *)propertiesTypes
{
    return @{@"string": @"NSString",
             @"number": @"NSNumber"};
}

+ (NSString *)tableName
{
    return @"stuff";
}

@end

@interface DTStorageTests : XCTestCase

@property (nonatomic, strong) DTSManager *manager;
@property (nonatomic, strong) NSString *dbPath;

@end


@implementation DTStorageTests

- (void)setUp
{
    [super setUp];

    self.dbPath = [NSTemporaryDirectory() stringByAppendingString:@"test.db"];
    [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
    
    self.manager = [DTSManager new];
    [self.manager addManagedClass:[ObjectTest class]];

    [self.manager openDataBaseAtPath:self.dbPath
                          withSchema:^(FMDatabase *db, int *schemaVersion) {
        [db beginTransaction];
        
        // My custom failure handling. Yours may vary.
        void (^failedAt)(int statement) = ^(int statement){
            int lastErrorCode = db.lastErrorCode;
            NSString *lastErrorMessage = db.lastErrorMessage;
            [db rollback];
            NSAssert3(0, @"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
        };
        
        if (*schemaVersion < 1) {
            if (! [db executeUpdate:
                   @"CREATE TABLE stuff ("
                   @" objectId INTEGER UNIQUE NOT NULL PRIMARY KEY AUTOINCREMENT,"
                   @" string   TEXT NOT NULL DEFAULT '',"
                   @" number   REAL"
                   @");"
                   ]) failedAt(1);
            
            *schemaVersion = 1;
        }
        [db commit];
    }];
}

- (void)tearDown
{
    [[NSFileManager defaultManager] removeItemAtPath:self.dbPath error:nil];
    
    [super tearDown];
}

- (void)testInit
{
    // DB file must exists
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath],@"");
    
    // DB should be at the right path and openned
    FMDatabase *db = self.manager.db;
    XCTAssertEqualObjects(self.manager.dbFilePath, self.dbPath, @"");
    XCTAssertEqualObjects([db databasePath], self.dbPath, @"");
    FMResultSet *rs = [db executeQuery:@"SELECT 'hello world'"];
    XCTAssertNotNil(rs, @"DB should be open");
    
    XCTAssertTrue([db columnExists:@"objectId" inTableWithName:@"stuff"], @"");
    XCTAssertTrue([db columnExists:@"string" inTableWithName:@"stuff"], @"");
    XCTAssertTrue([db columnExists:@"number" inTableWithName:@"stuff"], @"");
}

- (void)testClose
{
    DTSManager *dbManager = self.manager;
    XCTAssertNil([dbManager closeDataBase], @"");
    XCTAssertNil(dbManager.db, @"");
    XCTAssertNil(dbManager.dbFilePath, @"");
}

- (void)testDelete
{
    [self.manager deleteDataBase];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath],@"");
}

- (void)testInsert
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    
    XCTAssertNil(obj.objectId, @"");
    
    NSError *error = [self.manager insertObject:obj
                                          table:@"stuff"
                                     properties:[ObjectTest propertiesTypes]];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(obj.objectId, @(1), @"");
    
    FMResultSet *rs = [self.manager.db executeQuery:@"SELECT * FROM stuff"];
    int i;
    for (i=0; [rs next]; ++i) {
        XCTAssertEqual([rs columnCount], 3, @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"string"], @"bla", @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"number"], @(42), @"");
        XCTAssertEqual([rs intForColumn:@"objectId"], 1, @"");
    }
    XCTAssertEqual(i, 1, @"");
}

- (void)testUpdate
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    
    [self.manager insertObject:obj
                         table:@"stuff"
                    properties:[ObjectTest propertiesTypes]];
    
    obj.string = @"blablabla";
    
    [self.manager updateObject:obj
                         table:@"stuff"
                         where:@{@"objectId": obj.objectId}
                    properties:[ObjectTest propertiesTypes]];
    
    FMResultSet *rs = [self.manager.db executeQuery:@"SELECT * FROM stuff"];
    int i;
    for (i=0; [rs next]; ++i) {
        XCTAssertEqual([rs columnCount], 3, @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"string"], @"blablabla", @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"number"], @(42), @"");
        XCTAssertEqual([rs intForColumn:@"objectId"], 1, @"");
    }
    XCTAssertEqual(i, 1, @"");
}

- (void)testLoadObject
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    
    [self.manager insertObject:obj
                         table:@"stuff"
                    properties:[ObjectTest propertiesTypes]];
    
    
    ObjectTest *result;
    result = (ObjectTest *)[self.manager newObjectWithId:@(1)
                                             objectClass:[ObjectTest class]];
    XCTAssertNotNil(result, @"");
    XCTAssertEqualObjects(result.objectId, @(1), @"");
    XCTAssertEqualObjects(result.string, @"bla", @"");
    XCTAssertEqualObjects(result.number, @(42), @"");
}

- (void)testPublicSaveObject
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    
    XCTAssertNil(obj.objectId, @"");
    
    [self.manager saveObject:obj];
    
    XCTAssertEqualObjects(obj.objectId, @(1), @"");
    
    FMResultSet *rs = [self.manager.db executeQuery:@"SELECT * FROM stuff"];
    int i;
    for (i=0; [rs next]; ++i) {
        XCTAssertEqual([rs columnCount], 3, @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"string"], @"bla", @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"number"], @(42), @"");
        XCTAssertEqual([rs intForColumn:@"objectId"], 1, @"");
    }
    XCTAssertEqual(i, 1, @"");
}

- (void)testPublicSaveObject_update
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    
    XCTAssertNil(obj.objectId, @"");
    
    [self.manager saveObject:obj];
    
    obj.string = @"blablabla";
    
    [self.manager saveObject:obj];
    
    FMResultSet *rs = [self.manager.db executeQuery:@"SELECT * FROM stuff"];
    int i;
    for (i=0; [rs next]; ++i) {
        XCTAssertEqual([rs columnCount], 3, @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"string"], @"blablabla", @"");
        XCTAssertEqualObjects([rs objectForColumnName:@"number"], @(42), @"");
        XCTAssertEqual([rs intForColumn:@"objectId"], 1, @"");
    }
    XCTAssertEqual(i, 1, @"");
}

- (void)testPublicDeleteObject
{
    
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);

    [self.manager saveObject:obj];
    
    [self.manager deleteObject:obj];
    
    FMResultSet *rs = [self.manager.db executeQuery:@"SELECT * FROM stuff"];
    XCTAssertFalse([rs next], @"");
}

- (void)testPublicArrayWithIds
{
    ObjectTest *obj = [ObjectTest new];
    obj.string = @"bla";
    obj.number = @(42);
    [self.manager saveObject:obj];
    
    ObjectTest *obj2 = [ObjectTest new];
    obj2.string = @"bla2";
    obj2.number = @(43);
    [self.manager saveObject:obj2];
    
    NSArray *ids = [self.manager arrayWithIdsFromClass:[ObjectTest class]];
    
    XCTAssertEqual([ids count], 2, @"");
    XCTAssertEqualObjects(ids[0], @(1), @"");
    XCTAssertEqualObjects(ids[1], @(2), @"");
}
@end
