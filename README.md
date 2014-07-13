BiggerAndBetter
===============

A prototype of a sharing economy app built while participating in AngelHack Bangkok 2014 (https://www.facebook.com/AngelHackBKK).

The app's hackathon.io page can be found at http://www.hackathon.io/32262

Description
-------------
List what you have and would like to share with others or trade playing the game of bigger and better. And it's all done in a single tap from your iOS device.


## iOS Setup
BiggerAndBetter requires Xcode 5 and iOS 7
#### Setting up your Xcode project
1. Open the Xcode project at `BiggerAndBetter-iOS/BiggerAndBetter.xcodeproj`.
2. Create your BiggerAndBetter App on [Parse](https://parse.com/apps).
3. Copy your new app's application id and client key into `BiggerAndBetter-iOS/BiggerAndBetter/BBAppDelegate.m`:

```objective-c
[Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY];"
```

License
-------
iOS prototype 'BiggerAndBetter' written by Nik Osipov - MIT License

Profile pictures used for this mockup are produced by [Content Generator Plugin for Sketch](https://github.com/timuric/Content-generator-sketch-plugin). Please see the appropriate license. The pictures may be used in mockups only (do NOT use in live apps).

Author
------
Nik Osipov (http://nikosgroup.com)
