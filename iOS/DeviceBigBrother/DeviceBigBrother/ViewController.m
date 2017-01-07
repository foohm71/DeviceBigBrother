//
//  ViewController.m
//  DeviceBigBrother
//
//  Created by Chris Foo on 1/5/17.
//  Copyright © 2017 Chris Foo. All rights reserved.
//
// For more info on how to do background location checking:
// http://www.raywenderlich.com/29948/backgrounding-for-ios
// Info on making HTTP Get/Post:
// http://codewithchris.com/tutorial-how-to-use-ios-nsurlconnection-by-example/

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize deviceID;
@synthesize filepath;
@synthesize locationMgr;

@synthesize deviceIDInput;

// This is how long to sleep
float sleepInSeconds = 5;
NSDate *lastCheckin = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // this part gets the saved deviceID and displays it
    NSFileManager *fileMgr;
    NSString *documentDir;
    NSArray *directoryPaths;
    
    fileMgr = [NSFileManager defaultManager];
    directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentDir = [directoryPaths objectAtIndex:0];
    
    
    filepath = [[NSString alloc] initWithString:[documentDir stringByAppendingPathComponent:@"deviceID.dat"]];
    
    if ([fileMgr fileExistsAtPath:filepath]) {
        
        deviceID = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        deviceIDInput.text = deviceID;
    }

    // This part initializes the check in time
    lastCheckin = [NSDate date];
    
    // this part gets the location
    locationMgr = [[CLLocationManager alloc] init];
    locationMgr.delegate = self;
    locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [locationMgr requestAlwaysAuthorization];
    [locationMgr startUpdatingLocation];
    NSLog(@"LocationManager started");

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [self bigBrotherPing:deviceID withLatitude:0.0 withLongitude:0.0];
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [lastCheckin timeIntervalSinceNow];
    NSString *coord;
    
    NSLog(@"Inside didUpdateLocations");
    
    if (fabs(howRecent) > sleepInSeconds) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        coord = [[NSString alloc] initWithFormat:@"%f,%f",location.coordinate.latitude, location.coordinate.longitude];
        
        [self bigBrotherPing:deviceID withLatitude:location.coordinate.latitude withLongitude:location.coordinate.longitude];
        
        lastCheckin = [NSDate date];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)endTyping:(id)sender {
    [deviceIDInput resignFirstResponder];
}

- (IBAction)dismissKeyboard:(id)sender {
    [deviceIDInput resignFirstResponder];
}

- (IBAction)submitButton:(id)sender {
    deviceID = deviceIDInput.text;
    
    [NSKeyedArchiver archiveRootObject:deviceID toFile:filepath];

    NSLog(@"Submitting deviceID %@", deviceID);
}

// How to make a simple HTTP call
// http://codewithchris.com/tutorial-how-to-use-ios-nsurlconnection-by-example/
//
// Interestingly performing a URLEncode is not that trivial
// https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/WorkingwithURLEncoding/WorkingwithURLEncoding.html
//
// How to set header in the request
// http://stackoverflow.com/questions/4809047/nsurlrequest-setting-the-http-header
//
// Need to take note of disabling App Transport Security
// http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http

-(void)bigBrotherPing:(NSString *)deviceID withLatitude:(float)latitude withLongitude:(float)longitude {
    NSURL *url;
    NSString *urlstring, *httpbody;
    NSString *log = @"Ping";
    NSString *host = @"muhost";
    NSString *URI = @"/DeviceBigBrother/track.php";
    NSString *hash = nil;

    
    if (![deviceID  isEqual: @""]) {
        NSString *model_raw = [[UIDevice currentDevice] model];
        NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString *model = [model_raw stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        NSDate *date = [NSDate date];
        NSTimeInterval timestamp = [date timeIntervalSince1970];
        NSString *timestamp_as_string = [NSString stringWithFormat:@"%d", (int) timestamp];
        
        NSString *queryString = [NSString stringWithFormat:@"deviceID=%@&model=%@&lat=%f&lon=%f&ts=%d", deviceID, model,latitude,longitude, (int) timestamp];
        urlstring = [[NSString alloc] initWithFormat:@"http://%@%@?%@", host, URI, queryString];
        
        url = [NSURL URLWithString:urlstring];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        hash = [self genHash:timestamp_as_string];
        [request setValue:hash forHTTPHeaderField:@"Authorization"];
        NSURLResponse * response = nil;
        NSError * error = nil;
        [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        
        NSLog(@"Made call %@", urlstring);
        NSLog(@"HTTP Body %@", httpbody);
        NSLog(@"Error %@", error);
    } else {
        NSLog(@"No deviceID set up");
    }
}

// Both generateHash and base64forData are from:
// https://www.jokecamp.com/blog/examples-of-creating-base64-hashes-using-hmac-sha256-in-different-languages/#java

- (NSString *) genHash:(NSString *)aMessage {
    NSString* key = @"MySecret";
    
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [aMessage cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSLog(@"%@", hash);
    
    NSString* s = [ViewController base64forData:hash];
    NSLog(@"Base64 hash:%@", s);
    
    return s;
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
