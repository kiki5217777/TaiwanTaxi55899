//
//  TextAlertView.m
//  TaiwanTaxi
//
//  Created by jason on 3/11/13.
//
//

#import "TextAlertView.h"

@implementation TextAlertView

- (void)dealloc
{
    [textView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDefaultSetting
{    
    self = [super initWithTitle:@"台灣大車隊註冊會員同意條款"
                        message:@"\n\n\n\n\n\n\n"
                       delegate:nil
              cancelButtonTitle:@"取消" otherButtonTitles:@"我同意", nil];
    if(self) {
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"term"
                                                         ofType:@"txt"];
        NSString *termOfService = [NSString stringWithContentsOfFile:path
                                                            encoding:NSUTF8StringEncoding
                                                               error:NULL];
        
        [self setupCustomView:termOfService];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title termOfService:(NSString *)termOfService
{
    self = [super initWithTitle:title
                        message:@"\n\n\n\n\n\n\n"
                       delegate:nil
              cancelButtonTitle:@"取消" otherButtonTitles:@"我同意", nil];
    if(self) {
        [self setupCustomView:termOfService];
    }
    return self;
}

- (void)setupCustomView:(NSString *)termOfService
{
    //CGRectMake(12, 50, 260, 142)
    textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 140)];
    textView.editable = NO;
    
    
    textView.text = termOfService;
    
    [self addSubview:textView];
}

@end

@implementation TextAlertViewiOS7

- (id)initWithTitle:(NSString *)title termOfService:(NSString *)termOfService parentView:(UIView *)parentView
{
    self = [super initWithParentView:parentView];
    if (self) {
        [self setupContentView:title termOfService:termOfService];
        [self setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"我同意", nil]];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title precautionOfService:(NSString *)termOfService parentView:(UIView *)parentView
{
    self = [super initWithParentView:parentView];
    if (self) {
        [self setupContentView:title precationOfService:termOfService];
        [self setButtonTitles:[NSMutableArray arrayWithObjects:@"下次不再顯示", @"好", nil]];
    }
    return self;
}
- (void)setupContentView:(NSString *)title termOfService:(NSString *)termOfService
{
    UIView *view = [[[UIView alloc] init] autorelease];
    view.frame = CGRectMake(0, 0, 260, 180);
    
    // the title
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.frame = CGRectMake(0, 10, 260, 20);
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // tos text view
    UITextView *textView = [[[UITextView alloc] init] autorelease];
    textView.frame = CGRectMake(0, 40, 260, 140);
    textView.editable = NO;
    textView.text = termOfService;
    
    [view addSubview:titleLabel];
    [view addSubview:textView];
    
    [self setContainerView:view];
}
- (void)setupContentView:(NSString *)title precationOfService:(NSString *)termOfService{
    UIView *view = [[[UIView alloc] init] autorelease];
    view.frame = CGRectMake(0, 0, 270, 430);
    [view setBackgroundColor:[UIColor clearColor]];
    
    // the image
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"alert.png"]];
    [image setFrame:CGRectMake(0, 0, 270, 430)];
    
    
    // tos text view
    UITextView *textView = [[[UITextView alloc] init] autorelease];
    textView.frame = CGRectMake(15, 65, 240, 300);
    textView.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    textView.editable = NO;
    textView.text = termOfService;
    
    [view addSubview:image];
    [view addSubview:textView];
    
    [self setContainerView:view];
}
@end
