//
//  UIAppearance+Swift.m
//  Happ
//
//  Created by Aleksei Pugachev on 12/14/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

#import "UIAppearance+Swift.h"
@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end
