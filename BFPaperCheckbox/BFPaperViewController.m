//
//  BFPaperViewController.m
//  BFPaperCheckbox
//
//  Created by Bence Feher on 7/22/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//
/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Bence Feher
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "BFPaperViewController.h"
#import "UIColor+BFPaperColors.h"

@interface BFPaperViewController ()
@property BFPaperCheckbox *paperCheckbox;
@property BFPaperCheckbox *paperCheckbox2;
@property UILabel *paperCheckboxLabel;
@property UILabel *paperCheckboxLabel2;
@end

@implementation BFPaperViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Forgive the lack of autolayout for this simple example program.
    
    // Set up fist checkbox:
    self.paperCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(20, 150, bfPaperCheckboxDefaultRadius * 2, bfPaperCheckboxDefaultRadius * 2)];
    self.paperCheckbox.tag = 1001;
    self.paperCheckbox.delegate = self;
    [self.view addSubview:self.paperCheckbox];
    
    // Set up first checkbox label:
    self.paperCheckboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 31)];
    self.paperCheckboxLabel.text = @"BFPaperCheckbox [OFF]";
    self.paperCheckboxLabel.backgroundColor = [UIColor clearColor];
    self.paperCheckboxLabel.center = CGPointMake(self.paperCheckbox.center.x + ((2 * self.paperCheckboxLabel.frame.size.width) / 3), self.paperCheckbox.center.y);
    [self.view addSubview:self.paperCheckboxLabel];
    
    
    // Set up second checkbox and customize it:
    self.paperCheckbox2 = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, 250, 25 * 2, 25 * 2)];
    self.paperCheckbox2.center = CGPointMake(self.paperCheckbox.center.x, self.paperCheckbox2.frame.origin.y);
    self.paperCheckbox2.tag = 1002;
    self.paperCheckbox2.delegate = self;
    self.paperCheckbox2.rippleFromTapLocation = NO;
    self.paperCheckbox2.tapCirclePositiveColor = [UIColor paperColorAmber]; // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.paperCheckbox2.tapCircleNegativeColor = [UIColor paperColorRed];   // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.paperCheckbox2.checkmarkColor = [UIColor paperColorLightBlue];
    [self.view addSubview:self.paperCheckbox2];
    
    // Set up second checkbox label:
    self.paperCheckboxLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 31)];
    self.paperCheckboxLabel2.text = @"Customized [OFF]";
    self.paperCheckboxLabel2.backgroundColor = [UIColor clearColor];
    self.paperCheckboxLabel2.center = CGPointMake(self.paperCheckbox2.center.x + ((2 * self.paperCheckboxLabel2.frame.size.width) / 3), self.paperCheckbox2.center.y);
    [self.view addSubview:self.paperCheckboxLabel2];


    // Set up a standard switch:
    UISwitch *standardSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 100, 1, 1)];
    standardSwitch.center = CGPointMake(self.paperCheckbox.center.x, standardSwitch.frame.origin.y);
    standardSwitch.tintColor = [UIColor paperColorGray700];
    standardSwitch.onTintColor = [UIColor paperColorGreen];
    [self.view addSubview:standardSwitch];
    
    // Set up a label for standard switch:
    UILabel *standardSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, 200, 31)];
    standardSwitchLabel.center = CGPointMake(self.paperCheckboxLabel.center.x, standardSwitchLabel.frame.origin.y);
    standardSwitchLabel.text = @"Standard switch";
    standardSwitchLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:standardSwitchLabel];

    
    // A button for programmatically swapping states with animations:
    UIButton *animateChangeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 135, 31)];
    animateChangeBtn.tag = 2001;
    animateChangeBtn.backgroundColor = [UIColor darkGrayColor];
    [animateChangeBtn setTitle:@"animate change" forState:UIControlStateNormal];
    [animateChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [animateChangeBtn addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animateChangeBtn];
    
    // A button for programmatically swapping states without animations:
    UIButton *staticChangeBtn = [[UIButton alloc] initWithFrame:CGRectMake(165, 300, 135, 31)];
    staticChangeBtn.tag = 2002;
    staticChangeBtn.backgroundColor = [UIColor darkGrayColor];
    [staticChangeBtn setTitle:@"static change" forState:UIControlStateNormal];
    [staticChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [staticChangeBtn addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:staticChangeBtn];

}

- (void)tapped:(UIButton *)sender
{
    BOOL animate;
    if (sender.tag == 2001) {
        animate = YES;
    }
    else if (sender.tag == 2002) {
        animate = NO;
    }
    
    /* 
     * Below are the two ways of programmatically setting the state of a checkbox.
     */
    
    // (1) Swap paperCheckbox's state with the 'switchStates...' method:
    [self.paperCheckbox switchStatesAnimated:animate];
    
    // (2) Swap paperCheckbox2's state with the 'check...'/'uncheck...' methods:
    if (self.paperCheckbox2.isChecked) {
        [self.paperCheckbox2 uncheckAnimated:animate];
    }
    else {
        [self.paperCheckbox2 checkAnimated:animate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - BFPaperCheckbox Delegate
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox
{
    if (checkbox.tag == 1001) {      // First box
        self.paperCheckboxLabel.text = self.paperCheckbox.isChecked ? @"BFPaperCheckbox [ON]" : @"BFPaperCheckbox [OFF]";
    }
    else if (checkbox.tag == 1002) { // Second box
        self.paperCheckboxLabel2.text = self.paperCheckbox2.isChecked ? @"Customized [ON]" : @"Customized [OFF]";
    }
}

@end
