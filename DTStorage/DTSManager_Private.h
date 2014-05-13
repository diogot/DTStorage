//
//  DTSManager_Private.h
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import "DTSManager.h"

@class FMResultSet;

@interface DTSManager ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSString *dbFilePath;

- (instancetype)initWithDbPath:(NSString *)dbFilePath;
- (instancetype)initWithDBPath:(NSString *)dbFilePath
                managedObjects:(NSDictionary *)managedObject
      customTypesSerialization:(NSDictionary *)typesSerializations
    customTypesDeserialization:(NSDictionary *)typesDeserializations;

- (NSError *)insertObject:(id)object
                    table:(NSString *)table
               properties:(NSDictionary *)properties;
- (NSError *)updateObject:(id)object
                    table:(NSString *)table
                    where:(NSDictionary *)where
               properties:(NSDictionary *)properties;
- (id)newObjectOfClass:(Class)objectClass
               withRow:(FMResultSet *)rs
            properties:(NSDictionary *)properties;

@end
