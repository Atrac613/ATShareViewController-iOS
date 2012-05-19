//
//  ShareViewController.h
//  ShareView
//
//  Created by Osamu Noguchi on 4/30/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "FBConnect.h"

@protocol ATShareViewControllerDelegate;

enum {
    ATShareViewControllerResultCancelled,
    ATShareViewControllerResultSent,
    ATShareViewControllerResultFailed
};
typedef NSUInteger ATShareViewControllerResult;

@interface ATShareViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, FBSessionDelegate, FBRequestDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UINavigationItem *navigationItem;
    UIToolbar *toolBar;
    NSString *shareMessage;
    PendingView *pendingView;
    BOOL doTweet;
    BOOL doFacebook;
    
    __weak id<ATShareViewControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) NSString *shareMessage;
@property (nonatomic, retain) PendingView *pendingView;
@property (nonatomic) BOOL doTweet;
@property (nonatomic) BOOL doFacebook;
@property (weak, nonatomic) id<ATShareViewControllerDelegate> delegate;

- (void)sendFacebook:(NSString *)message url:(NSString*)url;
- (void)sendTwitter:(NSString *)message;

- (void)cancelButtonPressed;
- (void)doneButtonPressed;
- (void)closeButtonPressed;

- (void)showPendingView;
- (void)hidePendingView;

@end

@protocol ATShareViewControllerDelegate

- (void)shareViewController:(ATShareViewController*)controller didFinishWithResult:(ATShareViewControllerResult)result;

@end