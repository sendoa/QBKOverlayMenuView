//
//  QBKOverlayMenuView.h
//  QBKOverlayMenuView
//
//  Created by Sendoa Portuondo on 11/05/12.
//  Copyright (c) 2012 Qbikode Solutions, S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kQBKOverlayMenuViewPositionDefault,
    kQBKOverlayMenuViewPositionTop,
    kQBKOverlayMenuViewPositionBottom
} QBKOverlaMenuViewPosition;

struct QBKOverlayMenuViewOffset {
    CGFloat bottomOffset;
    CGFloat topOffset;
};
typedef struct QBKOverlayMenuViewOffset QBKOverlayMenuViewOffset;

@protocol QBKOverlayMenuViewDelegate;

@interface QBKOverlayMenuView : UIView
{
    UIButton *_mainButton;                  // referencia al botón principal. Es el encargado de iniciar el despliegue o repliegue del control
    UIImageView *_mainBackgroundImageView;  // imagen de fondo principal. Solo se muestra con el control desplegado.
}

@property (nonatomic, weak, readonly) id<QBKOverlayMenuViewDelegate> delegate;
@property (nonatomic, weak) UIView *parentView;                                 // la vista que contendrá a este control
@property (nonatomic, readonly) QBKOverlaMenuViewPosition position;
@property (nonatomic, readonly) BOOL unfolded;                                  // el control está desplegado o no?
@property (nonatomic, readonly) QBKOverlayMenuViewOffset offset;                // desplazamiento con respecto al borde inferior/superior del parentView
@property (nonatomic, strong, readonly) UIView *contentView;                    // contenedor de los botones adicionales
@property (nonatomic, strong, readonly) NSMutableArray *additionalButtons;      // colección de botones adicionales agregados por el usuario

- (id)initWithDelegate:(id <QBKOverlayMenuViewDelegate>)delegate position:(QBKOverlaMenuViewPosition)position offset:(QBKOverlayMenuViewOffset)offset;
- (id)initWithDelegate:(id <QBKOverlayMenuViewDelegate>)delegate position:(QBKOverlaMenuViewPosition)position;
- (void)addButtonWithImage:(UIImage *)image index:(NSInteger)index;
@end

@protocol QBKOverlayMenuViewDelegate <NSObject>

@optional
- (void)overlayMenuView:(QBKOverlayMenuView *)overlayMenuView didActivateAdditionalButtonWithIndex:(NSInteger)index;
- (void)didPerformUnfoldActionInOverlayMenuView:(QBKOverlayMenuView *)overlaymenuView;
- (void)didPerformFoldActionInOverlayMenuView:(QBKOverlayMenuView *)overlaymenuView;

@end

// Notificaciones
extern NSString *QBKOverlayMenuDidPerformUnfoldActionNotification;
extern NSString *QBKOverlayMenuDidPerformFoldActionNotification;

// Esta notitificación lleva una clave para el userInfo con el nombre "QBKButtonIndex" que albergará el index del botón pulsado (NSInteger)
#define QBKButtonIndexKey @"QBKButtonIndex"
extern NSString *QBKOverlayMenuDidActivateAdditionalButtonNotification;
