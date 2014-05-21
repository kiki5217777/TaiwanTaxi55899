//
//  MemberSectionViewController.h
//  TaiwanTaxi
//
//  Created by jason on 8/15/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MemberViewController.h"
#import "RelieveViewController.h"
#import "ContactViewController.h"

@interface MemberSectionViewController : BaseViewController
{
    
}

@property (nonatomic, retain) MemberViewController *mvc;
@property (nonatomic, retain) RelieveViewController *rvc;
@property (nonatomic, retain) ContactViewController *cvc;

@end
