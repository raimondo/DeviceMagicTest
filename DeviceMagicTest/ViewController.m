//
//  ViewController.m
//  DeviceMagicTest
//
//  Created by Ray de Rose on 2017/05/17.
//  Copyright © 2017 Ray de Rose. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <objc/runtime.h>


static char * const kIndexPathAssociationKey = "RDR_indexPath";


#define valueURLSTR @"https://glacial-sands-39825.herokuapp.com/downloads/"
#define itemURLSTR @"https://glacial-sands-39825.herokuapp.com"

@interface ViewController ()<NSXMLParserDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSXMLParser *xmlParser;

@property (nonatomic, strong) NSMutableString *foundValue;

@property (nonatomic, strong) NSMutableArray *itemsArray;

@property (nonatomic, strong) NSMutableArray *phraseArray;

@property (nonatomic, strong) NSMutableDictionary *dictTempDataStorage;

@property (nonatomic, strong) NSString *currentElement;




@end

@implementation ViewController
{
    BOOL errorParsing;
    BOOL itemsParsed;
    UITableView *tableView;
    UIActivityIndicatorView *spinner;
}

-(void)loadView
{
    [super loadView];
    self.itemsArray = [[NSMutableArray alloc] init];
    self.phraseArray = [[NSMutableArray alloc] init];
    
    [self downloadItemsListWithURL:itemURLSTR];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-40) style:UITableViewStylePlain];
    tableView.rowHeight = 30;
    [tableView setAutoresizesSubviews:YES];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor blackColor];
    [self.view  addSubview:tableView];
    
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2-10, [UIScreen mainScreen].bounds.size.height/2-40)];
    [tableView addSubview:spinner];
    
    [spinner startAnimating];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemsArray.count;
}



- (UITableViewCell *)tableView:(UITableViewCell *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor greenColor];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    cell.textLabel.text = [_itemsArray objectAtIndex:indexPath.row];
    
    return cell;
}




-(void)downloadValueListWithURL:(NSString*)URLString cell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    objc_setAssociatedObject(cell,kIndexPathAssociationKey,indexPath,OBJC_ASSOCIATION_RETAIN);
    dispatch_async(queue, ^
                   {
                       NSURL *url = [NSURL URLWithString:URLString];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          NSLog(@"url %@",url);
                                          // Download the data.
                                          [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
                                              // Make sure that there is data.
                                              if (data != nil) {
                                                  self.xmlParser = [[NSXMLParser alloc] initWithData:data];
                                                  self.xmlParser.delegate = self;
                                                  
                                                  // Initialize the mutable string that we'll use during parsing.
                                                  self.foundValue = [[NSMutableString alloc] init];
                                                  
                                                  // Start parsing.
                                                  [self.xmlParser parse];
                                              }
                                          }];
                                          
                                      });
                   });
    
}



-(void)downloadItemsListWithURL:(NSString*)URLString{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^
                   {
                       NSURL *url = [NSURL URLWithString:URLString];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
                                              // Make sure that there is data.
                                              if (data != nil) {
                                                  self.xmlParser = [[NSXMLParser alloc] initWithData:data];
                                                  self.xmlParser.delegate = self;
                                                  
                                                  // Initialize the mutable string that we'll use during parsing.
                                                  self.foundValue = [[NSMutableString alloc] init];
                                                  
                                                  // Start parsing.
                                                  [self.xmlParser parse];
                                              }
                                          }];
                                          
                                      });
                   });
    
}



-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"item"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
    }
    self.currentElement = elementName;
}



-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if ([self.currentElement isEqualToString:@"item"]||[self.currentElement isEqualToString:@"value"]) {
        
        if (![string isEqualToString:@"\n"]) {
            [self.foundValue appendString:string];
        }
    }
}


-(NSString *)removeWhiteSpaceFromLine:(NSString *)line {
    NSString *newline = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return newline;
}



-(NSArray *)breakStringByNewlines:(NSString *)line {
    NSArray *myArray = [line componentsSeparatedByString:@"\n"];
    return myArray;
}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"item"])
    {
        NSArray * arrayWithspaces = [self breakStringByNewlines:self.foundValue];
        for (NSString * string in arrayWithspaces)
        {
            NSString * str =  [self removeWhiteSpaceFromLine:string];
            if (![str isEqualToString:@""])
            {
                [self.itemsArray addObject:str];
                
                NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_itemsArray.count-1 inSection:0];
                [indexPathsToDelete addObject:indexPath];
                [tableView insertRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
                
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                
                NSString *valueUrlStr = [valueURLSTR stringByAppendingString:str];
                
                [self downloadValueListWithURL:valueUrlStr cell:cell indexPath:[NSIndexPath indexPathForRow:_itemsArray.count-1 inSection:0]];
                
            }
        }
    }
    else
        if ([elementName isEqualToString:@"value"]){
            
            if (!itemsParsed) {
                [self.itemsArray removeAllObjects];
                [tableView reloadData];
                itemsParsed = YES;
            }
            
            [self.itemsArray addObject:[self.foundValue copy]];
            
            NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_itemsArray.count-1 inSection:0];
            [indexPathsToInsert addObject:indexPath];
            [tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
            
            
        }
    [self.foundValue setString:@""];
}



- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    if (errorParsing == NO )
    {
      
    } else {
        NSLog(@"Error occurred during XML processing");
    }
    [spinner stopAnimating];
}




-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // Initialize the neighbours data array.
    
}



-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]);
}





@end
