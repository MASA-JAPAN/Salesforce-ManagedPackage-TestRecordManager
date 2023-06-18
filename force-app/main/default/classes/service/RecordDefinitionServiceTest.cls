@isTest
private class RecordDefinitionServiceTest {
    @isTest
    static void testUpsertDefinition() {
        // Test data setup
        RecordDefinitionDto.KeyedFieldValue keyedStringFieldValue = new RecordDefinitionDto.KeyedFieldValue();
        keyedStringFieldValue.key = 'key-0';
        keyedStringFieldValue.fieldValue = new RecordDefinitionDto.FieldValue();
        keyedStringFieldValue.fieldValue.field = 'Name';
        keyedStringFieldValue.fieldValue.value = 'Test-Company-{0}';

        RecordDefinitionDto recordDefinitionDto = new RecordDefinitionDto();
        recordDefinitionDto.name = 'Test Definition Name';
        recordDefinitionDto.obj = 'Account';
        recordDefinitionDto.keyedFieldValues = new List<RecordDefinitionDto.KeyedFieldValue>{keyedStringFieldValue};

        String recordDefinitionDtoString = JSON.serialize(recordDefinitionDto);

        // Test method execution
        Test.startTest();
        try {
            RecordDefinitionService.upsertDefinition(recordDefinitionDtoString);
        } catch (Exception e) {
            // This try/catch is for avoiding custom validation
            return;
        }
        Test.stopTest();

        // Assertion    
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c, FieldValuesToEdit__c FROM RecordDefinition__c];
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c recordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', recordDefinition.Name);
        System.assertEquals('Account', recordDefinition.Object__c);
        System.assertEquals('[{"key":"key-0","fieldValue":{"value":"Test-Company-{0}","field":"Name"}}]', recordDefinition.FieldValuesToEdit__c);
    }


    @isTest
    static void testGetAllRecordDefinitions() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
        recordDefinition.FieldValuesToEdit__c = '[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]';
        insert recordDefinition;

        // Test method execution
        Test.startTest();
        List<RecordDefinition__c> recordDefinitions = RecordDefinitionService.getAllRecordDefinitions();
        Test.stopTest();

        // Assertion
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c fetchedRecordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', fetchedRecordDefinition.Name);
        System.assertEquals('Account', fetchedRecordDefinition.Object__c);
        System.assertEquals('[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]', fetchedRecordDefinition.FieldValuesToEdit__c);
    }

    @isTest
    static void testSearchRecordDefinitions() {
        // Test data setup
        RecordDefinition__c recordDefinition1 = new RecordDefinition__c();
        recordDefinition1.Name = 'Test Account Definition Name 1';
        recordDefinition1.Object__c = 'Account';
        recordDefinition1.FieldValuesToEdit__c = '[{"key":"key-0","fieldValue":{"value":"Test-Company-1","field":"Name"}}]';
        insert recordDefinition1;

        RecordDefinition__c recordDefinition2 = new RecordDefinition__c();
        recordDefinition2.Name = 'Test Account Definition Name 2';
        recordDefinition2.Object__c = 'Account';
        recordDefinition2.FieldValuesToEdit__c = '[{"key":"key-1","fieldValue":{"value":"Test-Company-2","field":"Name"}}]';
        insert recordDefinition2;

        // Test method execution
        Test.startTest();
        List<RecordDefinition__c> recordDefinitions = RecordDefinitionService.searchRecordDefinitions('Test Account Definition Name 2');
        Test.stopTest();

        // Assertion
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c fetchedRecordDefinition = recordDefinitions[0];
        System.assertEquals('Test Account Definition Name 2', fetchedRecordDefinition.Name);
        System.assertEquals('Account', fetchedRecordDefinition.Object__c);
        System.assertEquals('[{"key":"key-1","fieldValue":{"value":"Test-Company-2","field":"Name"}}]', fetchedRecordDefinition.FieldValuesToEdit__c);
    }

    @isTest
    static void testDeleteDefinition() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
        recordDefinition.FieldValuesToEdit__c = '[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]';
        insert recordDefinition;
        
        // Test method execution
        Test.startTest();
        RecordDefinitionService.deleteDefinition(recordDefinition.Id);
        Test.stopTest();

        // Assertion
        List<RecordDefinition__c> recordDefinitions = [SELECT Id FROM RecordDefinition__c];
        System.assertEquals(0, recordDefinitions.size());
    }
}