# DeviceBigBrother
Mobile Device Tracking System built using PHP, Android, iOS

There are 3 components:
* LAMP ie. the backend that is built on a LAMP stack
* iOS ie. the iOS app
* Android ie. the Android app

The iOS/Android apps beacon the device's location to the backend and it periodically checks to see if the device has checked in and if it is out of a given boundary.

## LAMP

This consists of:
* createtables.sql - to create the tables
* DeviceBigBrother - you need to put this on your Apache document root. Please make sure PHP is working. 

### DeviceBigBrother

This was built/tested on PHP 7.0.8 on Ubuntu 0.16.04.3 (but it should work on PHP > 5)

If you want to have the system send email alerts, you will need PHPMailer from https://github.com/PHPMailer/PHPMailer or rewrite the sendmail function in utils.php if necessary.

What you'll need to configure:
* globals.php
..* secret - shared secret that you need to set in your Android and iOS code as well
..* mailinglist - where you want the alert emails to go to
..* home_lat, home_lon - lat/lon of your location
..* home_boundary - radius (in miles) of your geofence
..* num_hours - number of hours is considered late for device check-in
* utils.php
..* sendmail - I've used Yahoo's smtp server but you can configure it however you want. If using Yahoo's smtp you'll need to set up with a valid account. 
* mysql.php - please configure the mysql login params

## iOS

iOS code was built on XCode 8.2.1 on MacOS 10.12.2

What you'll need to configure:
* ViewController.m 
..* bigBrotherPing - configure host to point to hostname of the LAMP code
..* genHash - configure key (make sure it is the same secret as the one in globals.php)

You'll need to add your signing key in order to deploy to real devices.

## Android

Android code was built on Android Studio 2.3.3 on MacOS 10.12.2

What you'll need to configure:
* BigBrotherService.java
..* hostname - configure to hostname of LAMP code
..* genHash - configure secret (make sure it is the same secret as the one in globals.php)
