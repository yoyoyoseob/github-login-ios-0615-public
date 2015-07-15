//
//  FISViewController.m
//  github-repo-starring
//
//  Created by Joe Burgess on 5/12/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>
#import "FISConstants.h"

@interface FISViewController ()

@end

@implementation FISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Begin listening
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleApplicationOpenedForURL:) name:@"ApplicationOpenedForURL" object:nil];
}

-(NSString *)firstValueForQueryItemNamed:(NSString *)name inURL:(NSURL *)url
{
    // Method will pull out NSArray of key-value pairs and locate the key named "code"
    NSURLComponents *urlComps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:nil];
    NSArray *queryItems = urlComps.queryItems;
    
    for (NSURLQueryItem *queryItem in queryItems)
    {
        if ([queryItem.name isEqualToString:name])
        {
            return queryItem.value;
        }
    }
    return nil;
}

-(void)handleApplicationOpenedForURL:(NSNotification *)notification
{
    NSURL *url = notification.userInfo[@"url"];
    
    NSString *code = [self firstValueForQueryItemNamed:@"code" inURL:url]; // Need to exchange this code for access token
    
    NSURL *baseURL = [NSURL URLWithString:@"https://github.com/"];
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                    clientID:GITHUB_CLIENT_ID
                                      secret:GITHUB_CLIENT_SECRET];
    
    OAuth2Manager.useHTTPBasicAuthentication = NO;
    
    [OAuth2Manager authenticateUsingOAuthWithURLString:@"/login/oauth/access_token" code:code redirectURI:@"" success:^(AFOAuthCredential *credential) {
        
        NSLog(@"Success, your credential is: %@", credential);
        
        [AFOAuthCredential storeCredential:credential withIdentifier:@"githubauth"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSError *error) {
        NSLog(@"Error...%@", error.localizedDescription);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop listening since we won't be on this view controller anymore
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApplicationOpenedForURL" object:nil];
}

- (IBAction)logInButtonTapped:(id)sender
{
    // send user to Github URL
    // wait for response
    // get access token
    
    NSMutableString *authURLString = [@"https://github.com/login/oauth/authorize" mutableCopy];
    [authURLString appendString:@"?client_id=e0b7d8b7bf46020fa75d"];
    [authURLString appendString:@"&scope=public_repo"];
    [authURLString appendString:@"&redirect_uri=my-github-app://oauth"];
    
    NSURL *url = [NSURL URLWithString:authURLString];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
