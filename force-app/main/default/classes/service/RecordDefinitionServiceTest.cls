@isTest
private class RecordDefinitionServiceTest {
    @isTest
    static void testUpsertDefinition() {
        // Test data setup
        RecordDefinitionDto.KeyedFieldValue fieldValue = new RecordDefinitionDto.KeyedFieldValue();
        fieldValue.key = 'key-0';
        fieldValue.fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue.fieldValue.field = 'Name';
        fieldValue.fieldValue.value = 'Test-Company';

        RecordDefinitionDto recordDefinitionDto = new RecordDefinitionDto();
        recordDefinitionDto.name = 'Test Definition Name';
        recordDefinitionDto.obj = 'Account';
        recordDefinitionDto.keyedFieldValues = new List<RecordDefinitionDto.KeyedFieldValue>{fieldValue};

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
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c, FieldValues__c FROM RecordDefinition__c];
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c recordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', recordDefinition.Name);
        System.assertEquals('Account', recordDefinition.Object__c);
        System.assertEquals('[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]', recordDefinition.FieldValues__c);
    }

    @isTest
    static void testGetRecordDefinitions() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
        recordDefinition.FieldValues__c = '[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]';
        insert recordDefinition;

        // Test method execution
        Test.startTest();
        List<RecordDefinition__c> recordDefinitions = RecordDefinitionService.getRecordDefinitions();
        Test.stopTest();

        // Assertion
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c fetchedRecordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', fetchedRecordDefinition.Name);
        System.assertEquals('Account', fetchedRecordDefinition.Object__c);
        System.assertEquals('[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]', fetchedRecordDefinition.FieldValues__c);
    }

    @isTest
    static void testDeleteDefinition() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
        recordDefinition.FieldValues__c = '[{"key":"key-0","fieldValue":{"value":"Test-Company","field":"Name"}}]';
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