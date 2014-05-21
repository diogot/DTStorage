//
//  DTSObject.m
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import "DTSObject_Private.h"
#import "DTSManager.h"


NSString * const DTSObjectIdKey = @"objectId";

static DTSManager *DBManager = nil;

static DTSManager * GetDBManager()
{
    if (DBManager == nil) {
        DBManager = [DTSManager sharedManager];
    }
    
    return DBManager;
}

static void SetDBManager(DTSManager *dbManager)
{
    DBManager = dbManager;
}

@interface DTSObject ()

@property (nonatomic, readwrite, strong) NSNumber *objectId;

@end


@implementation DTSObject


#pragma mark - NSObject


// Need to Xcode don't complain about
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


#pragma mark - Private Methods

+ (DTSManager *)dbManager
{
    return GetDBManager();
}

+ (void)setDbManager:(DTSManager *)manager
{
    SetDBManager(manager);
}


#pragma mark - Public Methods

+ (NSDictionary *)propertiesTypes
{
    [self undefinedPropertiesTypesException];
    
    return nil;
}

+ (void)undefinedPropertiesTypesException
{
    //  TODO: extract this strings to simbols
    [NSException raise:@"DTSObjectUndefinedPropertiesTypes"
                format:@"DTSObject propertiesTypes has zero types."];
}

+ (NSString *)tableName
{
    //  TODO: extract this strings to simbols
    [NSException raise:@"DTSObjectUndefinedTableName"
                format:@"DTSObject tableName not defined."];
    
    return nil;
}

- (void)save
{
    [[DTSObject dbManager] saveObject:self];
}

- (void)delete
{
    [[DTSObject dbManager] deleteObject:self];
}

+ (instancetype)newObjectWithId:(NSNumber *)objectId
{
    if (objectId == nil) {
        NSLog(@"Undefined %@", DTSObjectIdKey);
        return nil;
    }
    
    id object = [[DTSObject dbManager] newObjectWithId:objectId
                                           objectClass:[self class]];
    
    return object;
}

+ (NSArray *)arrayWithObjectIds
{
    NSArray *array = [[DTSObject dbManager] arrayWithIdsFromClass:self];
    
    return array;
}


- (NSString *)debugDescription
{
    NSString *desc;
    
    desc = [NSString stringWithFormat:@"<%@: %p; objectId: %@; %@>",
            NSStringFromClass([self class]),
            self,
            self.objectId,
            [self description]];
    
    return desc;
}

@end
