#import <AuthenticationServices/AuthenticationServices.h>
#import <Cordova/CDVPlugin.h> // this already includes Foundation.h

@interface SignInWithApple : CDVPlugin {
  NSMutableString *_callbackId;
}
@end

@implementation SignInWithApple
- (void)pluginInitialize {
  NSLog(@"SignInWithApple initialize");
}

- (void)signin:(CDVInvokedUrlCommand *)command {
  NSLog(@"SignInWithApple signin()");

  if (@available(iOS 13, *)) {
    _callbackId = [NSMutableString stringWithString:command.callbackId];

    ASAuthorizationAppleIDProvider *provider =
        [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    [request setRequestedScopes:@[
      ASAuthorizationScopeFullName, ASAuthorizationScopeEmail
    ]];

    [request setRequestedScopes:@[
      ASAuthorizationScopeFullName, ASAuthorizationScopeEmail
    ]];

    ASAuthorizationController *controller = [[ASAuthorizationController alloc]
        initWithAuthorizationRequests:@[ request ]];
    controller.delegate = self;
    [controller performRequests];

  } else {
    NSLog(@"SignInWithApple signin() ignored because your iOS version < 13");

    CDVPluginResult *result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                      messageAsDictionary:@{
                        @"error" : @"PLUGIN_ERROR",
                        @"code" : @"",
                        @"localizedDescription" : @"",
                        @"localizedFailureReason" : @"",
                      }];
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
  }
}

- (void)authorizationController:(ASAuthorizationController *)controller
    didCompleteWithAuthorization:(nonnull ASAuthorization *)authorization
    API_AVAILABLE(ios(13.0)) {
  ASAuthorizationAppleIDCredential *appleIDCredential =
      [authorization credential];

  NSDictionary *fullName;
  NSDictionary *fullNamePhonetic;
  if (appleIDCredential.fullName) {
    if (appleIDCredential.fullName.phoneticRepresentation) {
      fullNamePhonetic = @{
        @"namePrefix" :
                appleIDCredential.fullName.phoneticRepresentation.namePrefix
            ? appleIDCredential.fullName.phoneticRepresentation.namePrefix
            : @"",
        @"givenName" :
                appleIDCredential.fullName.phoneticRepresentation.givenName
            ? appleIDCredential.fullName.phoneticRepresentation.givenName
            : @"",
        @"givenName" :
                appleIDCredential.fullName.phoneticRepresentation.middleName
            ? appleIDCredential.fullName.phoneticRepresentation.middleName
            : @"",
        @"familyName" :
                appleIDCredential.fullName.phoneticRepresentation.familyName
            ? appleIDCredential.fullName.phoneticRepresentation.familyName
            : @"",
        @"nameSuffix" :
                appleIDCredential.fullName.phoneticRepresentation.nameSuffix
            ? appleIDCredential.fullName.phoneticRepresentation.nameSuffix
            : @"",
        @"nickname" : appleIDCredential.fullName.phoneticRepresentation.nickname
            ? appleIDCredential.fullName.phoneticRepresentation.nickname
            : @""
      };
    }
    fullName = @{
      @"namePrefix" : appleIDCredential.fullName.namePrefix
          ? appleIDCredential.fullName.namePrefix
          : @"",
      @"givenName" : appleIDCredential.fullName.givenName
          ? appleIDCredential.fullName.givenName
          : @"",
      @"givenName" : appleIDCredential.fullName.middleName
          ? appleIDCredential.fullName.middleName
          : @"",
      @"familyName" : appleIDCredential.fullName.familyName
          ? appleIDCredential.fullName.familyName
          : @"",
      @"nameSuffix" : appleIDCredential.fullName.nameSuffix
          ? appleIDCredential.fullName.nameSuffix
          : @"",
      @"nickname" : appleIDCredential.fullName.nickname
          ? appleIDCredential.fullName.nickname
          : @"",
      @"phoneticRepresentation" : fullNamePhonetic ? fullNamePhonetic : @{}
    };
  }
  NSString *identityToken =
      [[NSString alloc] initWithData:appleIDCredential.identityToken
                            encoding:NSUTF8StringEncoding];

  NSString *authorizationCode =
      [[NSString alloc] initWithData:appleIDCredential.authorizationCode
                            encoding:NSUTF8StringEncoding];
  NSDictionary *dic = @{
    @"user" : appleIDCredential.user ? appleIDCredential.user : @"",
    @"state" : appleIDCredential.state ? appleIDCredential.state : @"",
    @"fullName" : fullName ? fullName : @{},
    @"email" : appleIDCredential.email ? appleIDCredential.email : @"",
    @"authorizationCode": authorizationCode,
    @"identityToken" : identityToken
  };

  CDVPluginResult *result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                    messageAsDictionary:dic];
  [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
  NSLog(@" error => %@ ", [error localizedDescription]);

  CDVPluginResult *result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                    messageAsDictionary:@{
                      @"error" : @"ASAUTHORIZATION_ERROR",
                      @"code" : error.code
                          ? [NSString stringWithFormat:@"%ld", (long)error.code]
                          : @"",
                      @"localizedDescription" : error.localizedDescription
                          ? error.localizedDescription
                          : @"",
                      @"localizedFailureReason" : error.localizedFailureReason
                          ? error.localizedFailureReason
                          : @"",
                    }];
  [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

@end
