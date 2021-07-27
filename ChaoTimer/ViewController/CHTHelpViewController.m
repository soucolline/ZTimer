//
//  CHTHelpViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTHelpViewController.h"
#import "ChaoTimer-Swift.h"

@interface CHTHelpViewController ()
@property (nonatomic, strong) CHTTheme *timerTheme;

@end

@implementation CHTHelpViewController
@synthesize helps = _helps;
@synthesize helpsToDo = _helpsToDo;
@synthesize helpsImage = _helpsImage;
@synthesize timerTheme;

- (NSArray *)helps {
    if (!_helps) {
        _helps = [[NSArray alloc] initWithObjects:
                  [Utils getLocalizedStringFrom:@"1fhold"],
                  [Utils getLocalizedStringFrom:@"sr"],
                  [Utils getLocalizedStringFrom:@"sl"],
                  [Utils getLocalizedStringFrom:@"1f2t"],
                  [Utils getLocalizedStringFrom:@"2f2t"],
                  [Utils getLocalizedStringFrom:@"2fup"],
                  [Utils getLocalizedStringFrom:@"1fd"],
                  nil];
    }
    return _helps;
}

- (NSArray *)helpsToDo {
    if (!_helpsToDo) {
        _helpsToDo = [[NSArray alloc] initWithObjects:
                      [Utils getLocalizedStringFrom:@"1fholdto"],
                      [Utils getLocalizedStringFrom:@"srto"],
                      [Utils getLocalizedStringFrom:@"slto"],
                      [Utils getLocalizedStringFrom:@"1f2tto"],
                      [Utils getLocalizedStringFrom:@"2f2tto"],
                      [Utils getLocalizedStringFrom:@"2fupto"],
                      [Utils getLocalizedStringFrom:@"1fdto"],
                      nil];
    }
    return _helpsToDo;
}

- (NSArray *)helpsImage {
    if (!_helpsImage) {
        _helpsImage = [[NSArray alloc] initWithObjects:
                       [UIImage imageNamed:@"1hold.png"],
                       [UIImage imageNamed:@"1fr.png"],
                       [UIImage imageNamed:@"1fl.png"],
                       [UIImage imageNamed:@"1f2t.png"],
                       [UIImage imageNamed:@"2f2t.png"],
                       [UIImage imageNamed:@"2fup.png"],
                       [UIImage imageNamed:@"1fd.png"],
                       nil];
    }
    return _helpsImage;
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
    self.navigationItem.title = [Utils getLocalizedStringFrom:@"Gestures Help"];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    self.timerTheme = [CHTTheme getTimerTheme];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
    UIApplication *myApp = [UIApplication sharedApplication];
    if (self.timerTheme.myTheme == THEME_WHITE) {
        [myApp setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    } else {
        [myApp setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"shake");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.helps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.helpsToDo objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.helps objectAtIndex:indexPath.row];
    cell.imageView.image = [self.helpsImage objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:19.0f ipadSize:22.0f]];
    [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:14.0f ipadSize:15.0f]];
    
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([Utils getDevice] == ZDevicePhone) {
        return 60;
    } else {
        return 80;
    }
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
