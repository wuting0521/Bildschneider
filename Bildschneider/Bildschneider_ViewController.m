//
//  Bildschneider_ViewController.m
//  Bildschneider
//
//  Created by Ting Wu on 13-7-5.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import "Bildschneider_ViewController.h"
#import "Bildschneider_PolygonCropView.h"

@interface Bildschneider_ViewController ()  {
    UIImageView *b;
}
@property (nonatomic) IBOutlet UIImageView *imagePreview;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) UIImage *imageToUse;
@property (strong, nonatomic) Bildschneider_PolygonCropView *polygonPointsView;
@end

@implementation Bildschneider_ViewController
@synthesize imagePreview = _imagePreview;
@synthesize actionSheet = _actionSheet;
@synthesize imageToUse = _imageToUse;

- (IBAction)importFromLibrary:(UIBarButtonItem *)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}
- (IBAction)cropShapeSelection:(UIBarButtonItem *)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Shape" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Rectangle", @"Polygon", @"Cancel", nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    self.actionSheet.destructiveButtonIndex = 2;
    [self.actionSheet showInView:self.view];
}

- (IBAction)finishCrop:(UIBarButtonItem *)sender {
    self.imagePreview.image = [self.polygonPointsView deleteBackgroundOfImage:self.imagePreview];
}

- (IBAction)cancelCrop:(id)sender {
    self.imagePreview.image = self.imageToUse;
}

- (IBAction)saveCropedImage:(UIBarButtonItem *)sender {
    //to be continued...
    if (self.imagePreview.image) {
        UIImageWriteToSavedPhotosAlbum(self.imagePreview.image, NULL, NULL, NULL);
        UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"Image saved." message:NULL delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [dialog show];
    }
}

//resize image to fit the imageVIew
- (UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height {
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    alphaInfo = kCGImageAlphaNoneSkipLast;
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef),
                                                4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //rectangle
            self.imagePreview.image = self.imageToUse;
            break;
        case 1:
            //polygon
            self.imagePreview.image = self.imageToUse;
            self.imagePreview.frame = [Bildschneider_PolygonCropView scaleRespectAspectFromRect1:CGRectMake(0, 0, self.imagePreview.image.size.width, self.imagePreview.image.size.height) toRect2:self.imagePreview.frame];
            self.polygonPointsView = [[Bildschneider_PolygonCropView alloc] initWithImageView:self.imagePreview];
            [self.polygonPointsView addPoints:8];
            [self.view addSubview:self.polygonPointsView];
            //NSLog(@"PolygonCropViewSize: %f * %f", self.polygonPointsView.frame.size.width, self.polygonPointsView.frame.size.height);
            NSLog(@"PolygonCropViewLocation: (%f, %f)", self.polygonPointsView.frame.origin.x, self.polygonPointsView.frame.origin.y);

        case 2:
            //cancel
            break;
        default:
            break;
    }
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController *) controller usingDelegate: (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil)
         || (controller == nil)) return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originalImage, *editedImage;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            self.imageToUse = editedImage;
        } else {
            self.imageToUse = originalImage;
        }
        
        self.imageToUse = [self resizeImage:self.imageToUse width:248 height:372];
        self.imagePreview.image = self.imageToUse;
        self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
}
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
