//
//  ContextMaker.m
//  Happ
//
//  Created by Aleksei Pugachev on 1/6/17.
//  Copyright © 2017 Sattar Stamkulov. All rights reserved.
//

#import "ContextMaker.h"

@implementation ContextMaker

+ (CIContext*) makeMeAContext {
    return [CIContext contextWithOptions:nil];
}

@end
