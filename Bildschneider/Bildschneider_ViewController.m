//
//  Bildschneider_ViewController.m
//  Bildschneider
//
//  Created by Ting Wu on 13-7-5.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import "Bildschneider_ViewController.h"

@interface Bildschneider_ViewController ()

@end

@implementation Bildschneider_ViewController
@synthesize imagePreview = _imagePreview;

- (IBAction)accessToPhotoLibrary:(UIButton *)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)cropImageSelection:(UIButton *)sender {
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
    //NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //NSLog(@"%@", [info objectForKey:UIImagePickerControllerMediaType]);
    UIImage *originalImage, *editedImage, *imageToUse;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        //NSLog(@"%@", imageToUse.description);
        
        //Do something with imageToUse
        self.imagePreview.image = imageToUse;
        self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    //if (CFStringCompare((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
    //  NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
    //  Do something with the picked movie
    //}
    
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
