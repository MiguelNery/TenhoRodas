//
//  MPGeometry.h
//  
//
//  Created by Daniel Nielsen on 9/9/13.
//
//

#import "MPJSONModel.h"

/**
 Basic geometry class holding one or more coordinate sets
 */
@interface MPGeometry : MPJSONModel
/**
 Type of data (equals Geometry)
 */
//@property NSString *type;
/**
 Array holding one or more coordinate sets (if so, the array will be an array of arrays)
 */
@property NSArray *coordinates;

@end
