# QBKOverlaMenuView

It's basically an `UIView` object that tries to mimic the behavior of the floating control used by [http://sparrowmailapp.com/iphone.php](Sparrow for iOS). The control appears at the bottom right corner of the screen and it unfolds a menu whenever it's touched.

![Here you have the control working without the animation :-)](https://github.com/sendoa/QBKOverlayMenuView/raw/master/Docs/ejemplo.png)

**Please, take in consideration that I've coded this control as a mrere excercise so the options are not too customizable nor the code is intended to be *final***. It's currently designed to work in *portrait* orientation and it can be positioned either at the bottom or at the top of the screen. You can add an *offset* to avoid overlapping with `UITabBar`, `UINavigationBar` or similar controls.

To make it work, you only need to include the *.h* file wherever you intend to use the control and instantiate it this way —usually, from a *view controller*:

	QBKOverlayMenuView *qbkOverlayMenu = [[QBKOverlayMenuView alloc] initWithDelegate:self position:kQBKOverlayMenuViewPositionBottom];
    [qbkOverlayMenu setParentView:[self view]];
    
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton1.png"] index:0];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton2.png"] index:1];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton3.png"] index:2];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton4.png"] index:3];

The `setParentView:` method indicates the view where QBKOverlayMenuView will be positioned —usually, the main view of the view controller.

## Positioning

There are two constants available to indicate the positioning of the control:

* `kQBKOverlayMenuViewPositionBottom`: the control positions itself at bottom-right corner of the screen.
* `kQBKOverlayMenuViewPositionTop`: the control positions itself at top-right corner of the screen.

## Offset

If you need the control to appear displaced from the bounds of the container view —usually not to overlap  some kind of `UITabBar`, `UINavigationBar`…— you can do this:

	QBKOverlayMenuViewOffset offset;
    offset.bottomOffset = 44;
    offset.topOffset = 44;
    
	QBKOverlayMenuView *qbkOverlayMenu = [[QBKOverlayMenuView alloc] initWithDelegate:self position:kQBKOverlayMenuViewPositionBottom offset:offset];

## Adding buttons

You just have to make use of the `addButtonWithImage:index:` method. Then, when the button is touched, the message `overlayMenuView:didActivateAdditionalButtonWithIndex:` will be sent with the `index` of the touched button to the delegate specified in the *init* method.

	- (void)overlayMenuView:(QBKOverlayMenuView *)overlayMenuView didActivateAdditionalButtonWithIndex:(NSInteger)index
	{
    	NSLog(@"Button touched with index: %d", index);
	}

## Graphics

I've attached the graphics I created trying to mimic the aspect of those used by Sparrow. I've only created one additional icon instead of the whole set that Sparrow offers.