//
//  ChildView.m
//  ota-ios
//
//  Created by WAYNE SMALL on 7/26/15.
//  Copyright (c) 2015 Trotter. All rights reserved.
//

#import "ChildView.h"
#import "WotaButton.h"
#import "ChildSubView.h"
#import "ChildTraveler.h"
#import "AppEnvironment.h"

NSTimeInterval const kCvAnimationDuration = 0.6;

@interface ChildView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet WotaButton *daRealDoneButton;
@property (weak, nonatomic) IBOutlet UILabel *numberKidsLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *minusChildButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *addChildButtonOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childOneOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childTwoOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childThreeOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childFourOutlet;
@property (nonatomic) NSUInteger selectedChildOutlet;
@property (nonatomic, strong) UILabel *selectorViewLabel;
@property (nonatomic, strong) WotaButton *doneButton;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *pickerData;

- (IBAction)justPushIt:(id)sender;

@end

@implementation ChildView {
    UIControl *overlay;
}

+ (ChildView *)childViewFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ChildView" owner:self options:nil];
    if ([views count] != 1) {
        return nil;
    }
    
    ChildView *cv = views.firstObject;
    
    [cv checkIfWeCanAddKids];
    [cv checkIfWeCanRemoveKids];
    
    [cv updateNumberOfKidsLabel];
    
    [cv setupLabelForAgeSelector];
    [cv setupDoneButton];
    [cv setupTheAgePickerViewAndData];
    
    cv.childOneOutlet.childAbcdLabelOutlet.text = @"Child One";
    cv.childTwoOutlet.childAbcdLabelOutlet.text = @"Child Two";
    cv.childThreeOutlet.childAbcdLabelOutlet.text = @"Child Three";
    cv.childFourOutlet.childAbcdLabelOutlet.text = @"Child Four";
    
    [cv setAgeLabelsAndTapGestures];
    
    return cv;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.frame = CGRectMake(0, 569, 320, 320);
        overlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0.0f;
        [overlay addTarget:self action:@selector(overlayClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark Load and drop

- (void)loadChildView {
    __weak typeof(self) tcp = self;
    __weak typeof(UIView) *sv = self.superview;
    
    [sv addSubview:overlay];
    [sv bringSubviewToFront:overlay];
    [sv bringSubviewToFront:tcp];
    
    [UIView animateWithDuration:0.33 animations:^{
        overlay.alpha = 0.7;
        tcp.frame = CGRectMake(0, 248, 320, 320);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)dropChildView {
    __weak typeof(self) tcp = self;
    __weak typeof(UIView) *sv = self.superview;
    
    [UIView animateWithDuration:0.33 animations:^{
        overlay.alpha = 0.0f;
        tcp.frame = CGRectMake(0, 569, 320, 320);
    } completion:^(BOOL finished) {
        [sv sendSubviewToBack:overlay];
        [overlay removeFromSuperview];
        [sv sendSubviewToBack:tcp];
//        [tcp.childViewDelegate childViewDonePressed];
        
        // Get those kids whose ages have not been set
        NSDictionary *kidsWithoutAges = [ChildTraveler childTravelersWithoutAges];
        
        // And set their ages to the arbitrary value of 10
        // TODO: parameterize this value of 10 with a constant variable
        for (ChildTraveler *ct in [kidsWithoutAges objectEnumerator]) {
            ct.childAge = 10;
        }
        
        [self.childViewDelegate didHideChildView:self];
    }];
}

#pragma mark Various

- (void)overlayClicked {
    [self.childViewDelegate childViewCancelled];
    [self dropChildView];
}

- (void)setAgeLabelsAndTapGestures {
    for (int j = 0; j < 4; j++) {
        [self setChildsAgeLabel:(j + 1)];
        [[self childSubOutletForInt:(j + 1)] addGestureRecognizer:[self tapper]];
    }
}

- (UITapGestureRecognizer *)tapper  {
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestOnChildSubs:)];
    tapper.numberOfTapsRequired = 1;
    tapper.numberOfTouchesRequired = 1;
    return tapper;
}

- (void)setChildsAgeLabel:(NSUInteger)childNumber {
    ChildTraveler *ct = [ChildTraveler childTravelerForId:childNumber];
    if (ct != nil) {
        NSString *plural = ct.childAge == 1 ? @"" : @"s";
        NSString *provisionAgeString = ct.childAge == 0 ? @"Less than 1" : [NSString stringWithFormat:@"%lu year%@ old", (unsigned long)ct.childAge, plural];
        NSString *ageString = ct.ageHasBeenSet ? provisionAgeString : @"Select age";
        [self childSubOutletForInt:childNumber].worbelOutlet.text = ageString;
        [self childSubOutletForInt:childNumber].hidden = NO;
    } else {
        [self childSubOutletForInt:childNumber].worbelOutlet.text = @"Select age";
        [self childSubOutletForInt:childNumber].hidden = YES;
    }
}

- (IBAction)tapGestOnChildSubs:(id)sender {
    __weak UIView *childSubView = ((UITapGestureRecognizer *)sender).view;
    
    // We don't want to respond to a second quick tap
    if (childSubView != nil && childSubView.gestureRecognizers != nil && [childSubView.gestureRecognizers count] > 0) {
        ((UIGestureRecognizer *) childSubView.gestureRecognizers[0]).enabled = NO;
    }
    
    self.selectedChildOutlet = [self intForChildSubOutlet:childSubView];
    [self resetPickerViewSelectedRow];
    
    __block UIView *asv = [self childAgeSelectorView];
    
    CGFloat fromX = childSubView.center.x - asv.center.x;
    CGFloat fromY = childSubView.center.y - asv.center.y;
    
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    fromTransform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    asv.transform = fromTransform;
    
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    toTransform = CGAffineTransformScale(toTransform, 1.0f, 1.0f);
    
    [self addSubview:asv];
    [UIView animateWithDuration:kCvAnimationDuration animations:^{
        asv.transform = toTransform;
    } completion:^(BOOL finished) {
        // Let's re-enable the gesture recognizer
        if (childSubView != nil && childSubView.gestureRecognizers != nil && [childSubView.gestureRecognizers count] > 0) {
            ((UIGestureRecognizer *) childSubView.gestureRecognizers[0]).enabled = YES;
        }
    }];
}

- (void)checkIfWeCanAddKids {
    if (![ChildTraveler moreKidsOk]) {
        self.addChildButtonOutlet.userInteractionEnabled = NO;
        self.addChildButtonOutlet.enabled = NO;
    } else {
        self.addChildButtonOutlet.userInteractionEnabled = YES;
        self.addChildButtonOutlet.enabled = YES;
    }
}

- (void)checkIfWeCanRemoveKids {
    if (![ChildTraveler lessKidsOk]) {
        self.minusChildButtonOutlet.userInteractionEnabled= NO;
        self.minusChildButtonOutlet.enabled = NO;
    } else {
        self.minusChildButtonOutlet.userInteractionEnabled= YES;
        self.minusChildButtonOutlet.enabled = YES;
    }
}

- (IBAction)justPushIt:(id)sender {
    if (sender == self.daRealDoneButton) {
        [self.childViewDelegate childViewDonePressed];
        [self dropChildView];
    } else if (sender == self.doneButton) {
        [self modifyChildTravelerWithDrop:YES];
    } else if (sender == self.minusChildButtonOutlet) {
        [self removeChildTraveler];
        [self checkIfWeCanRemoveKids];
        [self checkIfWeCanAddKids];
    } else if (sender == self.addChildButtonOutlet) {
        [self addChildTraveler];
        [self checkIfWeCanAddKids];
        [self checkIfWeCanRemoveKids];
    } else {
        TrotterLog(@"ERROR: %@.%@ didn't recognize sender", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

- (void)modifyChildTravelerWithDrop:(BOOL)dropAgeSelectorView {
    // Update the child's age
    NSInteger selectedAgeRow = [self.pickerView selectedRowInComponent:0] - 1;
    if (selectedAgeRow >= 0) {
        ChildTraveler *ct = [ChildTraveler childTravelerForId:self.selectedChildOutlet];
        
        if (selectedAgeRow == 0) {
            ct.isLessThanOne = YES;
        }
        
        ct.childAge = selectedAgeRow;
        
        // Update the label with the child's age
        [self setChildsAgeLabel:self.selectedChildOutlet];
    }
    
    if (!dropAgeSelectorView) {
        return;
    }
    
    // Remove the child age selector view
    __block UIView *snv = self.doneButton.superview;
    UIView *cov = [self childSubOutletForInt:self.selectedChildOutlet];
    
    CGFloat toX = cov.center.x - snv.center.x;
    CGFloat toY = cov.center.y - snv.center.y;
    __block CGAffineTransform transform = CGAffineTransformMakeTranslation(toX, toY);
    transform = CGAffineTransformScale(transform, 0.01f, 0.01f);
    
    [UIView animateWithDuration:kCvAnimationDuration animations:^{
        snv.transform = transform;
    } completion:^(BOOL finished) {
        [snv removeFromSuperview];
    }];
}

- (void)addChildTraveler {
    NSInteger childOrder = [ChildTraveler addChildTraveler];
    
    __weak UIView *childSubView = [self childSubOutletForInt:childOrder];
    
    CGFloat fromX = self.numberKidsLabelOutlet.center.x - childSubView.center.x;
    CGFloat fromY = self.numberKidsLabelOutlet.center.y - childSubView.center.y;
    
    CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromX, fromY);
    fromTransform = CGAffineTransformScale(fromTransform, 0.01f, 0.01f);
    childSubView.transform = fromTransform;
    childSubView.hidden = NO;
    
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
    toTransform = CGAffineTransformScale(toTransform, 1.0f, 1.0f);
    
    [childSubView.superview bringSubviewToFront:childSubView];
    
    [UIView animateWithDuration:kCvAnimationDuration animations:^{
        childSubView.transform = toTransform;
    } completion:^(BOOL finished) {
        ;
    }];
    
    [self updateNumberOfKidsLabel];
}

- (void)removeChildTraveler {
    NSInteger childOrder = [ChildTraveler removeLastChildTraveler];
    
    __weak ChildSubView *childSubView = [self childSubOutletForInt:childOrder];
    
    CGFloat toX = self.numberKidsLabelOutlet.center.x - childSubView.center.x;
    CGFloat toY = self.numberKidsLabelOutlet.center.y - childSubView.center.y;
    
    __block CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toX, toY);
    toTransform = CGAffineTransformScale(toTransform, 0.01f, 0.01f);
    
    [UIView animateWithDuration:kCvAnimationDuration animations:^{
        childSubView.transform = toTransform;
    } completion:^(BOOL finished) {
        childSubView.worbelOutlet.text = @"Select age";
        childSubView.hidden = YES;
    }];
    
    [self updateNumberOfKidsLabel];
}

- (void)updateNumberOfKidsLabel {
    NSUInteger numberOfKids = [ChildTraveler numberOfKids];
    NSString *plural = numberOfKids == 1 ? @"Child" : @"Children";
    id numbKids = numberOfKids == 0 ? @"Add" : [NSString stringWithFormat:@"%lu", (unsigned long) numberOfKids];
    self.numberKidsLabelOutlet.text = [NSString stringWithFormat:@"%@ %@", numbKids, plural];
}

- (ChildSubView *)childSubOutletForInt:(NSUInteger)childOrder {
    switch (childOrder) {
        case 1:
            return self.childOneOutlet;
        case 2:
            return self.childTwoOutlet;
        case 3:
            return self.childThreeOutlet;
        case 4:
            return self.childFourOutlet;
        default:
            return nil;
    }
}

- (NSUInteger)intForChildSubOutlet:(UIView *)view {
    if (view == self.childOneOutlet) {
        return 1;
    } else if (view == self.childTwoOutlet) {
        return 2;
    } else if (view == self.childThreeOutlet) {
        return 3;
    } else if (view == self.childFourOutlet) {
        return 4;
    } else {
        return 0;
    }
}

#pragma mark Setup some views

- (void)resetPickerViewSelectedRow {
    ChildTraveler *kid = [ChildTraveler childTravelerForId:self.selectedChildOutlet];
    if (kid.ageHasBeenSet) {
        [self.pickerView selectRow:(kid.childAge + 1) inComponent:0 animated:NO];
    } else {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

- (UIView *)childAgeSelectorView {
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.autoresizesSubviews = YES;
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.selectorViewLabel];
    [view addSubview:self.doneButton];
    [view addSubview:self.pickerView];
    
    return view;
}

- (void)setupLabelForAgeSelector {
    _selectorViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 32)];
    _selectorViewLabel.backgroundColor = [UIColor clearColor];
    _selectorViewLabel.text = @"Select child's age";
    _selectorViewLabel.textColor = [UIColor blackColor];
    _selectorViewLabel.font = [UIFont boldSystemFontOfSize:16.0f];
}

- (void)setupDoneButton {
    self.doneButton = [WotaButton wbWithFrame:CGRectMake(255, 5, 60, 32)];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTheAgePickerViewAndData {
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 87, 320, 162)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    _pickerData = [NSMutableArray arrayWithObjects:@"", @"Less than 1", @"1 year old", nil];
    
    for (int j = 2; j < 18; j++) {
        [_pickerData addObject:[NSString stringWithFormat:@"%d years old", j]];
    }
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerData.count;
}

#pragma mark UIPickerViewDelegate methods

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self modifyChildTravelerWithDrop:NO];
}

@end
