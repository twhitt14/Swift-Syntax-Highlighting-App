# Swift Syntax Highlighting App

This app is UI wrapper around [Splash][1] 
so most of the credit goes to John Sundell for building our engine.

I post every few weeks on my blog [www.theSwift.dev](https://www.theswift.dev) and often 
need some syntax highlighting for my Swift example code, so I put this app together to
help me out.

## Usage

Download the project & open it in Xcode - the Splash package should auto download. 
I typically run the app on my Mac for easy copy & paste into my blog CMS. If you want
to run the app on your Mac, you'll need to select the MacOS scheme, change the 
development team to your own (you need a paid developer account to build to real
devices) and you should change the bundle identifier so that it reflects your
own development team (e.g. com.myWebsite.Swift-Syntax-Highlighting-App)

I hope this makes your life easier! If you're generating HTML formatted Swift, 
don't forget to check out the [Splash][1] repo 
for instructions on how to update your [website CSS](https://github.com/JohnSundell/Splash/blob/master/Examples/sundellsColors.css) so it will highlight your code
correctly.

Happy highlighting!

[1]: https://github.com/JohnSundell/Splash
