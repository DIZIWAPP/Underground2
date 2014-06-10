//
//  UGTermsViewController.h
//  Underground
//
//  Created by Jon Como on 5/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    kTermsActionAgreed,
    kTermsActionDisagreed
} kTermsAction;

@class UGTermsViewController;

@protocol UGTermsViewControllerDelegate <NSObject>

-(void)termsViewController:(UGTermsViewController *)viewController dismissedWithAction:(kTermsAction)action;

@end

@interface UGTermsViewController : UIViewController

@property (nonatomic, weak) id <UGTermsViewControllerDelegate> delegate;
@property BOOL shouldChooseImageOnComplete;

@end
