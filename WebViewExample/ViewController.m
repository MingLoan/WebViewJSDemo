//
//  ViewController.m
//  WebViewExample
//
//  Created by Mingloan Chan on 5/30/18.
//  Copyright © 2018 com.mingloan. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toWKWebView:(UIButton *)sender {
    WKWebViewController *vc = (WKWebViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WKWebViewController"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end
