/*
	iRfRgService.m
	The implementation classes and methods for the RgService web service.
	Generated by SudzC.com
*/

#import "iRfRgService.h"
				
#import "Soap.h"
	
#import "iRfArrayOfString.h"
#import "iRfRet.h"

/* Implementation of the service */
				
@implementation iRfRgService

	- (id) init
	{
		if(self = [super init])
		{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL internetFlag = [defaults boolForKey:@"enabled_preference"];
            
            if (internetFlag) {
                self.serviceUrl = @"http://www.gzmpc.com:8060/gzmpcscm3/services/RgService";
            }
            else{
                self.serviceUrl = [defaults stringForKey:@"serviceurl_preference"];
            }
            
//			self.serviceUrl = @"http://173.1.1.237:8070/gzmpcscm3/services/RgService";
			self.namespace = @"http://org/gzmpc/RgService";
			self.headers = nil;
			self.logging = NO;
		}
		return self;
	}
	
	- (id) initWithUsername: (NSString*) username andPassword: (NSString*) password {
		if(self = [super initWithUsername:username andPassword:password]) {
		}
		return self;
	}
	
	+ (iRfRgService*) service {
		return [iRfRgService serviceWithUsername:nil andPassword:nil];
	}
	
	+ (iRfRgService*) serviceWithUsername: (NSString*) username andPassword: (NSString*) password {
		return [[[iRfRgService alloc] initWithUsername:username andPassword:password] autorelease];
	}

		
	/* Returns NSString*.  */
	- (SoapRequest*) queryXML: (id <SoapDelegate>) handler sql: (NSString*) sql dbname: (NSString*) dbname
	{
		return [self queryXML: handler action: nil sql: sql dbname: dbname];
	}

	- (SoapRequest*) queryXML: (id) _target action: (SEL) _action sql: (NSString*) sql dbname: (NSString*) dbname
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: sql forName: @"sql"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: dbname forName: @"dbname"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"queryXML" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: @"NSString"];
		[_request send];
		return _request;
	}

	/* Returns iRfRet*.  */
	- (SoapRequest*) setRgSuccess: (id <SoapDelegate>) handler ids: (NSMutableArray*) ids code: (NSString*) code
	{
		return [self setRgSuccess: handler action: nil ids: ids code: code];
	}

	- (SoapRequest*) setRgSuccess: (id) _target action: (SEL) _action ids: (NSMutableArray*) ids code: (NSString*) code
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: ids forName: @"ids"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: code forName: @"code"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"setRgSuccess" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: [[iRfRet alloc] autorelease]];
		[_request send];
		return _request;
	}

	/* Returns iRfRet*.  */
	- (SoapRequest*) getRgs: (id <SoapDelegate>) handler queryxml: (NSString*) queryxml code: (NSString*) code
	{
		return [self getRgs: handler action: nil queryxml: queryxml code: code];
	}

	- (SoapRequest*) getRgs: (id) _target action: (SEL) _action queryxml: (NSString*) queryxml code: (NSString*) code
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: queryxml forName: @"queryxml"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: code forName: @"code"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"getRgs" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: [[iRfRet alloc] autorelease]];
		[_request send];
		return _request;
	}

	/* Returns NSString*.  */
	- (SoapRequest*) getRg: (id <SoapDelegate>) handler username: (NSString*) username password: (NSString*) password labelno: (NSString*) labelno
	{
		return [self getRg: handler action: nil username: username password: password labelno: labelno];
	}

	- (SoapRequest*) getRg: (id) _target action: (SEL) _action username: (NSString*) username password: (NSString*) password labelno: (NSString*) labelno
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: username forName: @"username"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: password forName: @"password"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: labelno forName: @"labelno"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"getRg" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: @"NSString"];
		[_request send];
		return _request;
	}

	/* Returns NSString*.  */
	- (SoapRequest*) doRg: (id <SoapDelegate>) handler username: (NSString*) username password: (NSString*) password splid: (NSString*) splid rgqty: (NSString*) rgqty locno: (NSString*) locno
	{
		return [self doRg: handler action: nil username: username password: password splid: splid rgqty: rgqty locno: locno];
	}

	- (SoapRequest*) doRg: (id) _target action: (SEL) _action username: (NSString*) username password: (NSString*) password splid: (NSString*) splid rgqty: (NSString*) rgqty locno: (NSString*) locno
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: username forName: @"username"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: password forName: @"password"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: splid forName: @"splid"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: rgqty forName: @"rgqty"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: locno forName: @"locno"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"doRg" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: @"NSString"];
		[_request send];
		return _request;
	}

	/* Returns NSString*.  */
	- (SoapRequest*) queryJSON: (id <SoapDelegate>) handler sql: (NSString*) sql dbname: (NSString*) dbname
	{
		return [self queryJSON: handler action: nil sql: sql dbname: dbname];
	}

	- (SoapRequest*) queryJSON: (id) _target action: (SEL) _action sql: (NSString*) sql dbname: (NSString*) dbname
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[[SoapParameter alloc] initWithValue: sql forName: @"sql"] autorelease]];
		[_params addObject: [[[SoapParameter alloc] initWithValue: dbname forName: @"dbname"] autorelease]];
		NSString* _envelope = [Soap createEnvelope: @"queryJSON" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"" postData: _envelope deserializeTo: @"NSString"];
		[_request send];
		return _request;
	}


@end
	