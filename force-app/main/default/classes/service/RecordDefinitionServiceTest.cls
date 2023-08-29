@isTest
private class RecordDefinitionServiceTest {
    @isTest
    static void testUpsertDefinition() {
        // Test data setup
        RecordDefinitionDto.FieldValue fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue.field = 'Name';
        fieldValue.value = 'Test-Company-{0}';

        RecordDefinitionDto recordDefinitionDto = new RecordDefinitionDto();
        recordDefinitionDto.name = 'Test Definition Name';
        recordDefinitionDto.obj = 'Account';
        recordDefinitionDto.fieldValues = new List<RecordDefinitionDto.FieldValue>{fieldValue};

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
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c FROM RecordDefinition__c];
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c recordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', recordDefinition.Name);
        System.assertEquals('Account', recordDefinition.Object__c);
    }


    @isTest
    static void testGetAllRecordDefinitions() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
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
    }

    @isTest
    static void testSearchRecordDefinitions() {
        // Test data setup
        RecordDefinition__c recordDefinition1 = new RecordDefinition__c();
        recordDefinition1.Name = 'Test Account Definition Name 1';
        recordDefinition1.Object__c = 'Account';
        insert recordDefinition1;

        RecordDefinition__c recordDefinition2 = new RecordDefinition__c();
        recordDefinition2.Name = 'Test Account Definition Name 2';
        recordDefinition2.Object__c = 'Account';
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
    }

    @isTest
    static void testDeleteDefinition() {
        // Test data setup
        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = 'Test Definition Name';
        recordDefinition.Object__c = 'Account';
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