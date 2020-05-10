//
//  Zee5ResourceHelperm
//  Pods
//
//  Created by Miri on 15/01/2019.
//
//

#import "Zee5ResourceHelper.h"
@import ApplicasterSDK;

@interface Zee5ResourceHelper ()
@property (nonatomic, strong) NSArray *bundlesArray;
@end

@implementation Zee5ResourceHelper

+ (instancetype)sharedManager {
    static Zee5ResourceHelper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;

}

+ (NSArray *)bundlesArray {
    NSArray *retVal = [[self sharedManager] bundlesArray];
    if (retVal == nil) {
        retVal = [NSArray arrayWithObject:[NSBundle mainBundle]];
    }
    return retVal;
}

+ (void)setBundelsArray:(NSArray *)bundlesArray {
    if (bundlesArray) {
        Zee5ResourceHelper *resourceHelper = [self sharedManager];
        resourceHelper.bundlesArray = bundlesArray;
    }
}

+ (NSBundle *)defaultBundle{
    return [[self bundlesArray] firstObject];
}

+ (NSBundle *)bundleForNibNamed:(NSString *)nibName
{
    return [self bundleForResourceNamed:nibName
                                 ofType:@"nib"];
}

+ (UIImage *)imageNamed:(NSString *)imageName{
    UIImage *resultImage;

    NSBundle *currentBundle = [NSBundle bundleForClass:[Zee5ResourceHelper class]];
    if (currentBundle != nil) {
        resultImage = [self imageNamed:imageName fromBundle:currentBundle];
        if (resultImage != nil) {
            return resultImage;
        }
    }
    
    for (NSBundle *bundle in [self bundlesArray]) {
        resultImage = [self imageNamed:imageName
                            fromBundle:bundle];
        if(resultImage != nil){
            break;
        }
    }

    return resultImage;
}


+ (UIImage *)imageNamed:(NSString *)imageName
             fromBundle:(NSBundle *)bundle {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil) {
        return [UIImage imageNamed:imageName
                          inBundle:bundle
     compatibleWithTraitCollection:nil];
    }
    return image;
}

+ (NSBundle *)bundleForResourceNamed:(NSString *)resourceName
                              ofType:(NSString *)type{
    NSBundle *resultBundle;

    for (NSBundle *bundle in [self bundlesArray]) {
        if ([bundle pathForResource:resourceName ofType:type] != nil) {
            resultBundle = bundle;
            break;
        }
    }

    return resultBundle;
}

@end
