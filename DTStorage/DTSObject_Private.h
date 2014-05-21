//
//  DTSObject_Private.h
//  DTStorage
//
//  Created by Diogo Tridapalli on 5/20/14.
//  Copyright (c) 2014 Diogo Tridapalli. All rights reserved.
//

#import "DTSObject.h"

@class DTSManager;

@interface DTSObject ()

+ (DTSManager *)dbManager;
+ (void)setDbManager:(DTSManager *)manager;

@end
