//
//  FMDBManager.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/19.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "AppDelegate.h"


@interface FMDBManager : NSObject{
    
//        FMDatabase *db;
//    NSString *imageFilePath;
//    NSString *selectimgfilename;
    NSString *dbPath;
//    AppDelegate *delegate;
}
@property (retain , nonatomic) NSFileManager *fileMgr;
@property (retain , nonatomic) FMDatabase *db;
+(FMDBManager *) sharedInstance;

-(void) getAllFreeWayDataFromDB;
//-(void) createDataBaseAndTablesIfNeeded;

/*
-(void) deleteDBEntry:(NSString*)filepath;
-(BOOL) deleteImgFile:(NSString*)imgfilename;
-(void)showSelectImgfilename:(NSString *)name;
-(void) setPhotoTextToDB:(NSString*)phototext :(NSString*)filepath;
-(void) setPhotoTitleToDB:(NSString*)phototitle :(NSString*)filepath;
-(void) setPhotoFilepathToDB:(NSString *) photoNewname :(NSString *)imgfilename;
-(void) insertDataToDB:(NSString *) title :(NSString *)text :(NSString *) imgname :(NSString *)showyn;

-(NSString *) setImageFilename;
-(NSString *) getSelectImgfilename;
-(NSString *) getPhotoTextFromDB:(NSString*)imgfilename;

-(NSArray*) getImageFileList;
*/
-(NSMutableArray *) getDataFromDBWithCondition:(NSString*)str1 condition2:(NSString*)str2 condition3:(NSString *)str3;
-(NSMutableArray *) getFreewayDataFromDB;
-(NSMutableArray *) getRoadDataFromDB:(NSInteger)index;
-(NSMutableDictionary *) getPriceWithCondition:(NSString*)str1 condition2:(NSString*)str2 condition3:(NSString *)str3;
/*
-(UIImage *) ReadFromImageFileWithName:(NSUInteger)index;
-(UIImage *) loadImageWithName:(NSString*)imgName;
 */
@end
