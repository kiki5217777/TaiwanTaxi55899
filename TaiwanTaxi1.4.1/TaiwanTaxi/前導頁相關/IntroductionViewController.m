//
//  IntroductionViewController.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/22.
//
//

#import "IntroductionViewController.h"
#import "AFHTTPRequestOperation.h"


@interface IntroductionViewController (){
    NSTimer *timer;
}

@end

@implementation IntroductionViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.currentVersionLabel.text = [NSString stringWithFormat:@"Ver: %@",currentVersion];

    if (![self checkFolder:INTRO_IMG_FILENAME]) {
        if (IS_IPHONE_5) {
            [self.introImageView setImage:[UIImage imageNamed:@"前導頁640X1136.png"]];
            
        }else{
            [self.introImageView setImage:[UIImage imageNamed:@"前導頁640X960.png"]];
        }
        [self addTimer];
        
    }else{
        [self getLocalIntroImag];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];
    [super viewWillDisappear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setCurrentVersionLabel:nil];
    [self setIntroImageView:nil];
    self.manager = nil;
    [super viewDidUnload];
}
- (void)dealloc {
    
    [_introImageView release];
    [_currentVersionLabel release];
    self.manager = nil;
    [super dealloc];
}

#pragma mark - Check local image files

-(void)getLocalIntroImag{

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"]!=nil) {
            NSString *filetype = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"];
            NSLog(@"filetype get %@",filetype);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:INTRO_IMG_FILENAME] stringByAppendingPathExtension:filetype];
            UIImage *img = [UIImage imageWithContentsOfFile:path];
            [self.introImageView setImage:img];
        
            [self addTimer];
        
        }else{
            if (IS_IPHONE_5) {
                [self.introImageView setImage:[UIImage imageNamed:@"前導頁640X1136.png"]];
                
            }else{
                [self.introImageView setImage:[UIImage imageNamed:@"前導頁640X960.png"]];
            }
            [self addTimer];
            NSLog(@"fileType miss error");
        }
}

-(BOOL)checkFolder:(NSString*) _name {
    NSString *filetype = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"];
    if (filetype !=nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:_name] stringByAppendingPathExtension:filetype];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            return NO;
        }
        else
            return YES;

    }
    return NO;
}

#pragma mark - Timer
-(void)addTimer{
    timer=[NSTimer scheduledTimerWithTimeInterval:
           3.0 target:self selector:@selector(changetologinView) userInfo:nil repeats:NO];
}
-(void)stopTimer{
    [timer invalidate];
}

#pragma mark - Dismiss self view
-(void)changetologinView{
    [self stopTimer];
    [delegate changeToLoginView];
}
@end
