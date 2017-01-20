//
//  ViewController.m
//  MapsAndGestureRecognizers
//
//  Created by Nicolás Hechim on 15/1/17.
//  Copyright © 2017 Nicolás Hechim. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Monumento.h"
#import "SoundManager/SoundManager.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *monumentos;
    Monumento *monumento;
    UILongPressGestureRecognizer *longPress;
    UISwipeGestureRecognizer *swipe;
    CLLocationCoordinate2D touchMapCoordinate;
    NSString *labelDistanciaKm;
    int puntajeAcumulado;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initJuego];
}

- (void) initJuego
{
    //Corner radius para los botones y View Info
    _viewInfo.layer.cornerRadius = 10;
    _buttonNext.layer.cornerRadius = 10;
    _buttonValida.layer.cornerRadius = 10;
    
    _viewInfo.layer.masksToBounds = YES;
    _buttonNext.layer.masksToBounds = YES;
    _buttonValida.layer.masksToBounds = YES;
    
    //Inicializo los valores las etiquetas de la view
    puntajeAcumulado = 0;
    [_etiquetaDistancia setText:[NSString stringWithFormat:@"%d", puntajeAcumulado]];
    [_etiquetaCentralSuperior setText:@"Sitúa el monumento en el mapa"];
    [_etiquetaCentralInferior setText:@""];
    [_etiquetaCentralInferior setHidden:NO];
    
    //Desactivo los botones
    [_buttonValida setEnabled:NO];
    [_buttonValida setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_buttonValida setBackgroundColor:[UIColor lightGrayColor]];
    
    [_buttonNext setEnabled:NO];
    [_buttonNext setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_buttonNext setBackgroundColor:[UIColor lightGrayColor]];
    
    //Type maps
    [_mapaMonumento setMapType:MKMapTypeSatelliteFlyover];
    [_mapaMundo setMapType:MKMapTypeStandard];
    
    //Resize maps
    [_mapaMonumento setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [_mapaMundo setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    
    //Config maps
    [_mapaMonumento setShowsBuildings:YES];
    [_mapaMonumento setPitchEnabled:YES];
    [_mapaMonumento setRotateEnabled:YES];
    [_mapaMonumento setZoomEnabled:NO];
    [_mapaMonumento setScrollEnabled:NO];
    
    [_mapaMundo setShowsBuildings:YES];
    [_mapaMundo setScrollEnabled:YES];
    [_mapaMundo setZoomEnabled:NO];
    
    //Config cameras
    [_mapaMundo.camera setCenterCoordinate: CLLocationCoordinate2DMake(41.4028931, 2.1719068)];
    [_mapaMundo.camera setAltitude: 9000000.0f];
    
    //Delegate maps
    [_mapaMonumento setDelegate:self];
    [_mapaMundo setDelegate:self];
    
    //Config SoundManager
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    [self initMonumentos];
    [self mostrarMonumento];
}

- (void) setLongPressGesture:(MKMapView *)mapView
{
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    
    [longPress setNumberOfTouchesRequired:1];
    [longPress setMinimumPressDuration:1];
    [longPress setAllowableMovement:100];
    
    [mapView addGestureRecognizer:longPress];
}

- (void) setSwipeGesture
{
    swipe = [[UISwipeGestureRecognizer alloc]
               initWithTarget:self
               action:@selector(siguienteMonumento:)];
    
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipe setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:swipe];
}

- (void) mostrarMonumento
{
    [self selectRandomMonumento];
    
    if(monumento != nil)
    {
        //Seteo Gesture Recognizer LongPress
        [self setLongPressGesture:_mapaMundo];
        
        //Seteo la región para el monumento
        [self setRegion:CLLocationCoordinate2DMake(monumento.lat, monumento.lng)
              distancia: monumento.distancia
                 enMapa: _mapaMonumento];
        
        //Configuro la cámara del monumento
        [_mapaMonumento.camera setPitch:monumento.pitch];
        [_mapaMonumento.camera setHeading:monumento.heading];
        
        //Actualizo los datos de la view
        [_etiquetaCentralSuperior setText:@"Sitúa el monumento en el mapa"];
        [_etiquetaCentralInferior setText:@""];
        [_etiquetaCentralInferior setHidden:NO];
    }
    else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Fin del juego"
                                     message:@"¿Quieres jugar otra vez?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"¡Sí!"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self initJuego];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No, gracias"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) selectRandomMonumento
{
    if(monumentos.count > 0) {
        int ramdomIndex = arc4random() % monumentos.count;
        monumento = monumentos[ramdomIndex];
        [monumentos removeObjectAtIndex:ramdomIndex];
    }
    else
    {
        monumento = nil;
    }
}

- (void) setRegion:(CLLocationCoordinate2D)centro
         distancia:(int)distancia
            enMapa:(MKMapView*)mapa {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centro, distancia, distancia);
    [mapa setRegion:region];
}

- (void) handleLongPressGesture:(UITapGestureRecognizer*)paramGestureRecognizer
{
    if (paramGestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    //Si hay una anotación previa, la elimino
    if(_mapaMundo.annotations != nil)
        [_mapaMundo removeAnnotations: _mapaMundo.annotations];
    
    //Tomo el punto que eligió el usuario
    CGPoint touchPoint = [paramGestureRecognizer locationInView:_mapaMundo];
    touchMapCoordinate = [_mapaMundo convertPoint:touchPoint
                             toCoordinateFromView:_mapaMundo];
    
    //Muestro anotación en el punto
    [self mostrarAnotacion:touchMapCoordinate title:nil subtitle:nil];
}

- (IBAction)validarJuego:(id)sender
{
    //Permitimos validar el juego si el usuario tiene elegido un punto en el mapa
    if(_mapaMundo.annotations.count == 1)
    {
        //Lugar donde el jugador ha puesto la anotación
        touchMapCoordinate = _mapaMundo.annotations.firstObject.coordinate;
        CLLocationCoordinate2D desdeCoordinate2D =
            CLLocationCoordinate2DMake(touchMapCoordinate.latitude,
                                       touchMapCoordinate.longitude);
        CLLocation *desdeLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude
                                                               longitude:touchMapCoordinate.longitude];
        
        //Ubicación del monumento en juego
        CLLocationCoordinate2D hastaCoordinate2D = CLLocationCoordinate2DMake(monumento.lat,
                                                                              monumento.lng);
        CLLocation *hastaLocation = [[CLLocation alloc] initWithLatitude:monumento.lat
                                                               longitude:monumento.lng];
        
        //Desactivo el longPress
        [_mapaMundo removeGestureRecognizer:longPress];
        
        //Calculo distancia entre los puntos
        int distancia = [self distancia:desdeLocation
                                  hasta:hastaLocation];
        labelDistanciaKm = [NSString stringWithFormat:@"(%d km)",
                            distancia];
        [self playSound:distancia];
        
        //Centra el mapaMundo en las coordenadas del monumento.
        [_mapaMundo.camera setCenterCoordinate:hastaCoordinate2D];
        
        // Muestra anotación
        [self mostrarAnotacion:hastaCoordinate2D
                         title:monumento.nombre
                      subtitle:[NSString stringWithFormat:@"%@ %@",
                                monumento.ciudad,
                                labelDistanciaKm]];
        
        //Dibuja una línea entre los puntos
        [self dibujarLineaDesde:desdeCoordinate2D
                          hasta:hastaCoordinate2D];
        
        //Actualizo los datos de la view
        [_etiquetaCentralSuperior setText:monumento.nombre];
        [_etiquetaCentralInferior setText:monumento.ciudad];
        [_etiquetaCentralInferior setHidden:NO];
        
        //Desactivo buttonValida
        [_buttonValida setEnabled:NO];
        [_buttonValida setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_buttonValida setBackgroundColor:[UIColor lightGrayColor]];
        
        //Activo buttonNext
        [_buttonNext setEnabled:YES];
        [_buttonNext setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonNext setBackgroundColor:[UIColor grayColor]];
        
        //Seteo Gesture Recognizer SwipeGesture
        [self setSwipeGesture];
    }
}

- (IBAction)siguienteMonumento:(id)sender
{
    //Desactivo Gesture Recognizer Swipe
    [self.view removeGestureRecognizer:swipe];
    
    [self borrarAnotaciones];
    [self mostrarMonumento];
    
    //Desactivo buttonNext
    [_buttonNext setEnabled:NO];
    [_buttonNext setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_buttonNext setBackgroundColor:[UIColor lightGrayColor]];
    
}

- (void) borrarAnotaciones
{
    //Borro anotaciones y líneas entre sí
    [_mapaMundo removeAnnotations: _mapaMundo.annotations];
    [_mapaMundo removeOverlays: _mapaMundo.overlays];
}


- (int) distancia:(CLLocation*)desde
            hasta:(CLLocation*)hasta
{
    CLLocationDistance kilometers = (int)roundf([desde distanceFromLocation:hasta] / 1000);
    
    //Actualizo puntaje acumulado
    puntajeAcumulado += kilometers;
    [_etiquetaDistancia setText:[NSString stringWithFormat:@"%d", puntajeAcumulado]];
    
    return kilometers;
}

- (void) mostrarAnotacion:(CLLocationCoordinate2D)coordenadas
                    title:(NSString*)titulo
                 subtitle:(NSString*)subtitulo
{
    //Creo una anotación en la ubicación del monumento en juego
    MKPointAnnotation *annotationMonumento = [[MKPointAnnotation alloc] init];
    [annotationMonumento setCoordinate:coordenadas];
    [annotationMonumento setTitle:titulo];
    [annotationMonumento setSubtitle:subtitulo];
    
    //Seteo la anotación
    [_mapaMundo addAnnotation:annotationMonumento];
    [_mapaMundo selectAnnotation:annotationMonumento animated:YES];
    
    //Habilito buttonValida para poder validar el juego
    [_buttonValida setEnabled:YES];
}

- (void) dibujarLineaDesde:(CLLocationCoordinate2D)desde
                     hasta:(CLLocationCoordinate2D)hasta
{
    //Estructura de coordenadas con el inicio y el final de la línea
    CLLocationCoordinate2D points[2];
    points[0] = desde;
    points[1] = hasta;
    
    //Creo la línea
    MKPolyline *overlayPolyline = [MKPolyline polylineWithCoordinates:points count:2];
    
    //Seteo la línea al mapa
    [_mapaMundo addOverlay:overlayPolyline];
}

- (void) playSound:(int)distancia
{
    if(distancia < 300)
        [[SoundManager sharedManager] playSound:@"applause-moderate-03.wav" looping:NO];
    else if(distancia >= 300 && distancia < 1000)
        [[SoundManager sharedManager] playSound:@"applause-light-02.wav" looping:NO];
    else [[SoundManager sharedManager] playSound:@"boo-01.wav" looping:NO];
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView
             rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *polylineRender  = [[MKPolylineRenderer alloc]
                                           initWithOverlay:overlay];
    UIColor *lineColor = [UIColor redColor];
    
    if([overlay isKindOfClass:[MKGeodesicPolyline class]])
    {
        lineColor = [UIColor blackColor];
    }
    [polylineRender setStrokeColor:lineColor];
    [polylineRender setLineWidth:3.0f];
    
    return polylineRender;
}

-(void) initMonumentos
{
    Monumento *monumento1 = [[Monumento alloc] init];
    
    monumento1.nombre = @"La Sagrada Familia";
    monumento1.ciudad = @"BARCELONA";
    monumento1.lat = 41.4028931;
    monumento1.lng = 2.1719068;
    monumento1.distancia = 450;
    monumento1.pitch = 80;
    monumento1.heading = 70;
    
    
    Monumento *monumento2 = [[Monumento alloc] init];
    monumento2.nombre = @"La Puerta de Alcalá";
    monumento2.ciudad = @"MADRID";
    monumento2.lat = 40.420788;
    monumento2.lng = -3.688876;
    monumento2.distancia = 200;
    monumento2.pitch = 25;
    monumento2.heading = 230;
    
    Monumento *monumento3 = [[Monumento alloc] init];
    monumento3.nombre = @"Empire State";
    monumento3.ciudad = @"NEW YORK";
    monumento3.lat = 40.748327;
    monumento3.lng = -73.985471;
    monumento3.distancia = 925;
    monumento3.pitch = 45;
    monumento3.heading = 170;
    
    Monumento *monumento4 = [[Monumento alloc] init];
    monumento4.nombre = @"La Torre Eiffel";
    monumento4.ciudad = @"PARÍS";
    monumento4.lat = 48.8583701;
    monumento4.lng = 2.2922926;
    monumento4.distancia = 1200;
    monumento4.pitch = 60;
    monumento4.heading = 60;
    
    Monumento *monumento5 = [[Monumento alloc] init];
    monumento5.nombre = @"El Coliseo";
    monumento5.ciudad = @"ROMA";
    monumento5.lat = 41.8902102;
    monumento5.lng = 12.4900422;
    monumento5.distancia = 250;
    monumento5.pitch = 80;
    monumento5.heading = 75;
    
    Monumento *monumento6 = [[Monumento alloc] init];
    monumento6.nombre = @"La Casa Blanca";
    monumento6.ciudad = @"WASHINGTON";
    monumento6.lat = 38.8976815;
    monumento6.lng = -77.0368423;
    monumento6.distancia = 500;
    monumento6.pitch = 45;
    monumento6.heading = 0;
    
    Monumento *monumento7 = [[Monumento alloc] init];
    monumento7.nombre = @"El Big Ben";
    monumento7.ciudad = @"LONDRES";
    monumento7.lat = 51.5007292;
    monumento7.lng = -0.1268141;
    monumento7.distancia = 550;
    monumento7.pitch = 80;
    monumento7.heading = 260;
    
    Monumento *monumento8 = [[Monumento alloc] init];
    monumento8.nombre = @"El Kremlin";
    monumento8.ciudad = @"MOSCÚ";
    monumento8.lat = 55.751382;
    monumento8.lng = 37.618446;
    monumento8.distancia = 600;
    monumento8.pitch = 30;
    monumento8.heading = 280;
    
    Monumento *monumento9 = [[Monumento alloc] init];
    monumento9.nombre = @"Tokyo Tower";
    monumento9.ciudad = @"TOKYO";
    monumento9.lat = 35.6585805;
    monumento9.lng = 139.7448857;
    monumento9.distancia = 900;
    monumento9.pitch = 45;
    monumento9.heading = 0;
    
    Monumento *monumento10 = [[Monumento alloc] init];
    monumento10.nombre = @"La Opera";
    monumento10.ciudad = @"SIDNEY";
    monumento10.lat = -33.857033;
    monumento10.lng = 151.215191;
    monumento10.distancia = 500;
    monumento10.pitch = 45;
    monumento10.heading = 110;
    
    Monumento *monumento11 = [[Monumento alloc] init];
    monumento11.nombre = @"El Partenón";
    monumento11.ciudad = @"ATENES";
    monumento11.lat = 37.971402;
    monumento11.lng = 23.726591;
    monumento11.distancia = 500;
    monumento11.pitch = 65;
    monumento11.heading = 0;
    
    Monumento *monumento12 = [[Monumento alloc] init];
    monumento12.nombre = @"Plaza de la Constitución";
    monumento12.ciudad = @"MEXICO DF";
    monumento12.lat = 19.4319642;
    monumento12.lng = -99.1333981;
    monumento12.distancia = 500;
    monumento12.pitch = 45;
    monumento12.heading = 0;
    
    Monumento *monumento13 = [[Monumento alloc] init];
    monumento13.nombre = @"Santa Sofía";
    monumento13.ciudad = @"ISTANBUL";
    monumento13.lat = 41.005270;
    monumento13.lng = 28.976960;
    monumento13.distancia = 500;
    monumento13.pitch = 45;
    monumento13.heading = 0;
    
    Monumento *monumento14 = [[Monumento alloc] init];
    monumento14.nombre = @"La Puerta de Brandenburgo";
    monumento14.ciudad = @"BERLÍN";
    monumento14.lat = 52.5162746;
    monumento14.lng = 13.3755153;
    monumento14.distancia = 400;
    monumento14.pitch = 75;
    monumento14.heading = 260;
    
    Monumento *monumento15 = [[Monumento alloc] init];
    monumento15.nombre = @"La Plaza de Mayo";
    monumento15.ciudad = @"BUENOS AIRES";
    monumento15.lat = -34.6080556;
    monumento15.lng = -58.3724665;
    monumento15.distancia = 500;
    monumento15.pitch = 45;
    monumento15.heading = 75;
    
    monumentos = [NSMutableArray arrayWithObjects:monumento1, monumento2, monumento3, monumento4, monumento5, monumento6, monumento7, monumento8, monumento9, monumento10, monumento11, monumento12, monumento13, monumento14, monumento15, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
