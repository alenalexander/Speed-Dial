//
//  ViewController.m
//  SpeedDial
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import <AudioToolbox/AudioServices.h>
//#import <AVFoundation/AVFoundation.h>
#import "PRTween.h"


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ViewController ()

@end

@implementation ViewController
@synthesize audioPlayer,StopAlertLabel,backgroundTask;
NSTimer *timer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (IS_IPHONE_5) {
        self = [super initWithNibName:@"ViewController2" bundle:nil];
        NSLog(@"Started as iphone 5");
    }
    else {
        self = [super initWithNibName:@"ViewController" bundle:nil];
        NSLog(@"Started as iphone 4");
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupViews];
    [self setupCoreLocationStack];
    self.currentSpeed = 0;
    self.animating = NO;
    self.lastCalculatedValue = 0;
    [self setupBackgrounding];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appBackgrounding:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appForegrounding:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(updateSpeedometer)
                                   userInfo:nil
                                    repeats:YES];
}


/* fonts
    Eurostile LT
    EurostileLT
    EurostileLT_Oblique
*/

- (void) updateSpeedometer
{
    if (self.lastKnownSpeed == 0 && self.currentSpeed > 0)
    {
        self.date = [NSDate date];
    }
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:self.lastCalculatedValue endValue:self.currentSpeed duration:0.7];// 0.9 aa
    PRTweenOperation *operation = [PRTweenOperation new];
    operation.period = period;
    operation.target = self;
    operation.timingFunction = &PRTweenTimingFunctionLinear;
    operation.updateSelector = @selector(update:);
    [[PRTween sharedInstance] addTweenOperation:operation];
    
    if (self.currentSpeed < 100) {
        [self updateTimeLabel];
    }
}

- (void)update:(PRTweenPeriod*)period {
    int test = (int)period.tweenedValue;
    if(test!=0 & test>=10)
    {
    test=(int)period.tweenedValue+5;
    }
    
    [self animateToSpeed:@(test)];
    self.centralSpeedLabel.text = [NSString stringWithFormat:@"%d", test];
    if (test > 40)      // Set Speed Limit here. Or take it as user i/p from user. Here, speedlimit is set as 40km/hr
    {
             NSString *path = [[NSBundle mainBundle]
                               pathForResource:@"out" ofType:@"caf"];
             NSURL *fileURLsound = [[NSURL alloc] initFileURLWithPath: path];
             audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:
                            fileURLsound error:nil];
             [audioPlayer prepareToPlay];
             [audioPlayer play];
    }
    StopAlertLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(StopAlrtLblTap)];
    [StopAlertLabel addGestureRecognizer:tapGesture];
    self.lastCalculatedValue = period.tweenedValue;
}


- (void) updateTimeLabel
{
    NSTimeInterval interval = [self.date timeIntervalSinceNow];
    double interval2 = fabs(interval);
    if (interval2 > 60) {
        interval2 = 0;
    }
    self.hundredLabel.text = [NSString stringWithFormat:@"%.1f", interval2];
}

- (void) setupCoreLocationStack
{
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.manager.distanceFilter = kCLDistanceFilterNone;
    [self.manager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations lastObject];
    self.lastKnownSpeed = self.currentSpeed;
    self.currentSpeed = loc.speed * 3.6;
    
    if (self.currentSpeed < 0) {
        self.currentSpeed = 0;
    }
    
}


- (void) setupViews
{
    
    for (UILabel *label in self.view.subviews) {
        
        if ([label class] == [UILabel class])
        {
            label.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    self.bgImageView.image = [UIImage imageNamed:@"gradient.jpg"];
    
    self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arr_red.png"]];
    [self.baseImageView addSubview:self.arrow];;
      
    self.arrow.center = CGPointMake(self.baseImageView.frame.size.width / 2, self.baseImageView.frame.size.height / 2 + 18);
    self.arrow.layer.anchorPoint = CGPointMake(0.5, 0.95);
    
    UIImageView *circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
    circleView.frame = CGRectMake(200, 200, 120, 120);
    circleView.center = self.baseImageView.center;
    circleView.center = CGPointMake(self.baseImageView.center.x, self.baseImageView.center.y + 23 );
    [self.view addSubview:circleView];
    
    self.centralSpeedLabel.textColor = [UIColor whiteColor];
    self.centralSpeedLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:45];
    
    self.centralDescriptionLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.centralDescriptionLabel.text = @"km/h";
    self.centralDescriptionLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:18];
    
    self.hundredLabel.textColor = [UIColor whiteColor];
    self.hundredLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:30];
    self.hundredLabel.text = @"7,6";
    
    self.hundredDescriptionLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.hundredDescriptionLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:15];
    self.hundredDescriptionLabel.text = @"0-100";
    
    self.bgImageView.image = [UIImage imageNamed:@"gradientor.png"];
    
    self.StopAlertLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23];
    
    
    [self.view bringSubviewToFront:self.centralSpeedLabel];
    [self.view bringSubviewToFront:self.centralDescriptionLabel];
    
    if (IS_IPHONE_5) {
        self.baseImageView.frame = CGRectMake(self.baseImageView.frame.origin.x, self.baseImageView.frame.origin.y + 100, self.baseImageView.frame.size.width, self.baseImageView.frame.size.height);
        NSLog(@"Called?");
    }
}

- (void) animateToSpeed: (NSNumber *) speed
{
    
     self.arrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, - 2.4 + 0.109 * ([speed doubleValue] / 5.0));

}


- (void) StopAlrtLblTap
{
    
    [audioPlayer stop];
    [timer invalidate];
    StopAlertLabel.text = @"Enable Speed Breaker Alert";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(EnableAlrtLblTap)];
    [StopAlertLabel addGestureRecognizer:tapGesture];

}


- (void) EnableAlrtLblTap
{
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(updateSpeedometer)
                                           userInfo:nil
                                            repeats:YES];
    
    StopAlertLabel.text = @"Disable Speed Breaker Alert";
}


- (void)setupBackgrounding {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appBackgrounding:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appForegrounding:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
}

- (void)appBackgrounding: (NSNotification *)notification {
    [self keepAlive];
}

- (void) keepAlive {
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
        [self keepAlive];
    }];
}

- (void)appForegrounding: (NSNotification *)notification {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}


//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    backgroundTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
//        // Clean up any unfinished task business by marking where you
//        // stopped or ending the task outright.
//        [application endBackgroundTask:backgroundTask];
//        backgroundTask = UIBackgroundTaskInvalid;
//    }];
//    
//    // Start the long-running task and return immediately.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Do the work associated with the task, preferably in chunks.
//        
//        [application endBackgroundTask:backgroundTask];
//        backgroundTask = UIBackgroundTaskInvalid;
//    });
//}
//
@end
