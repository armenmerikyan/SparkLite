//
//  ViewController.m
//  M
//
//  Created by Armen Merikyan on 8/3/15.
//  Copyright (c) 2015 LiteWorks2 Inc. All rights reserved.
//

#import "ViewController.h"
#import "ContactsCell.h"
#import "SelfieViewController.h"

@interface ViewController ()

@end

@implementation ViewController

BOOL postMessageNow = NO;
BOOL forceRefresh = NO;
BOOL isHearted = NO;
BOOL isUped = NO;
BOOL isDowned = NO;
BOOL isFaked = NO;
BOOL isBlocked = NO;
BOOL isAgreeToTerms = NO;
BOOL isWebViewOpen = NO;
- (void)viewDidLoad {
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [super viewDidLoad];
    [self setReuseCellDict:[NSMutableDictionary alloc]];
    [self setRefreshControl:[[UIRefreshControl alloc] init]];
    [[self refreshControl] addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [[self purchasesTableView] addSubview:[self refreshControl]];
    
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(leftSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self purchasesTableView] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(rightSwipe:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self purchasesTableView] addGestureRecognizer:recognizer];
    [self currentSparkImage].hidden = YES;
    [self currentSparkImageClose].hidden = YES;
    [self heartButton].hidden = YES;
    [self upButton].hidden = YES;
    [self downButton].hidden = YES;
    [self authButton].hidden = YES;
    [self blockButton].hidden = YES;
    [self heartLabel].hidden = YES;
    [self upLabel].hidden = YES;
    [self downLabel].hidden = YES;
    [self authLabel].hidden = YES;
    [self blockLabel].hidden = YES;
    [self termsAgree].hidden = YES;
    [self termsDisagree].hidden = YES;
    [self locationButton].hidden = YES;

    [self setTermsAgree:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self termsAgree].frame=CGRectMake(10,screenRect.size.height-80,120,60);
    [[self  termsAgree].titleLabel setTextColor:[UIColor grayColor]];
    [[self  termsAgree] addTarget:self action:@selector(registerButtonClickedTermsOfServiceYes:) forControlEvents:UIControlEventTouchUpInside];
    [[self termsAgree] setBackgroundColor:[UIColor greenColor]];
    [[self  termsAgree] setTitle: @"Agree" forState: UIControlStateNormal];
    
    [self.view addSubview:[self  termsAgree]];
    [self  termsAgree].hidden = YES;
    [self termsButtonBkLabel].hidden = YES;
    [[self termsButtonBkLabel] setFrame:CGRectMake(0,screenRect.size.height-80,screenRect.size.width,80)];
    [self setTermsDisagree:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self termsDisagree].frame=CGRectMake(screenRect.size.width- 130,screenRect.size.height-80,120,60);
    [[self  termsDisagree].titleLabel setTextColor:[UIColor grayColor]];
    [[self  termsDisagree] setTitle: @"Cancel" forState: UIControlStateNormal];
    [[self termsDisagree] setBackgroundColor:[UIColor redColor]];
    [[self  termsDisagree] addTarget:self action:@selector(registerButtonClickedTermsOfServiceNo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:[self  termsDisagree]];
    [self  termsDisagree].hidden = YES;
    [self writeToTextFile];

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)refresh:(id)sender
{
    forceRefresh = YES;
    // do your refresh here and reload the tablview
}
- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //do you left swipe stuff here.
    CGPoint location = [gestureRecognizer locationInView:[self purchasesTableView]];
    NSIndexPath *indexPath = [[self purchasesTableView] indexPathForRowAtPoint:location];
    ContactsCell *cell = (ContactsCell*)[[self purchasesTableView] cellForRowAtIndexPath:indexPath];
    //[self currentSparkImage].image = cell.liteImage.image;
    //if (![cell selectionStyle] == UITableViewCellSelectionStyleNone) {
        //OrderDetailViewController *addController = [[OrderDetailViewController alloc]
        //                                           init];
        
        NSArray* info = (NSArray*)[[self allMessages] objectAtIndex:indexPath.row];
        [self toField].text = [info objectAtIndex:1];
        [self fromField].text = [info objectAtIndex:2];
        //[self setCurrentSparkID:[info objectAtIndex:0]];
    //}
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //do you right swipe stuff here. Something usually using theindexPath that you get that way
    CGPoint location = [gestureRecognizer locationInView:[self purchasesTableView]];
    NSIndexPath *indexPath = [[self purchasesTableView] indexPathForRowAtPoint:location];
    ContactsCell *cell = (ContactsCell*)[[self purchasesTableView] cellForRowAtIndexPath:indexPath];
    [self currentSparkImage].image = cell.liteImage.image;
//    if (![cell selectionStyle] == UITableViewCellSelectionStyleNone) {
        //OrderDetailViewController *addController = [[OrderDetailViewController alloc]
        //                                           init];
        
        NSArray* info = (NSArray*)[[self allMessages] objectAtIndex:indexPath.row];
        [self toField].text = [info objectAtIndex:1];
        [self fromField].text = [info objectAtIndex:2];
        [self setCurrentSparkID:[info objectAtIndex:0]];
  //  }
    if ([self currentSparkImage].image != nil) {
        [self currentSparkImage].hidden = NO;
        [self currentSparkImageClose].hidden = NO;
        [self heartButton].hidden = NO;
        [self upButton].hidden = NO;
        [self downButton].hidden = NO;
        [self authButton].hidden = NO;
        [self blockButton].hidden = NO;
        [self heartLabel].hidden = NO;
        [self upLabel].hidden = NO;
        [self downLabel].hidden = NO;
        [self authLabel].hidden = NO;
        [self blockLabel].hidden = NO;
        [self getDetails];
    }

}

- (void)getDetails{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/phiViewDetail.jsp?spark_id=%@&clientID=%@", [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    NSArray* rows = [content componentsSeparatedByString:@"<ITEM>"];
    [self heartLabel].text =rows[0];
    if ([rows[1] isEqualToString:@"T"]) {isHearted = YES;
    }else{isHearted = NO;}
    [self authLabel].text =rows[2];
    if ([rows[3] isEqualToString:@"T"]) {isFaked = YES;
    }else{isFaked = NO;}
    [self upLabel].text =rows[4];
    if ([rows[5] isEqualToString:@"T"]) {isUped = YES;
    }else{isUped = NO;}
    [self downLabel].text =rows[6];
    if ([rows[7] isEqualToString:@"T"]) {isDowned = YES;
    }else{isDowned = NO;}
    [self blockLabel].text =rows[8];
    if ([rows[9] isEqualToString:@"T"]) {isBlocked = YES;
    }else{isBlocked = NO;}
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[self fromField] resignFirstResponder ];
    [[self toField] resignFirstResponder ];
    [[self messageField] resignFirstResponder ];
}
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    NSLog(string);
    if([string isEqualToString:@"\n"]) {
        [[self fromField] resignFirstResponder ];
        [[self toField] resignFirstResponder ];
        [[self messageField] resignFirstResponder ];
    }
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortrait){
        [self layoutSubviews];
        //Code
    }else{
        [self layoutSubviewsHorizontol];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [self layoutSubviews];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self startTimerThread];
        dispatch_async(dispatch_get_main_queue(), ^(void){
        });
    });

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    [[self messageImageView] setImage:[UIImage imageWithContentsOfFile:imagePath]];
    
}
- (void)layoutSubviewsHorizontol{
CGRect screenRect = [[UIScreen mainScreen] bounds];
[[self postButton] setFrame:CGRectMake(2,240,(screenRect.size.width/2)-4,40)];
[[[self postButton] layer] setBorderWidth:2];
[[self fromField] setFrame:CGRectMake(2,30,(screenRect.size.width/2)-74,40)];
[[[self fromField] layer] setBorderWidth:2];
[[self toField] setFrame:CGRectMake(2,80,(screenRect.size.width/2)-74,40)];
[[[self toField] layer] setBorderWidth:2];
[[self messageField] setFrame:CGRectMake(2,130,(screenRect.size.width/2)-74,100)];
[[[self messageField] layer] setBorderWidth:2];
[[self purchasesTableView] setFrame:CGRectMake((screenRect.size.width/2),0,(screenRect.size.width/2),screenRect.size.height)];
[[self switchButton] setFrame:CGRectMake((screenRect.size.width/2)-63,50,50,50)];
[[self addPhotoButton] setFrame:CGRectMake((screenRect.size.width/2)-63,165,50,30)];
    [[self messageImageView] setFrame:CGRectMake((screenRect.size.width/2)-74,130,72,100)];
    [[[self currentSparkImage] layer] setBorderWidth:2];
    [[self currentSparkImage] setFrame:CGRectMake(0,0,(screenRect.size.width/2),screenRect.size.height)];
    float imageHeight = ((((screenRect.size.width/2)-4)*1.329))+20;
    float buttonWidth = (screenRect.size.width/2)/5;
    
    [[self currentSparkImageClose] setFrame:CGRectMake(0,0,screenRect.size.width/2,buttonWidth)];
    [[self currentSparkImageClose] setAlpha:.7];
    [[self heartButton] setAlpha:.7];
    [[self upButton] setAlpha:.7];
    [[self authButton] setAlpha:.7];
    [[self downButton] setAlpha:.7];
    [[self blockButton] setAlpha:.7];
    
    [[self heartButton] setFrame:CGRectMake(0,screenRect.size.height-buttonWidth,buttonWidth,buttonWidth)];
    [[self upButton] setFrame:CGRectMake(buttonWidth*1,screenRect.size.height-buttonWidth,buttonWidth,buttonWidth)];
    [[self authButton] setFrame:CGRectMake(buttonWidth*2,screenRect.size.height-buttonWidth,buttonWidth,buttonWidth)];
    [[self downButton] setFrame:CGRectMake(buttonWidth*3,screenRect.size.height-buttonWidth,buttonWidth,buttonWidth)];
    [[self blockButton] setFrame:CGRectMake(buttonWidth*4,screenRect.size.height-buttonWidth,buttonWidth,buttonWidth)];
    [[[self heartButton] layer] setBorderWidth:2];
    [[[self upButton] layer] setBorderWidth:2];
    [[[self downButton] layer] setBorderWidth:2];
    [[[self authButton] layer] setBorderWidth:2];
    [[[self blockButton] layer] setBorderWidth:2];
    
    [[self heartLabel] setFrame:CGRectMake(0,(screenRect.size.height-buttonWidth)-30,buttonWidth,30)];
    [[self upLabel] setFrame:CGRectMake(buttonWidth*1,(screenRect.size.height-buttonWidth)-30,buttonWidth,30)];
    [[self authLabel] setFrame:CGRectMake(buttonWidth*2,(screenRect.size.height-buttonWidth)-30,buttonWidth,30)];
    [[self downLabel] setFrame:CGRectMake(buttonWidth*3,(screenRect.size.height-buttonWidth)-30,buttonWidth,30)];
    [[self blockLabel] setFrame:CGRectMake(buttonWidth*4,(screenRect.size.height-buttonWidth)-30,buttonWidth,30)];
    [[[self heartLabel] layer] setBorderWidth:2];
    [[[self upLabel] layer] setBorderWidth:2];
    [[[self downLabel] layer] setBorderWidth:2];
    [[[self authLabel] layer] setBorderWidth:2];
    [[[self blockLabel] layer] setBorderWidth:2];

    [[[self heartLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self upLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self downLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self authLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self blockLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[self purchasesTableView] reloadData];
    [self termsAgree].frame=CGRectMake(10,screenRect.size.height-80,120,60);
    [[self termsButtonBkLabel] setFrame:CGRectMake(0,screenRect.size.height-80,screenRect.size.width,80)];
    [self termsDisagree].frame=CGRectMake((screenRect.size.width/2)- 130,screenRect.size.height-80,120,60);
    [[self orderDetailWebView] setFrame:CGRectMake(0, 0, screenRect.size.width/2,(screenRect.size.height)-80)];
}
- (void)layoutSubviews{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float imageHeightExact = (screenRect.size.width-4) * ((screenRect.size.width-4)/((screenRect.size.width-4)*.75));
    [[self postButton] setFrame:CGRectMake(2,240,screenRect.size.width-4,40)];
    [[[self postButton] layer] setBorderWidth:2];
    [[self fromField] setFrame:CGRectMake(2,30,screenRect.size.width-95,40)];
    [[[self fromField] layer] setBorderWidth:2];
    [[self toField] setFrame:CGRectMake(2,80,screenRect.size.width-95,40)];
    [[[self toField] layer] setBorderWidth:2];
    [[self messageField] setFrame:CGRectMake(2,130,screenRect.size.width-95,100)];
    [[[self messageField] layer] setBorderWidth:2];
    [[self purchasesTableView] setFrame:CGRectMake(2,290,screenRect.size.width-4,screenRect.size.height-292)];
    [[self switchButton] setFrame:CGRectMake(screenRect.size.width-75,50,50,50)];
    [[self locationButton] setFrame:CGRectMake(screenRect.size.width-75,100,50,50)];
    [[self addPhotoButton] setFrame:CGRectMake(screenRect.size.width-75,165,50,30)];
    [[self messageImageView] setFrame:CGRectMake(screenRect.size.width-85,130,75,100)];
    [[[self currentSparkImage] layer] setBorderWidth:2];
    [[self currentSparkImage] setFrame:CGRectMake(2,20,screenRect.size.width-4,imageHeightExact)];
    float imageHeight = imageHeightExact+20;
    float buttonWidth = screenRect.size.width/5;
    
    [[self currentSparkImageClose] setFrame:CGRectMake(0,imageHeight+buttonWidth,screenRect.size.width,screenRect.size.height-(imageHeight+buttonWidth))];
    [[self currentSparkImageClose] setAlpha:1];
    [[self heartButton] setAlpha:1];
    [[self upButton] setAlpha:1];
    [[self authButton] setAlpha:1];
    [[self downButton] setAlpha:1];
    [[self blockButton] setAlpha:1];
    
    [[self heartButton] setFrame:CGRectMake(0,imageHeight,buttonWidth,buttonWidth)];
    [[self upButton] setFrame:CGRectMake(buttonWidth*1,imageHeight,buttonWidth,buttonWidth)];
    [[self authButton] setFrame:CGRectMake(buttonWidth*2,imageHeight,buttonWidth,buttonWidth)];
    [[self downButton] setFrame:CGRectMake(buttonWidth*3,imageHeight,buttonWidth,buttonWidth)];
    [[self blockButton] setFrame:CGRectMake(buttonWidth*4,imageHeight,buttonWidth,buttonWidth)];
    [[[self heartButton] layer] setBorderWidth:2];
    [[[self upButton] layer] setBorderWidth:2];
    [[[self downButton] layer] setBorderWidth:2];
    [[[self authButton] layer] setBorderWidth:2];
    [[[self blockButton] layer] setBorderWidth:2];
    
    [[self heartLabel] setFrame:CGRectMake(0,imageHeight-30,buttonWidth,30)];
    [[self upLabel] setFrame:CGRectMake(buttonWidth*1,imageHeight-30,buttonWidth,30)];
    [[self authLabel] setFrame:CGRectMake(buttonWidth*2,imageHeight-30,buttonWidth,30)];
    [[self downLabel] setFrame:CGRectMake(buttonWidth*3,imageHeight-30,buttonWidth,30)];
    [[self blockLabel] setFrame:CGRectMake(buttonWidth*4,imageHeight-30,buttonWidth,30)];
    [[[self heartLabel] layer] setBorderWidth:2];
    [[[self upLabel] layer] setBorderWidth:2];
    [[[self downLabel] layer] setBorderWidth:2];
    [[[self authLabel] layer] setBorderWidth:2];
    [[[self blockLabel] layer] setBorderWidth:2];
    
    [[[self heartLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self upLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self downLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self authLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    [[[self blockLabel] layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[self purchasesTableView] reloadData];
    [self termsAgree].frame=CGRectMake(10,screenRect.size.height-80,120,60);
    [[self termsButtonBkLabel] setFrame:CGRectMake(0,screenRect.size.height-80,screenRect.size.width,80)];
    [self termsDisagree].frame=CGRectMake(screenRect.size.width- 130,screenRect.size.height-80,120,60);
    [[self orderDetailWebView] setFrame:CGRectMake(0, 20, screenRect.size.width,(screenRect.size.height)-100)];
}
-(IBAction) goSelfieView{
    SelfieViewController *addController = [[SelfieViewController alloc]
                                           init];
    //[addController setCc_mask:cc_mask];
    [self presentViewController:addController animated:YES completion: nil];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[self fromField] resignFirstResponder ];
    [[self toField] resignFirstResponder ];
    [[self messageField] resignFirstResponder ];
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction) heartToggle:(id)sender{
    NSString *heartedString = @"Heart";
    if (isHearted ==NO) {
        isHearted = YES;
    }else{
        isHearted = NO;
        heartedString = @"UnHeart";
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/actionSpark.jsp?sparkType=%@&spark_id=%@&clientID=%@", heartedString, [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    [self getDetails];
}
- (IBAction)registerButtonClickedTermsOfServiceNo:(id)sender {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UIView beginAnimations:@"Pop WebView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [[self orderDetailWebView] setFrame:CGRectMake(0-(screenRect.size.width-55), 20, screenRect.size.width-55,screenRect.size.height-130)]; // or use CGAffineTransform
    [UIView commitAnimations];
    [self termsAgree].hidden = YES;
    [self termsDisagree].hidden = YES;
    [self termsButtonBkLabel].hidden = YES;
    [self orderDetailWebView].hidden = YES;
    
}
- (IBAction)registerButtonClickedTermsOfServiceYes:(id)sender {
    isAgreeToTerms = YES;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    
    [UIView beginAnimations:@"Pop WebView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [[self orderDetailWebView] setFrame:CGRectMake(0-(screenRect.size.width-55), 20, screenRect.size.width-55,screenRect.size.height-130)]; // or use CGAffineTransform
    [UIView commitAnimations];
    [self termsAgree].hidden = YES;
    [self termsDisagree].hidden = YES;
    [self termsButtonBkLabel].hidden = YES;
    [self orderDetailWebView].hidden = YES;
    [self WriteToTextFileTerms];
    [self postMessage:sender];
    
}
- (IBAction)registerButtonClickedTermsOfService:(id)sender {
    [self termsAgree].hidden = NO;
    [self termsDisagree].hidden = NO;
    [self termsButtonBkLabel].hidden = NO;
    
    [[self fromField] resignFirstResponder];
    [[self toField] resignFirstResponder];
    [[self messageField] resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self setOrderDetailWebView:[[UIWebView alloc]initWithFrame:CGRectMake(0, 20, 5,(screenRect.size.height)-100)]];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"Terms_of_service" ofType:@"html" inDirectory:nil];
    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
    [[self orderDetailWebView] loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.mytruckboard.com/AAAHOME/terms_of_service.html?CLIENT_ID=%@", [self clientID]];
    NSString *url=serverURL;
    NSLog(serverURL);
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    //[[self orderDetailWebView] loadRequest:nsrequest];
    [[self orderDetailWebView] setBackgroundColor:[UIColor clearColor]];
    [self orderDetailWebView].alpha = .95;
    [self.view addSubview:[self orderDetailWebView]];
    [UIView beginAnimations:@"Pop WebView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [[self orderDetailWebView] setFrame:CGRectMake(0, 20, screenRect.size.width,(screenRect.size.height)-100)]; // or use CGAffineTransform
    [UIView commitAnimations];
    isWebViewOpen = YES;
}
-(IBAction) blockToggle:(id)sender{
    NSString *heartedString = @"Block";
    if (isBlocked ==NO) {
        isBlocked = YES;
    }else{
        isBlocked = NO;
        heartedString = @"UnBlock";
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/actionSpark.jsp?sparkType=%@&spark_id=%@&clientID=%@", heartedString, [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    [self getDetails];
}
-(IBAction) fakeToggle:(id)sender{
    NSString *heartedString = @"Fake";
    if (isFaked ==NO) {
        isFaked = YES;
    }else{
        isFaked = NO;
        heartedString = @"UnFake";
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/actionSpark.jsp?sparkType=%@&spark_id=%@&clientID=%@", heartedString, [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    [self getDetails];
}
-(IBAction) downToggle:(id)sender{
    NSString *heartedString = @"Down";
    if (isDowned ==NO) {
        isDowned = YES;
    }else{
        isDowned = NO;
        heartedString = @"UnDown";
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/actionSpark.jsp?sparkType=%@&spark_id=%@&clientID=%@", heartedString, [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    [self getDetails];
}
-(IBAction) upToggle:(id)sender{
    NSString *heartedString = @"Up";
    if (isUped ==NO) {
        isUped = YES;
    }else{
        isUped = NO;
        heartedString = @"UnUp";
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/actionSpark.jsp?sparkType=%@&spark_id=%@&clientID=%@", heartedString, [self currentSparkID], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    [self getDetails];
}
-(IBAction) closeImage:(id)sender{
    [self currentSparkImage].hidden = YES;
    [self currentSparkImageClose].hidden = YES;
    [self heartButton].hidden = YES;
    [self upButton].hidden = YES;
    [self downButton].hidden = YES;
    [self authButton].hidden = YES;
    [self blockButton].hidden = YES;
    [self heartLabel].hidden = YES;
    [self upLabel].hidden = YES;
    [self downLabel].hidden = YES;
    [self authLabel].hidden = YES;
    [self blockLabel].hidden = YES;
}
-(IBAction) switchAddress:(id)sender{
    NSString *tempTOField =[self fromField].text;
    [self fromField].text = [self toField].text;
    [self toField].text = tempTOField;
}
-(IBAction) postMessage:(id)sender{
    if(isAgreeToTerms == NO && [self isWriteToTextFileTerms] ==NO){
        [self registerButtonClickedTermsOfService:sender];
        return;
    }
    postMessageNow = YES;
    [self setToFieldSending:[self toField].text];
    [self setFromFieldSending:[self fromField].text];
    [self setMessageFieldSending:[self messageField].text];
    [self setMessageImageSending:[self messageImageView].image];
    [[self fromField] resignFirstResponder ];
    [[self toField] resignFirstResponder ];
    [[self messageField] resignFirstResponder ];
    [self toField].text = @"";
    [self fromField].text= @"";
    [self messageField].text= @"";
    [self messageImageView].image= nil;
}
-(IBAction) postMessageFunction{
    if(![[self toFieldSending] isEqualToString:@""] && ![[self fromFieldSending] isEqualToString:@""] && ![[self messageFieldSending] isEqualToString:@""]){
        
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];

    NSString *serverURL = [NSString stringWithFormat:@"https://www.liteworks2.com/litem/postMessage.jsp?fromField=%@&toField=%@&messageField=%@&clientID=%@", [self fromFieldSending], [self toFieldSending], [self messageFieldSending], [self clientID]];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    
    //[self addressLabel].text = [content componentsSeparatedByString:@":"][0];
    NSLog([NSString stringWithFormat:@"Result From Transaction %@",  content] );
    
    NSArray* rows = [content componentsSeparatedByString:@"<ITEM>"];
        [self postImageToServer:rows[1] uploadType:@"facePic.jpg"];
        //[self postImageToServer:rows[1] uploadType:@"facePicHighRes.jpg"];
        [self postImageToServer:rows[1] uploadType:@"facePicLowRes.jpg"];
        
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    NSError *error2;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error2];
    
    [self getMessages];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Note"
                                                            message:@"Message has been sent it will be available after review"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self allMessages] count];//[[InAppRageIAPHelper sharedHelper].products count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A case was selected, so push into the CaseDetailViewController
    ContactsCell *cell = (ContactsCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self currentSparkImage].image = cell.liteImage.image;
    if (![cell selectionStyle] == UITableViewCellSelectionStyleNone) {
        //OrderDetailViewController *addController = [[OrderDetailViewController alloc]
        //                                           init];
        
        NSArray* info = (NSArray*)[[self allMessages] objectAtIndex:indexPath.row];
        //[self toField].text = [info objectAtIndex:1];
        //[self fromField].text = [info objectAtIndex:2];
        [self setCurrentSparkID:[info objectAtIndex:0]];
    }
    if ([self currentSparkImage].image != nil) {
        [self currentSparkImage].hidden = NO;
        [self currentSparkImageClose].hidden = NO;
        [self heartButton].hidden = NO;
        [self upButton].hidden = NO;
        [self downButton].hidden = NO;
        [self authButton].hidden = NO;
        [self blockButton].hidden = NO;
        [self heartLabel].hidden = NO;
        [self upLabel].hidden = NO;
        [self downLabel].hidden = NO;
        [self authLabel].hidden = NO;
        [self blockLabel].hidden = NO;
        [self getDetails];
    }
}
-(void) startTimerThread
{
    if (![[self timerServerSync] isValid]) {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        [self setTimerServerSync:[NSTimer scheduledTimerWithTimeInterval: 1.05
                                                                  target: self
                                                                selector: @selector(timerTick:)
                                                                userInfo: nil
                                                                 repeats: YES] ];
        
        [runLoop run];
    }
}
- (void)timerTick:(NSTimer *)timer
{
    NSLog(@"HELLO");
    if(![[self toFieldPrev] isEqualToString:[self toField].text]){
        NSLog(@"HELLO CHANGED");
        [self setToFieldPrev:[self toField].text];
        [self getMessages];
    }
    if(![[self fromFieldPrev] isEqualToString:[self fromField].text]){
        NSLog(@"HELLO CHANGED");
        [self setFromFieldPrev:[self fromField].text];
        [self getMessages];
    }
    if(![[self messageFieldPrev] isEqualToString:[self messageField].text]){
        NSLog(@"HELLO CHANGED");
        [self setMessageFieldPrev:[self messageField].text];
    }
    if (forceRefresh == YES) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        forceRefresh = NO;
        [self getMessages];
        [[self purchasesTableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [[self refreshControl] endRefreshing];
    }
    if (postMessageNow ==YES) {
        postMessageNow = NO;
        [self postMessageFunction];
    }
}
-(BOOL) isWriteToTextFileTerms{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/clientIDTerms.txt",
                          documentsDirectory];
    
    NSString *stringFromFile = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    if (stringFromFile != nil) {
        return YES;
    }
    return NO;
}
-(void) WriteToTextFileTerms{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/clientIDTerms.txt",
                          documentsDirectory];
    
    NSString *stringFromFile = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    if (stringFromFile != nil) {
        
    }
    [@"Terms Accepted" writeToFile:fileName
                        atomically:NO
                          encoding:NSStringEncodingConversionAllowLossy
                             error:nil];
    //return NO;
}
-(void) writeToTextFile{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/clientID.txt",
                          documentsDirectory];
    
    NSString *stringFromFile = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    if (stringFromFile != nil) {
        [self setClientID:[[NSString alloc] initWithString:stringFromFile]];
    }
    
    if([self clientID] ==nil){
        CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault,UUID);
        NSLog(@"Test Login");
        [self setClientID:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@",  UUIDString]]];
        [[self clientID] writeToFile:fileName
                   atomically:NO
                     encoding:NSStringEncodingConversionAllowLossy
                        error:nil];
    }else{
        NSLog(@"OLD ID USED %@", [self clientID]);
    }
    
    //make a file name to write the data to using the documents directory:
    //create content - four lines of text
    //save content to the documents directory
    
}
-(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size
{
    CGFloat actualHeight = orginalImage.size.height;
    CGFloat actualWidth = orginalImage.size.width;
    //  if(actualWidth <= size.width && actualHeight<=size.height)
    //  {
    //      return orginalImage;
    //  }
    float oldRatio = actualWidth/actualHeight;
    float newRatio = size.width/size.height;
    if(oldRatio < newRatio)
    {
        oldRatio = size.height/actualHeight;
        actualWidth = oldRatio * actualWidth;
        actualHeight = size.height;
    }
    else
    {
        oldRatio = size.width/actualWidth;
        actualHeight = oldRatio * actualHeight;
        actualWidth = size.width;
    }
    
    CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [orginalImage drawInRect:rect];
    orginalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return orginalImage;
}
-(void)postImageToServer : (NSString*) messageID uploadType:(NSString*) uploadType{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    if ([uploadType isEqualToString:@"facePicHighRes.jpg"]) {
        imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.High.jpg",@"cached"]];
    }
    if ([uploadType isEqualToString:@"facePicLowRes.jpg"]) {
        imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Small.jpg",@"cached"]];
    }
    
    
    UIImage *small = [UIImage imageWithContentsOfFile:imagePath];
    NSString *boundary = @"Filename.jpg";
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    
    //for (NSString *param in _params) {
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"CLIENT_ID"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", messageID] dataUsingEncoding:NSUTF8StringEncoding]];
    //}
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(small, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadType, uploadType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    
    NSString *serverURL = [NSString stringWithFormat:@"https://www.mytruckboard.com/litem/maid_upload_image.jsp?CLIENT_ID=%@", messageID];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    NSLog(@"Content %@", content);
    
}
-(void)getMessages{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    NSString *serverURL = [NSString stringWithFormat:@"https://www.mytruckboard.com/litem/phiView.jsp?fromField=%@&toField=%@", [self fromField].text , [self toField].text];
    serverURL = [serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:serverURL]];
    NSError *error;
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] ;
    NSString *content = [[NSString alloc]  initWithBytes:[result bytes]
                                                  length:[result length] encoding: NSUTF8StringEncoding];
    NSLog(@"Content %@", content);
    if (![content isEqualToString:@""]) {
        [self updateMessageTable:content];
    }
}
-(void)updateMessageTable:(NSString*)content
{
    
    //    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: _mapView.annotations];
    //    [annotationsToRemove removeObject: _mapView.userLocation];
    //    [_mapView removeAnnotations: annotationsToRemove];
    //   [_mapView removeOverlays:_mapView.overlays];
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault,UUID);
    NSLog(@"Test Login");
    NSArray* rows = [content componentsSeparatedByString:@"<ROW>"];
   NSMutableArray *tempAllMessages = [[NSMutableArray alloc] init];
    for(int i = 0; i < [rows count]; i++)
    {
        NSArray* items = [[rows objectAtIndex:i] componentsSeparatedByString:@"<FIELD>"];
        [tempAllMessages addObject:items];
    }
    [self setAllMessages:tempAllMessages];
    [[self  purchasesTableView] reloadData];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger row = [indexPath row];
    NSArray* info = (NSArray*)[[self allMessages] objectAtIndex:row];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSString *SimpleTableIdentifier = [info objectAtIndex:0];
    ContactsCell* cell = (ContactsCell*)[tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(cell == nil)
    {
        cell = [[ContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        
    }
    
    [cell liteMessage].text = [info objectAtIndex:3];
    [cell liteID].text = [info objectAtIndex:0];
    [cell liteTo].text = [info objectAtIndex:1];
    [cell liteFrom].text = [info objectAtIndex:2];
    [cell liteTime].text = [info objectAtIndex:4];
    if (([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight)){
        [[cell liteImage] setFrame:CGRectMake(((screenRect.size.width)/2)-135,0,135,180)];
        [[cell liteMessage] setFrame:CGRectMake(2,0,((screenRect.size.width-135)/2)-104,100)];
        [[cell liteTime] setFrame:CGRectMake(2,165,((screenRect.size.width-135)/2)-4,15)];
        [[cell liteTo] setFrame:CGRectMake(((screenRect.size.width-135)/4),130,(screenRect.size.width/2),20)];
        [[cell liteToLabel] setFrame:CGRectMake((screenRect.size.width-135)/4,150,30,10)];
        [[cell liteFrom] setFrame:CGRectMake(2,130,((screenRect.size.width-135)/4)-17,20)];
        [[cell liteFromLabel] setFrame:CGRectMake(2,150,30,10)];
    }else{
        [[cell liteImage] setFrame:CGRectMake(screenRect.size.width-135,0,135,180)];
        [[cell liteMessage] setFrame:CGRectMake(2,0,screenRect.size.width-139,100)];
        [[cell liteTime] setFrame:CGRectMake(2,165,screenRect.size.width-139,15)];
        [[cell liteTo] setFrame:CGRectMake(((screenRect.size.width-135)/2),130,((screenRect.size.width-135)/2),20)];
        [[cell liteToLabel] setFrame:CGRectMake((screenRect.size.width-135)/2,150,30,10)];
        [[cell liteFrom] setFrame:CGRectMake(2,130,((screenRect.size.width-135)/2)-17,20)];
        [[cell liteFromLabel] setFrame:CGRectMake(2,150,30,10)];
    }

    NSLog([NSString stringWithFormat:@"http://www.mytruckboard.com/litem/getImageService.jsp?CLIENT_ID=%@", [info objectAtIndex:0]]);


    
    /*
     cell.date.text = [info objectAtIndex:1];
     NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
     NSString* username = [prefs objectForKey:USERNAME];
     if(![info.username isEqualToString:username])
     {
     [cell.username setTextColor:[UIColor redColor]];
     [cell.price setTextColor:[UIColor redColor]];
     [cell.price setText:[NSString stringWithFormat:@"%@", info.price]];
     }else{
     [cell.username setTextColor:[UIColor blackColor]];
     [cell.price setTextColor:[UIColor blackColor]];
     cell.username.text = info.fromEmail;
     }
     */
    
    return cell;
}

@end
