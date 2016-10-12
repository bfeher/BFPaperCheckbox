//
//  BFPaperViewController.m
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


#import "BFPaperViewController.h"
// Classes:
#import "BFPaperCheckbox.h"


@interface BFPaperViewController () <BFPaperCheckboxDelegate>
// Standard switch for comparison:
@property (weak, nonatomic) IBOutlet UISwitch *standardSwitch;
@property (weak, nonatomic) IBOutlet UILabel *standardSwitchLabel;
// BFPaperCheckboxes, both IB and programmatically created:
@property (weak, nonatomic) IBOutlet BFPaperCheckbox *storyboardPaperCheckbox;
@property (weak, nonatomic) IBOutlet UILabel *storyboardPaperCheckboxLabel;
@property BFPaperCheckbox *programmaticPaperCheckbox;
@property UILabel *programmaticPaperCheckboxLabel;
@end


@implementation BFPaperViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set ourselves to tbe delegate of the standard switch:
    self.storyboardPaperCheckbox.delegate = self;   // Note that this guy is completely customized in the storyboard. Check out it's properties inspector and play around :)
    
    // Create and modify another BFPaperCheckbox programmatically:
    self.programmaticPaperCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, 0, bfPaperCheckboxDefaultDiameter, bfPaperCheckboxDefaultDiameter)];
    self.programmaticPaperCheckbox.tag = 1002;
    self.programmaticPaperCheckbox.delegate = self;
    self.programmaticPaperCheckbox.tintColor = [UIColor colorWithRed:97.f/255.f green:97.f/255.f blue:97.f/255.f alpha:1];
    // Note, we will use default values for the rest, change them yourself to experiment and find a setup you like :)
    self.programmaticPaperCheckbox.touchUpAnimationDuration = -1;
    self.programmaticPaperCheckbox.touchDownAnimationDuration = -1;
    self.programmaticPaperCheckbox.rippleFromTapLocation = NO;
    self.programmaticPaperCheckbox.checkmarkColor = nil;
    self.programmaticPaperCheckbox.positiveColor = nil;
    self.programmaticPaperCheckbox.negativeColor = nil;
    self.programmaticPaperCheckbox.startDiameter = -1;
    self.programmaticPaperCheckbox.endDiameter = 0;
    self.programmaticPaperCheckbox.burstAmount = 0;
    
    [self.view addSubview:self.programmaticPaperCheckbox];
    
    // Setup the label for our programmaticPaperCheckbox:
    self.programmaticPaperCheckboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 286, 21)];
    self.programmaticPaperCheckboxLabel.minimumScaleFactor = 0.5f;
    self.programmaticPaperCheckboxLabel.text = @"Programmatic [OFF]";
    [self.view addSubview:self.programmaticPaperCheckboxLabel];
    
    
    // Set up a standard switch:
    self.standardSwitch.tintColor = [UIColor colorWithRed:97.f/255.f green:97.f/255.f blue:97.f/255.f alpha:1];
    self.standardSwitch.onTintColor = [UIColor colorWithRed:76.f/255.f green:175.f/255.f blue:80.f/255.f alpha:1];
    [self.standardSwitch addTarget:self action:@selector(standardSwitchChangedState:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Autolayout code; you can ignore this.
    self.programmaticPaperCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    self.programmaticPaperCheckboxLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckbox
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1 constant:bfPaperCheckboxDefaultDiameter];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckbox
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1 constant:bfPaperCheckboxDefaultDiameter];
    [self.programmaticPaperCheckbox addConstraints:@[widthConstraint, heightConstraint]];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckbox
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.storyboardPaperCheckbox
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *verticalSpacingConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckbox
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.storyboardPaperCheckbox
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1 constant:18];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckboxLabel
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.programmaticPaperCheckbox
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1 constant:0];
    NSLayoutConstraint *leadingLabelConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckboxLabel
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.programmaticPaperCheckbox
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1 constant:8];
    NSLayoutConstraint *trailingLabelConstraint = [NSLayoutConstraint constraintWithItem:self.programmaticPaperCheckboxLabel
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeTrailingMargin
                                                                              multiplier:1 constant:0];
    [self.view addConstraints:@[centerXConstraint, verticalSpacingConstraint, centerYConstraint, leadingLabelConstraint, trailingLabelConstraint]];
}


- (IBAction)tapped:(UIButton *)sender {
    BOOL animate;
    if (sender.tag == 2001) {       // animate button tag
        animate = YES;
    }
    else if (sender.tag == 2002) {  // static button tag
        animate = NO;
    }
    // Animate our standard switch:
    if (self.standardSwitch.isOn) {
        [self.standardSwitch setOn:NO animated:animate];
    } else {
        [self.standardSwitch setOn:YES animated:animate];
    }
    [self standardSwitchChangedState:self.standardSwitch];

    /*
     * Below are the two ways of programmatically setting the state of a checkbox.
     */
    // (1) Swap storyboardPaperCheckbox state with the 'switchStates...' method:
    [self.storyboardPaperCheckbox switchStatesAnimated:animate];
    
    // (2) Swap programmaticPaperCheckbox's state with the 'check...'/'uncheck...' methods:
    if (self.programmaticPaperCheckbox.isChecked) {
        [self.programmaticPaperCheckbox uncheckAnimated:animate];
    }
    else {
        [self.programmaticPaperCheckbox checkAnimated:animate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UISwitch Delegate
- (IBAction)standardSwitchChangedState:(UISwitch *)sender {
    self.standardSwitchLabel.text = sender.isOn ? @"Standard switch [ON]" : @"Standard switch [OFF]";
}

#pragma mark - BFPaperCheckbox Delegate
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox
{
    if (checkbox.tag == 1001) {      // First box
        self.storyboardPaperCheckboxLabel.text = self.storyboardPaperCheckbox.isChecked ? @"IB Custom [ON]" : @"IB Custom [OFF]";
    }
    else if (checkbox.tag == 1002) { // Second box
        self.programmaticPaperCheckboxLabel.text = self.programmaticPaperCheckbox.isChecked ? @"Programmatic [ON]" : @"Programmatic [OFF]";
    }
}

@end
