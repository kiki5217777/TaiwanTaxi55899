//
//  AutoButtonArrayManager.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/30.
//
//

#import <Foundation/Foundation.h>

@interface AutoButtonArrayManager : NSObject{
    NSMutableArray *array;
}
@property (nonatomic, readonly) int count;

-(void)addToQueue:(id)object;
- (id)deQueue;
- (void)clearQueue;
@end
