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

/**
 *  The block that is executed to create and update the database schema.
 *
 *  @param db            FMDatabase reference
 *  @param schemaVersion int a reference for currente schema version
 */
typedef void(^DTSManagerSchemaBlock)(FMDatabase *db, int *schemaVersion);

/**
 *  Block that is used to define the logics to serialize a custom type on 
 *   database.
 *
 *  @param object     The object which will be saved
 *  @param key        NSString with the name of the property which should be saved
 *  @param parameters NSMutableDictionary that wich will hold the serialized type
 *
 *  @see DTSManagerTypeDeserializationBlock
 *  @see -addSerializationBlock:deserializationBlock:forClass:
 */
typedef void (^DTSManagerTypeSerializationBlock)(NSString *key,
                                                 id object,
                                                 NSMutableDictionary *parameters);

/**
 *  Block that is used to define the logics to deserialize a custom type on
 *   database.
 *
 *  @param key    NSString with the name of the property which should be saved
 *  @param rs     FMResultSet that contains the serialized property
 *  @param object The object instance that need to have the property
 *
 *  @see DTSManagerTypeSerializationBlock
 *  @see -addSerializationBlock:deserializationBlock:forClass:
 */
typedef void (^DTSManagerTypeDeserializationBlock)(NSString *key,
                                                   FMResultSet *rs,
                                                   id object);

/**
 *  Class that manage the database and is used to connect and configure it.
 */
@interface DTSManager : NSObject

/**
 *  A reference to the current database, can be used for customizations
 */
@property (nonatomic, strong) FMDatabase *db;

/**
 *  A class method that returns the instance of the manager currently in use.
 *   It's not recommended to have more than one instance of this class running.
 *
 *  @return DTSManager
 */
+ (instancetype)sharedManager;

/**
 *  A method that is used to add a class that will be saved to the manager
 *   database. Must be called for all classes that will be persisted BEFORE
 *   the database be open.
 *
 *  @param class Class of the persisted class
 */
- (void)addManagedClass:(Class)class;

/**
 *  A method that can be used to define how a custom class can be saved and read
 *   from the database. This is an optional feature and must be called BEFORE 
 *   the database be open.
 *
 *  @param sBlock DTSManagerTypeSerializationBlock
 *  @param dBlock DTSManagerTypeDeserializationBlock
 *  @param class  Class of the custom object
 *
 *  @see DTSManagerTypeDeserializationBlock
 *  @see DTSManagerTypeDeserializationBlock
 *  @see -addSerializationBlock:deserializationBlock:forType:
 */
- (void)addSerializationBlock:(DTSManagerTypeSerializationBlock)sBlock
         deserializationBlock:(DTSManagerTypeDeserializationBlock)dBlock
                     forClass:(Class)class;

/**
 *  A method that can be used to define how a custom type can be saved and read
 *   from the database. This is an optional feature and must be called BEFORE
 *   the database be open.
 *
 *  @param sBlock   DTSManagerTypeSerializationBlock
 *  @param dBlock   DTSManagerTypeDeserializationBlock
 *  @param typeName NSString of the custom type
 *
 *  @see DTSManagerTypeDeserializationBlock
 *  @see DTSManagerTypeDeserializationBlock
 *  @see -addSerializationBlock:deserializationBlock:forClass:
 */
- (void)addSerializationBlock:(DTSManagerTypeSerializationBlock)sBlock
         deserializationBlock:(DTSManagerTypeDeserializationBlock)dBlock
                      forType:(NSString *)typeName;

/**
 *  This method is used to open the database on the desired path and create or
 *   update the schema.
 *
 *  @param dbFilePath  NSString with the database file path
 *  @param schemaBlock DTSManagerSchemaBlock
 *
 *  @return NSError, returns nil if everything is ok.
 *
 *  @see -openDataBaseAtPath:withSchema:key:
 */
- (NSError *)openDataBaseAtPath:(NSString *)dbFilePath
                     withSchema:(DTSManagerSchemaBlock)schemaBlock;

/**
 *  This method is used to open an encripted database on the desired path 
 *   and create or update the schema.
 *
 *  @param dbFilePath  NSString with the database file path
 *  @param schemaBlock DTSManagerSchemaBlock
 *  @param key         NSString with database encription key
 *
 *  @return NSError, returns nil if everything is ok.
 *
 *  @see -openDataBaseAtPath:withSchema:
 */
- (NSError *)openDataBaseAtPath:(NSString *)dbFilePath
                     withSchema:(DTSManagerSchemaBlock)schemaBlock
                            key:(NSString *)key;

/**
 *  Used to close the database, returns nil if everything is ok.
 *
 *  @return NSError
 */
- (NSError *)closeDataBase;

/**
 *  Used to delete the database, returns nil if everything is ok.
 *
 *  @return NSError
 */
- (NSError *)deleteDataBase;

/**
 *  Method that saves an object
 *
 *  @param object DTSObject
 */
- (void)saveObject:(DTSObject *)object;

/**
 *  Method to load a saved object.
 *
 *  @param objectId NSNumber with the objectId
 *  @param class    Class of the saved object
 *
 *  @return DTSObject sub class, or nil if the object don't exists
 */
- (instancetype)objectWithId:(NSNumber *)objectId objectClass:(Class)class;

/**
 *  Deletes the object
 *
 *  @param object DTSObject sub class instance that will be deleted from the
 *   database
 */
- (void)deleteObject:(DTSObject *)object;

/**
 *  Fetch an array of objectId from objects from a desired class where a 
 *   property has a value, can be ordered descending.
 *
 *  @param class    Class managed
 *  @param property NSString of the property, can be nil
 *  @param value    Value that the property need to be, can be nil if property 
 *   is nil
 *  @param isDesc   BOOL the array is ordered descening if @a YES
 *
 *  @return NSArray of NSNumber with objectIds, nil if none is found.
 */
- (NSArray *)arrayWithIdsFromClass:(Class)class
                     whereProperty:(NSString *)property
                          hasValue:(id)value
                         orderDesc:(BOOL)isDesc;

@end
