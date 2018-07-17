//
//  WKWebViewController.m
//  WebViewExample
//
//  Created by Mingloan Chan on 5/30/18.
//  Copyright © 2018 com.mingloan. All rights reserved.
//

@import WebKit;
@import LocalAuthentication;
#import "WKWebViewController.h"

@interface WKWebViewController () <WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong, nonnull) WKWebView *webView;
@property (nonatomic, assign) NSInteger replyTime;
    
@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.replyTime = 0;
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"login"];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds configuration:config];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    [NSLayoutConstraint activateConstraints:@[[self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [self.webView.topAnchor constraintEqualToAnchor:self.toolbar.bottomAnchor]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"html"];
    if (path) {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

// replace - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // NSLog(@"%@", navigationAction);
    
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated:
        break;
        case WKNavigationTypeOther:
        if ([navigationAction.request.URL.scheme isEqualToString:@"hook"]) {
            NSLog(@"hook call");
            NSLog(@"%@", navigationAction.request.URL);
            
            self.replyTime += 1;
            
            decisionHandler(WKNavigationActionPolicyCancel);
            
            NSString *js = [NSString stringWithFormat:@"replyHook(%ld)", (long)self.replyTime];
            
            // replace -stringByEvaluatingJavaScriptFromString: from UIWebView
            [webView evaluateJavaScript:js completionHandler:^(id _Nullable message, NSError * _Nullable error) {
                
            }];
            
            return;
        }
        default:
        break;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
//
//}

- (void)webViewDidClose:(WKWebView *)webView {
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"login"]) {
        if ([message.body isEqualToString:@"JS needs authentication"]) {
            
            __weak WKWebViewController *weakSelf = self;
            [self performBiometricAuthenticationWithCompletionBlock:^(BOOL success) {
                NSString *js = @"onFingerprintAuthenticationResult(true)";
                if (!success) {
                    js = @"onFingerprintAuthenticationResult(false)";
                }
                
                // replace -stringByEvaluatingJavaScriptFromString: from UIWebView
                [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable message, NSError * _Nullable error) {
                    
                }];
            }];
        }
    }
}

#pragma mark - Local Authentication

- (void) performBiometricAuthenticationWithCompletionBlock:(void (^) (BOOL)) completion {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Authenticating...";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(success);
                                });
                            }];
    } else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO);
        });
    }
}

@end
