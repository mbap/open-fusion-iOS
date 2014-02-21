open-fusion-iOS
===============

This is the repository for the open fusion iOS application. This will be the home of all iOS code developed for the GSF Design Team.

After cloning this project, you will need to install opencv 2.4.8 for ios into the project. The way I achieved this was using cocoapods. Here are the steps you must follow.


1. Install cocoapods using this command
   
   $ sudo gem install cocoapods

2. In the working directory create a file called Podfile

3. In the file Podfile add the following lines.
   
   platform :ios
   
   pod 'OpenCV', '~> 2.4.8'

4. Run this command and your finished.
   
   pod install

From now on open the GSFDataCollecter.xcworkspace file instead of the xcproject file.
