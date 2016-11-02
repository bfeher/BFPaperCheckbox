BFPaperCheckbox
=============
[![CocoaPods](https://img.shields.io/cocoapods/v/BFPaperCheckbox.svg?style=flat)](https://github.com/bfeher/BFPaperCheckbox)

> iOS Checkboxes inspired by Google's Paper Material Design. 

![Animated Screenshot](https://raw.githubusercontent.com/bfeher/BFPaperCheckbox/master/BFPaperCheckboxDemoGif.gif "Animated Screenshot")


About
---------
### Now with Interface Builder customization support!

_BFPaperCheckbox_ is a subclass of UIControl that behaves much like the new paper checkboxes from Google's Material Design Labs.
All animation are asynchronous and are performed on sublayers.
BFPaperCheckboxes work right away with pleasing default behaviors, however they can be easily customized! The checkmark color and tap-circle color, both positive and negative (for checked and unchecked) are all readily customizable via public properties.
You can also set whether or not the tap-circle should appear from the location of the tap, or directly from the center of the control.

By default, BFPaperCheckboxes use "Smart Color" which will match the tap-circle's positive color to the color of the checkmark (`.checkmarkColor`).
You can set your own colors via: `.positiveColor` and `.negativeColor`. Note that setting these disables Smart Color functionality.

*Note: Try not to use super slow animation times. It breaks the visual effects (not the functionality though) plus, why would you?*


## Properties
`BOOL isChecked` <br />
> A BOOL representing the state of the checkbox. YES means checked, NO means unchecked.  

`CGFloat touchDownAnimationDuration` <br />
>(Go Steelers!) A CGFLoat representing the duration of the animations which take place on touch DOWN! Default is 0.25f seconds. Note that negative values will be converted to the default. NO FUNNY BUSINESS!  

`CGFloat touchUpAnimationDuration` <br />
>A CGFLoat representing the duration of the animations which take place on touch UP! Default is 2 * touchDownAnimationDuration seconds. Note that negative values will be converted to the default. NO FUNNY BUSINESS!  

`BOOL rippleFromTapLocation` <br />
>A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is NO.  

`UIColor *checkmarkColor` <br />
>A UIColor to use for the checkmark color. Note that `self.tintColor` will be used for the square box color.  

`UIColor *positiveColor` <br />
>The UIColor to use for the circle which appears where you tap to check the box. Default value is smartly calculated from the `.checkmarkColor` property. Set to nil to access default. Alpha values less than 1 are recommended.  

`UIColor *negativeColor` <br />
>The UIColor to use for the circle which appears where you tap to uncheck the box. Default value is smartly calculated from the `.tintColor` property. Set to nil to access default. Alpha values less than 1 are recommended.  

`CGFloat cornerRadius` <br />
>The CGFloat value representing the corner radius of the control. Default value is (bfPaperCheckboxDefaultDiameter / 2). Note that negative values will be converted to 0. NO FUNNY BUSINESS!  

`CGFloat startDiameter` <br />
>A CGFLoat representing the diameter of the tap-circle as soon as it spawns, before it grows. Default is 1.f. Note that negative values and values less than 1 will be converted to the default. NO FUNNY BUSINESS!  

`CGFloat endDiameter` <br />
>The CGFloat value representing the Diameter of the tap-circle. By default it will take up the entire checkbox background circle. Note that zero and negative values will be converted to the default. NO FUNNY BUSINESS!  

`CGFloat burstAmount` <br />
>The CGFloat value representing how much we should increase the diameter of the tap-circle by when we burst it. Default is 0 because we can't see a burst with the default `.tapCircleDiameter` which takes up the entire frame. If you want to see a burst, make the `.tapCircleDiameter` something smaller than the diameter of the control itself. Note that negative values will be converted to the default. NO FUNNY BUSINESS!  

`id <BFPaperCheckboxDelegate> delegate` <br />
>A delegate to use our protocol with! The functions it conforms to are detailed below.  


## Delegate Functions
`(void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox`<br />
>An optional protocol method for detecting when the checkbox state changed. You can check its current state here with `checkbox.isChecked`.


## Constant
`CGFloat const bfPaperCheckboxDefaultDiameter`<br />
>A nice recommended value for size (49 points). (eg. `[[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultDiameter, bfPaperCheckboxDefaultDiameter)];`)


## Utility Functions (programmatically set state)
`(void)switchStatesAnimated:(BOOL)animated`<br />
>Use this function to manually/programmatically switch the state of this checkbox.
>@param `animated` A BOOL flag to choose whether or not to animate the change.

`(void)checkAnimated:(BOOL)animated`<br />
>Use this function to manually check the checkbox. Does nothing if already checked.
>@param `animated` A BOOL flag to choose whether or not to animate the change.  

`(void)uncheckAnimated:(BOOL)animated`<br />
>Use this function to manually uncheck the checkbox. Does nothing if already unchecked.
>@param `animated` A BOOL flag to choose whether or not to animate the change.



Usage
---------
Add the _BFPaperCheckbox_ header and implementation file to your project. (.h & .m)

### Creating a nice default BFPaperCheckbox
```objective-c
BFPaperCheckbox *paperCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultDiameter, bfPaperCheckboxDefaultDiameter)];
```

### Customized Example
```objective-c
self.programmaticPaperCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, 0, bfPaperCheckboxDefaultDiameter, bfPaperCheckboxDefaultDiameter)];
self.programmaticPaperCheckbox.delegate = self;
self.programmaticPaperCheckbox.tintColor = [UIColor colorWithRed:97.f/255.f green:97.f/255.f blue:97.f/255.f alpha:1];
self.programmaticPaperCheckbox.touchUpAnimationDuration = 0.5f;
self.programmaticPaperCheckbox.touchDownAnimationDuration = 0.5f;
self.programmaticPaperCheckbox.rippleFromTapLocation = YES;
self.programmaticPaperCheckbox.checkmarkColor = [UIColor blueColor];
self.programmaticPaperCheckbox.positiveColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
self.programmaticPaperCheckbox.negativeColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
self.programmaticPaperCheckbox.startDiameter = 10;
self.programmaticPaperCheckbox.endDiameter = 35;
self.programmaticPaperCheckbox.burstAmount = 10;
[self.view addSubview:self.programmaticPaperCheckbox];
```

### Setting states manually
> Toggle with 'switchStates...'  
```objective-c
[self.paperCheckbox switchStatesAnimated:animate];
```  

> Manually check or uncheck:  
```objective-c
if (self.paperCheckbox.isChecked) {
  [self.paperCheckbox uncheckAnimated:animate];
} else {
  [self.paperCheckbox checkAnimated:animate];
}  
```  

CocoaPods
-------

CocoaPods are the best way to manage library dependencies in Objective-C projects.
Learn more at http://cocoapods.org

Add this to your podfile to add BFPaperCheckbox to your project.
```ruby
platform :ios, '7.0'
pod 'BFPaperCheckbox'
```


License
--------
_BFPaperCheckbox_ uses the MIT License:

> Please see included [LICENSE file](https://raw.githubusercontent.com/bfeher/BFPaperCheckbox/master/LICENSE.md).
