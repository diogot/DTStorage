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

@property (nonatomic, strong) FMDatabase *db;

+ (instancetype)sharedManager;

// Optional
- (void)addSerializationBlock:(DTSManagerTypeSerializationBlock)sBlock
         deserializationBlock:(DTSManagerTypeDeserializationBlock)dBlock
                     forClass:(Class)class;

- (void)addSerializationBlock:(DTSManagerTypeSerializationBlock)sBlock
         deserializationBlock:(DTSManagerTypeDeserializationBlock)dBlock
                      forType:(NSString *)typeName;


- (void)addManagedClass:(Class)class;

- (void)openDataBaseAtPath:(NSString *)dbFilePath
                withSchema:(DTSManagerSchemaBlock)schemaBlock;

- (void)openDataBaseAtPath:(NSString *)dbFilePath
                withSchema:(DTSManagerSchemaBlock)schemaBlock
                       key:(NSString *)key;

- (NSError *)closeDataBase;

- (NSError *)deleteDataBase;

- (void)saveObject:(DTSObject *)object;
- (instancetype)newObjectWithId:(NSNumber *)objectId objectClass:(Class)class;
- (void)deleteObject:(DTSObject *)object;
- (NSArray *)arrayWithIdsFromClass:(Class)class
                     whereProperty:(NSString *)property
                          hasValue:(id)value
                         orderDesc:(BOOL)isDesc;

@end
