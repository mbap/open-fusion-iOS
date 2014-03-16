//
//  GSFLoginViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFLoginViewController.h"

@interface GSFLoginViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *apiIn;

@end

@implementation GSFLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white1.png"]];
    [self.view addSubview:background];
    self.apiIn = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/8, self.view.frame.size.width/3, self.view.frame.size.height/8)];
    self.apiIn.delegate = self;
    self.apiIn.font = [UIFont systemFontOfSize:14];
    self.apiIn.placeholder = @"ENTER API KEY";
    [self.view addSubview:self.apiIn];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSData *apikey = [[NSData alloc] initWithData:[self.apiIn.text dataUsingEncoding:NSUTF8StringEncoding]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
