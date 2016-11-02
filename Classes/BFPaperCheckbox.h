//
//  BFPaperCheckbox.h
//  BFPaperCheckbox
//
//  Created by Bence Feher on 7/22/14.
//  Last updated by Bence Feher on 10/12/2016.
//  Copyright (c) 2016 Bence Feher. All rights reserved.
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


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class BFPaperCheckbox;
@protocol BFPaperCheckboxDelegate <NSObject>
@optional
/** An optional protocol method for detecting when the checkbox state changed. You can check its current state here with 'checkbox.isChecked'. */
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox;
@end


IB_DESIGNABLE
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
// CAAnimationDelegate is not available before iOS 10 SDK
@interface BFPaperCheckbox : UIControl <UIGestureRecognizerDelegate>
#else
@interface BFPaperCheckbox : UIControl <UIGestureRecognizerDelegate,CAAnimationDelegate>
#endif

#pragma mark - Constants
/** A nice recommended value for size. (eg. [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultDiameter, bfPaperCheckboxDefaultDiameter)]; */
extern CGFloat const bfPaperCheckboxDefaultDiameter;


#pragma mark - Properties
#pragma mark Animation
/** (Go Steelers!) A CGFLoat representing the duration of the animations which take place on touch DOWN! Default is 0.25f seconds.  Note that negative values will be converted to the default. NO FUNNY BUSINESS! */
@property IBInspectable CGFloat touchDownAnimationDuration;
/** A CGFLoat representing the duration of the animations which take place on touch UP! Default is 2 * touchDownAnimationDuration seconds. Note that negative values will be converted to the default. NO FUNNY BUSINESS! */
@property IBInspectable CGFloat touchUpAnimationDuration;

/** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is NO. */
@property IBInspectable BOOL rippleFromTapLocation;

#pragma mark Colors
/** A UIColor to use for the checkmark color. Note that 'self.tintColor' will be used for the square box color. */
@property IBInspectable UIColor *checkmarkColor;

/** The UIColor to use for the circle which appears where you tap to check the box. Default value is calculated from the '.checkmarkColor' property. Set to nil to access default. Alpha values less than 1 are recommended. */
@property IBInspectable UIColor *positiveColor;

/** The UIColor to use for the circle which appears where you tap to uncheck the box. Default value is calculated from the '.tintColor' property. Set to nil to access default. Alpha values less than 1 are recommended. */
@property IBInspectable UIColor *negativeColor;

#pragma mark Sizing
/** The CGFloat value representing the corner radius of the control. Default value is (bfPaperCheckboxDefaultDiameter / 2). Note that negative values will be converted to 0. NO FUNNY BUSINESS! */
@property (nonatomic) IBInspectable CGFloat cornerRadius;

/** A CGFLoat representing the diameter of the tap-circle as soon as it spawns, before it grows. Default is 1.f. Note that negative values and values less than 1 will be converted to the default. NO FUNNY BUSINESS! */
@property IBInspectable CGFloat startDiameter;

/** The CGFloat value representing the Diameter of the tap-circle. By default it will take up the entire checkbox background circle. Note that zero and negative values will be converted to the default. NO FUNNY BUSINESS! */
@property IBInspectable CGFloat endDiameter;

/** The CGFloat value representing how much we should increase the diameter of the tap-circle by when we burst it. Default is 0 because we can't see a burst with the default '.tapCircleDiameter' which takes up the entire frame. If you want to see a burst, make the '.tapCircleDiameter' something smaller than the diameter of the control itself. Note that negative values will be converted to the default. NO FUNNY BUSINESS! */
@property IBInspectable CGFloat burstAmount;

#pragma mark Status
/** A BOOL representing the state of the checkbox. YES means checked, NO means unchecked. **/
@property (nonatomic, readonly) BOOL isChecked;

#pragma mark Delegate
/** A delegate to use our protocol with! */
@property (weak) id <BFPaperCheckboxDelegate> delegate;


#pragma mark - Utility Functions
/**
 *  Use this function to manually/programmatically switch the state of this checkbox.
 *
 *  @param animated A BOOL flag to choose whether or not to animate the change.
 */
- (void)switchStatesAnimated:(BOOL)animated;

/**
 *  Use this function to manually check the checkbox. Does nothing if already checked.
 *
 *  @param animated A BOOL flag to choose whether or not to animate the change.
 */
- (void)checkAnimated:(BOOL)animated;

/**
 *  Use this function to manually uncheck the checkbox. Does nothing if already unchecked.
 *
 *  @param animated A BOOL flag to choose whether or not to animate the change.
 */
- (void)uncheckAnimated:(BOOL)animated;
@end
