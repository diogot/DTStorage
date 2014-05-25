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

/**
 *  Private method to set the DTSManager used by the class. This method can be
 *   used for dependency injection on tests.
 *
 *  @param manager DTSManager that should be used by the class.
 */
+ (void)setDbManager:(DTSManager *)manager;

@end
