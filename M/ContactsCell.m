//
//  ContactsCell.m
//  BrowniePoints
//
//  Created by Tatevik Gasparyan on 12/11/12.
//  Copyright (c) 2012 Armen Merikyan. All rights reserved.
//

#import "ContactsCell.h"

@implementation ContactsCell
int timerCount = 0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setLiteMessage:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [[self liteMessage] setNumberOfLines:4];
        [self setLiteFrom:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self setLiteFromLabel:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self liteFromLabel].text = @"from";
        [[self liteFrom] setFont:[UIFont boldSystemFontOfSize:12]];
        [[self liteFromLabel] setFont:[UIFont systemFontOfSize:10]];
        [[self liteFromLabel] setTextColor:[UIColor grayColor]];
        [self setLiteTo:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self setLiteToLabel:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self liteToLabel].text = @"to";
        [[self liteTo] setFont:[UIFont boldSystemFontOfSize:12]];
        [[self liteToLabel] setFont:[UIFont systemFontOfSize:10]];
        [[self liteToLabel] setTextColor:[UIColor grayColor]];
        [self setLiteID:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self setLiteTime:[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [[self liteTime] setFont:[UIFont systemFontOfSize:12]];
        [[self liteTime] setTextColor:[UIColor grayColor]];
        [self setLiteImage:[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]];
        [self liteID].hidden = YES;
        [self addSubview:[self liteMessage]];
        [self addSubview:[self liteFrom]];
        [self addSubview:[self liteFromLabel]];
        [self addSubview:[self liteTo]];
        [self addSubview:[self liteToLabel]];
        [self addSubview:[self liteTime]];
        [self addSubview:[self liteID]];
        [self addSubview:[self liteImage]];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [   self startTimerThread];
            dispatch_async(dispatch_get_main_queue(), ^(void){
            });
        });
    }
    return self;
}
-(void) startTimerThread
{
    timerCount = 0;
    if (![[self timerServerSync] isValid]) {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        [self setTimerServerSync:[NSTimer scheduledTimerWithTimeInterval: .1
                                                                  target: self
                                                                selector: @selector(timerTick:)
                                                                userInfo: nil
                                                                 repeats: YES] ];
        
        [runLoop run];
    }
}
- (void)timerTick:(NSTimer *)timer
{
    if ([self liteID].text !=nil) {
        if (timerCount >2) {
            [[self timerServerSync] invalidate];
        }
        if (timerCount ==0) {
            NSLog(@"Tick Timer");
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.liteworks2.com/litem/getImageServiceLow.jsp?CLIENT_ID=%@", [self liteID].text]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            [[self liteImage] setImage:img];
        }else{
            NSLog(@"Tick Timer");
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.liteworks2.com/litem/getImageService.jsp?CLIENT_ID=%@", [self liteID].text]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            [[self liteImage] setImage:img];
        }
        timerCount +=1;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
