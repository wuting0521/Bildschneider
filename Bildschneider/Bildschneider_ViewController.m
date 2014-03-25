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
#import <Dropbox/Dropbox.h>
#import <DBChooser/DBChooser.h>

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
@property (nonatomic) UIButton *dropboxButton;
@property (nonatomic, strong) NSMutableData *dbData;

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
@synthesize dropboxButton = _dropboxButton;

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.dbData setLength:0];
    NSLog(@"did receive response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.dbData appendData:data];
    NSLog(@"data:%d", self.dbData.length);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.dbData = nil;
    NSLog(@"faild! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:self.dbData];
    if (image) {
        NSLog(@"image");
        NSLog(@"size:%f * %f", image.size.width, image.size.height);
    } else {
        NSLog(@"nil");
    }
    //[self.imagePreview setBounds:[self resizePreviewFrameWithImage:self.imageToUse]];
    //[self.imagePreview setImage:self.imageToUse];
}
#pragma mark -
#pragma mark UI Action Events

//dropbox button action.old
- (void)didPressLink {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

//dropbox button chooser action
- (void)didPressChoose {
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:self completion:^(NSArray *results) {
        if ([results count]) {
            //process result from chooser
            DBChooserResult *result = [results firstObject];
            //TODO:load the image by https 异步 request;
            NSURLRequest *request = [NSURLRequest requestWithURL:result.link cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            self.dbData = [NSMutableData dataWithCapacity:0];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (!connection) {
                NSLog(@"failed");
                self.dbData = nil;
            }
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:result.link]];
            if (img) {
                self.imageToUse = img;
                [self.imagePreview setBounds:[self resizePreviewFrameWithImage:self.imageToUse]];
                [self.imagePreview setImage:self.imageToUse];
            }
            
            //[self.imagePreview setImage:self.imageToUse];
        } else {
            //user canceled the action
        }
    }];
}

//import button action
- (void)importFromLibrary {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

//crop button action
- (void)cropShapeSelection {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Shape" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"iPhone4", @"Rectangle", @"Polygon", @"Cancel", nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    self.actionSheet.destructiveButtonIndex = 3;
    [self.actionSheet showInView:self.view];
    self.blurSlider.hidden = YES;
}

//crop selection
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //iPhone 4
            if (self.polygonCropView || self.rectangleCropView) {
                [self.polygonCropView removeFromSuperview];
                [self.rectangleCropView removeFromSuperview];
            }
            self.rectangleCropView = [[Bildschneider_RectangleCropView alloc] initWithImageView:self.imagePreview deviceType:1];
            [self.view addSubview:self.rectangleCropView];
            break;
        case 1:
            //rectangle
            //self.imagePreview.image = self.imageToUse;
            self.rectangleCropView = [[Bildschneider_RectangleCropView alloc] initWithImageView:self.imagePreview];
            if (self.polygonCropView) {
                [self.polygonCropView removeFromSuperview];
            }
            [self.view addSubview:self.rectangleCropView];
            break;
        case 2:
            //polygon
            //self.imagePreview.image = self.imageToUse;
            self.polygonCropView = [[Bildschneider_PolygonCropView alloc] initWithImageView:self.imagePreview];
            if (self.rectangleCropView) {
                [self.rectangleCropView removeFromSuperview];
            }
            
            [self.view addSubview:self.polygonCropView];
            break;
        case 3:
            //cancel
            break;
        default:
            break;
    }
}

//blur button action
- (void)blurImage {
    self.blurSlider.hidden = NO;
    [self.blurSlider setValue:5 animated:YES];
    if (self.imagePreview.image) {
        [self.imagePreview setImageToBlur:self.imagePreview.image blurRadius:self.blurSlider.value completionBlock:^(NSError *error) {
        }];
    }
}

//undo button action
- (void)cancelCrop {
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

//done button action
- (void)finishCrop {
    if (self.polygonCropView) {
        self.imagePreview.image = [self.polygonCropView deleteBackgroundOfImage:self.imagePreview];
    }
    if (self.rectangleCropView) {
        self.imagePreview.image = [self.rectangleCropView deleteBackgroundOfImage:self.imagePreview];
    }
    
    self.blurSlider.hidden = YES;
    [self.blurSlider sendActionsForControlEvents:UIControlEventTouchCancel];
}

//save button action
- (void)saveCropedImage {
    if (self.imagePreview.image) {
        UIImageWriteToSavedPhotosAlbum(self.imagePreview.image, NULL, NULL, NULL);
        [self.view makeToast:@"Image saved."];
    }
}

//blur slider action
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

#pragma mark - 
#pragma mark Image Library

- (BOOL)startMediaBrowserFromViewController: (UIViewController *) controller usingDelegate: (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
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

#pragma mark - 
#pragma mark UI

- (CGRect)resizePreviewFrameWithImage:(UIImage *)image {
    CGRect previewFrame;
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat buttonHeight = 22;
    
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
    
    //image view
    UIImage *defaultBG = [UIImage imageNamed:@"bg"];
    self.imageToUse = defaultBG;
    
    self.imagePreview = [[UIImageView alloc] initWithFrame:[self resizePreviewFrameWithImage:self.imageToUse]];
    self.imagePreview.image = self.imageToUse;
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imagePreview];
    
    CGFloat buttonHeight = 22;
    CGFloat inset = 20;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    //buttons 
    CGRect firstButton = CGRectMake(inset, screenFrame.size.height - inset/2 - buttonHeight, buttonHeight, buttonHeight);
    CGRect secondButton = CGRectMake(firstButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect thirdButton = CGRectMake(secondButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect fourthButton = CGRectMake(thirdButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect fifthButton = CGRectMake(fourthButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect sixthButton = CGRectMake(fifthButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    CGRect seventhButton = CGRectMake(sixthButton.origin.x + buttonHeight + inset, firstButton.origin.y, buttonHeight, buttonHeight);
    
    self.dropboxButton = [[UIButton alloc] initWithFrame:firstButton];
    [self.dropboxButton setImage:[UIImage imageNamed:@"dropbox"] forState:UIControlStateNormal];
    self.dropboxButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.dropboxButton addTarget:self action:@selector(didPressChoose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dropboxButton];
    
    
    self.importButton = [[UIButton alloc]initWithFrame:secondButton];
    [self.importButton setImage:[UIImage imageNamed:@"import"] forState:UIControlStateNormal];
    self.importButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.importButton addTarget:self action:@selector(importFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.importButton];
    
    self.cropButton = [[UIButton alloc] initWithFrame:thirdButton];
    [self.cropButton setImage:[UIImage imageNamed:@"crop"] forState:UIControlStateNormal];
    self.cropButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cropButton addTarget:self action:@selector(cropShapeSelection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cropButton];
    
    self.blurButton = [[UIButton alloc] initWithFrame:fourthButton];
    [self.blurButton setImage:[UIImage imageNamed:@"blur"] forState:UIControlStateNormal];
    self.blurButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.blurButton addTarget:self action:@selector(blurImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.blurButton];
    
    self.undoButton = [[UIButton alloc] initWithFrame:fifthButton];
    [self.undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    self.undoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.undoButton addTarget:self action:@selector(cancelCrop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.undoButton];
    
    self.doneButton = [[UIButton alloc] initWithFrame:sixthButton];
    [self.doneButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    self.doneButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.doneButton addTarget:self action:@selector(finishCrop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
    
    self.saveButton = [[UIButton alloc] initWithFrame:seventhButton];
    [self.saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    self.saveButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.saveButton addTarget:self action:@selector(saveCropedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
    CGRect sliderFrame = CGRectMake(inset, screenFrame.size.height - inset * 2 - buttonHeight, screenFrame.size.width - 2 * inset, inset);
    
    //blur slider
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
