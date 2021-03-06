//
//  MPContactModule.h
//  MapsIndoors SDK for iOS
//
//  Created by Daniel Nielsen on 12/4/13.
//  Copyright (c) 2017 MapsPeople A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPJSONModel.h"
#import "MPDataField.h"

@interface MPContactModule : MPJSONModel

@property MPDataField<Optional>* email;
@property MPDataField<Optional>* phone;
@property MPDataField<Optional>* faxNumber;
@property MPDataField<Optional>* website;

@end
