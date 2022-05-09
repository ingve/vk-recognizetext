#import <AppKit/AppKit.h>
#import <Vision/Vision.h>

typedef void (^ResultHandler)(VNRequest * _Nonnull request, NSError * _Nullable error);

static NSString * const ArgumentsJSONFlag = @"--json";

static NSString * const JSONConfidenceKey = @"confidence";
static NSString * const JSONBoundingBoxKey = @"boundingBox";
static NSString * const JSONXKey = @"x";
static NSString * const JSONYKey = @"y";
static NSString * const JSONWidthKey = @"width";
static NSString * const JSONHeigthKey = @"height";
static NSString * const JSONStringKey = @"string";

ResultHandler string_result_handler = ^(VNRequest * _Nonnull request, NSError * _Nullable error) {
    if (error) {
		fprintf(stderr, "error: %s\n", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
		return;
    }

	for (VNRecognizedTextObservation *textObservation in request.results) {
		NSArray *candidates = [textObservation topCandidates:1];
		for (VNRecognizedText *candidate in candidates) {
			const char *text = [candidate.string cStringUsingEncoding:NSUTF8StringEncoding];
			printf("%s\n", text);
		}
	}
};

ResultHandler json_result_handler = ^(VNRequest * _Nonnull request, NSError * _Nullable error) {
	if (error) {
		fprintf(stderr, "error: %s\n", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
		return;
	}

	NSMutableArray *results = [NSMutableArray new];
	for (VNRecognizedTextObservation *textObservation in request.results) {
		NSMutableDictionary *observation = [NSMutableDictionary new];
		observation[JSONConfidenceKey] = [NSNumber numberWithFloat:textObservation.confidence];
		
		NSMutableDictionary *boundingBox = [NSMutableDictionary new];
		boundingBox[JSONXKey] = [NSNumber numberWithFloat:CGRectGetMinX(textObservation.boundingBox)];
		boundingBox[JSONYKey] = [NSNumber numberWithFloat:CGRectGetMinY(textObservation.boundingBox)];
		boundingBox[JSONWidthKey] = [NSNumber numberWithFloat:CGRectGetWidth(textObservation.boundingBox)];
		boundingBox[JSONHeigthKey] = [NSNumber numberWithFloat:CGRectGetHeight(textObservation.boundingBox)];
		observation[JSONBoundingBoxKey] = boundingBox;
		
		NSArray *candidates = [textObservation topCandidates:1];
		for (VNRecognizedText *candidate in candidates) {
			observation[JSONStringKey] = candidate.string;
		}

		[results addObject:observation];
	}
	
	NSOutputStream *stdout = [NSOutputStream outputStreamToFileAtPath:@"/dev/stdout" append:NO];
	[stdout open];
	NSError *writeError;
	if (![NSJSONSerialization writeJSONObject:results toStream:stdout options:NSJSONWritingPrettyPrinted error:&writeError]) {
		fprintf(stderr, "error writing JSON: %s\n", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	[stdout close];
};

int main(int argc __attribute__((unused)), char **argv __attribute__((unused))) {
    NSUInteger failures = 0;
	@autoreleasepool {
		NSProcessInfo *processInfo = [NSProcessInfo processInfo];
		NSArray *arguments = [processInfo arguments];
		if (arguments.count == 1) {
			fprintf(stderr, "Usage:\n%s [--json] files...\n", [processInfo.processName cStringUsingEncoding:NSUTF8StringEncoding]);
			exit(1);
		}
		
		const ResultHandler result_handler = [arguments containsObject:ArgumentsJSONFlag] ?
			json_result_handler : string_result_handler;

		for (NSUInteger i = 1; i < arguments.count; ++i) {
			NSString *argument = arguments[i];
			if ([argument isEqualToString:ArgumentsJSONFlag]) {
				continue;
			}
			NSString *path = arguments[i];
			NSURL *url = [NSURL fileURLWithPath:path];
			CIImage *image = [CIImage imageWithContentsOfURL:url];
			NSDictionary *options = [NSDictionary new];

			VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image
												orientation:kCGImagePropertyOrientationUp options:options];
			VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:result_handler];
			NSError *error;
			if (![handler performRequests:@[request] error:&error]) {
				fprintf(stderr, "error performing request: %s\n", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
				failures++;
			}
		}
	}
	return (failures > 0) ? EXIT_FAILURE : EXIT_SUCCESS;
}
