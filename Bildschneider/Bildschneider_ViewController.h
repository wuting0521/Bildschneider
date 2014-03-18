//
//  Bildschneider_ViewController.h
//  Bildschneider
//
//  Created by Ting Wu on 13-7-5.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Bildschneider_ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UISlider *blurSlider;

@end
