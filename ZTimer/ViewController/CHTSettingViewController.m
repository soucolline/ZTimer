//
//  CHTSettingViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/17/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSettingViewController.h"
#import "ZTimer-Swift.h"

@interface CHTSettingViewController ()
@property(nonatomic, strong) UILabel *fTime;
@property(nonatomic, strong) Theme *timerTheme;
@property(nonatomic, strong) UITableViewCell *sensCell;
@end

@implementation CHTSettingViewController
@synthesize fTime;
@synthesize sensCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [Utils getLocalizedStringFrom:@"setting"];
    self.timerTheme = [Theme getTimerTheme];
    if ([Utils getDevice] == DevicePad) {
        fTime = [[UILabel alloc]initWithFrame:CGRectMake(16, 25, 200, 15)];
    } else {
        fTime = [[UILabel alloc]initWithFrame:CGRectMake(16, 25, 200, 15)];
    }
    
    fTime.font = [Theme fontWithStyle:FontStyleLight iphoneSize:13.0f ipadSize:13.0f];
    fTime.backgroundColor = [UIColor clearColor];
    fTime.textColor = [UIColor darkGrayColor];
    int time = [[[Settings alloc] init] intForKey:@"freezeTime"];
    fTime.text = [NSString stringWithFormat:@"%0.1f s", (double)time*0.01];
    if ([fTime.text isEqualToString:@"0.0 s"]) {
        fTime.text = [fTime.text stringByAppendingString:[Utils getLocalizedStringFrom:@"no other gesture"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"get cell");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = [Utils getLocalizedStringFrom:@"wca inspection"];
                    cell.detailTextLabel.text = [Utils getLocalizedStringFrom:@"15 sec"];
                    UISwitch *wcaInsSwitch = [[UISwitch alloc] init];
                    [wcaInsSwitch addTarget:self action:@selector(wcaSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[Settings alloc] init] boolForKey: @"wcaInspection"] == YES) {
                        [wcaInsSwitch setOn:YES];
                    }
                    else {
                        [wcaInsSwitch setOn:NO];
                    }
                    cell.accessoryView = wcaInsSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = [Utils getLocalizedStringFrom:@"knockToStop"];
                    cell.detailTextLabel.text = [Utils getLocalizedStringFrom:@"knockToStopDetail"];
                    UISwitch *knockSwitch = [[UISwitch alloc] init];
                    [knockSwitch addTarget:self action:@selector(knockSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[Settings alloc] init] boolForKey: @"knockToStop"] == YES) {
                        [knockSwitch setOn:YES];
                    }
                    else {
                        [knockSwitch setOn:NO];
                    }
                    cell.accessoryView = knockSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2:
                {
                    cell.textLabel.text = [Utils getLocalizedStringFrom:@"sensitivity"];
                    [cell.detailTextLabel setText:@""];
                    UISlider *sensSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
                    [sensSlider setTintColor:[self.timerTheme getTintColor]];
                    
                    sensSlider.minimumValue = 0;
                    sensSlider.maximumValue = 110;
                    [sensSlider addTarget:self action:@selector(sensSliderChanged:) forControlEvents:UIControlEventValueChanged];
                    int sens = [[[Settings alloc] init] intForKey:@"knockSensitivity"];
                    if (![[[Settings alloc] init] hasObjectForKey:@"knockSensitivity"]) {
                        sens = 60;
                        [[[Settings alloc] init] saveWithInt:sens forKey:@"knockSensitivity"];
                    }
                    sensSlider.value = sens;
                    [cell addSubview:fTime];
                    cell.accessoryView = sensSlider;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if ([[[Settings alloc] init] boolForKey: @"knockToStop"] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.textLabel.enabled = NO;
                        ((UISwitch *)(cell.accessoryView)).enabled = NO;
                    } else {
                        cell.userInteractionEnabled = YES;
                        cell.textLabel.enabled = YES;
                        ((UISwitch *)(cell.accessoryView)).enabled = YES;
                    }
                    cell.indentationLevel = 2;
                    cell.indentationWidth = 10;
                    self.sensCell = cell;
                    break;
                }
                case 3:
                {
                    cell.textLabel.text = [Utils getLocalizedStringFrom:@"start freeze"];
                    [cell.detailTextLabel setText:@" "];
                    UISlider *freezeTime = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
                    [freezeTime setTintColor:[self.timerTheme getTintColor]];

                    freezeTime.minimumValue = 10;
                    freezeTime.maximumValue = 100;
                    [freezeTime addTarget:self action:@selector(freezeTimeSliderChanged:) forControlEvents:UIControlEventValueChanged];
                    int time = [[[Settings alloc] init] intForKey:@"freezeTime"];
                    freezeTime.value = time;
                    [cell addSubview:fTime];
                    cell.accessoryView = freezeTime;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    [cell.textLabel setText:[Utils getLocalizedStringFrom:@"newest time on"]];
                    NSArray *solveOrders = [[NSArray alloc] initWithObjects:[Utils getLocalizedStringFrom:@"bottom"], [Utils getLocalizedStringFrom:@"top"], nil];
                    UISegmentedControl *solveOrderSegment = [[UISegmentedControl alloc] initWithItems:solveOrders];
                    
                    [solveOrderSegment setTintColor:[self.timerTheme getTintColor]];
                    int order = [[[Settings alloc] init] intForKey:@"solveOrder"];
                    [solveOrderSegment setSelectedSegmentIndex:order];
                    //[solveOrderSegment setFrame:CGRectMake(0, 0, 180, 30)];
                    [solveOrderSegment addTarget:self action:@selector(solveOrderSegmentChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = solveOrderSegment;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.detailTextLabel setText:@""];
                }
                    break;
                case 1:
                {
                    [cell.textLabel setText:[Utils getLocalizedStringFrom:@"solve subtitle"]];
                    NSArray *solveDetails = [[NSArray alloc] initWithObjects:[Utils getLocalizedStringFrom:@"time"], [Utils getLocalizedStringFrom:@"scrStr"], [Utils getLocalizedStringFrom:@"type"], nil];
                    UISegmentedControl *solveDetailSegment = [[UISegmentedControl alloc] initWithItems:solveDetails];
                    //[solveDetailSegment setFrame:CGRectMake(0, 0, 180, 30)];
                    [solveDetailSegment addTarget:self action:@selector(solveDetailSegmentChange:) forControlEvents:UIControlEventValueChanged];
                    [solveDetailSegment setTintColor:[self.timerTheme getTintColor]];
                    int detail = [[[Settings alloc] init] intForKey:@"solveDetailDisplay"];
                    [solveDetailSegment setSelectedSegmentIndex:detail];
                    cell.accessoryView = solveDetailSegment;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.detailTextLabel setText:@""];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    cell.textLabel.font = [Theme fontWithStyle:FontStyleRegular iphoneSize:18.0f ipadSize:18.0f];
    cell.detailTextLabel.font = [Theme fontWithStyle:FontStyleLight iphoneSize:13.0f ipadSize:13.0f];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [Utils getLocalizedStringFrom:@"Timing"];
        case 1:
            return [Utils getLocalizedStringFrom:@"Stats"];
        default:
            return @"";
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [Utils getLocalizedStringFrom:@"TimingFooter"];
        case 1:
            return [Utils getLocalizedStringFrom:@"StatsFooter"];
        default:
            return @"";
            break;
    }
}

- (IBAction)freezeTimeSliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    fTime.text = [NSString stringWithFormat:@"%0.1f s", (double)progressAsInt*0.01];
    if ([fTime.text isEqualToString:@"0.0 s"]) {
        fTime.text = [fTime.text stringByAppendingString:[Utils getLocalizedStringFrom:@"no other gesture"]];
    }
    [[[Settings alloc] init] saveWithInt:progressAsInt forKey:@"freezeTime"];
}

- (IBAction)wcaSwitchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [[[Settings alloc] init] saveWithBool:YES forKey:@"wcaInspection"];
    }else {
        [[[Settings alloc] init] saveWithBool:NO forKey:@"wcaInspection"];
    }
}

- (IBAction)solveOrderSegmentChange:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    [[[Settings alloc] init] saveWithInt:segCtrl.selectedSegmentIndex forKey:@"solveOrder"];
}

- (IBAction)solveDetailSegmentChange:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    [[[Settings alloc] init] saveWithInt:segCtrl.selectedSegmentIndex forKey:@"solveDetailDisplay"];
}

- (IBAction)knockSwitchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [[[Settings alloc] init] saveWithBool:YES forKey:@"knockToStop"];
        sensCell.userInteractionEnabled = YES;
        sensCell.textLabel.enabled = YES;
        ((UISwitch *)(sensCell.accessoryView)).enabled = YES;
    }else {
        [[[Settings alloc] init] saveWithBool:NO forKey:@"knockToStop"];
        sensCell.userInteractionEnabled = NO;
        sensCell.textLabel.enabled = NO;
        ((UISwitch *)(sensCell.accessoryView)).enabled = NO;
    }
}

- (IBAction)sensSliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    [[[Settings alloc] init] saveWithInt:progressAsInt forKey:@"knockSensitivity"];
}
@end
