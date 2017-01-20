//
//  ViewController.h
//  MapsAndGestureRecognizers
//
//  Created by Nicolás Hechim on 15/1/17.
//  Copyright © 2017 Nicolás Hechim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate,
CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapaMonumento;
@property (strong, nonatomic) IBOutlet MKMapView *mapaMundo;
@property (strong, nonatomic) IBOutlet UIView *viewInfo;
@property (strong, nonatomic) IBOutlet UILabel *etiquetaDistancia;
@property (strong, nonatomic) IBOutlet UILabel *etiquetaCentralSuperior;
@property (strong, nonatomic) IBOutlet UILabel *etiquetaCentralInferior;
@property (strong, nonatomic) IBOutlet UIButton *buttonValida;
@property (strong, nonatomic) IBOutlet UIButton *buttonNext;
- (IBAction)validarJuego:(id)sender;
- (IBAction)siguienteMonumento:(id)sender;

@end

