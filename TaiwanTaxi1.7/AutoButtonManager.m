//
//  AutoButtonManager.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/30.
//
//

#import "AutoButtonManager.h"
#import "AFHTTPRequestOperation.h"

@implementation AutoButtonManager
@synthesize alertDelegate;
static AutoButtonManager *sharedInstance = nil;

+(AutoButtonManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AutoButtonManager alloc]init];
    });
    return sharedInstance;
}

#pragma mark - init
-(id)init{
    if (self = [super init]) {
        menuArray = [[[NSMutableArray alloc]init]retain];
        buttonArray = [[[NSMutableArray alloc]init]retain];
        downloadArray = [[[AutoButtonArrayManager alloc]init]retain];
        isRequestOnly = FALSE;
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [menuArray release];
    [buttonArray release];
    [downloadArray release];
    [super dealloc];
}

#pragma mark - Button set up
-(void) setupMenuButton:(id)object{
    
    isdownload = FALSE;
    
    NSArray *temp = [[self filterObjectToGetMenu:object] copy];
//    NSLog(@"temp %@",temp);
    [self menuSetup:temp];
    
    
    NSArray *temp1 = [[self filterObjectToGetButton:object] copy];
    NSLog(@"temp1 %@",temp1);
    [self buttnSetup:temp1];
//    NSLog(@"temp1 %@",buttonArray);

    if ([downloadArray count] && !isRequestOnly) {

        isRequestOnly = TRUE;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(confirmToDownload) name:@"DownloadImage" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveToUserDefultForNotification) name:@"SaveMenuVersion" object:nil];
        
        [alertDelegate showChangeMenuUIAlert];
        
    }else{
        NSLog(@"test: menuArray %@\n, buttonArray %@ ",menuArray,buttonArray);
        return;
    }
    
}

-(void)menuSetup:(NSArray *)array{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"MenuObject"])
        menuArray = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"MenuObject"]] mutableCopy];
        

//    NSLog(@"%@", [[array objectAtIndex:0] objectForKey:@"CreateDate"]);
    NSDate *date1,*date2,*date;
    if (IS_IPHONE_5) {
        date = [self StringToDate:TAXI_MENU_UI_BUTTONIMG_I5_DEFAULT_VERSION];
        NSLog(@"i5 %@",date);
    }else{
        date = [self StringToDate:TAXI_MENU_UI_BUTTONIMG_I4_DEFAULT_VERSION];
        NSLog(@"i4 %@",date);
    }
    
    
    for (int i =0; i<[array count]; i++) {
        
        date1 = [self StringToDate:[[array objectAtIndex:i] objectForKey:@"CreateDate"]];
        if (![self CompareVersionDate:date :date1]) {
            
            if ([defaults valueForKey:@"MenuObject"]) {
                
                date2 = [self StringToDate:[[menuArray objectAtIndex:i] objectForKey:@"CreateDate"]];
                
                if (![self CompareVersionDate:date1 :date2]) {
                    
                    [menuArray replaceObjectAtIndex:i withObject:[array objectAtIndex:i]];
                    [downloadArray addToQueue:[array objectAtIndex:i]];
                }
            }
            else
            {
                [downloadArray addToQueue:[array objectAtIndex:i]];
                [menuArray addObject:[array objectAtIndex:i]];
            }
            
        }
    }
    
}
-(void)buttnSetup:(NSArray *)array{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"ButtonObject"])
        buttonArray = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"ButtonObject"]] mutableCopy];
    
    
    //    NSLog(@"%@", [[array objectAtIndex:0] objectForKey:@"CreateDate"]);
    NSDate *date1,*date2,*date;
    if (IS_IPHONE_5) {
        date = [self StringToDate:TAXI_MENU_UI_BUTTONIMG_I5_DEFAULT_VERSION];
    }else
        date = [self StringToDate:TAXI_MENU_UI_BUTTONIMG_I4_DEFAULT_VERSION];
    
    for (int i =0; i<[array count]; i++) {
        date1 = [self StringToDate:[[array objectAtIndex:i] objectForKey:@"CreateDate"]];
        
        if (![self CompareVersionDate:date :date1]) {
            
            if ([defaults valueForKey:@"ButtonObject"]) {
                
                date2 = [self StringToDate:[[buttonArray objectAtIndex:i] objectForKey:@"CreateDate"]];/////bug
                if (![self CompareVersionDate:date1 :date2]) {
                    
                    [buttonArray replaceObjectAtIndex:i withObject:[array objectAtIndex:i]];
                    [downloadArray addToQueue:[array objectAtIndex:i]];
                }
            }
            else
            {
                [downloadArray addToQueue:[array objectAtIndex:i]];
                [buttonArray addObject:[array objectAtIndex:i]];
            }
            
        }
    }
}

#pragma mark - UIAlert confirm to downlaod Images
-(void)confirmToDownload{
    NSLog(@"tt : %@\n%@",menuArray,buttonArray);
    
    //modified by kiki Huang 2014.02.10
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ImageIsDownload"];
    
    [self downloadImage:[downloadArray deQueue]];
}

#pragma mark - Filter data from server
-(NSArray *)filterObjectToGetMenu:(id)object{
    NSLog(@"menu 0: %@", object);
    NSString *fileType;
    NSMutableArray *resultArray = [NSMutableArray array];
    // init empty array
    for (int i=0; i<2; i++) {
        [resultArray addObject:[NSNull null]];
    }
    
    for (NSDictionary *dict in object) {
//        NSLog(@"teyp %@",[[dict objectForKey:@"PicPath"] pathExtension]);
        fileType = [[dict objectForKey:@"PicPath"] pathExtension];
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
        
        //add
        [resultDict setValue:[NSNumber numberWithInt:0] forKey:@"MenuType"];
        [resultDict setValue:[NSNumber numberWithInt:[self imageTypeStringToEnum:[dict objectForKey:@"BtnFunction"]]] forKey:@"FunctionTag"];
        NSLog(@"imageurl%@",[self getDownloadPath:[dict objectForKey:@"PicPath"]]);
        [resultDict setValue:[self getDownloadPath:[dict objectForKey:@"PicPath"]] forKey:@"DownloadPath"];
        
        if ([[dict objectForKey:@"Location"] isEqualToString:@"0"]) {
            [resultDict setValue:[self getSaveDocumentPath:[@"background" stringByAppendingPathExtension:fileType]] forKey:@"SavePath"];
            [resultArray replaceObjectAtIndex:0 withObject:resultDict];
            
        }else if([[dict objectForKey:@"Location"] isEqualToString:@"01"]){
            
            [resultDict setValue:[self getSaveDocumentPath:[@"persion" stringByAppendingPathExtension:fileType]] forKey:@"SavePath"];
            [resultArray replaceObjectAtIndex:1 withObject:resultDict];
        }
        
        [resultDict retain];
    }
    
    NSLog(@"menu : %@", resultArray);
    [fileType retain];
    return resultArray;
}

-(NSArray *)filterObjectToGetButton:(id)object{
    
    NSString *fileType;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    //init empty array
    for(int i = 0; i < ([object count] - 2); i++)
        [resultArray addObject: [NSNull null]];
    
    for(NSDictionary *dict in object) {
        fileType = [[dict objectForKey:@"PicPath"] pathExtension];
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        [resultDict setValue:[NSNumber numberWithInt:1] forKey:@"MenuType"];
        [resultDict setValue:[NSNumber numberWithInteger:[self imageTypeStringToEnum:[dict objectForKey:@"BtnFunction"]]]
                      forKey:@"FunctionTag"];
        [resultDict setValue:[self getDownloadPath:[dict objectForKey:@"PicPath"]] forKey:@"DownloadPath"];
        
        if (!([[dict objectForKey:@"Location"] isEqualToString:@"0"] || [[dict objectForKey:@"Location"] isEqualToString:@"01"])) {
            
            int i = [[dict objectForKey:@"Location"] integerValue]-1;
            [resultDict setValue:[self getSaveDocumentPath:[NSString stringWithFormat:@"btn%d.%@", i, fileType]] forKey:@"SavePath"];
            [resultArray replaceObjectAtIndex:i withObject:resultDict];
        }
        
        [resultDict retain];
    }
    
    NSLog(@"button : %@", resultArray);
    [fileType retain];
    return  resultArray;
}

#pragma mark - Return image file path
-(NSString *)getDownloadPath:(NSString *)name{
    NSString *baseUrl =[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    
    NSString *url = [baseUrl stringByAppendingString:[@"stark/images/package/" stringByAppendingPathComponent:name]];
    NSString *_escapedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"_escapeedUrlString %@",_escapedUrlString);
    return _escapedUrlString;
}

-(NSString *)getSaveDocumentPath:(NSString *)name{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:name];
}

#pragma mark - Download images from server
-(void)downloadImage:(NSDictionary *)param{
    NSLog(@"para %@ save %@",[param objectForKey:@"DownloadPath"],[param objectForKey:@"SavePath"]);
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    NSURLRequest *request =[[NSURLRequest requestWithURL:[NSURL URLWithString:[param objectForKey:@"DownloadPath"]]] copy];
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc]initWithRequest:request] autorelease];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[param objectForKey:@"SavePath"] append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([downloadArray count]) {
            [self downloadImage:[downloadArray deQueue]];
        }
        else{
            NSLog(@"result success : %@\n%@",menuArray,buttonArray);
            [self saveToUserDefault];
            app.networkActivityIndicatorVisible = NO;
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DownloadImage" object:nil];
            
            //modified by kiki 2014.02.10
            [[NSNotificationCenter defaultCenter]postNotificationName:@"autoButtonDone" object:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@",error);
        isdownload = TRUE;

        [self downloadFailProcess:param];
        
        if ([downloadArray count]) {
            [self downloadImage:[downloadArray deQueue]];
        }
        else{
            NSLog(@"result fail : %@\n%@",menuArray,buttonArray);
            [self saveToUserDefault];
            app.networkActivityIndicatorVisible = NO;
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DownloadImage" object:nil];
            
            //modified by kiki 2014.02.10
            [[NSNotificationCenter defaultCenter]postNotificationName:@"autoButtonDone" object:self];
        }
    }];
    [operation start];
}

#pragma mark - Save details to userfault
-(void)saveToUserDefault{
    NSString *msg;
    if (!isdownload) {
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"ImageIsDownload"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:menuArray] forKey:@"MenuObject"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:buttonArray] forKey:@"ButtonObject"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        msg = @"主選單主題下載成功\n重啟App即可更新！";
    }
    
    else {
        msg = @"主選單主題下載失敗\n下次重啟App將重新下載！";
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    isRequestOnly = FALSE;
    [self showAlert:msg];
}

-(void)saveToUserDefultForNotification{
    NSLog(@"tt : %@\n%@",menuArray,buttonArray);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //edited by kiki Huang 2014.02.05
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MenuObject"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"ButtonObject"]) {
        
        NSString *tempDateStr;
        
        
        //menu
        NSMutableArray *tempArray = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"MenuObject"]] mutableCopy];
        for (int i = 0 ; i < [menuArray count]; i++) {
            tempDateStr = [[menuArray objectAtIndex:i] objectForKey:@"CreateDate"];
            NSDictionary *tempDict = [[tempArray objectAtIndex:i] copy];
            [tempDict setValue:tempDateStr forKey:@"CreateDate"];
            
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:tempArray] forKey:@"MenuObject"];
        
        
        
        
        //button
        tempArray = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"ButtonObject"]] mutableCopy];
        for (int i = 0 ; i < [buttonArray count]; i++) {
            tempDateStr = [[buttonArray objectAtIndex:i] objectForKey:@"CreateDate"];
            NSDictionary *tempDict = [[tempArray objectAtIndex:i] copy];
            [tempDict setValue:tempDateStr forKey:@"CreateDate"];
            
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:tempArray] forKey:@"ButtonObject"];
    }
    
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:menuArray] forKey:@"MenuObject"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:buttonArray] forKey:@"ButtonObject"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSLog(@"ww : %@", [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"MenuObject"]]);
}

#pragma mark - Other methods
-(void)downloadFailProcess:(NSDictionary *)failPacket{
    NSInteger failIndex;
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    if ([failPacket objectForKey:@"MenuType"]==0) {
        
        failIndex = [menuArray indexOfObject:failPacket];
        dict = [[menuArray objectAtIndex:failIndex]mutableCopy];
        [dict setValue:[self StringToDate:TAXI_MENU_UI_BUTTONIMG_DOWNLOAD_ERROR_VERSION]  forKey:@"CreateDate"];
        [menuArray replaceObjectAtIndex:failIndex withObject:dict];
        
    }else{
        
        failIndex = [buttonArray indexOfObject:failPacket];
        dict = [[buttonArray objectAtIndex:failIndex]mutableCopy];
        [dict setValue:[self StringToDate:TAXI_MENU_UI_BUTTONIMG_DOWNLOAD_ERROR_VERSION]  forKey:@"CreateDate"];
        [buttonArray replaceObjectAtIndex:failIndex withObject:dict];
    }
    [dict release];
}

-(NSInteger)imageTypeStringToEnum:(NSString *)strVal{
    NSArray *imageTypeArray = [[NSArray alloc]initWithObjects:TaxiButtonTagArray];
    NSInteger n = [imageTypeArray indexOfObject:strVal];
    
    if (n != NSNotFound) {
        return (TaxiButtonTag) n;
    }
    return -1;
}

-(void)showAlert:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles: nil];
    [alert show];
    alert = nil;
}

-(NSDate*)StringToDate:(NSString *)str{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSLog(@"stringToDate %@", [formatter dateFromString:str]);
    return [formatter dateFromString:str];
}

-(BOOL)CompareVersionDate:(NSDate*)date1 :(NSDate*)date2{
    
    if ([date1 compare:date2] == NSOrderedDescending) {
        return NO;
        
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        return NO;
        
    } else {
        return YES;
        
    }
}
@end
