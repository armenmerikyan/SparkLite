//
//  ContactsCell.h
//  BrowniePoints
//
//  Created by Tatevik Gasparyan on 12/11/12.
//  Copyright (c) 2012 Armen Merikyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsCell : UITableViewCell

@property (retain, nonatomic) IBOutlet NSTimer *timerServerSync ;
@property(nonatomic, retain) IBOutlet UILabel* liteMessage;
@property(nonatomic, retain) IBOutlet UILabel* liteTime;
@property(nonatomic, retain) IBOutlet UILabel* liteID;
@property(nonatomic, retain) IBOutlet UILabel* liteFrom;
@property(nonatomic, retain) IBOutlet UILabel* liteTo;
@property(nonatomic, retain) IBOutlet UILabel* liteFromLabel;
@property(nonatomic, retain) IBOutlet UILabel* liteToLabel;
@property(nonatomic, retain) IBOutlet UIImageView* liteImage;

@end
