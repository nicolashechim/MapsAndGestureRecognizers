//
//  Monumento.h
//  MapsAndGestureRecognizers
//
//  Created by Nicolás Hechim on 15/1/17.
//  Copyright © 2017 Nicolás Hechim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Monumento : NSObject

@property(nonatomic, strong) NSString *nombre;
@property(nonatomic, strong) NSString *ciudad;
@property(nonatomic) CGFloat lat;
@property(nonatomic) CGFloat lng;
@property(nonatomic) CGFloat distancia;
@property(nonatomic) CGFloat pitch;
@property(nonatomic) CGFloat heading;

@end
