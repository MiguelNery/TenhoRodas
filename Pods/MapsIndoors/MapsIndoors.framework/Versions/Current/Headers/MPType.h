//
//  MPType.h
//  MapsIndoors for iOS
//
//  Created by Martin Hansen on 7/23/15.
//  Copyright (c) 2015 MapsPeople A/S. All rights reserved.
//

#import "MPJSONModel.h"
#import "MPLocationDisplayRule.h"

/**
 POI types (used by MapsPeoples services)
 */
@interface MPType : MPJSONModel

@property NSString* name;
@property NSString* icon;
@property MPLocationDisplayRule<Optional>* displayRule;

@end
