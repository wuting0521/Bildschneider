//
//  Bildschneider_ViewController.m
//  Bildschneider
//
//  Created by Ting Wu on 13-7-5.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import "Bildschneider_ViewController.h"
#import "Bildschneider_PolygonCropView.h"
#import "Bildschneider_RectangleCropView.h"
#import "Toast+UIView.h"
#import "UIImageView+LBBlurredImage.h"

@interface Bildschneider_ViewController ()  {
    UIImageView *b;
}
@property (nonatomic) UIImageView *imagePreview;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) UIImage *imageToUse;
@property (nonatomic) UIButton *cropButton;
@property (nonatomic) UIButton *blurButton;
@property (nonatomic) UIButton *undoButton;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIButton *importButton;
@property (nonatomic) UIButton *saveButton;

@property (strong, nonatomic) Bildschneider_PolygonCropView *polygonCropView;
@property (strong, nonatomic) Bildschneider_RectangleCropView *rectangleCropView;
@end

@implementation Bildschneider_ViewController
@synthesize imagePreview = _imagePreview;
@synthesize blurSlider = _blurSlider;
@synthesize actionSheet = _actionSheet;
@synthesize imageToUse = _imageToUse;

@synthesize cropButton = _cropButton;
@synthesize blurButton = _blurButton;
@synthesize undoButton = _undoButton;
@synthesize doneButton = _doneButton;
@synthesize importButton = _importButton;
@synthesize saveButton = _saveButton;

- (IBAction)importFromLibrary:(UIBarButtonItem *)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)cropShapeSelection:(UIBarButtonItem *)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Shape" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Rectangle", @"Polygon", @"Cancel", nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    self.actionSheet.destructiveButtonIndex = 2;
    [self.actionSheet showInView:self.view];
    self.blurSlider.hidden = YES;
}

- (IBAction)finishCrop:(UIBarButtonItem *)sender {

    if (self.polygonCropView) {
        self.imagePreview.image = [self.polygonCropView deleteBackgroundOfImage:self.imagePreview];
    }
    if (self.rectangleCropView) {
        self.imagePreview.image = [self.rectangleCropView deleteBackgroundOfImage:self.imagePreview];
    }
    
    
    self.blurSlider.hidden = YES;
    [self.blurSlider sendActionsForControlEvents:UIControlEventTouchCancel];
}

- (IBAction)cancelCrop:(id)sender {

    self.blurSlider.value = 0.0f;
    [self.blurSlider sendActionsForControlEvents:UIControlEventTouchCancel];

    if (self.polygonCropView) {
        [self.polygonCropView removeFromSuperview];
    }
    if (self.rectangleCropView) {
        [self.rectangleCropView removeFromSuperview];
    }
    self.imagePreview.image = self.imageToUse;
    
    if (self.imagePreview.image) {
        [self.imagePreview setImageToBlur:self.imagePreview.image blurRadius:0 completionBlock:^(NSError *error) {
            
        }];
    }    
}

- (IBAction)saveCropedImage:(UIBarButtonItem *)sender {

    if (self.imagePreview.image) {
        UIImageWriteToSavedPhotosAlbum(self.imagePreview.image, NULL, NULL, NULL);
        [self.view makeToast:@"Image saved."];
    }
}

- (IBAction)blurImage:(UIBarButtonItem *)sender {
    self.blurSlider.hidden = NO;
    [self.blurSlider setValue:5 animated:YES];
    if (self.imagePreview.image) {
        [self.imagePreview setImageToBlur:self.imagePreview.image blurRadius:self.blurSlider.value completionBlock:^(NSError *error) {
        }];
    }
}

- (void)blurImageSlide {
    
    self.imagePreview.image = self.imageToUse;
    
    if (self.imagePreview.image) {
        [self.imagePreview setImageToBlur:self.imagePreview.image blurRadius:self.blurSlider.value completionBlock:^(NSError *error) {
            //NSLog(@"Radius:%f", sender.value);
        }];
    }

}


//resize image to fit the imageVIew
/*
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
 */

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //rectangle
            //self.imagePreview.image = self.imageToUse;
            self.rectangleCropView = [[Bildschneider_RectangleCropView alloc] initWithImageView:self.imagePreview];
            if (self.polygonCropView) {
                [self.polygonCropView removeFromSuperview];
            }
            
            [self.view addSubview:self.rectangleCropView];
            break;
        case 1:
            //polygon
            //self.imagePreview.image = self.imageToUse;
            self.polygonCropView = [[Bildschneider_PolygonCropView alloc] initWithImageView:self.imagePreview];
            if (self.rectangleCropView) {
                [self.rectangleCropView removeFromSuperview];
            }
            
            [self.view addSubview:self.polygonCropView];
            break;
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
        
        self.imagePreview.bounds = [self resizePreviewFrameWithImage:self.imageToUse];
        self.imagePreview.image = self.imageToUse;
        self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
}
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)resizePreviewFrameWithImage:(UIImage *)image {
    CGRect previewFrame;
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat buttonHeight = 30;
    
    if (image.size.width >= image.size.height) {
        CGFloat width = screenFrame.size.width - 2 * inset;
        CGFloat height = width * image.size.height / image.size.width;
        previewFrame = CGRectMake(inset, (screenFrame.size.height - height)/2, width, height);
    } else {
        CGFloat height = screenFrame.size.height - 3 * inset - buttonHeight;
        CGFloat width = height * image.size.width / image.size.height;
        previewFrame = CGRectMake((screenFrame.size.width - width)/2, inset, width, height);
    }
    
    return previewFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *defaultBG = [UIImage imageNamed:@"bg"];
    self.imageToUse = defaultBG;

    self.imagePreview = [[UIImageView alloc] initWithFrame:[self resizePreviewFrameWithImage:self.imageToUse]];
    self.imagePreview.image = self.imageToUse;
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imagePreview];
    
    CGFloat buttonHeight = 30;
    CGFloat inset = 20;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    CGRect firstButton = CGRectMake(inset, screenFrame.size.height - inset - buttonHeight, buttonHeight, buttonHeight);
    CGRect secondButton = CGRectMake(firstButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect thirdButton = CGRectMake(secondButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect fourthButton = CGRectMake(thirdButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect fifthButton = CGRectMake(fourthButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect sixthButton = CGRectMake(fifthButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    
    self.importButton = [[UIButton alloc]initWithFrame:firstButton];
    [self.importButton setImage:[UIImage imageNamed:@"import"] forState:UIControlStateNormal];
    self.importButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.importButton];
    
    self.cropButton = [[UIButton alloc] initWithFrame:secondButton];
    [self.cropButton setImage:[UIImage imageNamed:@"crop"] forState:UIControlStateNormal];
    self.cropButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.cropButton];
    
    self.blurButton = [[UIButton alloc] initWithFrame:thirdButton];
    [self.blurButton setImage:[UIImage imageNamed:@"blur"] forState:UIControlStateNormal];
    self.blurButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.blurButton];
    
    self.undoButton = [[UIButton alloc] initWithFrame:fourthButton];
    [self.undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    self.undoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.undoButton];
    
    self.doneButton = [[UIButton alloc] initWithFrame:fifthButton];
    [self.doneButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    self.doneButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.doneButton];
    
    self.saveButton = [[UIButton alloc] initWithFrame:sixthButton];
    [self.saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    self.saveButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.saveButton];
    
    CGRect sliderFrame = CGRectMake(inset, screenFrame.size.height - inset * 2 - buttonHeight, screenFrame.size.width - 2 * inset, inset);
    
    self.blurSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    self.blurSlider.hidden = YES;
    self.blurSlider.value = 0;
    self.blurSlider.maximumValue = 15;
    [self.blurSlider addTarget:self action:@selector(blurImageSlide) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.blurSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
