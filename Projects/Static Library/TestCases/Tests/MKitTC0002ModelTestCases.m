//
//  ModelTestCases.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/28/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0002ModelTestCases.h"
#import "TestModel.h"

@implementation MKitTC0002ModelTestCases

-(TestModel *)makeModelWithId:(NSString *)modelId
{
    TestModel *m1=[TestModel instanceWithObjectId:modelId];
    
    m1.stringV=modelId;
    m1.shortV=192;
    m1.intV=32456;
    m1.boolV=YES;
    m1.floatV=0.66f;
    m1.doubleV=10.233;
    m1.dateV=[NSDate date];
    
    return m1;
}

-(void)test001SerializeDeserialize
{
    [MKitModelContext clearAllContexts];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.amodelV=m2;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.amodelV=m3;
    
    // Serialize
    id data=[m1 serialize];
    
    // Make sure the context has been cleared
    [MKitModelContext clearAllContexts];
    m1=(TestModel *)[[MKitModelContext current] modelForObjectId:@"001" andClass:[TestModel class]];
    STAssertTrue(m1==nil, @"Context wasn't cleared.");
    
    // Deserialize
    m1=[TestModel instanceWithSerializedData:data];
    
    // Make sure we have 4 objects in the context
    STAssertTrue([MKitModelContext current].contextCount==4, @"Context count mismatch, should be 4.");
    
    m2=[TestModel instanceWithObjectId:@"002"];
    m3=[TestModel instanceWithObjectId:@"003"];
    m4=[TestModel instanceWithObjectId:@"004"];

    
    STAssertTrue(m1.amodelV==m4, @"Model didn't deserialize correctly.");
    STAssertTrue(m2.amodelV==m1, @"Model didn't deserialize correctly.");
    STAssertTrue(m3.amodelV==m2, @"Model didn't deserialize correctly.");
    STAssertTrue(m4.amodelV==m3, @"Model didn't deserialize correctly.");
    STAssertTrue([m1.amodelArrayV indexOfObject:m2]!=NSNotFound, @"Model didn't deserialize correctly.");
}

-(void)test002SerializeDeserializeJSON
{
    [MKitModelContext clearAllContexts];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.amodelV=m2;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.amodelV=m3;
    
    // Serialize
    NSString *json=[m1 serializeToJSON];
    
    // Make sure the context has been cleared
    [MKitModelContext clearAllContexts];
    m1=(TestModel *)[[MKitModelContext current] modelForObjectId:@"001" andClass:[TestModel class]];
    STAssertTrue(m1==nil, @"Context wasn't cleared.");
    
    // Deserialize
    m1=[TestModel instanceWithJSON:json];
    
    // Make sure we have 4 objects in the context
    STAssertTrue([MKitModelContext current].contextCount==4, @"Context count mismatch, should be 4.");
    
    m2=[TestModel instanceWithObjectId:@"002"];
    m3=[TestModel instanceWithObjectId:@"003"];
    m4=[TestModel instanceWithObjectId:@"004"];
    
    
    STAssertTrue(m1.amodelV==m4, @"Model didn't deserialize correctly.");
    STAssertTrue(m2.amodelV==m1, @"Model didn't deserialize correctly.");
    STAssertTrue(m3.amodelV==m2, @"Model didn't deserialize correctly.");
    STAssertTrue(m4.amodelV==m3, @"Model didn't deserialize correctly.");
    STAssertTrue([m1.amodelArrayV indexOfObject:m2]!=NSNotFound, @"Model didn't deserialize correctly.");
}


-(void)test003PredicateQuery
{
    [MKitModelContext clearAllContexts];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.stringV=@"Jon";
    m1.shortV=255;
    m1.boolV=YES;
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.stringV=@"Jon";
    m2.shortV=255;
    m2.boolV=NO;
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.stringV=@"Chan";
    m3.shortV=192;
    m3.boolV=NO;
    m3.amodelV=m1;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.stringV=@"Jasan";
    m4.shortV=192;
    m4.boolV=YES;
    m4.amodelV=m1;
    
    MKitModelQuery *query=[TestModel query];
    [query key:@"shortV" condition:KeyEquals value:@(255)];
    NSArray *results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==2, [NSString stringWithFormat:@"Should have 2 items, has %d",results.count]);
    
    query=[TestModel query];
    [query key:@"amodelV" condition:KeyEquals value:m1];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==3, [NSString stringWithFormat:@"Should have 3 items, has %d",results.count]);

    query=[TestModel query];
    [query key:@"stringV" condition:KeyBeginsWith value:@"Jo"];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==2, [NSString stringWithFormat:@"Should have 2 items, has %d",results.count]);

    query=[TestModel query];
    [query key:@"stringV" condition:KeyEndsWith value:@"an"];
    [query key:@"boolV" condition:KeyEquals value:@(YES)];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==1, [NSString stringWithFormat:@"Should have 1 items, has %d",results.count]);
    
    query=[TestModel query];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==4, [NSString stringWithFormat:@"Should have 4 items, has %d",results.count]);
    
}

@end
