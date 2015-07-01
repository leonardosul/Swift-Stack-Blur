Swift Stack Blur
------------------------

This is an implementation of Mario Klingemann's Stack Blur originally written in Java, but ported to iOS and objective-C by [Thomas LANDSPURG](https://github.com/tomsoft1) here [StackBluriOS](https://github.com/tomsoft1/StackBluriOS).

The original can be seen here:
[http://incubator.quasimondo.com/processing/fast_blur_deluxe.php](http://incubator.quasimondo.com/processing/fast_blur_deluxe.php)

I have attempted to recreate what Thomas has done with the port, although you could just go ahead and use his port in a mostly Swift project and link to his objective-C using a bridging header file.

I believe that Thomas's objective-C implementation may be slightly faster right now, but this could change with future improvements to the Swift compiler.


## Installation & Usage
This has been written as an extension to the UIImage class and should be fairly easy to implement in any project.

- Clone this repo.
- Copy the SwiftStackBlur.swift file to your own project.
- You can now use the .swiftStackBlur function on any UIImage by passing in a radius for the blur.


## License

Swift Stack Blur is available under the The BSD 3-Clause License. Check the LICENSE file for more info.
