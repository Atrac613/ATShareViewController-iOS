//
//  MasterViewController.h
//  ATShareViewController
//
//  Created by Osamu Noguchi on 5/19/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATShareViewController.h"

@interface MasterViewController : UIViewController <ATShareViewControllerDelegate>

- (IBAction)shareButtonPressed:(id)sender;

@end
