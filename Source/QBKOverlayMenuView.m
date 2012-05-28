//
//  QBKOverlayMenuView.m
//  QBKOverlayMenuView
//
//  Created by Sendoa Portuondo on 11/05/12.
//  Copyright (c) 2012 Qbikode Solutions, S.L. All rights reserved.
//

#import "QBKOverlayMenuView.h"

#define QBK_OVERLAY_MENU_MAX_ADDITIONAL_BUTTONS 4               // sin usar por el momento
#define QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_WIDTH 22            // anchura del frame de los botones adicionales
#define QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_HEIGHT 22           // altura del frame de los botones adicionales
#define QBK_OVERLAY_MENU_CONTENT_VIEW_PADDING 5                 // pading a los lados del contenedor de botones adicionales
#define QBK_OVERLAY_MENU_VIEW_WIDTH 44                          // anchura del control cuando aparece como un botón flotante
#define QBK_OVERLAY_MENU_VIEW_HEIGHT 44                         // altura del control cuando aparece como un botón flotante
#define QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_WIDTH 28              // anchura del botón flotante
#define QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_HEIGHT 28             // altura del botón flotante
#define QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_Y_OFFSET 1            // desplazamiento vertical del botón principal para que ajustar el centrado vertical
#define QBK_OVERLAY_MENU_VIEW_ADDITIONAL_BUTTONS_Y_OFFSET 1     // desplazamiento vertical de los botones adicionales para que ajustar el centrado vertical
#define QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS 5              // márgenes horizontales del control con respecto a los bordes de la vista contenedora
#define QBK_OVERLAY_MENU_VIEW_TOP_MARGIN 10                     // margen superior del control con respecto a los bordes de la vista contenedora
#define QBK_OVERLAY_MENU_VIEW_BOTTOM_MARGIN 10                  // margen inferior del control con respecto a los bordes de la vista contenedora
#define QBK_OVERLAY_MENU_VIEW_ANIMATION_DURATION 0.2            // duración de la animación de despliegue al pulsar el botón principal

// Notificaciones
NSString *QBKOverlayMenuDidActivateAdditionalButtonNotification = @"QBKOverlayMenuDidActivateAdditionalButtonNotification";
NSString *QBKOverlayMenuDidPerformUnfoldActionNotification = @"QBKOverlayMenuDidPerformUnfoldActionNotification";
NSString *QBKOverlayMenuDidPerformFoldActionNotification = @"QBKOverlayMenuDidPerformFoldActionNotification";

@interface QBKOverlayMenuView ()

- (void)setupMainButton;
- (void)setupContentView;
- (void)mainButtonPressed;
- (void)additionalButtonPressed:(id)sender;
- (void)unfoldWithAnimationDuration:(float)duration;
- (void)foldWithAnimationDuration:(float)duration;
- (CGRect)createFoldedMainFrameForPosition:(QBKOverlaMenuViewPosition)position;
- (CGRect)createUnfoldedMainFrameForPosition:(QBKOverlaMenuViewPosition)position;
- (CGRect)createFoldedContentViewFrameForPosition:(QBKOverlaMenuViewPosition)position;
- (CGRect)createUnfoldedContentViewFrameForPosition:(QBKOverlaMenuViewPosition)position;
@end

@implementation QBKOverlayMenuView
@synthesize parentView = _parentView;
@synthesize delegate = _delegate;
@synthesize position = _position;
@synthesize unfolded = _unfolded;
@synthesize offset = _offset;
@synthesize contentView = _contentView;
@synthesize additionalButtons = _additionalButtons;

- (id)initWithDelegate:(id <QBKOverlayMenuViewDelegate>)delegate position:(QBKOverlaMenuViewPosition)position offset:(QBKOverlayMenuViewOffset)offset
{
    if (delegate && [delegate conformsToProtocol:@protocol(QBKOverlayMenuViewDelegate)]) {
        _delegate = delegate;
        
        _position = position;
        _offset = offset;
        _unfolded = NO;
        
        return (self = [self initWithFrame:CGRectZero]);
    }
    
    return nil;
}

- (id)initWithDelegate:(id<QBKOverlayMenuViewDelegate>)delegate position:(QBKOverlaMenuViewPosition)position
{
    QBKOverlayMenuViewOffset offset = {0.0f,0.0f};
    return [self initWithDelegate:delegate position:position offset:offset];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        if (!_position) _position = kQBKOverlayMenuViewPositionDefault;
        _unfolded = NO;
    }
    
    return self;
}

#pragma mark - Agregamos el control a la vista "del usuario"
- (void)setParentView:(UIView *)view
{
    _parentView = view;
    
    // Configuración el frame
    CGRect frame = [self createFoldedMainFrameForPosition:_position];
    [self setFrame:frame];
    [self setClipsToBounds:YES];
    
    // Configuración del botón principal
    [self setupMainButton];
    [self addSubview:_mainButton];
    
    // Configuración de la imagen de fondo principal (solo visible con el menú desplegado)
    _mainBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"]];
    [self addSubview:_mainBackgroundImageView];
    [self sendSubviewToBack:_mainBackgroundImageView];
    [_mainBackgroundImageView setAlpha:0.0f];
    
    // Configuración de contenedor de botones adicionales
    [self setupContentView];
    [self addSubview:_contentView];
    
    // Añadimos el control a la vista indicada
    [view addSubview:self];
}

#pragma mark - Métodos de acción
- (void)mainButtonPressed
{
    // Ejecutamos las animaciones de despliegue y repliegue
    if (!_unfolded) {
        [self unfoldWithAnimationDuration:QBK_OVERLAY_MENU_VIEW_ANIMATION_DURATION];
    } else {
        [self foldWithAnimationDuration:QBK_OVERLAY_MENU_VIEW_ANIMATION_DURATION];
    }
}

- (void)additionalButtonPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(overlayMenuView:didActivateAdditionalButtonWithIndex:)]) {
        [_delegate overlayMenuView:self didActivateAdditionalButtonWithIndex:[_additionalButtons indexOfObject:sender]];
    }
    
    // Notificación con información adjunta (index del botón pulsado)
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[_additionalButtons indexOfObject:sender]] 
                                                     forKey:QBKButtonIndexKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:QBKOverlayMenuDidActivateAdditionalButtonNotification 
                                                        object:self 
                                                      userInfo:info];
}

#pragma mark - Rutinas de despliegue y repliegue
- (void)unfoldWithAnimationDuration:(float)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect newFrame = [self createUnfoldedMainFrameForPosition:_position];
        [self setFrame:newFrame];
        [_mainBackgroundImageView setAlpha:.9f];
        
        CGAffineTransform xform = CGAffineTransformMakeRotation(-M_PI_2);
        [_mainButton setTransform:xform];
        
        _unfolded = YES;
    } completion:^(BOOL finished) {
        [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-left.png"] forState:UIControlStateNormal];
        
        // Aviso al delegate
        if (_delegate && [_delegate respondsToSelector:@selector(didPerformUnfoldActionInOverlayMenuView:)]) {
            [_delegate didPerformUnfoldActionInOverlayMenuView:self];
        }
        
        // Notificación
        [[NSNotificationCenter defaultCenter] postNotificationName:QBKOverlayMenuDidPerformUnfoldActionNotification 
                                                            object:self 
                                                          userInfo:nil];
    }];
}

- (void)foldWithAnimationDuration:(float)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect newFrame = [self createFoldedMainFrameForPosition:_position];
        [self setFrame:newFrame];
        [_contentView setFrame:[self createFoldedContentViewFrameForPosition:_position]];
        [_mainBackgroundImageView setAlpha:0.0f];
        
        CGAffineTransform xform = CGAffineTransformMakeRotation(0);
        [_mainButton setTransform:xform];
        
        _unfolded = NO;
    } completion:^(BOOL finished) {
        [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-up.png"] forState:UIControlStateNormal];
        
        // Aviso al delegate
        if (_delegate && [_delegate respondsToSelector:@selector(didPerformFoldActionInOverlayMenuView:)]) {
            [_delegate didPerformFoldActionInOverlayMenuView:self];
        }
        
        // Notificación
        [[NSNotificationCenter defaultCenter] postNotificationName:QBKOverlayMenuDidPerformFoldActionNotification
                                                            object:self 
                                                          userInfo:nil];
    }];
}

#pragma mark - Métodos "convenient"
- (void)addButtonWithImage:(UIImage *)image index:(NSInteger)index
{
    if (!_additionalButtons) _additionalButtons = [[NSMutableArray alloc] init];
    
    // Calculamos la posición de los botones en el contentView
    CGFloat tamHuecoBoton = (320 - (QBK_OVERLAY_MENU_VIEW_WIDTH + QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS * 2 + QBK_OVERLAY_MENU_CONTENT_VIEW_PADDING * 2 )) / QBK_OVERLAY_MENU_MAX_ADDITIONAL_BUTTONS;
    
    CGFloat posXBotonCentrado = (tamHuecoBoton - QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_WIDTH) / 2;
    CGFloat posYBotonCentrado = (([_contentView bounds].size.height - QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_HEIGHT) / 2) - QBK_OVERLAY_MENU_VIEW_ADDITIONAL_BUTTONS_Y_OFFSET;
    
    CGFloat posXBoton = (QBK_OVERLAY_MENU_MAX_ADDITIONAL_BUTTONS - ([_additionalButtons count] + 1)) * tamHuecoBoton + posXBotonCentrado;
    
    // Configuramos el botón
    UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake(posXBoton, posYBotonCentrado, QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_WIDTH, QBK_OVERLAY_MENU_ADDITIONAL_BUTTONS_HEIGHT)];
    [newButton setBackgroundImage:image forState:UIControlStateNormal];
    [newButton setAutoresizingMask:UIViewAutoresizingNone];
    [newButton addTarget:self action:@selector(additionalButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Registramos el nuevo botón
    [_additionalButtons insertObject:newButton atIndex:index];
    
    // Añadimos el botón al contentView
    [_contentView addSubview:newButton];
}

- (void)setupMainButton
{
    // Calculamos posición centrada del botón
    CGFloat x = (QBK_OVERLAY_MENU_VIEW_WIDTH - QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_WIDTH) / 2;
    CGFloat y = (QBK_OVERLAY_MENU_VIEW_HEIGHT - QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_HEIGHT) / 2 - QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_Y_OFFSET;
    
    _mainButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_WIDTH, QBK_OVERLAY_MENU_VIEW_MAIN_BUTTON_HEIGHT)];
    [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-up.png"] forState:UIControlStateNormal];
    [_mainButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [_mainButton addTarget:self action:@selector(mainButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupContentView
{
    _contentView = [[UIView alloc] initWithFrame:[self createFoldedContentViewFrameForPosition:_position]];
    [_contentView setClipsToBounds:YES];
    [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

// Configuración del frame del contentView cuando está REPLEGADO
- (CGRect)createFoldedContentViewFrameForPosition:(QBKOverlaMenuViewPosition)position
{
    CGRect frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, 0, QBK_OVERLAY_MENU_VIEW_HEIGHT);
    
    return frame;
}

// Configuración del frame del contentView cuando está DESPLEGADO
- (CGRect)createUnfoldedContentViewFrameForPosition:(QBKOverlaMenuViewPosition)position
{
    CGRect frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width - QBK_OVERLAY_MENU_VIEW_WIDTH, QBK_OVERLAY_MENU_VIEW_HEIGHT);
    
    return frame;
}

// Configuración del frame de la vista principal cuando el control está REPLEGADO
- (CGRect)createFoldedMainFrameForPosition:(QBKOverlaMenuViewPosition)position
{
    CGRect frame;
    
    switch (_position) {
        case kQBKOverlayMenuViewPositionBottom:
            frame = CGRectMake([_parentView bounds].size.width - (QBK_OVERLAY_MENU_VIEW_WIDTH + QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS), [_parentView bounds].size.height - (QBK_OVERLAY_MENU_VIEW_HEIGHT + QBK_OVERLAY_MENU_VIEW_BOTTOM_MARGIN + _offset.bottomOffset), QBK_OVERLAY_MENU_VIEW_WIDTH, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
        case kQBKOverlayMenuViewPositionTop:
            frame = CGRectMake([_parentView bounds].size.width - (QBK_OVERLAY_MENU_VIEW_WIDTH + QBK_OVERLAY_MENU_VIEW_TOP_MARGIN), QBK_OVERLAY_MENU_VIEW_TOP_MARGIN + _offset.topOffset, QBK_OVERLAY_MENU_VIEW_WIDTH, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
        default:
            frame = CGRectMake([_parentView bounds].size.width - (QBK_OVERLAY_MENU_VIEW_WIDTH + QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS), [_parentView bounds].size.height - (QBK_OVERLAY_MENU_VIEW_HEIGHT + QBK_OVERLAY_MENU_VIEW_BOTTOM_MARGIN + _offset.bottomOffset), QBK_OVERLAY_MENU_VIEW_WIDTH, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
    }
    
    return frame;
}

// Configuración del frame de la vista principal cuando el control está DESPLEGADO
- (CGRect)createUnfoldedMainFrameForPosition:(QBKOverlaMenuViewPosition)position
{
    CGRect frame;
    
    switch (_position) {
        case kQBKOverlayMenuViewPositionBottom:
            frame = CGRectMake(QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS, [[self superview] bounds].size.height - (QBK_OVERLAY_MENU_VIEW_HEIGHT + QBK_OVERLAY_MENU_VIEW_BOTTOM_MARGIN + _offset.bottomOffset), [[self superview] bounds].size.width - QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS * 2, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
        case kQBKOverlayMenuViewPositionTop:
            frame = CGRectMake(QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS, QBK_OVERLAY_MENU_VIEW_TOP_MARGIN + _offset.topOffset, [[self superview] bounds].size.width - QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS * 2, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
        default:
            frame = CGRectMake(QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS, [[self superview] bounds].size.height - (QBK_OVERLAY_MENU_VIEW_HEIGHT + QBK_OVERLAY_MENU_VIEW_BOTTOM_MARGIN + _offset.bottomOffset), [[self superview] bounds].size.width - QBK_OVERLAY_MENU_VIEW_HORIZONTAL_MARGINS * 2, QBK_OVERLAY_MENU_VIEW_HEIGHT);
            break;
    }
    
    return frame;
}

@end
