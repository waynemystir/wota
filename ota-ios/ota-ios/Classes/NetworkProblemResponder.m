//
//  NetworkProblemResponder.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/11/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "NetworkProblemResponder.h"
#import "WotaButton.h"
#import "AppEnvironment.h"
#import "NetworkProblemView.h"

@interface NetworkProblemResponder ()

@property (nonatomic, weak) NetworkProblemView *networkProblemView;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, weak) WotaButton *wb;

@end

@implementation NetworkProblemResponder

- (id)initWithSuperView:(UIView *)superView
            headerTitle:(NSString *)headerTitle
          messageString:(NSString *)messageString
     completionCallback:(void (^)(void))completionCallback {
    
    if (self = [super init]) {
        _overlay = [[UIView alloc] initWithFrame:superView.bounds];
        _overlay.tag = 50900;
        _overlay.backgroundColor = [UIColor blackColor];
        _overlay.alpha = 0.0f;
        _overlay.userInteractionEnabled = YES;
        
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NetworkProblemView" owner:self options:0];
        _networkProblemView = views.firstObject;
        _networkProblemView.frame = CGRectMake(15, 180, 290, 195);
        _networkProblemView.layer.cornerRadius = WOTA_CORNER_RADIUS;
        _networkProblemView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        _networkProblemView.completionCallback = completionCallback;
        
        UILabel *titleView = (UILabel *)[_networkProblemView viewWithTag:50901];
        titleView.text = headerTitle ? : titleView.text;
        
        UILabel *messageView = (UILabel *)[_networkProblemView viewWithTag:50902];
        messageView.text = messageString ? : messageView.text;
        
        _wb = (WotaButton *)[_networkProblemView viewWithTag:97314793];
        [_wb addTarget:[self class] action:@selector(okClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

+ (void)launchWithSuperView:(UIView *)superView
                headerTitle:(NSString *)headerTitle
              messageString:(NSString *)messageString
         completionCallback:(void (^)(void))completionCallback {
    
    NetworkProblemResponder *npr = [[NetworkProblemResponder alloc] initWithSuperView:superView headerTitle:headerTitle messageString:messageString completionCallback:completionCallback];
    
    __weak UIView *npv = npr.networkProblemView;
    __weak UIView *ovl = npr.overlay;
    
    [superView addSubview:npr.overlay];
    [superView bringSubviewToFront:npr.overlay];
    [superView addSubview:npr.networkProblemView];
    [superView bringSubviewToFront:npr.networkProblemView];
    
    [superView endEditing:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        ovl.alpha = 0.7f;
        npv.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        ;
    }];
}

+ (void)okClick:(WotaButton *)wb {
    __weak NetworkProblemView *npv = (NetworkProblemView *)wb.superview;
    __weak UIView *ovl = [wb.superview.superview viewWithTag:50900];
    
    [UIView animateWithDuration:0.25 animations:^{
        ovl.alpha = 0.0f;
        npv.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
    } completion:^(BOOL finished) {
        [ovl removeFromSuperview];
        [npv removeFromSuperview];
        if (nil != npv.completionCallback) {
            npv.completionCallback();
        }
    }];
}

@end
