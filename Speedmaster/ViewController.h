//
//  ViewController.h
//  SpeedDial
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIImageView *baseImageView;
@property (strong, nonatomic) IBOutlet UILabel *StopAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *centralSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *centralDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *hundredLabel;
@property (weak, nonatomic) IBOutlet UILabel *hundredDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mirrorImageView;
@property double currentSpeed;
@property double lastKnownSpeed;
@property bool animating;
@property (strong, nonatomic) NSDate *date;
@property float lastCalculatedValue;
@property(strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) CLLocationManager *manager;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (void) StopAlrtLblTap;
- (void)setupBackgrounding;

@end
