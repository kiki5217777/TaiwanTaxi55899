//
//  FaceInfo.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 2014/2/6.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FaceInfo : NSManagedObject

@property (nonatomic, retain) NSString * picturePath;
@property (nonatomic, retain) NSString * userID;

@end
