//
//  ViewController.h
//  DeviceBigBrother
//
//  Created by Chris Foo on 1/5/17.
//  Copyright © 2017 Chris Foo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *deviceIDInput;

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *filepath;

@property (strong, nonatomic) CLLocationManager *locationMgr;

@end

