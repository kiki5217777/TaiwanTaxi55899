//
//  FreewayViewController.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/17.
//  Copyright (c) 2013年 kiki Huang. All rights reserved.
//

#import "FreewayViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"
#import "ResultViewController.h"
#import "TextAlertView.h"
#import "CustomIOS7AlertView.h"
#define FREEWAY_SELECTBTN_TAG 100
#define START_SELECTBTN_TAG 101
#define END_SELECTBTN_TAG 102

@interface FreewayViewController (){
    NSInteger tableViewRowSelect,freewayPickerViewRowSelect,stareRoadPickerViewRowSelect,startroadPickerViewRowSelect;
    UIButton *activebtn;
    int selectedButtonTag,currentFreewayIndex,currentStartRoadIndex,currentEndRoadIndex,freewaycount;
    BOOL rowIsSelected;
}

@end

@implementation FreewayViewController
@synthesize cellArray,freewayArray,startRoadArray,roadArray,tempRoadArray,actionSheet,pickerViewSelectRowTitle,filterExitOnlyArray;
#pragma mark - dealloc
- (void)dealloc
{
    [activebtn release];
//    [textalert release];
    [_myTableView release];
    [_morebtnView release];
    [self.fmdbManager release];
    [self.cellArray release];
    [self.freewayArray release];
    [self.startRoadArray release];
//    [self.tempRoadArray release];
//    [self.roadArray release];
    [self.filterExitOnlyArray release];
    [self.actionSheet release];
    [self.pickerViewSelectRowTitle release];
    [self.pickerViewTextField release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
#ifdef __IPHONE_7_0
        if([[UIDevice currentDevice].systemVersion hasPrefix:@"7"])
        {
            self.extendedLayoutIncludesOpaqueBars = YES;
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //view initial
    self.title=@"國道收費試算";
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"回首頁"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(close)];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    self.myTableView.tableFooterView = self.morebtnView;
    
    //piker view row index initial
    rowIsSelected = false;
    currentFreewayIndex= 0;
    currentStartRoadIndex = 0;
    currentEndRoadIndex = 0;
    freewayPickerViewRowSelect = 0;
    stareRoadPickerViewRowSelect = 0;
    
    //fmdb manager initial
    self.fmdbManager = [[FMDBManager alloc]init];
    freewayArray = [[NSMutableArray alloc]init];
    startRoadArray = [[NSMutableArray alloc]init];
    roadArray = [[NSArray alloc]init];
    tempRoadArray = [[NSMutableArray alloc]init];
    filterExitOnlyArray = [[NSMutableArray alloc]init];
    
    //table cell array
    cellArray = [[NSMutableArray alloc]init];
    
    //fmdb data
    freewayArray = [self.fmdbManager getFreewayDataFromDB];
    startRoadArray = [[self.fmdbManager getRoadDataFromDB:0]copy];
    
    [self addNewItemToCellArray];
    
    NSString *title = @"注意事項";
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Precautions" ofType:@"txt"];
    NSString *precationOfServer = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    TextAlertViewiOS7 *textalert = [[[TextAlertViewiOS7 alloc] initWithTitle:title precautionOfService:precationOfServer parentView:self.parentViewController.view]autorelease];
    textalert.delegate = self;
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"show alert"]){
        [textalert show:1];
        
    }

}

-(void)viewWillAppear:(BOOL)animated{
    
    stareRoadPickerViewRowSelect = 0;
    [super viewWillAppear:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    activebtn = nil;
//    textalert = nil;
    
    [super viewWillDisappear:YES];
}
-(void)viewDidUnload{
    
    activebtn = nil;
//    textalert = nil;
    [self setMyTableView:nil];
    [self setMorebtnView:nil];
    self.fmdbManager = nil;
    self.cellArray = nil;
    self.freewayArray = nil;
    self.startRoadArray = nil;
    self.tempRoadArray = nil;
    self.roadArray = nil;
    self.filterExitOnlyArray = nil;
    self.actionSheet = nil;
    self.pickerViewSelectRowTitle = nil;
    self.pickerViewTextField = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user interaction

-(void)close
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [cellArray count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tmpStr=@" ";
    NSString *CellIdentifier = @"CustomTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        else{
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSInteger index = [indexPath row]%2;
    
    UIView *customCellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 90)];
    
    UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 90)];
    if (index==0) {
        [backgroundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cell_1.png"]]];
    }else
        [backgroundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cell_2.png"]]];
    
    [customCellView addSubview:backgroundImage];
    
    tmpStr = [[cellArray objectAtIndex:indexPath.row] objectForKey:@"Freeway"];
    UIButton *freewaySelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [freewaySelectBtn setFrame:CGRectMake(50, 14, 90, 24)];
    [freewaySelectBtn setBackgroundImage:[UIImage imageNamed:@"select_short_1218.png"] forState:UIControlStateNormal];
    [freewaySelectBtn setTitle:tmpStr forState:UIControlStateNormal];

    [freewaySelectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [freewaySelectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [freewaySelectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    freewaySelectBtn.tag = FREEWAY_SELECTBTN_TAG;
    [freewaySelectBtn addTarget:self action:@selector(buttonPressedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [customCellView addSubview:freewaySelectBtn];

    
    tmpStr = [[cellArray objectAtIndex:indexPath.row] objectForKey:@"StartRoad"];
    UIButton *startSelectBtn = [ UIButton buttonWithType:UIButtonTypeCustom];
    [startSelectBtn setFrame:CGRectMake(152, 14, 160, 24)];
    [startSelectBtn setBackgroundImage:[UIImage imageNamed:@"select_long_1218.png"] forState:UIControlStateNormal];
    [startSelectBtn setTitle:tmpStr forState:UIControlStateNormal];

    [startSelectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [startSelectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    startSelectBtn.titleEdgeInsets = UIEdgeInsetsMake(0,-30, 0, 0);
    startSelectBtn.tag = START_SELECTBTN_TAG;
    [startSelectBtn addTarget:self action:@selector(buttonPressedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [customCellView addSubview:startSelectBtn];

    
    tmpStr = [[cellArray objectAtIndex:indexPath.row] objectForKey:@"EndRoad"];
    UIButton *endSelectBtn = [ UIButton buttonWithType:UIButtonTypeCustom];
    [endSelectBtn setFrame:CGRectMake(152, 52, 160, 24)];
    [endSelectBtn setBackgroundImage:[UIImage imageNamed:@"select_long_1218.png"] forState:UIControlStateNormal];
    [endSelectBtn setTitle:tmpStr forState:UIControlStateNormal];

    [endSelectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [endSelectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    endSelectBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    endSelectBtn.tag = END_SELECTBTN_TAG;
    [endSelectBtn addTarget:self action:@selector(buttonPressedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [customCellView addSubview:endSelectBtn];
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 14, 50, 20)];
    [numberLabel setBackgroundColor:[UIColor clearColor]];
    numberLabel.text = [NSString stringWithFormat:@"%d.",indexPath.row+1];
    numberLabel.textColor =[UIColor grayColor];
    [customCellView addSubview:numberLabel];
    
    [cell.contentView addSubview:customCellView];
    return cell;
}

#pragma mark - Buttom Events
- (IBAction)addMoreBtnPressed:(id)sender {
    
   [self addNewItemToCellArray];
    [self.myTableView reloadData];
    if (self.myTableView.contentSize.height > self.myTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.myTableView.contentSize.height - self.myTableView.frame.size.height);
        [self.myTableView setContentOffset:offset animated:YES];
    }

    
}

- (IBAction)calculateTotalRate:(id)sender {
    
    __block float price=0;
    __block NSMutableArray*routeArray =[[NSMutableArray alloc]init];
    
//    NSLog(@"cellarray %d",[cellArray count]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=0; i<[cellArray count]; i++) {
            NSDictionary *d = [cellArray objectAtIndex:i];
            NSMutableDictionary *result = [self.fmdbManager getPriceWithCondition:[d objectForKey:@"Freeway_rid"]
                                                            condition2:[d objectForKey:@"StartRoad_pid"]
                                                            condition3:[d objectForKey:@"EndRoad_pid"]];
            
//            NSLog(@"price result %@",result);
            if ([result objectForKey:@"PRICE"]!=nil) {
                
                price += [[result objectForKey:@"PRICE"] floatValue];
                NSMutableDictionary *routeDict =[[NSMutableDictionary alloc]init];
                [routeDict setValue:[d objectForKey:@"StartRoad"]  forKey:@"StartRoad"];
                [routeDict setValue:[d objectForKey:@"EndRoad"] forKey:@"EndRoad"];
                [routeDict setValue:[result objectForKey:@"PRICE"] forKey:@"PRICE"];
                [routeDict setValue:[result objectForKey:@"KM"] forKey:@"KM"];
                [routeArray addObject:routeDict];
            }
            

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            NSLog(@"routeArray %@",routeArray);
//            NSLog(@"total price :%f",price);
//            price = floor(price);
            
            /*
            if (price <=24) {
                price =0;
                
            }else if(price >24 && price <=240){
                price = floor(price-24);
            }
            else if(price >240) {
                NSLog(@"over 240 dollars");
                price = floor(price - [self countExtraCost:price]-24);
            }*/
            
//            NSLog(@"total price 計算後四捨五入 :%f",roundf(price));
            
            ResultViewController *resultView = [[ResultViewController alloc]initWithNibName:@"ResultViewController" bundle:nil];
            resultView.routeArray = routeArray;
            resultView.totalPrice = [NSString stringWithFormat:@"%i",(int)roundf(price)];
            [self.navigationController pushViewController:resultView animated:YES];

        });
    });
}

-(float)countExtraCost:(float)price{
    float extra;
    extra = price-240;
    extra = extra-extra*0.75;
//    NSLog(@"extra %f",extra);
    
    return extra;
}
#pragma mark - ActionSheet methods

-(void) createActionSheet:(int) buttonTag{
    
    selectedButtonTag = buttonTag;
    freewayPickerViewRowSelect =0;
    stareRoadPickerViewRowSelect = 0;
    // set the frame to zero
    self.pickerViewTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pickerViewTextField];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    pickerView.tag = buttonTag;
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.pickerViewTextField.inputView = pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCurrentActionSheet:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCurrentActionSheet:)];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.pickerViewTextField.inputAccessoryView = toolBar;
    
    if (buttonTag == FREEWAY_SELECTBTN_TAG) {
        rowIsSelected = false;
        [pickerView selectRow:0 inComponent:0 animated:NO];
    }
    else if (buttonTag == START_SELECTBTN_TAG){
        rowIsSelected = false;
        [pickerView selectRow:0 inComponent:0 animated:NO];
    }
    else if (buttonTag == END_SELECTBTN_TAG){
        rowIsSelected = false;
        [pickerView selectRow:0 inComponent:0 animated:NO];
    }
    
    
    
    [self.pickerViewTextField becomeFirstResponder];
}

- (void) dismissCurrentActionSheet:(UIBarButtonItem *)sender{

    if (selectedButtonTag == FREEWAY_SELECTBTN_TAG) {
        if (!rowIsSelected) {
            freewayPickerViewRowSelect =0;
        }
        
//        NSLog(@"pickerrowselect %d",freewayPickerViewRowSelect);
        
        [self buttonOfTableViewTitleChange:[[cellArray objectAtIndex:tableViewRowSelect] objectForKey:@"Freeway_rid"] CompareString:[[freewayArray objectAtIndex:freewayPickerViewRowSelect] objectForKey:@"RID"]];

    }
    if (selectedButtonTag == START_SELECTBTN_TAG) {
        if (!rowIsSelected) {
            stareRoadPickerViewRowSelect =0;
        }
        [self buttonOfTableViewTitleChange:[[cellArray objectAtIndex:tableViewRowSelect] objectForKey:@"StartRoad_pid"]
                             CompareString:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect] objectForKey:@"PID"]];
        
    }
    if (selectedButtonTag == END_SELECTBTN_TAG) {
        if (!rowIsSelected) {
            stareRoadPickerViewRowSelect =0;
           
        }
        [self buttonOfTableViewTitleChange:[[cellArray objectAtIndex:tableViewRowSelect] objectForKey:@"EndRoad_pid"]
                             CompareString:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect] objectForKey:@"PID"]];
        
    }

    [self.pickerViewTextField resignFirstResponder];

}

- (void) cancelCurrentActionSheet:(UIBarButtonItem *)sender{
     [self.pickerViewTextField resignFirstResponder];
    [self.pickerViewTextField removeFromSuperview];
//    [actionSheet dismissWithClickedButtonIndex:((UISegmentedControl *)sender).selectedSegmentIndex animated:YES];
    
}

#pragma mark - PickerView delegate and methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == FREEWAY_SELECTBTN_TAG)
    {
        return [freewayArray count];
    }
    return [filterExitOnlyArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (pickerView.tag == FREEWAY_SELECTBTN_TAG) {
       return [[freewayArray objectAtIndex:row]objectForKey:@"RNAME"];
    }
    
    return [NSString stringWithFormat:@"%@%@",[[filterExitOnlyArray objectAtIndex:row]objectForKey:@"PNAME"],[[filterExitOnlyArray objectAtIndex:row]objectForKey:@"PMEMO"]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
//    NSLog(@"select row index %d",freewayPickerViewRowSelect);
    if (pickerView.tag == FREEWAY_SELECTBTN_TAG) {
        rowIsSelected = true;
        freewayPickerViewRowSelect = row;
    }
    else{
        rowIsSelected = true;
        stareRoadPickerViewRowSelect = row;
    }
}

#pragma mark - Buttons event methods

-(void)buttonPressedEvent:(id)sender{
    
    activebtn = (UIButton *)sender;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTableView];
    tableViewRowSelect = [self.myTableView indexPathForRowAtPoint:buttonPosition].row;
//    NSLog(@"tableViewRowSelect %d",tableViewRowSelect);
     NSDictionary *dict = [cellArray objectAtIndex:tableViewRowSelect];
    NSString *str=[dict objectForKey:@"Freeway"];
    NSString *str1 = [dict objectForKey:@"StartRoad"];
//    NSLog(@"str%@, str1%@",str,str1);
    
    switch (activebtn.tag)
    {
        case FREEWAY_SELECTBTN_TAG:
        {
            [self createActionSheet:activebtn.tag];
            break;
        }
        case START_SELECTBTN_TAG:
        {
            if ([str isEqualToString:@"請選擇"]) {
                [self showAlertView:@"請先選擇國道"];
            }
            else{
                roadArray = nil;
                tempRoadArray = nil;
                
                roadArray =[[self filterFreeWayToGetStartRoad:[[cellArray objectAtIndex:tableViewRowSelect]objectForKey:@"Freeway_rid"]] copy];
                
                filterExitOnlyArray = [[self filterFreeWayToGetStartRoadRemoveExitOnly]copy];
                
                [self createActionSheet:activebtn.tag];

            }
            break;
        }
        case END_SELECTBTN_TAG:
        {
            if ([str isEqualToString:@"請選擇"] || [str1 isEqualToString:@"選擇起點"]) {
                [self showAlertView:@"請先選擇國道與起點"];
            }else{
                roadArray = nil;
                tempRoadArray = nil;
                
                roadArray = [[self filterFreeWayToGetStartRoad:[[cellArray objectAtIndex:tableViewRowSelect]objectForKey:@"Freeway_rid"]]copy];

                filterExitOnlyArray = [[self filterStartRoadToGetEndRoad:[[[cellArray objectAtIndex:tableViewRowSelect] objectForKey:@"StartGate"] integerValue] keyword:[[cellArray objectAtIndex:tableViewRowSelect] objectForKey:@"StartRoad_pid"]] copy];
                
                [self createActionSheet:activebtn.tag];
            }
            
            break;
        }
        default:
            break;
    }
    
}
-(NSArray*)getRoadArrayForDefault:(NSInteger)tag{
//    roadArray = nil;
//    tempRoadArray = nil;
//    NSLog(@"freewayArray 0 %@",[[freewayArray objectAtIndex:tag]objectForKey:@"RID"]);
    roadArray =[self filterFreeWayToGetStartRoad:[[freewayArray objectAtIndex:tag]objectForKey:@"RID"]];
//    NSLog(@"roadArray default %@",roadArray);
    filterExitOnlyArray = [[self filterFreeWayToGetStartRoadRemoveExitOnly]copy];
    tempRoadArray= [filterExitOnlyArray copy];
//    NSLog(@"temparray default %@",tempRoadArray);
    return tempRoadArray;
}

-(NSArray*)getFilterRoadArrayForDefault:(NSInteger)tag{
//    NSLog(@"roadarray gateway %i , pid %@",[[[roadArray objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue],[[roadArray objectAtIndex:0] objectForKey:@"PID"]);
    
    tempRoadArray = [self filterStartRoadToGetEndRoad:[[[filterExitOnlyArray objectAtIndex:tag] objectForKey:@"GATEWAY"] integerValue] keyword:[[filterExitOnlyArray objectAtIndex:tag] objectForKey:@"PID"]];
//     NSLog(@"filter temparray1 %@",tempRoadArray);
    
//    tempRoadArray = [self filterFreeWayToGetStartRoadAndRemoveItself:[[filterExitOnlyArray objectAtIndex:tag]objectForKey:@"PID"]];
//    NSLog(@"filter temparray %@",tempRoadArray);
    return tempRoadArray;
}
-(BOOL)isBtnTitleEmpty:(UIButton *)btn :(NSString *)title{
    BOOL isEmpty = NO;
    if ([[btn currentTitle]isEqualToString:title])
    {
        isEmpty = YES;
    }
    return isEmpty;
}
         
-(void)showAlertView:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"錯誤" message:msg delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
}
#pragma mark - CustomTableViewCell Check

-(void)addNewItemToCellArray{
    freewayPickerViewRowSelect = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[[freewayArray objectAtIndex:0] objectForKey:@"RNAME"] forKey:@"Freeway"];
    
    [dict setValue:[[[self getRoadArrayForDefault:freewayPickerViewRowSelect] objectAtIndex:0] objectForKey:@"PNAME"] forKey:@"StartRoad"];
    
    [dict setValue:[[[self getFilterRoadArrayForDefault:0] objectAtIndex:0] objectForKey:@"PNAME"] forKey:@"EndRoad"];
    
    [dict setValue:[[freewayArray objectAtIndex:0] objectForKey:@"RID"] forKey:@"Freeway_rid"];
    
    [dict setValue:[[[self getRoadArrayForDefault: freewayPickerViewRowSelect] objectAtIndex:0] objectForKey:@"PID"] forKey:@"StartRoad_pid"];
    
    [dict setValue:[[[self getFilterRoadArrayForDefault:0] objectAtIndex:0] objectForKey:@"PID"] forKey:@"EndRoad_pid"];
    
    [dict setValue:[NSNumber numberWithInteger:[[[[self getRoadArrayForDefault:freewayPickerViewRowSelect] objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue]] forKey:@"StartGate"];
    [dict setValue:[NSNumber numberWithInteger:[[[[self getFilterRoadArrayForDefault:0] objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue]] forKey:@"EndGate"];
    
    [cellArray addObject:dict];
//    dict = nil;
}
-(void)buttonOfTableViewTitleChange:(NSString *)oldStr CompareString:(NSString *)newStr{
    if (![oldStr isEqualToString:newStr]) {
        NSMutableDictionary *dict = [cellArray objectAtIndex:tableViewRowSelect];
        if (selectedButtonTag == FREEWAY_SELECTBTN_TAG){
            stareRoadPickerViewRowSelect = 0;
            NSArray *array;
            [dict setValue:[[freewayArray objectAtIndex:freewayPickerViewRowSelect]objectForKey:@"RID"] forKey:@"Freeway_rid"];
            [dict setValue:[[freewayArray objectAtIndex:freewayPickerViewRowSelect] objectForKey:@"RNAME"] forKey:@"Freeway"];
            
            
             array = [self getRoadArrayForDefault:freewayPickerViewRowSelect];
            [dict setValue:[[array objectAtIndex:0] objectForKey:@"PNAME"] forKey:@"StartRoad"];
            [dict setValue:[[array objectAtIndex:0] objectForKey:@"PID"] forKey:@"StartRoad_pid"];
            [dict setValue:[NSNumber numberWithInteger:[[[array objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue]] forKey:@"StartGate"];
            
            
            array = [self getFilterRoadArrayForDefault:stareRoadPickerViewRowSelect];
            [dict setValue:[[array objectAtIndex:0] objectForKey:@"PID"] forKey:@"EndRoad_pid"];
            [dict setValue:[[array objectAtIndex:0] objectForKey:@"PNAME"] forKey:@"EndRoad"];
            [dict setValue:[NSNumber numberWithInteger:[[[array objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue]] forKey:@"EndGate"];
        }
      
        if (selectedButtonTag == START_SELECTBTN_TAG){
            NSArray *array1;
            array1 = [self getFilterRoadArrayForDefault:stareRoadPickerViewRowSelect];
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect]objectForKey:@"PID"] forKey:@"StartRoad_pid"];
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect] objectForKey:@"PNAME"] forKey:@"StartRoad"];
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect]objectForKey:@"GATEWAY"] forKey:@"StartGate"];
            
            [dict setValue:[[array1 objectAtIndex:0] objectForKey:@"PID"] forKey:@"EndRoad_pid"];
            [dict setValue:[[array1 objectAtIndex:0] objectForKey:@"PNAME"] forKey:@"EndRoad"];
            [dict setValue:[NSNumber numberWithInteger:[[[array1 objectAtIndex:0] objectForKey:@"GATEWAY"] integerValue]] forKey:@"EndGate"];
//            NSLog(@"dict %@",dict);
        }
        
        if (selectedButtonTag == END_SELECTBTN_TAG){
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect]objectForKey:@"PID"] forKey:@"EndRoad_pid"];
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect] objectForKey:@"PNAME"] forKey:@"EndRoad"];
            [dict setValue:[[filterExitOnlyArray objectAtIndex:stareRoadPickerViewRowSelect] objectForKey:@"GATEWAY"] forKey:@"EndGate"];
        }
        
        [self replaceItemToCellArray:tableViewRowSelect writeItem:dict];
        
    }
}

-(void)buttonOfTableViewTitleClear:(NSString *)key value:(NSString *)str{
    NSMutableDictionary *dict = [cellArray objectAtIndex:tableViewRowSelect];
//    NSLog(@"get dic %@",dict);
    [dict setValue:str forKey:key];
    [self replaceItemToCellArray:tableViewRowSelect writeItem:dict];
    
}
-(void)replaceItemToCellArray:(NSInteger)index writeItem:(NSDictionary*)dict{
    [cellArray replaceObjectAtIndex:index withObject:dict];
//    NSLog(@"cellarray2%@",cellArray);
    [self.myTableView reloadData];
}

#pragma mark - Filter data list

-(NSInteger)getKeyWordIndexInArray:(NSArray*)a keyWord:(NSString*)key {
    for (int i = 0; i < [a count]; i++) {
        if ([[[a objectAtIndex:i] objectForKey:@"PID"] isEqualToString:key]) {
            return i;
        }
    }
    
    return -1;
}

-(NSMutableArray*)filterFreeWayToGetStartRoad:(NSString*)freewayID {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *d in startRoadArray) {
        if ([[d objectForKey:@"RID"] isEqualToString:freewayID]) {
            [array addObject:d];
        }
    }
    
    return array;
}

-(NSMutableArray*)filterFreeWayToGetStartRoadAndRemoveItself:(NSString*)itself{
    NSMutableArray *array = [NSMutableArray array];
    if (tempRoadArray==nil || [tempRoadArray count]==0) {
        [self showAlertView:@"tempRoadArray error!!!!"];
    }else{
        
        for (NSDictionary *d in tempRoadArray) {
            if (![[d objectForKey:@"PID"] isEqualToString:itself]) {
                [array addObject:d];
            }
        }
    }
   
    
    return array;
}

-(NSMutableArray*)filterFreeWayToGetStartRoadRemoveExitOnly{
    NSMutableArray *array = [NSMutableArray array];
    if (roadArray==nil || [roadArray count]==0) {
        [self showAlertView:@"roadArray error!!!"];
    }else{
        for (NSDictionary *d in roadArray) {
            if (![self hasExitOnly:[[d objectForKey:@"GATEWAY"] integerValue]]) {
                [array addObject:d];
            }
        }
    }
   
    return array;
}

-(bool)hasExitOnly:(NSInteger)exitCheck {
    int check = 0; //5 = 0000
    check = check ^ exitCheck; //XOR
    
    //0101, 0100, 0001
    if (check == 5 || check == 4 || check == 1) {
        return YES;
    }
    
    return NO;
}

-(NSArray*)filterStartRoadToGetEndRoad:(NSInteger)gateway keyword:(NSString *)key{
    int directionInt = 10; //10 = 1010
    
    //0 = wtf
    //2 = way to north only  0010
    //8 = way to south only  1000
    //10 = two way direction 1010
    directionInt = gateway & directionInt;
    //    NSLog(@"123 : %d", directionInt);
    
    NSArray *tempArray, *tempArray1;
    int parameter;
    int count = [roadArray count];
    int i = [self getKeyWordIndexInArray:roadArray keyWord:key];
    
//    NSLog(@"%d",i);
//    NSLog(@"%@",roadArray);
    if  (directionInt == 10) {
        tempArray = [[roadArray subarrayWithRange:NSMakeRange(0, i)] copy];
        tempArray1 = [roadArray subarrayWithRange:NSMakeRange(i, count - i)];
        
        parameter = 1;
        tempArray = [[self getEndRoadWithSubArray:tempArray withParameter:parameter] copy];
        
        parameter = 4;
        tempArray1 = [self getEndRoadWithSubArray:tempArray1 withParameter:parameter];
        
        return [tempArray arrayByAddingObjectsFromArray:tempArray1];
    }
    
    else if (directionInt == 2) {
        tempArray = [roadArray subarrayWithRange:NSMakeRange(0, i)];
        parameter = 1;   //0001
    }
    
    else if( directionInt == 8){
        tempArray = [roadArray subarrayWithRange:NSMakeRange(i, count - i)];
        parameter = 4;   //0100
    }
    
//    NSLog(@"%@",tempArray);
    return [self getEndRoadWithSubArray:tempArray withParameter:parameter];
}

-(NSMutableArray*)getEndRoadWithSubArray:(NSArray*)array withParameter:(NSInteger)para{
    NSMutableArray *a = [NSMutableArray array];
    
    for (NSDictionary *d in array) {
        if (([[d objectForKey:@"GATEWAY"] integerValue] & para) != 0) {
            [a addObject:d];
        }
    }
    
    return a;
}

#pragma mark - CustomAlertView Method
- (void)customIOS7FreewayDialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
//            NSLog(@"button 0");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"show alert"];
            [alertView close];
            
            break;
        case 1:
//            NSLog(@"button 1");
            [alertView close];
            
            break;
        default:
            break;
    }
    
    
}
@end
