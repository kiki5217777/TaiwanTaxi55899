//
//  AutoButtonManager.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/30.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "AutoButtonArrayManager.h"
#import "TaxiManager.h"


@protocol AutoButtonAlretDelegate
-(void)showChangeMenuUIAlert;
@end

@interface AutoButtonManager : NSObject{
    NSMutableArray *buttonArray;
    NSMutableArray *menuArray;
    AutoButtonArrayManager *downloadArray;
    BOOL isdownload,isRequestOnly;

}
@property (retain,nonatomic)id<AutoButtonAlretDelegate>alertDelegate;
+(AutoButtonManager *) sharedInstance;

-(void) setupMenuButton:(id)object;

@end
