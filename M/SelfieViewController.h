//
//  SelfieViewController.h
//  Maids App
//
//  Created by Armen Merikyan on 12/25/14.
//  Copyright (c) 2014 Maids App Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfieViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewHigh;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewLow;
@property(nonatomic, retain) NSString *clientID;


@end
