//
//  CHTStatsViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/2/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTStatsViewController.h"
#import "CHTSession.h"
#import "CHTSessionManager.h"
#import "ZTimer-Swift.h"

@interface CHTStatsViewController ()
@property (nonatomic, strong) CHTSession *session;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) Theme *timerTheme;
@end

@implementation CHTStatsViewController
@synthesize session = _session;
@synthesize stats = _stats;
@synthesize timerTheme;
@synthesize popoverController;

- (CHTSession *) session {
    if (!_session) {
        _session = [[CHTSessionManager load] loadCurrentSession];
    }
    return _session;
}

- (NSMutableArray *) stats {
    if (!_stats) {
        _stats = [[NSMutableArray alloc] init];
    }
    return _stats;
}

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
    self.navigationItem.title = [Utils getLocalizedStringFrom:@"Stats"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sessions.png"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSessionView)];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    [self reload];
    self.timerTheme = [Theme getTimerTheme];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.stats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    OneStat *oneStats = [self.stats objectAtIndex:indexPath.row];
    //NSLog(@"Stat: %@, detail %@",oneStats.statType, oneStats.statValue);
    cell.textLabel.text = [Utils getLocalizedStringFrom:oneStats.statType];
    cell.detailTextLabel.text = oneStats.statValue;
    if (indexPath.row == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.detailTextLabel setTextColor:[self.timerTheme getTintColor]];
    [cell.textLabel setFont:[Theme fontWithStyle:FontStyleRegular iphoneSize:18.0f ipadSize:18.0f]];
    [cell.detailTextLabel setFont:[Theme fontWithStyle:FontStyleLight iphoneSize:18.0f ipadSize:18.0f]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.session.sessionName isEqualToString:@"main session"]) {
        return [Utils getLocalizedStringFrom:@"main session"];
    } else
        return self.session.sessionName;
}

- (void)presentSessionView
{
    if([self.popoverController isPopoverVisible])
    {
        NSLog(@"oh");
        [self reload];
        [self.popoverController dismissPopoverAnimated:YES];
        return;
    }
    SessionViewController *sessionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionViewController"];
    if ([Utils getDevice] == DevicePad) {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:sessionViewController];
        self.popoverController.delegate = self;
        [self.popoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [sessionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:sessionViewController animated:YES completion:NULL];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"dismiss");
    [self reload];
}

- (void)reload{
    self.session = [[CHTSessionManager load] loadCurrentSession];
    int numberOfSolves = self.session.numberOfSolves;
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d", self.session.numberOfSolves]];
    [self.stats removeAllObjects];
    OneStat *numOfSolves = [OneStat initWithTypeWithStatType:@"Number of solves: " statValue:[NSString stringWithFormat:@"%d", self.session.numberOfSolves]];
    [self.stats addObject:numOfSolves];
    
    if (numberOfSolves > 0) {
        OneStat *bestTime = [OneStat initWithTypeWithStatType:@"Best time: " statValue:[[self.session bestSolve] toString]];
        OneStat *worstTime = [OneStat initWithTypeWithStatType:@"Worst time: " statValue:[[self.session worstSolve] toString]];
        OneStat *sessionAvg = [OneStat initWithTypeWithStatType:@"Session Average: " statValue:[[self.session sessionAvg] toString]];
        OneStat *sessionMean = [OneStat initWithTypeWithStatType:@"Session Mean: " statValue:[[self.session sessionMean] toString]];
        [self.stats addObject:bestTime];
        [self.stats addObject:worstTime];
        [self.stats addObject:sessionAvg];
        [self.stats addObject:sessionMean];
        
        if (numberOfSolves >= 5) {
            OneStat *current5 = [OneStat initWithTypeWithStatType:@"Current average of 5: " statValue:[[self.session currentAvgOf:5] toString]];
            OneStat *best5 = [OneStat initWithTypeWithStatType:@"Best average of 5: " statValue:[[self.session bestAvgOf:5] toString]];
            [self.stats addObject:current5];
            [self.stats addObject:best5];
            
            if (numberOfSolves >= 12) {
                OneStat *current12 = [OneStat initWithTypeWithStatType:@"Current average of 12: " statValue:[[self.session currentAvgOf:12] toString]];
                OneStat *best12 = [OneStat initWithTypeWithStatType:@"Best average of 12: " statValue:[[self.session bestAvgOf:12] toString]];
                [self.stats addObject:current12];
                [self.stats addObject:best12];
                
                if (numberOfSolves >= 100) {
                    OneStat *current100 = [OneStat initWithTypeWithStatType:@"Current average of 100: " statValue:[[self.session currentAvgOf:100] toString]];
                    OneStat *best100 = [OneStat initWithTypeWithStatType:@"Best average of 100: " statValue:[[self.session bestAvgOf:100] toString]];
                    [self.stats addObject:current100];
                    [self.stats addObject:best100];
                }
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    int row = indexPath.row;
    if (row != 0) {
        if (row == 1 || row == 2) {
            SolveDetailViewController *solveDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SolveDetailViewController"];
            solveDetailViewController.hidesBottomBarWhenPushed = YES;
            switch (row) {
                case 1:
                    solveDetailViewController.solve = [self.session bestSolve];
                    break;
                case 2:
                    solveDetailViewController.solve = [self.session worstSolve];
                    break;
                default:
                    break;
            }
            [self.navigationController pushViewController:solveDetailViewController animated:YES];
        } else {
            StatDetailViewController *statDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StatDetailViewController"];
            statDetailViewController.hidesBottomBarWhenPushed = YES;
            statDetailViewController.session = self.session;
            statDetailViewController.stat = [self.stats objectAtIndex:row];
            statDetailViewController.row = row;
            switch (row) {
                case 3:
                    // session avg
                    statDetailViewController.statDetails = [self.session getAllSolves];
                    break;
                case 4:
                    // session mean
                    statDetailViewController.statDetails = [self.session getAllSolves];
                    break;
                case 5:
                    // current 5
                    statDetailViewController.statDetails = [self.session getCurrent:5];
                    break;
                case 6:
                    // best 5
                    statDetailViewController.statDetails = [self.session getBest:5];
                    break;
                case 7:
                    // current 12
                    statDetailViewController.statDetails = [self.session getCurrent:12];
                    break;
                case 8:
                    // best 12
                    statDetailViewController.statDetails = [self.session getBest:12];
                    break;
                case 9:
                    // current 100
                    statDetailViewController.statDetails = [self.session getCurrent:100];
                    break;
                case 10:
                    // best 100
                    statDetailViewController.statDetails = [self.session getBest:100];
                    break;
                default:
                    break;
            }
            [self.navigationController pushViewController:statDetailViewController animated:YES];
        }
    }
}

@end
