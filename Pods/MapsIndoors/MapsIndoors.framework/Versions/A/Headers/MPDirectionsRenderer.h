//
//  MPDirectionsRenderer.h
//  MapsIndoors
//
//  Created by Daniel Nielsen on 01/10/15.
//  Copyright © 2015 MapsPeople A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MPRoute.h"

// Renderer delegate protocol
@protocol MPDirectionsRendererDelegate <NSObject>
/**
 Floor change event.
 @param  The floor level.
 */
@optional
- (void) floorDidChange: (NSNumber*)floor; 
@end

typedef NS_ENUM(NSUInteger, MPDirectionsRenderFit) {
    MPDirectionsRenderFitIndoorPathFirstLineUpwards,
    MPDirectionsRenderFitIndoorPathUpwards,
    MPDirectionsRenderFitNorthBound
};

@interface MPDirectionsRenderer : NSObject

@property (weak) id <MPDirectionsRendererDelegate> delegate;
/**
 Assigns (or unassigns) a Google map object
 */
@property (nonatomic, strong) GMSMapView* map;
/**
 Assigns (or unassigns) a route object
 */
@property (nonatomic, strong) MPRoute* route;
@property (nonatomic, strong) UIButton* nextRouteLegButton;
@property (nonatomic, strong) UIButton* previousRouteLegButton;
@property (nonatomic) NSInteger routeLegIndex;
@property (nonatomic) NSInteger routeStepIndex;

@property (nonatomic, strong) UIColor* solidColor;
@property (nonatomic, strong) UIColor* backgroundColor;
@property (nonatomic) BOOL fitBounds;
@property (nonatomic) MPDirectionsRenderFit fitMode;
@property (nonatomic) UIEdgeInsets edgeInsets;

/**
 Indicates whether the renderer is currently showing a route or not.
 */
@property (nonatomic, readonly) BOOL    isRenderingRoute;

- (void)animate:(NSTimeInterval)duration;


@end
