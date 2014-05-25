//
//  DTSObject.h
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/11/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTSManager;

/**
 *  Abstract class that should be the parent class of the persisted classes.
 */
@interface DTSObject : NSObject

/**
 *  Property that has the id of persisted object, if is @a nil the object is not
 *   saved.
 */
@property (nonatomic, readonly) NSNumber *objectId;

/**
 *  Class method that returns a reference for the database manager.
 *
 *  @return DTSManager
 */
+ (DTSManager *)dbManager;

/**
 *  Class method that must to be overridden on sub classes, this method should
 *   return a dictionary with the keys that are the names of persisted 
 *   properties and values that are strings of their class names. 
 *   Ex. @{@"name":@"NSString"}.
 *
 *  @return NSDictionary with persisted properties
 */
+ (NSDictionary *)propertiesTypes;

/**
 *  Class method that must to be overridden on sub classes, this method should
 *   return a NSString with the name of the table that this class objects are 
 *   persisted.
 *
 *  @return NSString with the table name
 */
+ (NSString *)tableName;

/**
 *  Class method that returns an array of all objectIds saved on database
 *   ordered by objectId. Returns nil if there is no object saved.
 *
 *  @see +arrayWithObjectIdsDesc
 *  @see +arrayWithIdsWhereProperty:hasValue:
 *  @return NSArray of NSNumber
 */
+ (NSArray *)arrayWithObjectIds;

/**
 *  Class method that returns an array of all objectIds saved on database
 *   ordered descending by objectId. Returns nil if there is no object saved.
 *
 *  @see +arrayWithObjectIds
 *  @see +arrayWithIdsWhereProperty:hasValue:
 *  @return NSArray of NSNumber
 */
+ (NSArray *)arrayWithObjectIdsDesc;

/**
 *  Class method that returns an array of all objectIds saved on database where 
 *   @a property has @a value, ordered objectId. 
 *   Returns nil if there is no object saved matches.
 *
 *  @param property NSString of a property name
 *  @param value    id of the desired property value
 *
 *  @see +arrayWithObjectIds
 *  @see +arrayWithObjectIdsDesc
 *  @return NSArray of NSNumber
 */
+ (NSArray *)arrayWithIdsWhereProperty:(NSString *)property
                              hasValue:(id)value;

/**
 *  Class method that returns an instance of the class with the saved object
 *   with the designed objectId. Returns nil if the object is not saved.
 *
 *  @param objectId NSNumber
 *
 *  @return Instance of this class with the saved objectId
 */
+ (instancetype)objectWithId:(NSNumber *)objectId;

/**
 *  Saves or update the object on database
 */
- (void)save;

/**
 *  Deletes the object on database
 */
- (void)delete;

@end

/**
 *  The string that is used to describe the objectId on the database
 */
extern NSString * const DTSObjectIdKey;