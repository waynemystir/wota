//
//  ChildViewController.m
//  ota-ios
//
//  Created by WAYNE SMALL on 3/29/15.
//  Copyright (c) 2015 Irwin. All rights reserved.
//

#import "ChildViewController.h"
#import "ChildSubView.h"
#import "ChildTraveler.h"
#import "ChildAgeSelectorViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "AppEnvironment.h"

NSTimeInterval const kAnimationDuration = 0.6;

@interface ChildViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *numberKidsLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *minusChildButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *addChildButtonOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childOneOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childTwoOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childThreeOutlet;
@property (weak, nonatomic) IBOutlet ChildSubView *childFourOutlet;
@property (nonatomic) NSUInteger selectedChildOutlet;
@property (nonatomic, strong) UILabel *selectorViewLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *pickerData;

- (IBAction)justPushIt:(id)sender;

@end

@implementation ChildViewController

- (id)init {
    self = [super initWithNibName:@"ChildView" bundle:nil];
    return self;
}

#pragma mark View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIfWeCanAddKids];
    [self checkIfWeCanRemoveKids];
    
    [self updateNumberOfKidsLabel];
    
    [self setupLabelForAgeSelector];
    [self setupDoneButton];
    [self setupTheAgePickerViewAndData];
    
    self.childOneOutlet.childAbcdLabelOutlet.text = @"Child One";
    self.childTwoOutlet.childAbcdLabelOutlet.text = @"Child Two";
    self.childThreeOutlet.childAbcdLabelOutlet.text = @"Child Three";
    self.childFourOutlet.childAbcdLabelOutlet.text = @"Child Four";
    
    [self setAgeLabelsAndTapGestures];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Get those kids whose ages have not been set
    NSDictionary *kidsWithoutAges = [ChildTraveler childTravelersWithoutAges];
    
    // And set their ages to the arbitrary value of 10
    // TODO: parameterize this value of 10 with a constant variable
    for (ChildTraveler *ct in [kidsWithoutAges objectEnumerator]) {
        ct.childAge = 10;
    }
}

#pragma mark Various methods

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
    
    [self.view addSubview:asv];
    [UIView animateWithDuration:kAnimationDuration animations:^{
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
    if (sender == self.doneButton) {
        [self modifyChildTraveler];
    } else if (sender == self.minusChildButtonOutlet) {
        [self removeChildTraveler];
        [self checkIfWeCanRemoveKids];
        [self checkIfWeCanAddKids];
    } else if (sender == self.addChildButtonOutlet) {
        [self addChildTraveler];
        [self checkIfWeCanAddKids];
        [self checkIfWeCanRemoveKids];
    } else {
        NSLog(@"Dude we've got a problem");
    }
}

- (void)modifyChildTraveler {
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
    
    // Remove the child age selector view
    __block UIView *snv = self.doneButton.superview;
    UIView *cov = [self childSubOutletForInt:self.selectedChildOutlet];
    
    CGFloat toX = cov.center.x - snv.center.x;
    CGFloat toY = cov.center.y - snv.center.y;
    __block CGAffineTransform transform = CGAffineTransformMakeTranslation(toX, toY);
    transform = CGAffineTransformScale(transform, 0.01f, 0.01f);
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
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
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
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
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
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
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.autoresizesSubviews = YES;
    view.backgroundColor = UIColorFromRGB(0xD2D2D2);
    [view addSubview:self.selectorViewLabel];
    [view addSubview:self.doneButton];
    [view addSubview:self.pickerView];
    
    return view;
}

- (void)setupLabelForAgeSelector {
    self.selectorViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 40)];
    self.selectorViewLabel.backgroundColor = [UIColor grayColor];
    self.selectorViewLabel.text = @"Select child's age";
}

- (void)setupDoneButton {
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 100, 40)];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor yellowColor];
    [self.doneButton addTarget:self action:@selector(justPushIt:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTheAgePickerViewAndData {
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 50, 300, 240)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    _pickerData = [NSMutableArray array];
    [_pickerData addObjectsFromArray:@[@"", @"Less than 1", @"1 year old"]];
    
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

@end
