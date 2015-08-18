//
//  ViewController.h
//  M
//
//  Created by Armen Merikyan on 8/3/15.
//  Copyright (c) 2015 LiteWorks2 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate>


@property (retain, nonatomic) IBOutlet NSTimer *timerServerSync ;
@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet UIButton *switchButton;
@property (retain, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (retain, nonatomic) IBOutlet UITextView *messageField;
@property (retain, nonatomic) IBOutlet UITextField *toField;
@property (retain, nonatomic) IBOutlet UITextField *fromField;
@property(nonatomic, retain) IBOutlet UITableView *purchasesTableView;
@property(nonatomic, retain) NSMutableArray* allMessages;
@property(nonatomic, retain) NSString *messageFieldPrev;
@property(nonatomic, retain) NSString *toFieldPrev;
@property(nonatomic, retain) NSString *fromFieldPrev;
@property(nonatomic, retain) NSString *messageFieldSending;
@property(nonatomic, retain) NSString *toFieldSending;
@property(nonatomic, retain) NSString *fromFieldSending;
@property(nonatomic, retain) NSString *clientID;
@property(nonatomic, retain) UIRefreshControl *refreshControl;

@property(nonatomic, retain) UIImage *messageImageSending;
@property(nonatomic, retain) IBOutlet UIImageView* messageImageView;
@property(nonatomic, retain) NSString *currentSparkID;
@property(nonatomic, retain) IBOutlet UIImageView* currentSparkImage;
@property (retain, nonatomic) IBOutlet UIButton *currentSparkImageClose;
@property (retain, nonatomic) IBOutlet UIButton *heartButton;
@property (retain, nonatomic) IBOutlet UIButton *upButton;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UIButton *authButton;
@property (retain, nonatomic) IBOutlet UIButton *blockButton;
@property (retain, nonatomic) IBOutlet UIButton *locationButton;
@property (retain, nonatomic) IBOutlet UILabel *heartLabel;
@property (retain, nonatomic) IBOutlet UILabel *upLabel;
@property (retain, nonatomic) IBOutlet UILabel *downLabel;
@property (retain, nonatomic) IBOutlet UILabel *authLabel;
@property (retain, nonatomic) IBOutlet UILabel *blockLabel;
@property (retain, nonatomic) IBOutlet UILabel *termsButtonBkLabel;
@property (retain, nonatomic) IBOutlet NSMutableDictionary *reuseCellDict;
@property (retain, nonatomic) IBOutlet UIButton *termsAgree;
@property (retain, nonatomic) IBOutlet UIButton *termsDisagree;
@property (retain, nonatomic) IBOutlet UIWebView *orderDetailWebView;

@end

