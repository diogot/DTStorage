//
//  DTSObject.m
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import "DTSObject.h"
#import "DTSManager.h"


NSString * const DTSObjectIdKey = @"objectId";

static DTSManager *DBManager;

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

@property (nonatomic, strong) DTSManager *dbManager;
@property (nonatomic, readwrite, strong) NSNumber *objectId;

@end


@implementation DTSObject
+ (NSDictionary *)propertiesTypes
{
    [self undefinedPropertiesTypesException];
    
    return nil;
}

+ (void)undefinedPropertiesTypesException
{
    [NSException raise:@"DTSObjectUndefinedPropertiesTypes"
                format:@"DTSObject propertiesTypes has zero types."];
}


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)save
{
    [self.dbManager saveObject:self];
}

- (void)delete
{
    [self.dbManager deleteObject:self];
}

- (DTSManager *)dbManager
{
    if (_dbManager == nil) {
        _dbManager = GetDBManager();
    }
    
    return _dbManager;
}

+ (instancetype)newObjectWithId:(NSNumber *)objectId
{
    if (objectId == nil) {
        NSLog(@"Undefined %@", DTSObjectIdKey);
        return nil;
    }
    
    id object = [GetDBManager() newObjectWithId:objectId
                                    objectClass:[self class]];
    
    return object;
}

+ (NSArray *)arrayWithObjectIds
{
    NSArray *array = [GetDBManager() arrayWithIdsFromClass:self];
    
    return array;
}


- (NSString *)debugDescription
{
    NSString *desc;
    
    desc = [NSString stringWithFormat:@"<%@: %p; %@>",
            NSStringFromClass([self class]),
            self,
            [self description]];
    
    return desc;
}

@end
