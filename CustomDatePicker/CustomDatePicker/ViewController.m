//
//  ViewController.m
//  CustomDatePicker
//
//  Created by 罗孟辉 on 2017/8/30.
//  Copyright © 2017年 罗孟辉. All rights reserved.
//

#import "ViewController.h"
#import "CustomDatePicker.h"

#define SCREENWIDTH UIScreen.mainScreen.bounds.size.width
#define SCREENHEIGHT UIScreen.mainScreen.bounds.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBWithColor(a, b, c, n) [[UIColor alloc] initWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:n]

@interface ViewController ()<CustomDatePickerDelegate>

@property (nonatomic, strong) CustomDatePicker *picker;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    [self addView];
}

- (void)addView
{
    NSArray *texts = @[@"选择时间", @"选择日期", @"选择时段"];
    for (int i = 0; i < 3; ++i)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.backgroundColor = RGBWithColor(0, 0, 0, 0.7);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 5.0f;
        [btn setTitle:texts[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(18, 50 + i * 55, SCREENWIDTH - 36, 45);
        [btn addTarget:self action:@selector(selectDateOrTime:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}
- (void)selectDateOrTime:(UIButton *)btn
{
    _picker = [[CustomDatePicker alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _picker.datePickerMode = btn.tag;
    _picker.minuteInterval = 10;
    _picker.delegate = self;
    [self.view addSubview:_picker];
}

- (void)selectTime:(NSString *)time
{
    NSLog(@"选中的时间 %@", time);
}
- (void)selectDate:(NSDate *)date
{
    NSLog(@"选中的日期 %@", [self strFromDate:date]);
}
- (void)selectHalfADay:(NSString *)halfADay
{
    NSLog(@"选中的时间段 %@", halfADay);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)strFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [formatter stringFromDate:date];
    
    return str;
}

@end
