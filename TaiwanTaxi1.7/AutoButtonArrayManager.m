//
//  AutoButtonArrayManager.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/30.
//
//

#import "AutoButtonArrayManager.h"

@implementation AutoButtonArrayManager
@synthesize count;
-(id)init{
    if (self= [super init]) {
        array = [[NSMutableArray alloc]init];
        count =0;
    }
    return self;
}
-(void)addToQueue:(id)object{
    [array addObject:object];
    count = [array count];
}

- (id)deQueue{
    
    id obj =nil;
    if (array.count>0) {
        obj = [[array objectAtIndex:0]retain];
        [array removeObjectAtIndex:0];
        count = [array count];
    }
    return  obj;
}

- (void)clearQueue{
    [array removeAllObjects];
    count =0;
}
@end
