//
//  FWTWebViewController.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 09/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTWebViewController.h"

NSString * const kViewControllerTitle   =   @"About";
NSString * const kWebViewRequestURL     =   @"http://www.futureworkshops.com";

@interface FWTWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation FWTWebViewController

- (void)dealloc
{
    [self->_webView stopLoading];
    [self->_webView setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    [self _setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kWebViewRequestURL]]];
}

#pragma mark - Private methods
- (void)_setupNavigationBar
{
    self.title = kViewControllerTitle;
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_dismissScreen)];
    self.navigationItem.rightBarButtonItem = closeBarButtonItem;
}

- (void)_dismissScreen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy loading
- (UIWebView*)webView
{
    if (self->_webView == nil){
        self->_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    }
    
    if (self->_webView.superview == nil){
        [self.view addSubview:self->_webView];
    }
    
    return self->_webView;
}

@end
