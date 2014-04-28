//
//  OtherSettingsViewController.m
//  TaiwanTaxi
//
//  Created by jason on 9/15/13.
//
//

#import "OtherSettingsViewController.h"

@interface OtherSettingsViewController ()

@end

@implementation OtherSettingsViewController

- (void)dealloc
{
    [_contentView release];
//    [_adBannerView release];
    [_mvpnTextField release];
    [_useMVPNSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // -------------------- view --------------------
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    useMVNP = [df boolForKey:USER_DEFAULT_KEY_USE_MVPN];
    NSString *mpvn = [df stringForKey:USER_DEFAULT_KEY_MVPN];
    if(mpvn && mpvn.length)
        self.mvpnTextField.text = mpvn;
    
    self.useMVPNSwitch.on = [df boolForKey:USER_DEFAULT_KEY_USE_MVPN];
    
    [self.view addSubview:self.contentView];
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    //edited by kiki Huang 2013.12.13
    //----------------------TWMTA Ad-------------------------
     TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                                  slotId:@"Dg1386570971882Nso"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.view addSubview:_upperAdView];
    [_upperAdView release];
    //-------------------------------------------------------
}

- (void)viewDidUnload
{
    [self setContentView:nil];
//    [self setAdBannerView:nil];
    [self setMvpnTextField:nil];
    [self setUseMVPNSwitch:nil];
    [super viewDidUnload];
}

#pragma mark - user interaction

- (IBAction)switchChanged:(id)sender
{
    if(self.mvpnTextField.text.length == 0 && self.useMVPNSwitch.on == YES)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"MVPN啟用"
                                                        message:@"請提供MVPN號碼"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"確定", nil] autorelease];
        [alert show];
        [self.useMVPNSwitch setOn:NO animated:NO];
    }
    else
    {
        BOOL val = self.useMVPNSwitch.on;
        [[NSUserDefaults standardUserDefaults] setBool:val forKey:USER_DEFAULT_KEY_USE_MVPN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)textFieldChanged:(id)sender
{
    int length = self.mvpnTextField.text.length;
    NSLog(@"txt field length :%d", length);
    
    if(length == 0)
    {
        [self.useMVPNSwitch setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULT_KEY_USE_MVPN];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.mvpnTextField.text forKey:USER_DEFAULT_KEY_MVPN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/*
#pragma mark - CustomAdBannerViewDelegate

- (void)bannerButtonPressed:(NSString *)url
{
    if([url isKindOfClass:[NSNull class]] == NO)
    {
        [self handleClickAd:url];
    }
}
*/
@end
