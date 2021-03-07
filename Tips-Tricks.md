If you change app package name you need to recreate firebase project in firebase and insert creds to google-service.json
flutter build apk --release -d "SM G973F"

https://play.google.com/apps/publish/
Google Play Console is related to publishing games on the Play Store and using the GPGS.

https://console.cloud.google.com/
Google Cloud Console is the regular console for anything Google Cloud related (GAE, GCE, IAM, etc, etc).

https://console.firebase.google.com/
Firebase Console is the console for Firebase related stuff, that are slowly being intertwined with GCP stuff.

https://console.developers.google.com/apis/
Google APIs & Services Management

https://pay.google.com/payments/home

## Android Changes

android/app/src/main/AndroidManifest.xml

android/gradle.properties
```
android.useAndroidX=true
android.enableJetifier=true
```

## iOS Changes

ios/Runner/Info.plist

ios/Podfile
```
platform :ios, '9.0'
use_frameworks!
```

## How to develop on IOS

- You need an apple developer account.
- [Enroll into IOS developer program](https://developer.apple.com/programs/enroll/)
- Log Xcode into your account via File -> Preferences -> Account -> Add Account
Once you have registered for an yearly 99$ subscription, go to https://developer.apple.com/account/resources/bundleId/add/
and register your app id.

xcode-select -p
xcode-select --install
xcode-select --switch /Applications/Xcode.app/Contents/Developer

```
open -a simulator
cd ios
pod cache clean --all
pod repo update
pod deintegrate
pod setup
pod install
cd ..
flutter clean
flutter pub get
flutter run -d all
```

## Make space on IOS

```
sudo cp -R /Applications /Volumes/[SSD drive name]/Applications
sudo mv /Applications /Apps
sudo ln -s /Volumes/[SSD drive name]/Applications /Applications
sudo rm -R /Apps
```

## Setting up Homebrew

Homebrew is a free and open-source software package management system that simplifies the installation of software on Apple’s macOS operating system and Linux. The name is intended to suggest the idea of building software on the Mac depending on the user’s taste. Follow the instructions on the site.

```
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"
brew doctor
brew update
```