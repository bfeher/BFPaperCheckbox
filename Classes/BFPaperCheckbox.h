//
//  BFPaperCheckbox.h
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


#import <UIKit/UIKit.h>

@class BFPaperCheckbox;
@protocol BFPaperCheckboxDelegate <NSObject>
@optional
/** An optional protocol method for detecting when the checkbox state changed. You can check its current state here with 'checkbox.isChecked'. */
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox;
@end

@interface BFPaperCheckbox : UIButton <UIGestureRecognizerDelegate>
/** A UIColor to use for the checkmark color. Note that self.tintColor will be used for the square box color. */
@property UIColor *checkmarkColor;

/** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
@property BOOL rippleFromTapLocation;

/** The UIColor to use for the circle which appears where you tap to check the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
@property UIColor *tapCirclePositiveColor;

/** The UIColor to use for the circle which appears where you tap to uncheck the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
@property UIColor *tapCircleNegativeColor;

/** A BOOL representing the state of the checkbox. YES means checked, NO means unchecked. **/
@property (nonatomic, readonly) BOOL isChecked;

/** A delegate to use our protocol with! */
@property (weak) id <BFPaperCheckboxDelegate> delegate;

/** A nice recommended value for size. (eg. [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultRadius * 2, bfPaperCheckboxDefaultRadius * 2)]; */
extern CGFloat const bfPaperCheckboxDefaultRadius;

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
