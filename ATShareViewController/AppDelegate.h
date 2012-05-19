//
//  AppDelegate.h
//  ATShareViewController
//
//  Created by Osamu Noguchi on 5/19/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    Facebook *facebook;
    NSOperationQueue *operationQueue;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end
