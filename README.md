DTStorage
=========

A library for data persistence on iOS that uses SQLite (with FMDB).
I ([Diogo Tridapalli](http://twitter.com/diogot)) started to develop this lib for the iOS app of [99Taxis](http://99taxis.com).
Still are under development but it's functional.

## A bit of History

To write this code I was inspired by [Brent Simmons](https://twitter.com/brentsimmons) in his [talk](http://inessential.com/2013/06/17/altwwdc_slides) at AltWWDC'13 and in a nice [article](http://inessential.com/2014/03/26/fetching_objects_with_fmdb_and_sqlite) in his blog. After that I studied a bit of [FMDB](https://github.com/ccgus/fmdb) and started to write a little layer over FMDB to avoid duplicated SQL code.

After a few interactions on code (and some spaghetti code) I decide do some research to see what the people are doing on this matter and I found another [great article](http://www.objc.io/issue-4/SQLite-instead-of-core-data.html) from Simmons. And a similar library from [Marco Arment](https://twitter.com/marcoarment), [FCModel](https://github.com/marcoarment/FCModel) has nice ideas that I use in this code, like the way used to open the database, but this code have support to simple relations, that FCModel don't.

Since most of the data persistence libraries are based on Core Data I, with the support of 99Taxis, decided to open this source code. I hope it can help :-)

Suggestions are welcome, feel free to contact me on [twitter](http://twitter.com/diogot).

## Requirements

* iOS 6 or later
* ARQ
* [FMDB](https://github.com/ccgus/fmdb)
* [FormatterKit](https://github.com/mattt/FormatterKit)

## Example

### CocoaPods config

```
pod 'DTStorage'
```

### Object definition

```objective-c
#import "DTSObject.h"
@interface ObjectExample : DTSObject
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@end

@implementation ObjectExample
+ (NSDictionary *)propertiesTypes
{
    return @{@"string": NSStringFromClass([NSString class]),
             @"number": NSStringFromClass([NSNumber class])};
}
+ (NSString *)tableName
{
    return @"example";
}
@end
```

### DTSManager configuration

```objective-c
DTSManager *manager = [DTSManager sharedManager];
[manager addManagedClass:[ObjectExample class]];
[manager openDataBaseAtPath:dbPath
                 withSchema:^(FMDatabase *db, int *schemaVersion) {
  [db beginTransaction];
  void (^failedAt)(int statement) = ^(int statement){
    int lastErrorCode = db.lastErrorCode;
    NSString *lastErrorMessage = db.lastErrorMessage;
    [db rollback];
    NSAssert3(0, @"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
  };
  if (*schemaVersion < 1) {
    if (! [db executeUpdate:
      @"CREATE TABLE example ("
      @" objectId INTEGER UNIQUE NOT NULL PRIMARY KEY AUTOINCREMENT,"
      @" string   TEXT NOT NULL DEFAULT '',"
      @" number   REAL"
      @");"
    ]) failedAt(1);
        
    *schemaVersion = 1;
  }
  [db commit];
}];
```

### Object creation

```objective-c
ObjectExample *obj = [ObjectExample new];
obj.string = @"text";
obj.number = @(42);
[obj save];
```

### Object list and load

```objective-c
NSArray *list = [ObjectExample arrayWithObjectIds];
ObjectExample *obj = [ObjectExample objectWithId:[list lastObject]];
```

### Delete

```objective-c
[obj delete];
```
