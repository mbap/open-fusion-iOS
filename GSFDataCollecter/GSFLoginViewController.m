//
//  GSFLoginViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFLoginViewController.h"
#import "UYLPasswordManager.h"

@interface GSFLoginViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *apiIn;

@property (nonatomic) UIButton *later;

@end

@implementation GSFLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // add background image here.
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    UIImageView *background = nil;
    if (iOSDeviceScreenSize.height == 568) {
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-white5.png"]];
    } else {
        background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-white.png"]];
    }
    [self.view addSubview:background];
    self.apiIn = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/8, self.view.frame.size.width/3, self.view.frame.size.height/8)];
    self.apiIn.delegate = self;
    self.apiIn.font = [UIFont systemFontOfSize:14];
    self.apiIn.placeholder = @"ENTER API KEY";
    [self.view addSubview:self.apiIn];
    self.later = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height*7/8, self.view.frame.size.width/3, self.view.frame.size.height/8)];
    [self.later setTitle:@"Enter Later" forState:UIControlStateNormal];
    self.later.titleLabel.textColor = [UIColor lightGrayColor];
    [self.later addTarget:self action:@selector(popMe) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.later];
}

- (void)popMe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.apiIn resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UYLPasswordManager *pman = [UYLPasswordManager sharedInstance];
    [pman registerKey:self.apiIn.text forIdentifier:@"apikey"];
    [self popMe];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
