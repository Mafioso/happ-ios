//
//  UIAppearance+Swift.h
//  Happ
//
//  Created by Aleksei Pugachev on 12/14/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
NS_ASSUME_NONNULL_END
