BFPaperCheckbox
===============
[![CocoaPods](https://img.shields.io/cocoapods/v/BFPaperCheckbox.svg?style=flat)](https://github.com/bfeher/BFPaperCheckbox)

> Note that this changelog was started very late, at roughly the time between version 1.2.8 and 2.0.0 Non consecutive jumps in changelog mean that there were incremental builds that weren't released as a pod, typically while solving a problem.


2.1.0
---------
* (+) Added an IBInspectable 'cornerRadius' property.  


2.0.0
---------
* (+) IB Designable support!  
* (^) Replaced 'bfPaperCheckboxDefaultRadius' constant with a more sensible 'bfPaperCheckboxDefaultDiameter' constant.  
* (^) Lowered the default size of the control from 78 to 49, making it more compact.  
* (^) 'rippleFromTapLocation' now defaults to NO.  
* (^) 'tapCircleDiameter' has been renamed to 'endDiameter'  
* (^) 'tapCirclePositiveColor' has been renamed to 'positiveColor'  
* (^) 'tapCircleNegativeColor' has been renamed to 'negativeColor'  
* (+) Added new property 'touchDownAnimationDuration'  
* (+) Added new property 'touchUpAnimationDuration'  
* (+) Added new property 'startDiameter'  
* (+) Added new property 'burstAmount'  
* (-) Removed UIColor+BFPaperColors pod.