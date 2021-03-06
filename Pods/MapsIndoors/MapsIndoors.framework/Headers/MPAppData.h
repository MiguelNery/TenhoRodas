//
//  MPAppData.h
//  MapsIndoors SDK for iOS
//
//  Created by Daniel Nielsen on 8/16/13.
//  Copyright (c) 2017 MapsPeople A/S. All rights reserved.
//

#import "MPJSONModel.h"
#import "MPLocationDisplayRuleset.h"
#import "MPMenuItem.h"


/** 
   Provides the contextual information needed for setting up a map with specific MapsPeople site data
 */
@interface MPAppData : MPJSONModel
/**
 Ruleset that defines how and when to show the different map markers
 */
@property (strong, nonatomic) MPLocationDisplayRuleset<Ignore>* displayRuleset;
@property (strong, nonatomic) NSString<Optional>* colorPrimary;
@property (strong, nonatomic) NSString<Optional>* colorPrimaryDark;
@property (strong, nonatomic) NSString<Optional>* colorAccent;
@property (strong, nonatomic) NSDictionary<NSString*, NSArray<NSDictionary*>*>* menuInfo;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*><Optional>* venueImages;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*><Optional>* appSettings;

@end
