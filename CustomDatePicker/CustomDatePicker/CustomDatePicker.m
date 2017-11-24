//
//  CustomDatePicker.m
//  CustomUIDatePicker
//
//  Created by 罗孟辉 on 2017/8/29.
//  Copyright © 2017年 罗孟辉. All rights reserved.
//

#import "CustomDatePicker.h"

@interface CustomDatePicker ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) NSMutableArray *hourMarr;
@property (nonatomic, strong) NSMutableArray *minuteMarr;
@property (nonatomic, assign) NSInteger selectHourRow;
@property (nonatomic, assign) NSInteger selectMinuteRow;

@property (nonatomic, strong) NSMutableArray *yearMarr;
@property (nonatomic, strong) NSMutableArray *monthMarr;
@property (nonatomic, strong) NSMutableArray *dayMarr;
@property (nonatomic, assign) NSInteger selectYearRow;
@property (nonatomic, assign) NSInteger selectMonthRow;
@property (nonatomic, assign) NSInteger selectDayRow;

@property (nonatomic, strong) NSMutableArray *halfADayMarr;
@property (nonatomic, assign) NSInteger selectHalfADayRow;

@property (nonatomic, assign) CGSize size;

@end

@implementation CustomDatePicker

#define SCREENWIDTH UIScreen.mainScreen.bounds.size.width
#define SCREENHEIGHT UIScreen.mainScreen.bounds.size.height

#define scaleWidth [UIScreen mainScreen].bounds.size.width / 375.0
#define scaleHeight [UIScreen mainScreen].bounds.size.height / 667.0

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBWithColor(a, b, c, n) [[UIColor alloc] initWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:n]

#define CELL_HEIGHT 40
#define PICKER_HEIGHT 5 * CELL_HEIGHT

#define TOTAL_ROW_COUNT 16384

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = RGBWithColor(0, 0, 0, 0.6);
        
        _minuteInterval = 1;
        _size = CGSizeMake(frame.size.width, frame.size.height);
        _date = [NSDate date];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [self addView];
}

- (void)addView
{
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, _size.height - 40 * scaleHeight - PICKER_HEIGHT, SCREENWIDTH, 40 * scaleHeight)];
    headBackView.backgroundColor = UIColorFromRGB(0x1faf50);
    [self addSubview:headBackView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(13 * scaleWidth, 10 * scaleHeight, 40, 20 * scaleHeight);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelSelected) forControlEvents:UIControlEventTouchUpInside];
    [headBackView addSubview:cancelBtn];
    
    NSArray *texts = @[@"选择时间", @"选择日期", @"选择时段"];
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 - 50, 10 * scaleHeight, 100, 20 * scaleHeight)];
    titleName.text = texts[_datePickerMode];
    titleName.font = [UIFont systemFontOfSize:15];
    titleName.textColor = UIColorFromRGB(0xffffff);
    titleName.textAlignment = NSTextAlignmentCenter;
    [headBackView addSubview:titleName];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(SCREENWIDTH - 53 * scaleWidth, 10 * scaleHeight, 40, 20 * scaleHeight);
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmSelected) forControlEvents:UIControlEventTouchUpInside];
    [headBackView addSubview:confirmBtn];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, _size.height - PICKER_HEIGHT, SCREENWIDTH, PICKER_HEIGHT)];
    [self addSubview:_backView];
    
    [self addSubview:self.picker];
    [self setSelectRow];
    
    if (_datePickerMode == 1)
    {
        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size.width / 2 - 63, _picker.frame.size.height / 2 - 10, 20, 20)];
        yearLabel.text = @"年";
        yearLabel.font = [UIFont systemFontOfSize:15];
        yearLabel.textColor = UIColorFromRGB(0x333333);
        yearLabel.textAlignment = NSTextAlignmentLeft;
        [_picker addSubview:yearLabel];
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size.width / 2 + 5, _picker.frame.size.height / 2 - 10, 20, 20)];
        monthLabel.text = @"月";
        monthLabel.font = [UIFont systemFontOfSize:15];
        monthLabel.textColor = UIColorFromRGB(0x333333);
        monthLabel.textAlignment = NSTextAlignmentLeft;
        [_picker addSubview:monthLabel];
        
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size.width / 2 + 70, _picker.frame.size.height / 2 - 10, 20, 20)];
        dayLabel.text = @"日";
        dayLabel.font = [UIFont systemFontOfSize:15];
        dayLabel.textColor = UIColorFromRGB(0x333333);
        dayLabel.textAlignment = NSTextAlignmentLeft;
        [_picker addSubview:dayLabel];
    }
}

- (void)setSelectRow
{
    switch (_datePickerMode)
    {
        case 0:
        {
            NSString *hourMinStr = [self strFromDate_time:_date];
            NSString *hourStr = [hourMinStr substringToIndex:2];
            NSString *minuteStr = [hourMinStr substringFromIndex:hourMinStr.length - 2];
            NSInteger hourIndex = 16384 / (self.hourMarr.count) / 2 * (self.hourMarr.count) + hourStr.integerValue;
            NSInteger minuteIndex = 16384 / (self.minuteMarr.count) / 2 * (self.minuteMarr.count) + minuteStr.integerValue / _minuteInterval;
            [_picker selectRow:hourIndex inComponent:0 animated:YES];
            [_picker selectRow:minuteIndex inComponent:1 animated:YES];
            _time = [NSString stringWithFormat:@"%@:%@", hourStr, minuteStr];
            _selectHourRow = hourIndex;
            _selectMinuteRow = minuteIndex;
        }
            break;
        case 1:
        {
            NSString *yearMonthDay = [self strFromDate_yearMonthDay:_date];
            NSString *yearStr = [yearMonthDay substringToIndex:4];
            NSString *monthStr = [yearMonthDay substringWithRange:NSMakeRange(5, 2)];
            NSString *dayStr = [yearMonthDay substringFromIndex:yearMonthDay.length - 2];
            NSInteger yearIndex = yearStr.integerValue - [self.yearMarr[0] integerValue];
            NSInteger monthIndex = 16384 / (self.monthMarr.count) / 2 * (self.monthMarr.count) + monthStr.integerValue - 1;
            NSInteger dayIndex = 16384 / (self.dayMarr.count) / 2 * (self.dayMarr.count) + dayStr.integerValue - 1;
            
            [_picker selectRow:yearIndex inComponent:0 animated:YES];
            [_picker selectRow:monthIndex inComponent:1 animated:YES];
            [_picker selectRow:dayIndex inComponent:2 animated:YES];
            _selectYearRow = yearIndex;
            _selectMonthRow = monthIndex;
            _selectDayRow = dayIndex;
        }
            break;
        case 2:
        {
            _selectHalfADayRow = 0;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - <UIPickerViewDataSource>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (_datePickerMode)
    {
        case 0:
        {
            return 2;
        }
            break;
        case 1:
        {
            return 3;
        }
            break;
        case 2:
        {
            return 1;
        }
            break;
            
        default:
            break;
    }
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (_datePickerMode)
    {
        case 0:
        {
            return 16384;
        }
            break;
        case 1:
        {
            if (component == 0)
            {
                return 81;
            }
            else
            {
                return 16384;
            }
        }
            break;
        case 2:
        {
            return 2;
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark - <UIPickerViewDelegate>
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (_datePickerMode)
    {
        case 0:
        {
            CGFloat width = 40;
            return width;
        }
            break;
        case 1:
        {
            if (component == 0)
            {
                return 80;
            }
            else
            {
                return 60;
            }
        }
            break;
        case 2:
        {
            return 60;
        }
            break;
            
        default:
            break;
    }
    
    return _picker.frame.size.width / 3;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return CELL_HEIGHT;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (_datePickerMode)
    {
        case 0:
        {
            if (component == 0)
            {
                NSInteger index = row % (self.hourMarr.count);
                return self.hourMarr[index];
            }
            else
            {
                NSInteger index = row % (self.minuteMarr.count);
                return self.minuteMarr[index];
            }
        }
            break;
        case 1:
        {
            if (component == 0)
            {
                return self.yearMarr[row];
            }
            else if (component == 1)
            {
                NSInteger index = row % (self.monthMarr.count);
                return self.monthMarr[index];
            }
            else
            {
                NSInteger index = row % (self.dayMarr.count);
                return self.dayMarr[index];
            }
        }
            break;
        case 2:
        {
            return self.halfADayMarr[row];
        }
            break;
            
        default:
            break;
    }
    return nil;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (!label)
    {
        label = [[UILabel alloc] init];
    }
    label.font = [UIFont systemFontOfSize:16];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = UIColorFromRGB(0x333333);
    
    switch (_datePickerMode)
    {
        case 0:
        {
            if (component == 0)
            {
                if (_selectHourRow == row)
                {
                    label.textColor = UIColorFromRGB(0x1faf50);
                }
            }
            else
            {
                if (_selectMinuteRow == row)
                {
                    label.textColor = UIColorFromRGB(0x1faf50);
                }
            }
        }
            break;
        case 1:
        {
            if (component == 0)
            {
                if (_selectYearRow == row)
                {
                    label.textColor = UIColorFromRGB(0x1faf50);
                }
            }
            else if (component == 1)
            {
                if (_selectMonthRow == row)
                {
                    label.textColor = UIColorFromRGB(0x1faf50);
                }
            }
            else
            {
                if (_selectDayRow == row)
                {
                    label.textColor = UIColorFromRGB(0x1faf50);
                }
            }
        }
            break;
        case 2:
        {
            if (_selectHalfADayRow == row)
            {
                label.textColor = UIColorFromRGB(0x1faf50);
            }
        }
            break;
            
        default:
            break;
    }
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (_datePickerMode)
    {
        case 0:
        {
            NSInteger hourIndex = [pickerView selectedRowInComponent:0] % (self.hourMarr.count);
            NSInteger minuteIndex = [pickerView selectedRowInComponent:1] % (self.minuteMarr.count);
            NSString *hourStr = self.hourMarr[hourIndex];
            NSString *minuteStr = self.minuteMarr[minuteIndex];
            _time = [NSString stringWithFormat:@"%@:%@", hourStr, minuteStr];
            _selectHourRow = [pickerView selectedRowInComponent:0];
            _selectMinuteRow = [pickerView selectedRowInComponent:1];
        }
            break;
        case 1:
        {
            NSInteger yearIndex = [pickerView selectedRowInComponent:0] % (self.yearMarr.count);
            NSInteger monthIndex = [pickerView selectedRowInComponent:1] % (self.monthMarr.count);
            NSInteger dayIndex = [pickerView selectedRowInComponent:2] % (self.dayMarr.count);
            if (component == 0 || component == 1)
            {
                [self DaysfromYear:[self.yearMarr[yearIndex] integerValue] andMonth:[self.monthMarr[monthIndex] integerValue]];
                [pickerView reloadComponent:2];
                if (dayIndex >= self.dayMarr.count)
                {
                    dayIndex = self.dayMarr.count - 1;
                }
                [_picker selectRow:dayIndex inComponent:2 animated:YES];
            }
            
            NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00", self.yearMarr[yearIndex], self.monthMarr[monthIndex], self.dayMarr[dayIndex]];
            _date = [self dateFromString:dateStr];
            _selectYearRow = [pickerView selectedRowInComponent:0];
            _selectMonthRow = [pickerView selectedRowInComponent:1];
            _selectDayRow = [pickerView selectedRowInComponent:2];
        }
            break;
        case 2:
        {
            _selectHalfADayRow = row;
        }
            break;
            
        default:
            break;
    }
    [pickerView reloadAllComponents];
}

#pragma mark - 取消
- (void)cancelSelected
{
    [self removeFromSuperview];
}
- (void)confirmSelected
{
    [self removeFromSuperview];
    
    switch (_datePickerMode)
    {
        case 0:
        {
            [self.delegate selectTime:_time];
        }
            break;
        case 1:
        {
            [self.delegate selectDate:_date];
        }
            break;
        case 2:
        {
            [self.delegate selectHalfADay:_selectHalfADayRow == 0 ? @"上午" : @"下午"];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year % 4 ==0 ? (num_year % 100 == 0 ? (num_year % 400 == 0 ? YES : NO) : YES) : NO;
    switch (num_month)
    {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:
        {
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:
        {
            [self setdayArray:30];
            return 30;
        }
        case 2:
        {
            if (isrunNian)
            {
                [self setdayArray:29];
                return 29;
            }
            else
            {
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [_dayMarr removeAllObjects];
    for (int i = 1; i <= num; ++i)
    {
        [_dayMarr addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

#pragma mark - 懒加载
- (UIPickerView *)picker
{
    if (!_picker)
    {
        _picker = [[UIPickerView alloc] initWithFrame:_backView.frame];
        _picker.dataSource = self;
        _picker.delegate = self;
        _picker.backgroundColor = UIColorFromRGB(0xffffff);
        _picker.showsSelectionIndicator = YES;
        
    }
    return _picker;
}

- (NSMutableArray *)yearMarr
{
    if (!_yearMarr)
    {
        _yearMarr = [NSMutableArray arrayWithCapacity:1];
        for (int i = 1970; i <= 2050; ++i)
        {
            NSString *text = [NSString stringWithFormat:@"%04d", i];
            [_yearMarr addObject:text];
        }
    }
    return _yearMarr;
}
- (NSMutableArray *)monthMarr
{
    if (!_monthMarr)
    {
        _monthMarr = [NSMutableArray arrayWithCapacity:1];
        for (int i = 1; i <= 12; ++i)
        {
            NSString *text = [NSString stringWithFormat:@"%02d", i];
            [_monthMarr addObject:text];
        }
    }
    return _monthMarr;
}
- (NSMutableArray *)dayMarr
{
    if (!_dayMarr)
    {
        _dayMarr = [NSMutableArray arrayWithCapacity:1];
        
        NSString *yearMonthDay = [self strFromDate_yearMonthDay:_date];
        NSString *yearStr = [yearMonthDay substringToIndex:4];
        NSString *monthStr = [yearMonthDay substringWithRange:NSMakeRange(5, 2)];
        [self DaysfromYear:yearStr.integerValue andMonth:monthStr.integerValue];
    }
    return _dayMarr;
}

- (NSMutableArray *)hourMarr
{
    if (!_hourMarr)
    {
        _hourMarr = [NSMutableArray arrayWithCapacity:1];
        
        for (int i = 0; i < 24; ++i)
        {
            NSString *text = [NSString stringWithFormat:@"%02d", i];
            [_hourMarr addObject:text];
        }
    }
    return _hourMarr;
}
- (NSMutableArray *)minuteMarr
{
    if (!_minuteMarr)
    {
        _minuteMarr = [NSMutableArray arrayWithCapacity:1];
        
        for (int i = 0; i < 60; i += _minuteInterval)
        {
            NSString *text = [NSString stringWithFormat:@"%02d", i];
            [_minuteMarr addObject:text];
        }
    }
    return _minuteMarr;
}

- (NSMutableArray *)halfADayMarr
{
    if (!_halfADayMarr)
    {
        _halfADayMarr = [NSMutableArray arrayWithCapacity:1];
        [_halfADayMarr addObject:@"上午"];
        [_halfADayMarr addObject:@"下午"];
    }
    return _halfADayMarr;
}

/**
 日期转化为时间HH:mm
 */
- (NSString *)strFromDate_time:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *str = [formatter stringFromDate:date];
    
    return str;
}

// 格式化字符串 yyyy-MM-dd
- (NSString *)strFromDate_yearMonthDay:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    
    return str;
}

/**
 字符串转日期
 */
- (NSDate *)dateFromString:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

@end
