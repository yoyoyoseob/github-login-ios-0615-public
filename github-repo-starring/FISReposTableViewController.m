//
//  FISReposTableViewController.m
//
//
//  Created by Joe Burgess on 5/5/14.
//
//

#import "FISReposTableViewController.h"
#import "FISReposDataStore.h"
#import "FISGithubRepository.h"
#import "FISGithubAPIClient.h"
#import "FISViewController.h"
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>

@interface FISReposTableViewController ()
@property (strong, nonatomic) FISReposDataStore *dataStore;
@end

@implementation FISReposTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@",[AFOAuthCredential retrieveCredentialWithIdentifier:@"githubauth"]);
    
    if (![AFOAuthCredential retrieveCredentialWithIdentifier:@"githubauth"])
    {
        FISViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FISViewController"];
        modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:modalViewController animated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizeIfNeeded) name:@"InvalidToken" object:nil];
}

- (void)authorizeIfNeeded
{
    
    [AFOAuthCredential deleteCredentialWithIdentifier:@"githubauth"];
    FISViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FISViewController"];
    modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.accessibilityLabel=@"Repo Table View";
    self.tableView.accessibilityIdentifier=@"Repo Table View";
    
    self.tableView.accessibilityIdentifier = @"Repo Table View";
    self.tableView.accessibilityLabel=@"Repo Table View";
    self.dataStore = [FISReposDataStore sharedDataStore];
    [self.dataStore getRepositoriesWithCompletion:^(BOOL success) {
        [self.tableView reloadData];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"InvalidToken" object:nil];
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
    return [self.dataStore.repositories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    
    FISGithubRepository *repo = self.dataStore.repositories[indexPath.row];
    cell.textLabel.text = repo.fullName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FISGithubRepository *repo = self.dataStore.repositories[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataStore toggleStarForRepo:repo CompletionBlock:^(BOOL starred) {
        if (starred) {
            NSString *message = [NSString stringWithFormat:@"You just starred %@", repo.fullName];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Repo Starred"  message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else
        {
            NSString *message = [NSString stringWithFormat:@"You just unstarred %@", repo.fullName];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Repo Unstarred"  message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorizeIfNeeded) name:@"InvalidToken" object:nil];
}

@end
