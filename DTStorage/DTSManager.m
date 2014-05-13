//
//  DTSManager.m
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import "DTSManager_Private.h"
#import "DTSObject.h"
#import <FMDB.h>
#import <TTTArrayFormatter.h>

static NSString * const TableNameKey = @"TableName";
static NSString * const PropertiesKey = @"Properties";

typedef void (^SerializePropertyBlock)(NSString *property,
                                       id object,
                                       NSMutableDictionary *parameters);

typedef void (^DeserializePropertyBlock)(NSString *property,
                                         FMResultSet *rs,
                                         id object);

@interface DTSManager ()

@property (nonatomic, strong) TTTArrayFormatter *arrayFormatterComma;
@property (nonatomic, strong) TTTArrayFormatter *arrayFormatterAND;

@property (nonatomic, strong) NSDictionary *managedObjects;

@property (nonatomic, strong) NSDictionary *typesBlockIn;
@property (nonatomic, strong) NSDictionary *typesBlockOut;

@end


@implementation DTSManager

#pragma mark - NSObject

- (instancetype)init
{
    return [self initWithDbPath:@""];
}

#pragma mark - Public Methods

+ (instancetype)sharedManager
{
    static DTSManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)saveObject:(DTSObject *)object
{
    if (object == nil) {
        NSLog(@"Unable to save a nil object");
        return;
    }
    
    NSNumber *objectId = object.objectId;
    
    NSString *className = NSStringFromClass([object class]);
    NSDictionary *objectDetails = self.managedObjects[className];
    if ([objectDetails count] == 0) {
        NSLog(@"Unable to save an object of a class not managed");
        return;
    }
    
    NSString *tableName = objectDetails[TableNameKey];
    if ([tableName length] == 0) {
        NSLog(@"Unable to save an object that don't have a table name");
        return;
    }
    
    NSDictionary *properties = objectDetails[PropertiesKey];
    if ([properties count] == 0) {
        NSLog(@"Unable to save an object that don't have properties");
        return;
    }
    
    if (objectId) {
        NSDictionary *where = @{DTSObjectIdKey: objectId};
        NSError *error = [self updateObject:object
                                      table:tableName
                                      where:where
                                 properties:properties];
        if (error) {
            NSLog(@"%@", error);
        }
    } else {
        NSError *error = [self insertObject:object
                                      table:tableName
                                 properties:properties];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (id)newObjectWithId:(NSNumber *)objectId objectClass:(Class)class
{
    if (objectId == nil) {
        NSLog(@"Unable to load an object without objectId");
        return nil;
    }
    
    if (class == nil) {
        NSLog(@"Unable to load an object without the class");
        return nil;
    }
    
    NSString *className = NSStringFromClass(class);
    NSDictionary *objectDetails = self.managedObjects[className];
    if ([objectDetails count] == 0) {
        NSLog(@"Unable to load an object of a class not managed");
        return nil;
    }
    
    NSString *tableName = objectDetails[TableNameKey];
    if ([tableName length] == 0) {
        NSLog(@"Unable to load an object that don't have a table name");
        return nil;
    }
    
    NSDictionary *properties = objectDetails[PropertiesKey];
    if ([properties count] == 0) {
        NSLog(@"Unable to load an object that don't have properties");
        return nil;
    }
    
    NSString *query;
    query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = (?)",
             tableName, DTSObjectIdKey];
    
    id object = nil;
    
    FMResultSet *rs = [self.db executeQuery:query, objectId];
    
    if ([rs next]) {
        object = [self newObjectOfClass:class
                                withRow:rs
                             properties:properties];
        [object setValue:objectId forKey:DTSObjectIdKey];
    }
    
    if (object == nil) {
        NSLog(@"Object %@ with %@ = %@ not found",
               className, DTSObjectIdKey, objectId);
    }
    
    return object;
}

- (void)deleteObject:(DTSObject *)object
{
    if (object == nil) {
        NSLog(@"Unable to delete a nil object");
        return;
    }
    
    NSString *className = NSStringFromClass([object class]);
    
    NSDictionary *objectDetails = self.managedObjects[className];
    if ([objectDetails count] == 0) {
        NSLog(@"Unable to delete an object of a class not managed");
        return;
    }
    
    NSString *tableName = objectDetails[TableNameKey];
    if ([tableName length] == 0) {
        NSLog(@"Unable to delete an object that don't have a table name");
        return;
    }
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = (?)",
                       tableName, DTSObjectIdKey];
    
    NSNumber *objectId = object.objectId;
    
    BOOL ok = [self.db executeUpdate:query, objectId];
    
    if (!ok) {
        NSLog(@"%@", [self.db lastError]);
    }
}

- (NSArray *)arrayWithIdsFromClass:(Class)class
{
    if (class == nil) {
        NSLog(@"Unable to load indexes without the class");
        return nil;
    }
    
    NSString *className = NSStringFromClass(class);
    NSDictionary *objectDetails = self.managedObjects[className];
    if ([objectDetails count] == 0) {
        NSLog(@"Unable to load indexes of a class not managed");
        return nil;
    }
    
    NSString *tableName = objectDetails[TableNameKey];
    if ([tableName length] == 0) {
        NSLog(@"Unable to load indexes that don't have a table name");
        return nil;
    }
    
    NSMutableArray *array = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",
                       tableName];
    FMResultSet *rs = [self.db executeQuery:query];
    
    NSInteger count = 0;
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    array = [NSMutableArray arrayWithCapacity:count];
    
    query = [NSString stringWithFormat:@"SELECT %@ FROM %@",
             DTSObjectIdKey, tableName];
    
    rs = [self.db executeQuery:query];
    while ([rs next]) {
        [array addObject:[rs objectForColumnName:DTSObjectIdKey]];
    }
    
    return [array count] ? array : nil;
}

#pragma mark - Private Methods

- (instancetype)initWithDbPath:(NSString *)dbFilePath
{
#warning TODO
    NSDictionary *managedObjects = @{@"bla": [DTSObject class]};
    
    
    //      Support to custom properties
    SerializePropertyBlock dateSerialize;
    dateSerialize = ^void(NSString *property,
                          id object,
                          NSMutableDictionary *parameters){
        NSDate *date = [object valueForKey:property];
        if (date) {
            [parameters setObject:@([date timeIntervalSince1970])
                           forKey:property];
        }
    };
    
    SerializePropertyBlock nsURLSerialize;
    nsURLSerialize = ^void(NSString *property,
                           id object,
                           NSMutableDictionary *parameters){
        NSURL *url = [object valueForKey:property];
        if (url) {
            [parameters setObject:[url absoluteString] forKey:property];
        }
    };
    
    NSDictionary *typesBlockIn;
    typesBlockIn = @{@"NSDate": [dateSerialize copy],
                     @"NSURL": [nsURLSerialize copy]};
    
    
    DeserializePropertyBlock dateDeserialize;
    dateDeserialize = ^void(NSString *property,
                            FMResultSet *rs,
                            id object) {
        if ([rs columnIsNull:property] == NO) {
            id value = [rs dateForColumn:property];
            [object setValue:value forKey:property];
        }
    };
    
    DeserializePropertyBlock nsURLDeserialize;
    nsURLDeserialize = ^void(NSString *property,
                             FMResultSet *rs,
                             id object) {
        if ([rs columnIsNull:property] == NO) {
            NSURL *url = [NSURL URLWithString:[rs stringForColumn:property]];
            if (url) {
                [object setValue:url forKeyPath:property];
            }
        }
    };
    
    NSDictionary *typesBlockOut;
    typesBlockOut = @{@"NSDate": [dateDeserialize copy],
                      @"NSURL": [nsURLDeserialize copy]};
    
    return [self initWithDBPath:dbFilePath
                 managedObjects:managedObjects
       customTypesSerialization:typesBlockIn
     customTypesDeserialization:typesBlockOut];
}

- (instancetype)initWithDBPath:(NSString *)dbFilePath
                managedObjects:(NSDictionary *)managedObjects
      customTypesSerialization:(NSDictionary *)typesSerializations
    customTypesDeserialization:(NSDictionary *)typesDeserializations
{
    self = [super init];
    
    if (self) {
        _arrayFormatterComma = [TTTArrayFormatter new];
        _arrayFormatterComma.arrayStyle = TTTArrayFormatterDataStyle;
        _arrayFormatterComma.separator = @" ";
        _arrayFormatterComma.delimiter = @",";
        _arrayFormatterComma.conjunction = @"";
        _arrayFormatterComma.abbreviatedConjunction = @"";
        _arrayFormatterAND = [TTTArrayFormatter new];
        _arrayFormatterAND.arrayStyle = TTTArrayFormatterDataStyle;
        _arrayFormatterAND.separator = @" ";
        _arrayFormatterAND.delimiter = @" AND ";
        _arrayFormatterAND.conjunction = @"";
        _arrayFormatterAND.abbreviatedConjunction = @"";
        _dbFilePath = dbFilePath;
        
        _managedObjects = [self prepareManagedObjectsDict:managedObjects];
        _typesBlockIn = typesSerializations;
        _typesBlockOut = typesDeserializations;
    }
    
    return self;
}

- (NSDictionary *)prepareManagedObjectsDict:(NSDictionary *)tablesAndClasses
{
    NSArray *tables = [tablesAndClasses allKeys];
    
    NSMutableDictionary *managedObjects = [NSMutableDictionary dictionaryWithCapacity:[tables count]];
    
    for (NSString *table in tables) {
        Class class = tablesAndClasses[table];
        NSString *className = NSStringFromClass(class);
        if ([className length] == 0) {
            NSLog(@"Undefined class name");
            continue;
        }
        NSDictionary *values = @{TableNameKey: table,
                                 PropertiesKey: [class propertiesTypes]};
        [managedObjects setObject:values forKey:className];
    }
    
    return managedObjects;
}

- (void)openDataBaseAtPath:(NSString *)dbFilePath
                withSchema:(DTSManagerSchemaBlock)schemaBlock
{
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    self.db = db;
    self.dbFilePath = dbFilePath;
    
    BOOL ok;
    NSError *error = nil;
    
    ok = [db open];
    if (ok) {
        ok = [db executeUpdate:@"PRAGMA foreign_keys=ON"];
        if (!ok) {
            error = [db lastError];
            NSLog(@"%@", error);
        }
        int version = [self databaseSchemaVersion:db];
        schemaBlock(db,&version);
        [self setDatabase:db schemaVersion:version];
    } else {
        error = [db lastError];
        NSLog(@"%@", error);
    }
    
    if (error) {
        self.db = nil;
    }
}

- (int)databaseSchemaVersion:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQuery:@"PRAGMA user_version"];
    int version = 0;
    if ([resultSet next]) {
        version = [resultSet intForColumnIndex:0];
    }
    return version;
}

- (void)setDatabase:(FMDatabase *)db schemaVersion:(int)version
{
    // FMDB cannot execute this query because FMDB tries to use prepared statements
    sqlite3_exec(db.sqliteHandle,
                 [[NSString stringWithFormat:@"PRAGMA user_version = %d", version] UTF8String],
                 NULL, NULL, NULL);
    //    TODO: error handling
}

- (NSError *)closeDataBase
{
    FMDatabase *db = self.db;
    NSError *error = nil;
    if ([db close] == NO) {
        error = [db lastError];
        NSLog(@"%@", error);
    };
    
    self.db = nil;
    
    return error;
}

- (NSError *)deleteDataBase
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL ok = [manager removeItemAtPath:self.dbFilePath error:&error];
    if (!ok) {
        NSLog(@"%@", error);
    }
    
    self.db = nil;
    
    return error;
}

- (NSError *)insertObject:(id)object
                    table:(NSString *)table
               properties:(NSDictionary *)properties
{
    NSDictionary *parameters = [self parametersFromObject:object
                                               properties:properties];
    
    NSArray *keys = [parameters allKeys];
    NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:[keys count]];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [placeholders addObject:[@":" stringByAppendingString:obj]];
    }];
    
    NSString *columns = [self.arrayFormatterComma stringFromArray:keys];
    NSString *values = [self.arrayFormatterComma stringFromArray:placeholders];
    
    NSString *query;
    query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
             table, columns, values];
    
    NSError *error = nil;
    
    BOOL ok = [self.db executeUpdate:query
             withParameterDictionary:parameters];
    
    if (!ok) {
        error = [self.db lastError];
    } else {
        [object setValue:@([self.db lastInsertRowId])
                  forKey:DTSObjectIdKey];
    }
    
    return error;
}

- (NSError *)updateObject:(id)object
                    table:(NSString *)table
                    where:(NSDictionary *)where
               properties:(NSDictionary *)properties
{
    NSDictionary *parameters = [self parametersFromObject:object
                                               properties:properties];
    
    NSArray *parColumnsArray = [self arrayWithColumnsEqualValuesFromDictKeys:parameters];
    NSString *parColumns = [self.arrayFormatterComma stringFromArray:parColumnsArray];
    
    NSArray *whereColumnsArray = [self arrayWithColumnsEqualValuesFromDictKeys:where];
    NSString *whereColumns = [self.arrayFormatterAND stringFromArray:whereColumnsArray];
    
    NSString *query;
    query = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",
             table, parColumns, whereColumns];
    
    NSMutableDictionary *allPars = [NSMutableDictionary dictionaryWithCapacity:[parameters count] + [where count]];
    [allPars addEntriesFromDictionary:parameters];
    [allPars addEntriesFromDictionary:where];
    
    NSError *error = nil;
    
    BOOL ok = [self.db executeUpdate:query
             withParameterDictionary:allPars];
    
    if (!ok) {
        error = [self.db lastError];
    }
    
    return error;
}

- (NSArray *)arrayWithColumnsEqualValuesFromDictKeys:(NSDictionary *)dict
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[dict count]];
    for (NSString *column in [dict allKeys]) {
        NSString *par = [NSString stringWithFormat:@"%@ = :%@", column, column];
        [array addObject:par];
    }
    return array;
}

- (NSDictionary *)parametersFromObject:(id)object
                            properties:(NSDictionary *)properties
{
    NSUInteger count = [properties count] * 2;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (NSString *property in properties) {
        
        NSString *type = properties[property];
        
        SerializePropertyBlock block = self.typesBlockIn[type];
        
        if (block) {
            block(property, object, parameters);
        } else {
            NSString *key = property;
            id value = [object valueForKey:property];
            if (value) {
                [parameters setObject:value forKey:key];
            }
        }
    }
    
    return parameters;
}

- (id)newObjectOfClass:(Class)objectClass
               withRow:(FMResultSet *)rs
            properties:(NSDictionary *)properties
{
    id object = [objectClass new];
    
    for (NSString *property in properties) {
        
        NSString *type = properties[property];
        DeserializePropertyBlock block = self.typesBlockOut[type];
        
        if (block) {
            block(property, rs, object);
        } else {
            if ([rs columnIsNull:property] == NO) {
                id value = [rs objectForColumnName:property];
                [object setValue:value forKey:property];
            }
        }
    }
    
    return object;
}

@end
