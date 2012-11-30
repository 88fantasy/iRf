/*
	iRfServices.h
	Creates a list of the services available with the iRf prefix.
	Generated by SudzC.com
*/
#import "iRfRgService.h"

@interface iRfServices : NSObject {
	BOOL logging;
	NSString* server;
	NSString* defaultServer;
iRfRgService* rgService;

}

-(id)initWithServer:(NSString*)serverName;
-(void)updateService:(SoapService*)service;
-(void)updateServices;
+(iRfServices*)service;
+(iRfServices*)serviceWithServer:(NSString*)serverName;

@property (nonatomic) BOOL logging;
@property (nonatomic, retain) NSString* server;
@property (nonatomic, retain) NSString* defaultServer;

@property (nonatomic, retain, readonly) iRfRgService* rgService;

@end
			