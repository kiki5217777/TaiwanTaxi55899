//
//  FMDBManager.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/19.
//
//

#import "FMDBManager.h"
#define IMG_NAME @"photo"
#define IMG_TYPE @".png"

@implementation FMDBManager
@synthesize fileMgr,db;

+(FMDBManager *) sharedInstance{
    
    static FMDBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[FMDBManager alloc]init];
    });
    return sharedInstance;
}

-(id)init{
    if (self = [super init]) {
        
        
        if (fileMgr == Nil) {
            fileMgr = [NSFileManager defaultManager];
            
        }
        /*
        if ([fileMgr fileExistsAtPath:IMG_PATH]) {
            [fileMgr createDirectoryAtPath:IMG_PATH withIntermediateDirectories:YES attributes:Nil error:Nil];
        }*/
        [self checkDefaultDB];
        NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"] intValue]);
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"]) {
            NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"] intValue]);
            
            NSNumber *dbNameVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            dbPath = [[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"NEW_ETC_DB%d.db",[dbNameVersion intValue]]] copy];
        }
        else{
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            dbPath = [[documentDirectory stringByAppendingPathComponent:@"ETC_DB_1.db"] copy];
        }
       
        
//        BOOL ok=[fileMgr fileExistsAtPath:dbPath];
//        if (ok) {
//            NSLog(@"db exit");
//        }else{
//            NSLog(@"db not exit");
//        }
        
        
//        selectimgfilename = [[NSString alloc]init];
//        delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}
/*
-(NSString*) getTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-ddHHmmss"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(NSString *) setImageFilename{
    return [IMG_NAME stringByAppendingFormat:@"%@%@",[self getTime],IMG_TYPE];
}


-(NSString *) getSelectImgfilename{
    return self.selectimgfilename;
}
-(void)showSelectImgfilename:(NSString *)name{
    delegate.selectimgfilename = name;
    NSLog(@"%@",delegate.selectimgfilename);
}
//get Image FileList
-(NSArray*) getImageFileList {
    NSError *error = nil;
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:HOME_PATH error:&error];
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    for (NSString *file in fileList) {
        NSString  *path =[HOME_PATH stringByAppendingPathComponent:file];
        //UIImage *image = [UIImage imageWithContentsOfFile:path];//uiimage
        BOOL isDir;
        BOOL success = [fileMgr fileExistsAtPath:path isDirectory:&isDir];
        BOOL other = NO;
        other = [file isEqualToString:@"sd_Directory.db"];
        BOOL other2 = NO;
        other2 = [file isEqualToString:@"DS_Store"];
        BOOL other3 = NO;
        other3 = [file isEqualToString:@"annotationimage.png"];
        if ( success & !isDir & !other & !other2 & !other3) {
            [dirList addObject:file];
        }
    }
    //降冪排列
    NSSortDescriptor *SortDescriptor=[NSSortDescriptor sortDescriptorWithKey:Nil ascending:NO selector:@selector(compare:)];
    dirList = [[dirList sortedArrayUsingDescriptors:[NSArray arrayWithObject:SortDescriptor]] mutableCopy];
    
    return dirList;
}


//load image
-(UIImage *) ReadFromImageFileWithName:(NSUInteger)index{
    
    imageFilePath = [[NSString alloc]init];
    UIImage *image;
    //NSError *error=nil;
    NSArray *imagefileList =[self getImageFileList];
    if ([imagefileList count] > 0) {
        NSString *imageFileName =[imagefileList objectAtIndex:index];
        NSString *title=nil;
        
        imageFilePath = [HOME_PATH stringByAppendingPathComponent:imageFileName];
        //NSString *txtInFile = [[NSString alloc] initWithContentsOfFile:imagefilepath encoding:NSUnicodeStringEncoding error:&err];
        //NSLog(@"\n image fath ------------%@",imageFilePath);
        image =[UIImage imageWithContentsOfFile:imageFilePath];
        if(!image){
            UIAlertView *tellErr = [[UIAlertView alloc] initWithTitle:title message:@"Unable to get image from file" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [tellErr show];
        }
    }
    return image;
}

-(UIImage *) loadImageWithName:(NSString*)imgName{
    
    imageFilePath = [[NSString alloc]init];
    UIImage *image;
    NSArray *temp = [imgName componentsSeparatedByString:@"."];
    imgName = temp[0];
    imgName = [imgName stringByAppendingString:IMG_TYPE];
    
    NSArray *imagefileList =[self getImageFileList];
    int index = [imagefileList indexOfObject:imgName];
    
    //NSLog(@"圖片列表%@",[imagefileList debugDescription]);
    //NSLog(@"圖片檔名%@ index %d",imgName, index);
    
    image = [self ReadFromImageFileWithName:index];
    return image;
}
 
-(void) createDataBaseAndTablesIfNeeded{
    
    //如果已經建立過就跳過
    if([fileMgr fileExistsAtPath:dbPath]) return;
    //打開通道
    db = [FMDatabase databaseWithPath:dbPath] ;
    [db open];
    
    if (![db open]) {
        NSLog(@"Could not open db!");
        return ;
    }
    //[db executeUpdate:@"CREATE TABLE IF NOT EXISTS PhotoList (Title, Text, ImgName)"];
    [db executeUpdate:@"CREATE TABLE PhotoList (RID, RNAME, ORD,SHOW_YN)"];
    //資料傳完了，通道要關好
    [db close];
}

-(void) insertDataToDB:(NSString *) title :(NSString *)text :(NSString *) imgname :(NSString *)showyn{
    
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    //開啟與資料庫的通道
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        [db executeUpdate:@"INSERT INTO t_ROAD (RID, RNAME, ORD,SHOW_YN) VALUES (?,?,?,?)",title,text,imgname,showyn];
        NSLog(@" insert data to PhotoList");
    }
    //資料傳完了，通道要關好
    [db close];
}
*/
-(void) getAllFreeWayDataFromDB{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"sd_Directory.db"];
    BOOL ok=[fileMgr fileExistsAtPath:dbPath];
    if (ok) {
        NSLog(@"db exit");
    }else{
        NSLog(@"db not exit");
    }
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if ([db hadError]) {
        NSLog(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_PRICE"];
        NSLog(@"result %@",[rs description]);
        while ([rs next]) {
            NSString *rid = [rs stringForColumn:@"RID"];
            NSString *spid = [rs stringForColumn:@"S_PID"];
            NSString *epid= [rs stringForColumn:@"E_PID"];
            NSString *km = [rs stringForColumn:@"KM"];
            NSString *price = [rs stringForColumn:@"PRICE"];
            
            NSLog(@"RID:%@, S_PID%@ , E_PID%@ , KM:%@ , PRICE:%@",rid,spid,epid,km,price);
        }
    }
    //資料傳完了，通道要關好
    [db close];
//    [paths release];
//    [documentDirectory release];
//    [dbPath release];
}
/*
-(void) setPhotoTitleToDB:(NSString*)phototitle :(NSString*)imgfilename{
    
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        [db executeUpdate:@"UPDATE PhotoList SET Title = ? WHERE Filepath =?",phototitle,imgfilename];
        
    }
    //資料傳完了，通道要關好
    [db close];
}

-(void) setPhotoTextToDB:(NSString*)phototext :(NSString*)imgfilename{
   
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        [db executeUpdate:@"UPDATE PhotoList SET Text = ? WHERE Filepath =?",phototext,imgfilename];
    }
    //資料傳完了，通道要關好
    [db close];
}
-(void) setPhotoFilepathToDB:(NSString *) photoNewname :(NSString *)imgfilename{
    NSString *isFilename;
    if (imgfilename) {
        NSLog(@"重設檔案：%@", imgfilename);
        
        db = [FMDatabase databaseWithPath:dbPath];
        [db open];
        if (![db open]) {
            NSLog(@"Could not open db.");
        }else {
            isFilename = [db stringForQuery:@"SELECT Filepath FROM PhotoList WHERE Filepath = ?",imgfilename];
            if (isFilename) {
                NSLog(@"isFilename :%@",isFilename);
                [db executeUpdate:@"UPDATE PhotoList SET Filepath = ? WHERE Filepath =?",photoNewname,isFilename];
            }
            else
                NSLog(@"No Filename in DB");
            
            //            FMResultSet *rs = [db executeQuery:@"SELECT Title, Text, Filepath FROM PhotoList"];
            //            while ([rs next]) {
            //                NSString *title = [rs stringForColumn:@"Title"];
            //                NSString *text = [rs stringForColumn:@"Text"];
            //                NSString *imgname= [rs stringForColumn:@"Filepath"];
            //                NSLog(@"Rest Title%@, Text%@ , Filepath%@",title,text,imgname);
            //            }
            
        }
        //資料傳完了，通道要關好
        [db close];
    }
}
 */
-(NSMutableArray *) getDataFromDBWithCondition:(NSString*)str1 condition2:(NSString*)str2 condition3:(NSString *)str3{
    NSMutableArray *array = [NSMutableArray array];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"sd_Directory.db"];
    if ([fileMgr fileExistsAtPath:dbPath]) {
        NSLog(@"db exit");
    }else
        NSLog(@"db not exit");
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSLog(@"getDataFromDBWithCondition%@-%@-%@", str1,str2,str3);
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_PRICE WHERE RID = ? AND S_PID = ? AND E_PID = ?",str1,str2,str3];
        //        title = [db stringForQuery:@"SELECT RID FROM t_PRICE WHERE RID = ?",imgfilename];
        while ([rs next]) {
           
            NSString *rid = [rs stringForColumn:@"RID"];
            NSString *spid = [rs stringForColumn:@"S_PID"];
            NSString *epid= [rs stringForColumn:@"E_PID"];
            NSString *km = [rs stringForColumn:@"KM"];
            NSString *price = [rs stringForColumn:@"PRICE"];
            NSLog(@"RID:%@, S_PID%@ , E_PID%@ , KM:%@ , PRICE:%@",rid,spid,epid,km,price);
            
            [dict setValue:rid forKey:@"RID"];
            [dict setValue:spid forKey:@"S_PID"];
            [dict setValue:epid forKey:@"E_PID"];
            [dict setValue:km forKey:@"KM"];
            [dict setValue:price forKey:@"PRICE"];
            
        }
        [array addObject:dict];
        
    }
    //資料傳完了，通道要關好
    [db close];
//    [paths release];
//    [documentDirectory release];
//    [dbPath release];
    return array;
}
-(NSMutableArray *) getFreewayDataFromDB{
    NSMutableArray *array = [[[NSMutableArray alloc]init]retain];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [[documentDirectory stringByAppendingPathComponent:@"sd_Directory.db"] copy];
    if ([fileMgr fileExistsAtPath:dbPath]) {
        NSLog(@"db exit");
    }else
        NSLog(@"db not exit");
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
       
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_ROAD WHERE SHOW_YN = ? ORDER BY ORD ASC",@"Y"];
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *rid = [rs stringForColumn:@"RID"];
            NSString *name = [rs stringForColumn:@"RNAME"];
            NSString *order= [rs stringForColumn:@"ORD"];
            NSString *isShow = [rs stringForColumn:@"SHOW_YN"];
            
            NSLog(@"RID:%@, RNAME%@ , ORD%@ , SHOW_YN:%@ ",rid,name,order,isShow);
            
            [dict setValue:rid forKey:@"RID"];
            [dict setValue:name forKey:@"RNAME"];
            
            [array addObject:dict];
            
            rid=nil;
            name = nil;
            order = nil;
            isShow = nil;
        }
        
    }
    [db close];
//    [paths release];
//    [documentDirectory release];
//    [dbPath release];
    return array;
}

-(NSMutableArray *) getRoadDataFromDB:(NSInteger)index{
    NSMutableArray *array = [[NSMutableArray alloc]init];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [[documentDirectory stringByAppendingPathComponent:@"sd_Directory.db"]copy];
    NSLog(@"dbpath %@",dbPath);
    if ([fileMgr fileExistsAtPath:dbPath]) {
        NSLog(@"db exit");
    }else
        NSLog(@"db not exit");
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        
        NSLog(@"getFreewayDataFromDB %d", index);
        FMResultSet *rs;
        if (index) {
            rs = [db executeQuery:@"SELECT * FROM t_POINT WHERE RID = ? ORDER BY ORD ASC",[NSString stringWithFormat:@"%d",index]];
        }else{
            rs = [db executeQuery:@"SELECT * FROM t_POINT ORDER BY ORD ASC"];
        }
        
        
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *rid = [rs stringForColumn:@"RID"];
            NSString *pid = [rs stringForColumn:@"PID"];
            NSString *name = [rs stringForColumn:@"PNAME"];
            NSString *memo = [rs stringForColumn:@"PMEMO"];
            NSString *order= [rs stringForColumn:@"ORD"];
            NSString *isCross = [rs stringForColumn:@"CROSS_YN"];
            NSString *gateway = [rs stringForColumn:@"GATEWAY"];
            
            
//            NSLog(@"RID:%@, PID :%@, PNAME:%@, PMEMO:%@, ORD:%@, CROSS_YN:%@ , GATEWAY:%@",rid,pid,name,memo,order,isCross,gateway);
            if (![gateway isEqualToString:@"0000"]) {
                [dict setValue:rid forKey:@"RID"];
                [dict setValue:pid forKey:@"PID"];
                [dict setValue:name forKey:@"PNAME"];
                [dict setValue:memo forKey:@"PMEMO"];
                [dict setValue:isCross forKey:@"CROSS_YN"];
                [dict setValue:[NSNumber numberWithInteger:[self toDecimalSystemWithBinarySystem:gateway]] forKey:@"GATEWAY"];
                [array addObject:dict];
            
                rid = nil;
                pid = nil;
                name = nil;
                memo = nil;
                order = nil;
                isCross = nil;
                gateway = nil;
            }else{
                NSLog(@"get exception %@ , %@",gateway,name);
            }
        }
        
    }
    [db close];
//    [paths release];
//    [documentDirectory release];
//    [dbPath release];
    return array;
}
/*
-(NSString *) getPhotoTextFromDB:(NSString*)imgfilename{
    NSString *text =nil;
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        
        NSLog(@"getPhotoTileFromDB%@", imgfilename);
        
        text = [db stringForQuery:@"SELECT Text FROM PhotoList WHERE Filepath = ?",imgfilename];
        
        NSLog(@"getPhotoTileFromDB_Text%@",text);
    }
    //資料傳完了，通道要關好
    [db close];
    return text;
}

-(void) deleteDBEntry:(NSString*)imgfilename{
    NSString *isFilename;
    if (imgfilename) {
        NSLog(@"刪除檔案：%@", imgfilename);
        db = [FMDatabase databaseWithPath:dbPath];
        [db open];
        if (![db open]) {
            NSLog(@"Could not open db.");
        }else {
            isFilename = [db stringForQuery:@"SELECT Filepath FROM PhotoList WHERE Filepath = ?",imgfilename];
            if (isFilename) {
                NSLog(@"isFilename :%@",isFilename);
                [db executeUpdate:@"DELETE FROM PhotoList WHERE Filepath = ?", isFilename];
            }
            else
                NSLog(@"No Filename in DB");
            //
            //            FMResultSet *rs = [db executeQuery:@"SELECT Title, Text, Filepath FROM PhotoList"];
            //            while ([rs next]) {
            //                NSString *title = [rs stringForColumn:@"Title"];
            //                NSString *text = [rs stringForColumn:@"Text"];
            //                NSString *imgname= [rs stringForColumn:@"Filepath"];
            //                NSLog(@"RestFile Title%@, Text%@ , Filepath%@",title,text,imgname);
            //            }
            
        }
        //資料傳完了，通道要關好
        [db close];
    }
}
-(BOOL) deleteImgFile:(NSString*)imgfilename{
    NSError *error;
    BOOL deleteSuccess =NO;
    if (imgfilename) {
        NSLog(@"刪除檔案：%@", imgfilename);
        
        deleteSuccess = [fileMgr removeItemAtPath:[HOME_PATH stringByAppendingPathComponent:imgfilename] error:&error];
        
        //NSArray *temp = [imgfilename componentsSeparatedByString:@"."];
        //name = temp[0];
        //name = [name stringByAppendingString:IMG_TYPE];
        //NSLog(@"刪除檔案：%@", name);
        //deleteSuccess = [fileMgr removeItemAtPath:[IMG_PATH stringByAppendingPathComponent:imgfilename] error:&error];
        NSArray *listdata = [self getImageFileList];
        
        for (NSString *file in listdata) {
            NSLog(@"目前剩餘檔案：%@\n",file);
        }
        
    }
    if (!deleteSuccess) {
        NSLog(@"Error delete file at %@\n%@",HOME_PATH, [error localizedFailureReason]);
    }
    return deleteSuccess;
    
}
 */
-(void)checkDefaultDB{
    NSArray *path = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [path lastObject];
    
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:@"ETC_DB_1.db"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ETC_DB_1" ofType:@"db"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Error: Unable to copy preloaded database.");
        }
    }
}
- (NSInteger)toDecimalSystemWithBinarySystem:(NSString *)binary {
    int total = 0;
    int  temp = 0;
    
    for (int i = 0; i < binary.length; i ++) {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        total += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",total];
    
    return [result integerValue];
}

-(NSMutableDictionary *) getPriceWithCondition:(NSString*)str1 condition2:(NSString*)str2 condition3:(NSString *)str3 {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSLog(@"str1: %@, str2: %@ ,str3: %@",str1,str2,str3);
    if ([fileMgr fileExistsAtPath:dbPath]) {
//        NSLog(@"db exit");
    }else
        NSLog(@"db not exit");
    db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_PRICE WHERE RID = ? AND S_PID = ? AND E_PID = ?",str1,str2,str3];
        while ([rs next]) {
            
            NSString *price  = [rs stringForColumn:@"PRICE"];
            NSString *km = [rs stringForColumn:@"KM"];
            NSLog(@"db get price :%@ ,km : %@",price,km);
            
            [dict setValue:price forKey:@"PRICE"];
            [dict setValue:km forKey:@"KM"];
            
            price = nil;
            km=nil;
        }
        
    }
    
    [db close];
    return dict;
}

@end
