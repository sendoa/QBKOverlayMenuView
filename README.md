# QBKOverlaMenuView

Se trata de un objeto `UIView` que trata de imitar el funcionamiento del control flotante que utiliza la aplicación [http://sparrowmailapp.com/iphone.php](Sparrow para iOS). El control aparece flotando en la parte inferior derecha de la pantalla y al ser pulsado despliega un menú de iconos hacia la izquierda.

![El control en funcionamieto aunque sin la animación :-)](https://github.com/sendoa/QBKOverlayMenuView/raw/master/Docs/ejemplo.png)

He programado este control **como un mero ejercicio**, así que no pretendía que fuese muy personalizable ni excesivamente flexible. Actualmente está diseñado para funcionar en posición *portrait* y se puede colocar tanto en la parte inferior derecha como en la parte superior de una vista —normalmente la vista principal. Además acepta un *offset* para permitir que no se solape con un posible `UITabBar`, `UINavigationBar` o similares.

Su funcionamiento es muy sencillo. Tan solo hay que incluir el archivo *.h* donde nos interese utilizar el control y posteriormente instanciar e inicializarlo de la siguiente forma —suponiendo que estemos en un *view controller*:

	QBKOverlayMenuView *qbkOverlayMenu = [[QBKOverlayMenuView alloc] initWithDelegate:self position:kQBKOverlayMenuViewPositionBottom];
    [qbkOverlayMenu setParentView:[self view]];
    
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton1.png"] index:0];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton2.png"] index:1];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton3.png"] index:2];
    [qbkOverlayMenu addButtonWithImage:[UIImage imageNamed:@"boton4.png"] index:3];

El método `setParentView:` indica cuál será el `UIView` en el que se alojará QBKOverlayMenuView. Lo normal es que sea la vista principal del view controller.

## Posicionamiento

Hay disponible dos constantes para indicar el posicionamiento del control:

* `kQBKOverlayMenuViewPositionBottom`: el control se sitúa abajo a la derecha.
* `kQBKOverlayMenuViewPositionTop`: el control se sitúa arriba a la derecha.

## Desplazamiento / Offset

Si necesitamos que el control aparezca desplazado con respecto a los límites —bounds— de la vista contenedora podemos hacer lo siguiente:

	QBKOverlayMenuViewOffset offset;
    offset.bottomOffset = 44;
    offset.topOffset = 44;
    
	QBKOverlayMenuView *qbkOverlayMenu = [[QBKOverlayMenuView alloc] initWithDelegate:self position:kQBKOverlayMenuViewPositionBottom offset:offset];

## Agregar botones

Tan solo tenemos que utilizar el método `addButtonWithImage:index:`. Posteriormente, cuando el botón sea pulsado, se mandará el mensaje `didPressAdditionalButtonWithIndex:` con el `index` del botón pulsado al delegado indicado en el inicializador:

	- (void)didPressAdditionalButtonWithIndex:(NSInteger)index
	{
    	NSLog(@"Botón pulsado con índice: %d", index);
	}

## Gráficos

Adjunto los gráficos que he creado tratando de imitar el aspecto de los utilizados por Sparrow, aunque en mi caso sólo he creado un icono de botón adicional en lugar del juego completo de iconos que ofrece Sparrow.