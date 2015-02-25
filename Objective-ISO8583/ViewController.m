//
//  ViewController.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)jorgeTapiaAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://jorgetapia.net"]];
}

- (IBAction)githubAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mordoskull/Objective-ISO8583"]];
}

@end
