//
//  RootCAAFSecurityPolicy.m
//  tablenow.online
//
//  Created by user1 on 10/3/16.
//  Copyright © 2016 swis.online. All rights reserved.
//

#import "RootCAAFSecurityPolicy.h"

@implementation RootCAAFSecurityPolicy
-(BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    if(self.SSLPinningMode == AFSSLPinningModeCertificate)
    {
        return [self shouldTrustServerTrust:serverTrust];
    }
    else
    {
        return [super evaluateServerTrust:serverTrust forDomain:domain];
    }
}
- (BOOL)shouldTrustServerTrust:(SecTrustRef)serverTrust
{
    // load up the bundled root CA
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"RootCA" ofType:@"der"];
    
//    NSAssert(certPath != nil, @"Specified certificate does not exist!");
    
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    NSAssert(cert != NULL, @"Failed to create certificate object. Is the certificate in DER format?");
    
    
    // establish a chain of trust anchored on our bundled certificate
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    OSStatus anchorCertificateStatus = SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    NSAssert(anchorCertificateStatus == errSecSuccess, @"Failed to specify custom anchor certificate");
    
    
    // trust also built-in certificates besides the specified CA
    OSStatus trustBuiltinCertificatesStatus = SecTrustSetAnchorCertificatesOnly(serverTrust, false);
    
    NSAssert(trustBuiltinCertificatesStatus == errSecSuccess, @"Failed to reenable trusting built-in anchor certificates");
    
    
    // verify that trust
    SecTrustResultType trustResult;
    OSStatus evalStatus =  SecTrustEvaluate(serverTrust, &trustResult);
    
    NSAssert(evalStatus == errSecSuccess, @"Failed to evaluate certificate trust");
    
    
    // clean up
    CFRelease(certArrayRef);
    CFRelease(cert);
    CFRelease(certDataRef);
    
    
    // did our custom trust chain evaluate successfully
    return (trustResult == kSecTrustResultProceed || trustResult == kSecTrustResultUnspecified);
}
@end
