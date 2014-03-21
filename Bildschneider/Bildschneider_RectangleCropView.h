//
//  Bildschneider_RectangleCropView.h
//  Bildschneider
//
//  Created by Ting Wu on 13-7-10.
//  Copyright (c) 2013年 Jia Daizi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Bildschneider_RectangleCropView : UIView

@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, strong) UIColor *lineColor;

- (id)initWithImageView:(UIImageView *)imageView;
- (id)initWithImageView:(UIImageView *)imageView deviceType:(int)type;

- (NSArray *)getPoints;
- (UIImage *)deleteBackgroundOfImage:(UIImageView *)image;

- (void)addPointsAt:(NSArray *)points;
- (void)addPoints;

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2;

@end
