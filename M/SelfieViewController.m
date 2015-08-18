//
//  SelfieViewController.m
//  Maids App
//
//  Created by Armen Merikyan on 12/25/14.
//  Copyright (c) 2014 Maids App Inc. All rights reserved.
//

#import "SelfieViewController.h"

@interface SelfieViewController ()
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *delayedPhotoButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation SelfieViewController
@synthesize clientID, imageView;
BOOL isPhotoDone = NO;
UIImagePickerController *imagePickerController;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capturedImages = [[NSMutableArray alloc] init];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        [toolbarItems removeObjectAtIndex:2];
        [self.toolBar setItems:toolbarItems animated:NO];
    }
    /*
    NSLog([NSString stringWithFormat:@"http://www.mytruckboard.com/AAA/getImageService.jsp?CLIENT_ID=%@", self.clientID]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.maidsapp.com/AAA/getImageService.jsp?CLIENT_ID=%@", self.clientID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectMake(50, 100 ,screenRect.size.width-100, screenRect.size.height -250)]];
    [[self imageView] setImage:img];
    [self.view addSubview:[self imageView]];
     */
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectMake(50, 100 ,100, 100)]];
    
}


- (IBAction)showImagePickerForCamera:(id)sender
{
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

}
- (void)viewDidAppear:(BOOL)animated{
    if(isPhotoDone == NO){
        isPhotoDone = YES;
        [self showImagePickerForCamera:nil];
    }else{
        isPhotoDone = NO;
        [self done:nil];
    }
}
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.imageView.isAnimating)
    {
        [self.imageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        imagePickerController.showsCameraControls = NO;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
    }
    
    self.imagePickerController = imagePickerController;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIButton *tempFlipCameraBUtton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tempFlipCameraBUtton.frame=CGRectMake((screenRect.size.width/2)-50,screenRect.size.height-150,100,100);
    [tempFlipCameraBUtton addTarget:self
                             action:@selector(switchCamera:)
                   forControlEvents:UIControlEventTouchUpInside];
    [[tempFlipCameraBUtton layer] setCornerRadius:8.0f];
//    [tempFlipCameraBUtton setTitle:@"Maid Mode" forState:UIControlStateNormal];
    [[tempFlipCameraBUtton layer] setMasksToBounds:YES];
    [[tempFlipCameraBUtton layer] setBorderColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor];
    
    UIImage * srcImgHand = [UIImage imageNamed:@"flip_camera.png"];
    [tempFlipCameraBUtton setBackgroundImage:srcImgHand forState:UIControlStateNormal];
    [self.imagePickerController.view addSubview:tempFlipCameraBUtton];    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


-(IBAction) switchCamera:(id)sender{
    if(imagePickerController.cameraDevice !=UIImagePickerControllerCameraDeviceRear){
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }else{
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}
#pragma mark - Toolbar actions

- (IBAction)done:(id)sender
{
    // Dismiss the camera.
    if ([self.cameraTimer isValid])
    {
        [self.cameraTimer invalidate];
    }
    [self finishAndUpdate];
}


- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}


- (IBAction)delayedTakePhoto:(id)sender
{
    // These controls can't be used until the photo has been taken
    self.doneButton.enabled = NO;
    self.takePictureButton.enabled = NO;
    self.delayedPhotoButton.enabled = NO;
    self.startStopButton.enabled = NO;
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
    NSTimer *cameraTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:1.0 target:self selector:@selector(timedPhotoFire:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:cameraTimer forMode:NSDefaultRunLoopMode];
    self.cameraTimer = cameraTimer;
}


- (IBAction)startTakingPicturesAtIntervals:(id)sender
{
    /*
     Start the timer to take a photo every 1.5 seconds.
     
     CAUTION: for the purpose of this sample, we will continue to take pictures indefinitely.
     Be aware we will run out of memory quickly.  You must decide the proper threshold number of photos allowed to take from the camera.
     One solution to avoid memory constraints is to save each taken photo to disk rather than keeping all of them in memory.
     In low memory situations sometimes our "didReceiveMemoryWarning" method will be called in which case we can recover some memory and keep the app running.
     */
    self.startStopButton.title = NSLocalizedString(@"Stop", @"Title for overlay view controller start/stop button");
    [self.startStopButton setAction:@selector(stopTakingPicturesAtIntervals:)];
    
    self.doneButton.enabled = NO;
    self.delayedPhotoButton.enabled = NO;
    self.takePictureButton.enabled = NO;
    
    self.cameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timedPhotoFire:) userInfo:nil repeats:YES];
    [self.cameraTimer fire]; // Start taking pictures right away.
}


- (IBAction)stopTakingPicturesAtIntervals:(id)sender
{
    // Stop and reset the timer.
    [self.cameraTimer invalidate];
    self.cameraTimer = nil;
    
    [self finishAndUpdate];
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
- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            
            UIImage *original = [[self.capturedImages objectAtIndex:0] copy];
            UIImage *imageToDisplay =
            [UIImage imageWithCGImage:[original CGImage]
                                scale:1.0
                          orientation: UIImageOrientationRight];
            UIImage *small = [self resizeImage:imageToDisplay resizeSize:CGSizeMake(1080,1080)];
            UIImage *smallSmall = [self resizeImage:imageToDisplay resizeSize:CGSizeMake(100,100)];
            NSString *boundary = @"Filename.jpg";
            
            NSData *imageData = UIImageJPEGRepresentation(small, 1.0);
            NSData *imageDataSmall = UIImageJPEGRepresentation(smallSmall, 1.0);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
            NSString *imagePathSmall =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Small.jpg",@"cached"]];
            
            NSLog((@"pre writing to file"));
            if (![imageData writeToFile:imagePath atomically:NO])
            {
                NSLog((@"Failed to cache image data to disk"));
            }
            else
            {
                NSLog((@"the cachedImagedPath is %@",imagePath)); 
            }
            if (![imageDataSmall writeToFile:imagePathSmall atomically:NO])
            {
                NSLog((@"Failed to cache image data to disk"));
            }
            else
            {
                NSLog((@"the cachedImagedPath is %@",imagePath));
            }
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            self.imageView.animationImages = self.capturedImages;
            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.imageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}


#pragma mark - Timer

// Called by the timer to take a picture.
- (void)timedPhotoFire:(NSTimer *)timer
{
    [self.imagePickerController takePicture];
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    
    if ([self.cameraTimer isValid])
    {
        return;
    }
    
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
