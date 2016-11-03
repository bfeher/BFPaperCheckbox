//
//  BFPaperCheckbox.m
//  BFPaperCheckbox
//
//  Created by Bence Feher on 7/22/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Bence Feher
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "BFPaperCheckbox.h"


@interface BFPaperCheckbox()
@property CGPoint centerPoint;
@property (nonatomic, strong) CAShapeLayer *lineLeft;   // Also used for checkmark left, shorter line.
@property (nonatomic, strong) CAShapeLayer *lineTop;
@property (nonatomic, strong) CAShapeLayer *lineRight;
@property (nonatomic, strong) CAShapeLayer *lineBottom; // Also used for checkmark right, longer line.
@property CGPoint tapPoint;
@property NSMutableArray *rippleAnimationQueue;
@property NSMutableArray *deathRowForCircleLayers;  // This is where old circle layers go to be killed :(
@property int checkboxSidesCompletedAnimating;          // This should bounce between 0 and 4, representing the number of checkbox sides which have completed animating.
@property int checkmarkSidesCompletedAnimating;         // This should bounce between 0 and 2, representing the number of checkmark sides which have completed animating.
@property BOOL finishedAnimations;
@property (nonatomic, readwrite) BOOL isChecked;
@end


@implementation BFPaperCheckbox
@synthesize touchDownAnimationDuration = _touchDownAnimationDuration;
@synthesize touchUpAnimationDuration = _touchUpAnimationDuration;
@synthesize burstAmount = _burstAmount;
@synthesize checkmarkColor = _checkmarkColor;
@synthesize negativeColor = _negativeColor;
@synthesize positiveColor = _positiveColor;
#pragma mark - Constants
// -Button size:
CGFloat const bfPaperCheckboxDefaultDiameter = 49.f;
// -animation durations:
static CGFloat const bfPaperCheckbox_animationDurationConstant       = 0.12f;
// -checkbox's beauty:
static CGFloat const bfPaperCheckbox_checkboxSideLength              = 9.f;
// -animation function names:
// For spinning box clockwise while shrinking:
static NSString *const box_spinClockwiseAnimationLeftLine = @"leftLineSpin";
static NSString *const box_spinClockwiseAnimationTopLine = @"topLineSpin";
static NSString *const box_spinClockwiseAnimationRightLine = @"rightLineSpin";
static NSString *const box_spinClockwiseAnimationBottomLine = @"bottomLineSpin";
// For spinning box counterclockwise while growing:
static NSString *const box_spinCounterclockwiseAnimationLeftLine = @"leftLineSpin2";
static NSString *const box_spinCounterclockwiseAnimationTopLine = @"topLineSpin2";
static NSString *const box_spinCounterclockwiseAnimationRightLine = @"rightLineSpin2";
static NSString *const box_spinCounterclockwiseAnimationBottomLine = @"bottomLineSpin2";
// For drawing an empty checkbox:
static NSString *const box_drawLeftLine = @"leftLineStroke";
static NSString *const box_drawTopLine = @"topLineStroke";
static NSString *const box_drawRightLine = @"rightLineStroke";
static NSString *const box_drawBottomLine = @"bottomLineStroke";
// For drawing checkmark:
static NSString *const mark_drawShortLine = @"smallCheckmarkLine";
static NSString *const mark_drawLongLine = @"largeCheckmarkLine";
// For removing checkbox:
static NSString *const box_eraseLeftLine = @"leftLineStroke2";
static NSString *const box_eraseTopLine = @"topLineStroke2";
static NSString *const box_eraseRightLine = @"rightLineStroke2";
static NSString *const box_eraseBottomLine = @"bottomLineStroke2";
// removing checkmark:
static NSString *const mark_eraseShortLine = @"smallCheckmarkLine2";
static NSString *const mark_eraseLongLine = @"largeCheckmarkLine2";


#pragma mark - Default Initializers
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupWithDiameter:bfPaperCheckboxDefaultDiameter];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithDiameter:MAX(CGRectGetWidth(frame), CGRectGetHeight(frame))];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self setupWithDiameter:bfPaperCheckboxDefaultDiameter];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.isChecked) {
        [self drawCheckmarkAnimated:NO];
    } else {
        [self drawCheckBoxAnimated:NO];
    }
}


#pragma mark - Setters and Getters
- (CGFloat)touchDownAnimationDuration
{
    if (_touchDownAnimationDuration < 0) {
        return 0.25f;
    }
    return _touchDownAnimationDuration;
}
- (void)setTouchDownAnimationDuration:(CGFloat)touchDownAnimationDuration
{
    _touchUpAnimationDuration = touchDownAnimationDuration;
}

- (CGFloat)touchUpAnimationDuration
{
    if (_touchUpAnimationDuration < 0) {
        return self.touchDownAnimationDuration * 2.f;
    }
    return _touchUpAnimationDuration;
}
- (void)setTouchUpAnimationDuration:(CGFloat)touchUpAnimationDuration
{
    _touchUpAnimationDuration = touchUpAnimationDuration;
}

- (CGFloat)burstAmount
{
    if (_burstAmount < 0) {
        return 0;
    }
    return _burstAmount;
}
- (void)setBurstAmount:(CGFloat)burstAmount
{
    _burstAmount = burstAmount;
}

- (UIColor *)checkmarkColor
{
    if (!_checkmarkColor) {
        return [UIColor colorWithRed:76.f/255.f green:175.f/255.f blue:80.f/255.f alpha:1];
    }
    return _checkmarkColor;
}
- (void)setCheckmarkColor:(UIColor *)checkmarkColor
{
    _checkmarkColor = checkmarkColor;
}

- (UIColor *)negativeColor
{
    if (!_negativeColor) {
        UIColor *tint = self.tintColor;
        return [tint colorWithAlphaComponent:0.3f];
    }
    return _negativeColor;
}
- (void)setNegativeColor:(UIColor *)negativeColor
{
    _negativeColor = negativeColor;
}

- (UIColor *)positiveColor
{
    if (!_positiveColor) {
        return [self.checkmarkColor colorWithAlphaComponent:0.3f];
    }
    return _positiveColor;
}
- (void)setPositiveColor:(UIColor *)positiveColor
{
    _positiveColor = positiveColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = MAX(cornerRadius, 0);
    self.layer.cornerRadius = _cornerRadius;
    [self layoutSubviews];
}


#pragma mark - Setup
- (void)setupWithDiameter:(CGFloat)diameter
{
    // Defaults:
    self.finishedAnimations = YES;
    _isChecked = NO;
    self.tintColor = self.tintColor ? self.tintColor : [UIColor colorWithRed:97.f/255.f green:97.f/255.f blue:97.f/255.f alpha:1];
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    self.layer.shadowOpacity = 0.f;
    self.cornerRadius = diameter / 2.f;
    self.backgroundColor = [UIColor clearColor];
    
    self.rippleAnimationQueue = [NSMutableArray array];
    self.deathRowForCircleLayers = [NSMutableArray array];
    
    self.lineLeft   = [CAShapeLayer new];
    self.lineTop    = [CAShapeLayer new];
    self.lineRight  = [CAShapeLayer new];
    self.lineBottom = [CAShapeLayer new];
    
    [@[ self.lineLeft, self.lineTop, self.lineRight, self.lineBottom ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.anchorPoint = CGPointMake(0.0, 0.0);
        layer.lineJoin = kCALineJoinRound;
        layer.lineCap = kCALineCapSquare;
        layer.contentsScale = self.layer.contentsScale;
        layer.lineWidth = 2.f;
        layer.strokeColor = self.tintColor.CGColor;
        
        
        // initialize with an empty path so we can animate the path w/o having to check for NULLs.
        CGPathRef dummyPath = CGPathCreateMutable();
        layer.path = dummyPath;
        CGPathRelease(dummyPath);
        
        [self.layer addSublayer:layer];
    }];
    
    [self drawCheckBoxAnimated:NO];

    
    [self addTarget:self action:@selector(paperTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(paperTouchUpAndSwitchStates:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(paperTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(paperTouchUp:) forControlEvents:UIControlEventTouchCancel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
}


#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    CGPoint location = [touch locationInView:self];
    //NSLog(@"location: x = %0.2f, y = %0.2f", location.x, location.y);
    
    self.tapPoint = location;
    
    return NO;  // Disallow recognition of tap gestures. We just needed this to grab that tasty tap location.
}


#pragma mark - IBAction/Callback Handlers
- (void)paperTouchDown:(BFPaperCheckbox *)sender
{
    //NSLog(@"Touch down handler");
    [self growTapCircle];
}


- (void)paperTouchUp:(BFPaperCheckbox *)sender
{
    //NSLog(@"Touch Up handler");
    [self fadeTapCircleOut];
}

- (void)paperTouchUpAndSwitchStates:(BFPaperCheckbox *)sender
{
    //NSLog(@"Touch Up handler with switching states");
    if (!self.finishedAnimations) {
        [self fadeTapCircleOut];
        return;
    }
    [self private_switchStatesAnimated:YES];
}


#pragma mark - Utility functions
#pragma mark Public
- (void)private_switchStatesAnimated:(BOOL)animated
{
    // Change states:
    self.isChecked = !self.isChecked;
    //NSLog(@"self.isChecked: %@", self.isChecked ? @"YES" : @"NO");

    // Notify our delegate that we changed states!
    [self.delegate paperCheckboxChangedState:self];
    

    if (self.isChecked) {
        // Shrink checkBOX:
        [self spinCheckboxAnimated:animated withAngle1:M_PI_4 andAngle2:-5*M_PI_4 andRadiusDenominator:4.f forDuration:bfPaperCheckbox_animationDurationConstant];
    }
    else {
        // Shrink checkMARK:
        [self shrinkAwayCheckmarkAnimated:animated];
    }
    [self fadeTapCircleOut];
}

- (void)switchStatesAnimated:(BOOL)animated
{
    // As long as this comment remains, Animating the change will take the regular path, statically changing the state will take a second path. I would like to combine the two but right now this is faster and easier.
    if (animated) {
        [self private_switchStatesAnimated:animated];  // setting to NO will break everything as a non-animated version of this function does not yet exist.
    }
    else {
        self.isChecked ? [self uncheckAnimated:animated] : [self checkAnimated:animated];
    }
}

- (void)checkAnimated:(BOOL)animated
{
    if (self.isChecked) {
        return;
    }
    self.isChecked = YES;
    
    // Notify our delegate that we changed states!
    [self.delegate paperCheckboxChangedState:self];

    if (animated) {
        [self spinCheckboxAnimated:animated withAngle1:M_PI_4 andAngle2:-5*M_PI_4 andRadiusDenominator:4.f forDuration:bfPaperCheckbox_animationDurationConstant];
    }
    else {
        [self drawCheckmarkAnimated:animated];
    }
}

- (void)uncheckAnimated:(BOOL)animated
{
    if (!self.isChecked) {
        return;
    }
    self.isChecked = NO;
    
    // Notify our delegate that we changed states!
    [self.delegate paperCheckboxChangedState:self];

    if (animated) {
        [self shrinkAwayCheckmarkAnimated:animated];
    }
    else {
        [self drawCheckBoxAnimated:animated];
    }
}

#pragma mark Private
- (CGFloat)calculateTapCircleFinalDiameter
{
    CGFloat finalDiameter = self.endDiameter;
    if (self.endDiameter <= 0) {
        // Calulate a diameter that will always cover the entire button:
        //////////////////////////////////////////////////////////////////////////////
        // Special thanks to github user @ThePantsThief for providing this code!    //
        //////////////////////////////////////////////////////////////////////////////
        CGFloat centerWidth   = self.frame.size.width;
        CGFloat centerHeight  = self.frame.size.height;
        CGFloat tapWidth      = 2 * MAX(self.tapPoint.x, centerWidth - self.tapPoint.x);
        CGFloat tapHeight     = 2 * MAX(self.tapPoint.y, centerHeight - self.tapPoint.y);
        CGFloat desiredWidth  = self.rippleFromTapLocation ? tapWidth : centerWidth;
        CGFloat desiredHeight = self.rippleFromTapLocation ? tapHeight : centerHeight;
        CGFloat diameter      = sqrt(pow(desiredWidth, 2) + pow(desiredHeight, 2));
        finalDiameter = diameter;
    }
    return finalDiameter;
}

- (CGFloat)calculateTapCircleStartingDiameter
{
    if (self.startDiameter <= 1) {
        return 1.f;
    } else {
        return self.startDiameter;
    }
}

- (CGPathRef)createCenteredLineWithRadius:(CGFloat)radius angle:(CGFloat)angle offset:(CGPoint)offset
// you are responsible for releasing the return CGPath
{
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    float c = cosf(angle);
    float s = sinf(angle);
    
    CGPathMoveToPoint(path, NULL,
                      self.centerPoint.x + offset.x + radius * c,
                      self.centerPoint.y + offset.y + radius * s);
    CGPathAddLineToPoint(path, NULL,
                         self.centerPoint.x + offset.x - radius * c,
                         self.centerPoint.y + offset.y - radius * s);
    
    return path;
}


#pragma mark - Animation
- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");
    
    // Spawn a growing circle that "ripples" through the button:
    // Calculate the tap circle's starting diameter:
    CGFloat tapCircleStartingDiameter = [self calculateTapCircleStartingDiameter];
    // Calculate the tap circle's ending diameter:
    CGFloat tapCircleFinalDiameter = [self calculateTapCircleFinalDiameter];

    
    // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    tapCircleLayerSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Calculate starting path:
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleStartingDiameter, tapCircleStartingDiameter)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create starting circle path:
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:tapCircleStartingDiameter / 2.f];
    
    // Calculate ending path:
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    endingRectSizerView.center = tapCircleLayerSizerView.center;
    
    // Create ending circle path:
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];
    
    // Create tap circle:
    CAShapeLayer *tapCircle = [CAShapeLayer layer];
    tapCircle.strokeColor = [UIColor clearColor].CGColor;
    tapCircle.borderColor = [UIColor clearColor].CGColor;
    tapCircle.borderWidth = 0;
    tapCircle.path = startingCirclePath.CGPath;
    // Set tap circle layer's background color:
    if (self.isChecked) {
        // It is currently checked, so we are unchecking it:
        UIColor *negativeColor = self.negativeColor;
        tapCircle.fillColor = negativeColor.CGColor;
    }
    else {
        // It is currently unchecked, so we are checking it:
        UIColor *positiveColor = self.positiveColor;
        tapCircle.fillColor = positiveColor.CGColor;
    }

    
    // Add tap circle to array and view:
    [self.rippleAnimationQueue addObject:tapCircle];
    [self.layer insertSublayer:tapCircle atIndex:0];
    
    
    /*
     * Animations:
     */
    // Grow tap-circle animation (performed on mask layer):
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.delegate = self;
    [tapCircleGrowthAnimation setValue:@"tapGrowth" forKey:@"id"];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    tapCircleGrowthAnimation.duration = self.touchDownAnimationDuration;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    // Fade in self.animationLayer:
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = bfPaperCheckbox_animationDurationConstant;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    // Add the animations to the layers:
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tapCircle addAnimation:fadeIn forKey:@"opacityAnimation"];
}

- (void)fadeTapCircleOut
{
    // Calculate the tap circle's ending diameter:
    CGFloat tapCircleFinalDiameter = [self calculateTapCircleFinalDiameter];
    tapCircleFinalDiameter += self.burstAmount;
    
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    endingRectSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Create ending circle path for mask:
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];

    // Get the next tap circle to expand:
    CAShapeLayer *tapCircle = [self.rippleAnimationQueue firstObject];
    if (nil != tapCircle) {
        if (self.rippleAnimationQueue.count > 0) {
            [self.rippleAnimationQueue removeObjectAtIndex:0];
        }
        [self.deathRowForCircleLayers addObject:tapCircle];
        
        CGPathRef startingPath = tapCircle.path;
        CGFloat startingOpacity = tapCircle.opacity;
        
        if ([[tapCircle animationKeys] count] > 0) {
            startingPath = [[tapCircle presentationLayer] path];
            startingOpacity = [[tapCircle presentationLayer] opacity];
        }
        
        // Burst tap-circle:
        CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        tapCircleGrowthAnimation.duration = self.touchUpAnimationDuration;
        tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        tapCircleGrowthAnimation.fromValue = (__bridge id)startingPath;
        tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
        tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
        tapCircleGrowthAnimation.removedOnCompletion = NO;
        
        // Fade tap-circle out:
        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeOut setValue:@"fadeCircleOut" forKey:@"id"];
        fadeOut.delegate = self;
        fadeOut.fromValue = [NSNumber numberWithFloat:startingOpacity];
        fadeOut.toValue = [NSNumber numberWithFloat:0.f];
        fadeOut.duration = self.touchUpAnimationDuration;
        fadeOut.fillMode = kCAFillModeForwards;
        fadeOut.removedOnCompletion = NO;
        
        [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
        [tapCircle addAnimation:fadeOut forKey:@"opacityAnimation"];
    }
}

- (void)drawCheckBoxAnimated:(BOOL)animated
{
    self.lineLeft.opacity   = 1;
    self.lineTop.opacity    = 1;
    self.lineRight.opacity  = 1;
    self.lineBottom.opacity = 1;
    
    // Using layers and paths:
    CGPathRef newLeftPath   = NULL;
    CGPathRef newTopPath    = NULL;
    CGPathRef newRightPath  = NULL;
    CGPathRef newBottomPath = NULL;
    
    newLeftPath = [self createCenteredLineWithRadius:bfPaperCheckbox_checkboxSideLength angle:M_PI_2 offset:CGPointMake(-bfPaperCheckbox_checkboxSideLength, 0)];
    newTopPath = [self createCenteredLineWithRadius:bfPaperCheckbox_checkboxSideLength angle:0 offset:CGPointMake(0, -bfPaperCheckbox_checkboxSideLength)];
    newRightPath = [self createCenteredLineWithRadius:bfPaperCheckbox_checkboxSideLength angle:M_PI_2 offset:CGPointMake(bfPaperCheckbox_checkboxSideLength, 0)];
    newBottomPath = [self createCenteredLineWithRadius:bfPaperCheckbox_checkboxSideLength angle:0 offset:CGPointMake(0, bfPaperCheckbox_checkboxSideLength)];
    
    if (animated) {
        {
            CABasicAnimation *lineLeftAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineLeftAnimation.removedOnCompletion = NO;
            lineLeftAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineLeftAnimation.fromValue = (__bridge id)self.lineLeft.path;
            lineLeftAnimation.toValue = (__bridge id)newLeftPath;
            [lineLeftAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineLeftAnimation setValue:box_drawLeftLine forKey:@"id"];
            lineLeftAnimation.delegate = self;
            [self.lineLeft addAnimation:lineLeftAnimation forKey:@"animateLeftLinePath"];
            
            CABasicAnimation *leftLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            leftLineColorAnimation.removedOnCompletion = NO;
            leftLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            leftLineColorAnimation.fromValue = (__bridge id)self.lineLeft.strokeColor;
            leftLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [leftLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineLeft addAnimation:leftLineColorAnimation forKey:@"animateLeftLineStrokeColor"];
        }
        {
            CABasicAnimation *lineTopAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineTopAnimation.removedOnCompletion = NO;
            lineTopAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineTopAnimation.fromValue = (__bridge id)self.lineTop.path;
            lineTopAnimation.toValue = (__bridge id)newTopPath;
            [lineTopAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineTopAnimation setValue:box_drawTopLine forKey:@"id"];
            lineTopAnimation.delegate = self;
            [self.lineTop addAnimation:lineTopAnimation forKey:@"animateTopLinePath"];
            
            CABasicAnimation *topLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            topLineColorAnimation.removedOnCompletion = NO;
            topLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            topLineColorAnimation.fromValue = (__bridge id)self.lineTop.strokeColor;
            topLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [topLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineTop addAnimation:topLineColorAnimation forKey:@"animateTopLineStrokeColor"];
        }
        {
            CABasicAnimation *lineRightAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineRightAnimation.removedOnCompletion = NO;
            lineRightAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineRightAnimation.fromValue = (__bridge id)self.lineRight.path;
            lineRightAnimation.toValue = (__bridge id)newRightPath;
            [lineRightAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineRightAnimation setValue:box_drawRightLine forKey:@"id"];
            lineRightAnimation.delegate = self;
            [self.lineRight addAnimation:lineRightAnimation forKey:@"animateRightLinePath"];
            
            CABasicAnimation *rightLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            rightLineColorAnimation.removedOnCompletion = NO;
            rightLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            rightLineColorAnimation.fromValue = (__bridge id)self.lineRight.strokeColor;
            rightLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [rightLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineRight addAnimation:rightLineColorAnimation forKey:@"animateRightLineStrokeColor"];
        }
        {
            CABasicAnimation *lineBottomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineBottomAnimation.removedOnCompletion = NO;
            lineBottomAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineBottomAnimation.fromValue = (__bridge id)self.lineBottom.path;
            lineBottomAnimation.toValue = (__bridge id)newBottomPath;
            [lineBottomAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineBottomAnimation setValue:box_drawBottomLine forKey:@"id"];
            lineBottomAnimation.delegate = self;
            [self.lineBottom addAnimation:lineBottomAnimation forKey:@"animateBottomLinePath"];
            
            CABasicAnimation *bottomLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            bottomLineColorAnimation.removedOnCompletion = NO;
            bottomLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            bottomLineColorAnimation.fromValue = (__bridge id)self.lineBottom.strokeColor;
            bottomLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [bottomLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineBottom addAnimation:bottomLineColorAnimation forKey:@"animateBottomLineStrokeColor"];
        }
    }
    
    self.lineLeft.path = newLeftPath;
    self.lineTop.path = newTopPath;
    self.lineRight.path = newRightPath;
    self.lineBottom.path = newBottomPath;
    
    self.lineLeft.strokeColor = self.tintColor.CGColor;
    self.lineTop.strokeColor = self.tintColor.CGColor;
    self.lineRight.strokeColor = self.tintColor.CGColor;
    self.lineBottom.strokeColor = self.tintColor.CGColor;
    
    CGPathRelease(newLeftPath);
    CGPathRelease(newTopPath);
    CGPathRelease(newRightPath);
    CGPathRelease(newBottomPath);
}

- (void)spinCheckboxAnimated:(BOOL)animated withAngle1:(CGFloat)angle1
                   andAngle2:(CGFloat)angle2
        andRadiusDenominator:(CGFloat)radiusDenominator
                 forDuration:(CGFloat)duration
{
    //NSLog(@"self.isChecked: %@", self.isChecked ? @"YES" : @"NO");
    
    self.finishedAnimations = NO;
    self.checkmarkSidesCompletedAnimating = 0;
    
    self.lineLeft.opacity   = 1;
    self.lineTop.opacity    = 1;
    self.lineRight.opacity  = 1;
    self.lineBottom.opacity = 1;

    CGPathRef newLeftPath   = NULL;
    CGPathRef newTopPath    = NULL;
    CGPathRef newRightPath  = NULL;
    CGPathRef newBottomPath = NULL;
    
    CGFloat ratioDenominator = radiusDenominator * 4;
    CGFloat radius = bfPaperCheckbox_checkboxSideLength / radiusDenominator;
    CGFloat ratio = bfPaperCheckbox_checkboxSideLength / ratioDenominator;
    CGFloat offset = radius - ratio;
    CGPoint slightOffsetForCheckmarkCentering = CGPointMake(4, 9);  // Hardcoded in the most offensive way. Forgive me Father, for I have sinned.
    
    newLeftPath   = [self createCenteredLineWithRadius:radius angle:angle2 offset:CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y)];
    newTopPath    = [self createCenteredLineWithRadius:radius angle:angle1 offset:CGPointMake(offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y)];
    newRightPath  = [self createCenteredLineWithRadius:radius angle:angle2 offset:CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    newBottomPath = [self createCenteredLineWithRadius:radius angle:angle1 offset:CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    
    if (animated) {
        {
            // LEFT:
            CABasicAnimation *lineLeftAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineLeftAnimation.removedOnCompletion = NO;
            lineLeftAnimation.duration = duration;
            lineLeftAnimation.fromValue = (__bridge id)self.lineLeft.path;
            lineLeftAnimation.toValue = (__bridge id)newLeftPath;
            [lineLeftAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            lineLeftAnimation.delegate = self;
            [lineLeftAnimation setValue:(self.isChecked ? box_spinClockwiseAnimationLeftLine : box_spinCounterclockwiseAnimationLeftLine) forKey:@"id"];
            [self.lineLeft addAnimation:lineLeftAnimation forKey:@"spinLeftLine"];
        }
        {
            // TOP:
            CABasicAnimation *lineTopAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineTopAnimation.removedOnCompletion = NO;
            lineTopAnimation.duration = duration;
            lineTopAnimation.fromValue = (__bridge id)self.lineTop.path;
            lineTopAnimation.toValue = (__bridge id)newTopPath;
            [lineTopAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            lineTopAnimation.delegate = self;
            [lineTopAnimation setValue:(self.isChecked ? box_spinClockwiseAnimationTopLine : box_spinCounterclockwiseAnimationTopLine) forKey:@"id"];
            [self.lineTop addAnimation:lineTopAnimation forKey:@"spinTopLine"];
        }
        {
            // RIGHT:
            CABasicAnimation *lineRightAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineRightAnimation.removedOnCompletion = NO;
            lineRightAnimation.duration = duration;
            lineRightAnimation.fromValue = (__bridge id)self.lineRight.path;
            lineRightAnimation.toValue = (__bridge id)newRightPath;
            [lineRightAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            lineRightAnimation.delegate = self;
            [lineRightAnimation setValue:(self.isChecked ? box_spinClockwiseAnimationRightLine : box_spinCounterclockwiseAnimationRightLine) forKey:@"id"];
            [self.lineRight addAnimation:lineRightAnimation forKey:@"spinRightLine"];
        }
        {
            // BOTTOM:
            CABasicAnimation *lineBottomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineBottomAnimation.removedOnCompletion = NO;
            lineBottomAnimation.duration = duration;
            lineBottomAnimation.fromValue = (__bridge id)self.lineBottom.path;
            lineBottomAnimation.toValue = (__bridge id)newBottomPath;
            [lineBottomAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            lineBottomAnimation.delegate = self;
            [lineBottomAnimation setValue:(self.isChecked ? box_spinClockwiseAnimationBottomLine : box_spinCounterclockwiseAnimationBottomLine) forKey:@"id"];
            [self.lineBottom addAnimation:lineBottomAnimation forKey:@"spinBottomLine"];
        }
    }
    
    self.lineLeft.path = newLeftPath;
    self.lineTop.path = newTopPath;
    self.lineRight.path = newRightPath;
    self.lineBottom.path = newBottomPath;
    
    CGPathRelease(newLeftPath);
    CGPathRelease(newTopPath);
    CGPathRelease(newRightPath);
    CGPathRelease(newBottomPath);
}

- (void)shrinkAwayCheckboxAnimated:(BOOL)animated
// This function only modyfies the checkbox. When it's animation is complete, it calls a function to draw the checkmark.
{
    // Red dot for debugging
    /*CALayer *redDot = [[CALayer alloc] init];
    redDot.backgroundColor = [UIColor redColor].CGColor;
    redDot.frame = CGRectMake(CGRectGetMidX(self.bounds) - 3, CGRectGetMidY(self.bounds) + 11, 1, 1);
    [self.layer addSublayer:redDot];*/

    CGPathRef newLeftPath   = NULL;
    CGPathRef newTopPath    = NULL;
    CGPathRef newRightPath  = NULL;
    CGPathRef newBottomPath = NULL;
    
    CGFloat radiusDenominator = 20.f;
    CGFloat ratioDenominator = radiusDenominator * 4;
    CGFloat radius = bfPaperCheckbox_checkboxSideLength / radiusDenominator;
    CGFloat ratio = bfPaperCheckbox_checkboxSideLength / ratioDenominator;
    CGFloat offset = radius - ratio;
    CGPoint slightOffsetForCheckmarkCentering = CGPointMake(4, 9);  // Hardcoded in the most offensive way. Forgive me Father, for I have sinned.
    
    CGFloat duration = bfPaperCheckbox_animationDurationConstant / 4.f;
    
    newLeftPath   = [self createCenteredLineWithRadius:radius angle:-5 * M_PI_4 offset:CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y)];
    newTopPath    = [self createCenteredLineWithRadius:radius angle:M_PI_4 offset:CGPointMake(offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y)];
    newRightPath  = [self createCenteredLineWithRadius:radius angle:-5 * M_PI_4 offset:CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    newBottomPath = [self createCenteredLineWithRadius:radius angle:M_PI_4 offset:CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    
    if (animated) {
        {
            // LEFT:
            CABasicAnimation *lineLeftAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineLeftAnimation.removedOnCompletion = NO;
            lineLeftAnimation.duration = duration;
            lineLeftAnimation.fromValue = (__bridge id)self.lineLeft.path;
            lineLeftAnimation.toValue = (__bridge id)newLeftPath;
            [lineLeftAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineLeft addAnimation:lineLeftAnimation forKey:@"animateLeftLinePath"];
            
            CABasicAnimation *leftLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            leftLineColorAnimation.removedOnCompletion = NO;
            leftLineColorAnimation.duration = duration;
            leftLineColorAnimation.fromValue = (__bridge id)self.lineLeft.strokeColor;
            leftLineColorAnimation.toValue = (__bridge id)self.checkmarkColor.CGColor;
            [leftLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [leftLineColorAnimation setValue:box_eraseLeftLine forKey:@"id"];
            leftLineColorAnimation.delegate = self;
            [self.lineLeft addAnimation:leftLineColorAnimation forKey:@"animateLeftLineStrokeColor"];
            
        }
        {
            // TOP:
            CABasicAnimation *lineTopAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineTopAnimation.removedOnCompletion = NO;
            lineTopAnimation.duration = duration;
            lineTopAnimation.fromValue = (__bridge id)self.lineTop.path;
            lineTopAnimation.toValue = (__bridge id)newTopPath;
            [lineTopAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineTop addAnimation:lineTopAnimation forKey:@"animateTopLinePath"];
            
            CABasicAnimation *topLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            topLineColorAnimation.removedOnCompletion = NO;
            topLineColorAnimation.duration = duration;
            topLineColorAnimation.fromValue = (__bridge id)self.lineTop.strokeColor;
            topLineColorAnimation.toValue = (__bridge id)self.checkmarkColor.CGColor;
            [topLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [topLineColorAnimation setValue:box_eraseTopLine forKey:@"id"];
            topLineColorAnimation.delegate = self;
            [self.lineTop addAnimation:topLineColorAnimation forKey:@"animateTopLineStrokeColor"];
        }
        {
            // RIGHT:
            CABasicAnimation *lineRightAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineRightAnimation.removedOnCompletion = NO;
            lineRightAnimation.duration = duration;
            lineRightAnimation.fromValue = (__bridge id)self.lineRight.path;
            lineRightAnimation.toValue = (__bridge id)newRightPath;
            [lineRightAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineRight addAnimation:lineRightAnimation forKey:@"animateRightLinePath"];
            
            CABasicAnimation *rightLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            rightLineColorAnimation.removedOnCompletion = NO;
            rightLineColorAnimation.duration = duration;
            rightLineColorAnimation.fromValue = (__bridge id)self.lineRight.strokeColor;
            rightLineColorAnimation.toValue = (__bridge id)self.checkmarkColor.CGColor;
            [rightLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [rightLineColorAnimation setValue:box_eraseRightLine forKey:@"id"];
            rightLineColorAnimation.delegate = self;
            [self.lineRight addAnimation:rightLineColorAnimation forKey:@"animateRightLineStrokeColor"];
        }
        {
            // BOTTOM:
            CABasicAnimation *lineBottomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineBottomAnimation.removedOnCompletion = NO;
            lineBottomAnimation.duration = duration;
            lineBottomAnimation.fromValue = (__bridge id)self.lineBottom.path;
            lineBottomAnimation.toValue = (__bridge id)newBottomPath;
            [lineBottomAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineBottom addAnimation:lineBottomAnimation forKey:@"animateBottomLinePath"];
            
            CABasicAnimation *bottomLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            bottomLineColorAnimation.removedOnCompletion = NO;
            bottomLineColorAnimation.duration = duration;
            bottomLineColorAnimation.fromValue = (__bridge id)self.lineBottom.strokeColor;
            bottomLineColorAnimation.toValue = (__bridge id)self.checkmarkColor.CGColor;
            [bottomLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [bottomLineColorAnimation setValue:box_eraseBottomLine forKey:@"id"];
            bottomLineColorAnimation.delegate = self;
            [self.lineBottom addAnimation:bottomLineColorAnimation forKey:@"animateBottomLineStrokeColor"];
        }
    }
    
    self.lineLeft.path = newLeftPath;
    self.lineTop.path = newTopPath;
    self.lineRight.path = newRightPath;
    self.lineBottom.path = newBottomPath;
    
    self.lineLeft.strokeColor = self.checkmarkColor.CGColor;
    self.lineTop.strokeColor = self.checkmarkColor.CGColor;
    self.lineRight.strokeColor = self.checkmarkColor.CGColor;
    self.lineBottom.strokeColor = self.checkmarkColor.CGColor;
    
    CGPathRelease(newLeftPath);
    CGPathRelease(newTopPath);
    CGPathRelease(newRightPath);
    CGPathRelease(newBottomPath);
}

- (void)drawCheckmarkAnimated:(BOOL)animated
{
    self.lineLeft.opacity = 0;
    self.lineTop.opacity = 0;
    
    CGPathRef newRightPath  = NULL;
    CGPathRef newBottomPath = NULL;
    
    CGFloat checkmarkSmallSideLength = bfPaperCheckbox_checkboxSideLength * 0.6f;
    CGFloat checkmarkLargeSideLength = bfPaperCheckbox_checkboxSideLength * 1.3f;
    
    CGPoint smallSideOffset = CGPointMake(-9, 5);       // Hardcoded in the most offensive way.
    CGPoint largeSideOffset = CGPointMake(3.5, 0.5);    // Hardcoded in the most offensive way. Forgive me father, for I have sinned!
    

    // Right path will become the large part of the checkmark:
    newRightPath = [self createCenteredLineWithRadius:checkmarkLargeSideLength angle:-5 * M_PI_4 offset:largeSideOffset];
    
    // Bottom path will become the small part of the checkmark:
    newBottomPath = [self createCenteredLineWithRadius:checkmarkSmallSideLength angle:M_PI_4 offset:smallSideOffset];

    if (animated) {
        {
            // RIGHT:
            CABasicAnimation *lineRightAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineRightAnimation.removedOnCompletion = NO;
            lineRightAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineRightAnimation.fromValue = (__bridge id)self.lineRight.path;
            lineRightAnimation.toValue = (__bridge id)newRightPath;
            [lineRightAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineRightAnimation setValue:mark_drawLongLine forKey:@"id"];
            lineRightAnimation.delegate = self;
            [self.lineRight addAnimation:lineRightAnimation forKey:@"animateRightLinePath"];
        }
        {
            // BOTTOM:
            CABasicAnimation *lineBottomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineBottomAnimation.removedOnCompletion = NO;
            lineBottomAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineBottomAnimation.fromValue = (__bridge id)self.lineBottom.path;
            lineBottomAnimation.toValue = (__bridge id)newBottomPath;
            [lineBottomAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineBottomAnimation setValue:mark_drawShortLine forKey:@"id"];
            lineBottomAnimation.delegate = self;
            [self.lineBottom addAnimation:lineBottomAnimation forKey:@"animateBottomLinePath"];
        }
    }
    else {
        self.lineRight.strokeColor = self.checkmarkColor.CGColor;
        self.lineBottom.strokeColor = self.checkmarkColor.CGColor;
    }
    
    self.lineRight.path = newRightPath;
    self.lineBottom.path = newBottomPath;
    
    CGPathRelease(newRightPath);
    CGPathRelease(newBottomPath);
}

- (void)shrinkAwayCheckmarkAnimated:(BOOL)animated
// This function only modyfies the checkmark. When it's animation is complete, it calls a function to draw the checkbox.
{
    self.finishedAnimations = NO;
    self.checkmarkSidesCompletedAnimating = 0;
    
    CGPathRef newRightPath  = NULL;
    CGPathRef newBottomPath = NULL;
    
    CGFloat radiusDenominator = 18.f;
    CGFloat ratioDenominator = radiusDenominator * 4;
    CGFloat radius = bfPaperCheckbox_checkboxSideLength / radiusDenominator;
    CGFloat ratio = bfPaperCheckbox_checkboxSideLength / ratioDenominator;
    CGFloat offset = radius - ratio;
    CGPoint slightOffsetForCheckmarkCentering = CGPointMake(3, 11);
    
    newRightPath = [self createCenteredLineWithRadius:radius angle:-5 * M_PI_4 offset:CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    newBottomPath = [self createCenteredLineWithRadius:radius angle:M_PI_4 offset:CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y)];
    if (animated) {
        {
            // RIGHT:
            CABasicAnimation *lineRightAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineRightAnimation.removedOnCompletion = NO;
            lineRightAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineRightAnimation.fromValue = (__bridge id)self.lineRight.path;
            lineRightAnimation.toValue = (__bridge id)newRightPath;
            [lineRightAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineRightAnimation setValue:mark_eraseLongLine forKey:@"id"];
            lineRightAnimation.delegate = self;
            [self.lineRight addAnimation:lineRightAnimation forKey:@"animateRightLinePath"];
            
            CABasicAnimation *rightLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            rightLineColorAnimation.removedOnCompletion = NO;
            rightLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            rightLineColorAnimation.fromValue = (__bridge id)self.lineRight.strokeColor;
            rightLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [rightLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineRight addAnimation:rightLineColorAnimation forKey:@"animateRightLineStrokeColor"];
        }
        {
            // BOTTOM:
            CABasicAnimation *lineBottomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            lineBottomAnimation.removedOnCompletion = NO;
            lineBottomAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            lineBottomAnimation.fromValue = (__bridge id)self.lineBottom.path;
            lineBottomAnimation.toValue = (__bridge id)newBottomPath;
            [lineBottomAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [lineBottomAnimation setValue:mark_eraseShortLine forKey:@"id"];
            lineBottomAnimation.delegate = self;
            [self.lineBottom addAnimation:lineBottomAnimation forKey:@"animateBottomLinePath"];
            
            CABasicAnimation *bottomLineColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            bottomLineColorAnimation.removedOnCompletion = NO;
            bottomLineColorAnimation.duration = bfPaperCheckbox_animationDurationConstant;
            bottomLineColorAnimation.fromValue = (__bridge id)self.lineBottom.strokeColor;
            bottomLineColorAnimation.toValue = (__bridge id)self.tintColor.CGColor;
            [bottomLineColorAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.lineBottom addAnimation:bottomLineColorAnimation forKey:@"animateBottomLineStrokeColor"];
        }
    }
    
    self.lineRight.path = newRightPath;
    self.lineBottom.path = newBottomPath;
    
    self.lineLeft.strokeColor = self.tintColor.CGColor;
    self.lineTop.strokeColor = self.tintColor.CGColor;
    self.lineRight.strokeColor = self.tintColor.CGColor;
    self.lineBottom.strokeColor = self.tintColor.CGColor;
    
    CGPathRelease(newRightPath);
    CGPathRelease(newBottomPath);
}

#pragma mark Delegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    // Draw checkBOX:
    if ([[animation valueForKey:@"id"] isEqualToString:box_drawLeftLine]
        ||
        [[animation valueForKey:@"id"] isEqualToString:box_drawTopLine]
        ||
        [[animation valueForKey:@"id"] isEqualToString:box_drawRightLine]
        ||
        [[animation valueForKey:@"id"] isEqualToString:box_drawBottomLine]) {
        self.checkboxSidesCompletedAnimating++;
        
        if (self.checkboxSidesCompletedAnimating >= 4) {
            self.checkboxSidesCompletedAnimating = 0;
            self.finishedAnimations = YES;
            //NSLog(@"FINISHED drawing BOX");
        }
    }
    // Shrink away checkBOX:
    else if ([[animation valueForKey:@"id"] isEqualToString:box_eraseLeftLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_eraseTopLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_eraseRightLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_eraseBottomLine]) {
        self.checkboxSidesCompletedAnimating++;
        
        if (self.checkboxSidesCompletedAnimating >= 4) {
            //NSLog(@"FINISHED shrinking box");
            self.checkboxSidesCompletedAnimating = 0;
            [self drawCheckmarkAnimated:YES];
        }
    }
    // Spin checkBOX clockwise:
    else if ([[animation valueForKey:@"id"] isEqualToString:box_spinClockwiseAnimationLeftLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinClockwiseAnimationTopLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinClockwiseAnimationRightLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinClockwiseAnimationBottomLine]) {
        self.checkboxSidesCompletedAnimating++;
        
        if (self.checkboxSidesCompletedAnimating >= 4) {
            //NSLog(@"FINISHED spinning box CW");
            self.checkboxSidesCompletedAnimating = 0;
            [self shrinkAwayCheckboxAnimated:YES];
        }
    }
    // Spin checkBOX counter clockwise
    else if ([[animation valueForKey:@"id"] isEqualToString:box_spinCounterclockwiseAnimationLeftLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinCounterclockwiseAnimationTopLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinCounterclockwiseAnimationRightLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:box_spinCounterclockwiseAnimationBottomLine]) {
        self.checkboxSidesCompletedAnimating++;
        
        if (self.checkboxSidesCompletedAnimating >= 4) {
            //NSLog(@"FINISHED spinning box CCW");
            self.checkboxSidesCompletedAnimating = 0;
            self.finishedAnimations = YES;
            [self drawCheckBoxAnimated:YES];
            //NSLog(@"FINISHED animating 4 sides of checkbox");
        }
    }
    // Draw checkMARK
    else if ([[animation valueForKey:@"id"] isEqualToString:mark_drawShortLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:mark_drawLongLine]) {
        self.checkmarkSidesCompletedAnimating++;
        if (self.checkmarkSidesCompletedAnimating >= 2) {
            self.checkmarkSidesCompletedAnimating = 0;
            self.finishedAnimations = YES;
            //NSLog(@"FINISHED drawing checkmark");
        }
    }
    // Shrink checkMARK:
    else if ([[animation valueForKey:@"id"] isEqualToString:mark_eraseShortLine]
             ||
             [[animation valueForKey:@"id"] isEqualToString:mark_eraseLongLine]) {
        self.checkmarkSidesCompletedAnimating++;
        if (self.checkmarkSidesCompletedAnimating >= 2) {
            //NSLog(@"FINISHED shrinking checkmark");
            self.checkmarkSidesCompletedAnimating = 0;
            [self spinCheckboxAnimated:YES withAngle1:M_PI_4 andAngle2:-5*M_PI_4 andRadiusDenominator:4 forDuration:bfPaperCheckbox_animationDurationConstant / 2.f];
        }
    }
    // Remove tap-circles:
    else if ([[animation valueForKey:@"id"] isEqualToString:@"fadeCircleOut"]) {
        if (self.deathRowForCircleLayers.count > 0) {
            [[self.deathRowForCircleLayers objectAtIndex:0] removeFromSuperlayer];
            [self.deathRowForCircleLayers removeObjectAtIndex:0];
        }
    }
}

@end
