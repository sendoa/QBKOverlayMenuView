//
//  QBKRootViewController.m
//  QBKOverlayMenuView
//
//  Created by Sendoa Portuondo on 11/05/12.
//  Copyright (c) 2012 Qbikode Solutions, S.L. All rights reserved.
//

#import "QBKRootViewController.h"
#import "QBKOverlayMenuView.h"

@interface QBKRootViewController ()

@end

@implementation QBKRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QBKOverlayMenuViewOffset offset;
    offset.bottomOffset = 44;
    
    _qbkOverlayMenu = [[QBKOverlayMenuView alloc] initWithDelegate:self position:kQBKOverlayMenuViewPositionBottom offset:offset];
    [_qbkOverlayMenu setParentView:[self view]];
    
    [_qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"rw-button.png"] index:0];
    [_qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"rw-button.png"] index:1];
    [_qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"rw-button.png"] index:2];
    [_qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"rw-button.png"] index:3];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Métodos de QBKOverlayMenuViewDelegate
- (void)overlayMenuView:(QBKOverlayMenuView *)overlayMenuView didActivateAdditionalButtonWithIndex:(NSInteger)index
{
    NSLog(@"Botón pulsado con índice: %d", index);
}

- (void)didPerformUnfoldActionInOverlayMenuView:(QBKOverlayMenuView *)overlaymenuView
{
    NSLog(@"Menú DESPLEGADO");
}

- (void)didPerformFoldActionInOverlayMenuView:(QBKOverlayMenuView *)overlaymenuView
{
    NSLog(@"Menú REPLEGADO");
}

@end
