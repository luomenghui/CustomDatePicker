//
//  CustomDatePicker.h
//  CustomUIDatePicker
//
//  Created by 罗孟辉 on 2017/8/29.
//  Copyright © 2017年 罗孟辉. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CustomDatePickerMode) {
    CustomDatePickerModeTime,
    CustomDatePickerModeDate,
    CustomDatePickerModeHalfADay,           // 上下午
//    CustomDatePickerModeDateAndTime,
//    CustomDatePickerModeCountDownTimer,
};

@protocol CustomDatePickerDelegate <NSObject>

- (void)confirmSelect;

@end

@interface CustomDatePicker : UIView

@property (nonatomic, assign) CustomDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, assign) NSInteger minuteInterval;         // default is 1. min is 1, max is 30
@property (nonatomic, strong) NSDate *date;        // default is current date when picker created.
@property (nonatomic, strong) NSString *time;

@property (nonatomic, weak) id<CustomDatePickerDelegate>delegate;

@end
