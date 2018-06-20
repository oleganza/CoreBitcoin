OpenSSL-Universal
=======

OpenSSL CocoaPod for iOS and OSX. Complete solution to OpenSSL on iOS and OSX. Package came with precompiled libraries, and include script to build newer version if necessary.

Current version contains binaries build with SDK iOS 8.0 (target 6.0), and SDK OSX 10.9 (target 10.8) for all supported architectures.

**Architectures**

- iOS with architectures: armv7, armv7s, arm64 + simulator (i386, x86_64)
- OSX with architectures: i386, x86_64

**Why?**

[Apple says](https://developer.apple.com/library/mac/documentation/security/Conceptual/cryptoservices/GeneralPurposeCrypto/GeneralPurposeCrypto.html):
"Although OpenSSL is commonly used in the open source community, OpenSSL does not provide a stable API from version to version. For this reason, although OS X provides OpenSSL libraries, the OpenSSL libraries in OS X are deprecated, and OpenSSL has never been provided as part of iOS."

**Installation**

````
pod 'OpenSSL-Universal'
````

Or always latest version

````
pod 'OpenSSL-Universal', :git => 'https://github.com/krzyzanowskim/OpenSSL.git', :branch => :master
````

**Authors**

[Marcin Krzyżanowski](https://twitter.com/krzyzanowskim)

**Tutorial **
This tutorial assumes you want to: 
1) Write a C application.
2) Use OpenSSL libraries for some crypto operation.
3) Use a Mac and xCode 8.
4) Use CocoaPods and the OpenSSL-Universal pod as an elegant way to stay updated with the latest libraries and headers.  

*** Step 1 - Create your macOS HelloWorld C app ***
If you have not done this before with xCode, select  `File / New Project / macOS / Command Line Tool`.  Hit build and run.  You just successfully build the default Hello World C project.

*** Step 2 - Setup Cocoa Pods *** 
Make sure your machine is setup for CocoaPods.
After CocoaPods is setup, open `Terminal` and navigate to your project folder and run `pod init`.  
After that has completed, type `open -a Xcode Podfile`.  

*** Step 3 - get the OpenSSL-Universal pod ***
Add `pod 'OpenSSL-Universal'` inside the podfile. 
Save the file.
Return to `Terminal` and run `Pod Install`.
After that download completes, make sure to close the C project and open the workspace file that was created.

*** Step 4 - What is inside of the OpenSSL-Universal pod?*** 
Once this successfully completed, you have now got access to a pre-compiled version of the static OpenSSL libraries and the C header files required to call these functions.  

*** Where can I use OpenSSL-Universal?***
These libraries work for both iOS and MacOS.  There are two OpenSSL static libraries; `libcrypto.a` and `libssl.a`     ::Do NOT expect these OpenSSL files to work on every CPU architecture in the world. It is your prerogative to check.  Ask yourself, are you trying to write an app for old devices? new devices only? all iOS devices? only macOS?, etc ::

***Fat Binaries***
The OpenSSL-Universal Framework is a Fat Binary. That means it supports multiple CPU architectures in a single file.    To understand this, return to `Terminal`.  Navigate to your OpenSSL-Universal macOS files and run the command `file libcrypto.a`  This will tell you architecture the file is compiled against `x86_64` and `x386`.  If you tried the iOS OpenSSL-Universal files it would have said `armv7`, `armv7s`, `arm64` + Simulators (`i386, x86_64`).  

***xCode Setup***
You want to ensure xCode knows; 

1. Where the OpenSSL static libraries are located.
2. Where the OpenSSL header files are located for the C include statements. 
Inside your workspace, go to the Target (not the Project).  The Target is the C app that is produced after a successful build.  Select `Build Phases` and `Link Binary With Libraries`.    Select `+` and navigate to the static OpenSSL libraries that was included in the framework.  The magical result was, your `Target` and `Building Settings` `Library Search Paths` were populated without you typing anything.  Now go to the  Target.  In `Build Settings` set the `Always Search User Paths` to `Yes`.  Then add a new entry to the `User Header Search Paths`. This should be the location of the OpenSSL header files that were included in OpenSSLUniversal.

***Test your app builds: include OpenSSL Header file ***
