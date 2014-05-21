//
//  DTSManager.h
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTSObject;
@class FMDatabase;
@class FMResultSet;

typedef void(^DTSManagerSchemaBlock)(FMDatabase *db, int *schemaVersion);


typedef void (^DTSManagerTypeSerializationBlock)(NSString *key,
                                                 id object,
                                                 NSMutableDictionary *parameters);

typedef void (^DTSManagerTypeDeserializationBlock)(NSString *key,
                                                   FMResultSet *rs,
                                                   id object);


@interface DTSManager : NSObject

+ (instancetype)sharedManager;

// Optional
- (void)addSerializationBlock:(DTSManagerTypeSerializationBlock)sBlock
         deserializationBlock:(DTSManagerTypeDeserializationBlock)dBlock
                     forClass:(Class)class;

- (void)addManagedClass:(Class)class;

- (void)openDataBaseAtPath:(NSString *)dbFilePath
                withSchema:(DTSManagerSchemaBlock)schemaBlock;

- (NSError *)closeDataBase;

- (NSError *)deleteDataBase;

- (void)saveObject:(DTSObject *)object;
- (instancetype)newObjectWithId:(NSNumber *)objectId objectClass:(Class)class;
- (void)deleteObject:(DTSObject *)object;
- (NSArray *)arrayWithIdsFromClass:(Class)class;

@end
