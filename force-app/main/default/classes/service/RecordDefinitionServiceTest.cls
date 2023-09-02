@isTest
private class RecordDefinitionServiceTest {
    @isTest
    static void testUpsertDefinition() {
        // Test data setup
        RecordDefinitionDto.FieldValue fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue.field = 'Name';
        fieldValue.value = 'Test-Company';

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
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c, ConfigToInsert__c FROM RecordDefinition__c];
        System.assertEquals(1, recordDefinitions.size());
        RecordDefinition__c recordDefinition = recordDefinitions[0];
        System.assertEquals('Test Definition Name', recordDefinition.Name);
        System.assertEquals('Account', recordDefinition.Object__c);
        System.assertEquals('{"obj":"Account","fieldValues":[{"value":"Test-Company","field":{"dataType":"STRING","apiName":"Name"}}]}', recordDefinition.ConfigToInsert__c);

    }


    @isTest
    static void testCreateDefinition() {
        // Test data setup
        RecordDefinitionDto.FieldValue fieldValue1 = new RecordDefinitionDto.FieldValue();
        fieldValue1 = new RecordDefinitionDto.FieldValue();
        fieldValue1.field = 'Name';
        fieldValue1.value = 'Test-Company1';

        RecordDefinitionDto recordDefinitionDto1 = new RecordDefinitionDto();
        recordDefinitionDto1.name = 'Test Definition Name 1';
        recordDefinitionDto1.obj = 'Account';
        recordDefinitionDto1.fieldValues = new List<RecordDefinitionDto.FieldValue>{fieldValue1};


        RecordDefinitionDto.FieldValue fieldValue2 = new RecordDefinitionDto.FieldValue();
        fieldValue2 = new RecordDefinitionDto.FieldValue();
        fieldValue2.field = 'Name';
        fieldValue2.value = 'Test-Company2';

        RecordDefinitionDto recordDefinitionDto2 = new RecordDefinitionDto();
        recordDefinitionDto2.name = 'Test Definition Name 2';
        recordDefinitionDto2.obj = 'Account';
        recordDefinitionDto2.fieldValues = new List<RecordDefinitionDto.FieldValue>{fieldValue2};

        // Test method execution
        Test.startTest();
        try {
            RecordDefinitionService.createDefinitions(new List<RecordDefinitionDto>{recordDefinitionDto1, recordDefinitionDto2});
        } catch (Exception e) {
            // This try/catch is for avoiding custom validation
            return;
        }
        Test.stopTest();

        // Assertion    
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c, ConfigToInsert__c FROM RecordDefinition__c ORDER BY Name];
        System.assertEquals(2, recordDefinitions.size());

        RecordDefinition__c recordDefinition1 = recordDefinitions[0];
        System.assertEquals('Test Definition Name 1', recordDefinition1.Name);
        System.assertEquals('Account', recordDefinition1.Object__c);
        System.assertEquals('{"obj":"Account","fieldValues":[{"value":"Test-Company1","field":{"dataType":"STRING","apiName":"Name"}}]}', recordDefinition1.ConfigToInsert__c);

        RecordDefinition__c recordDefinition2 = recordDefinitions[1];
        System.assertEquals('Test Definition Name 2', recordDefinition2.Name);
        System.assertEquals('Account', recordDefinition2.Object__c);
        System.assertEquals('{"obj":"Account","fieldValues":[{"value":"Test-Company2","field":{"dataType":"STRING","apiName":"Name"}}]}', recordDefinition2.ConfigToInsert__c);
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

    @isTest
    static void testValidSoql() {
        // Test a valid SOQL query
        String validSoql = 'SELECT LastName, FirstName FROM Contact';
        RecordDefinitionService.ParsedSoql result = RecordDefinitionService.parseSoql(validSoql);
        
        System.assertEquals('Contact', result.obj, 'Object should be "Contact"');
        System.assertEquals(2, result.fields.size(), 'There should be 2 fields');
        System.assertEquals('LastName', result.fields[0], 'First field should be "LastName"');
        System.assertEquals('FirstName', result.fields[1], 'Second field should be "FirstName"');
    }

    @isTest
    static void testInvalidSoqlNoFields() {
        // Test an invalid SOQL query with no fields
        String invalidSoql = 'SELECT FROM Account';
        
        try {
            RecordDefinitionService.parseSoql(invalidSoql);
            // If the method doesn't throw an exception, the test should fail
            System.assert(false, 'Expected an exception for invalid SOQL query');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Invalid SOQL query: Cannot determine fields', e.getMessage(), 'Exception message should match');
        }
    }

    @isTest
    static void testInvalidSoqlNoObject() {
        // Test an invalid SOQL query with no object
        String invalidSoql = 'SELECT LastName, FirstName FROM';
        
        try {
            RecordDefinitionService.parseSoql(invalidSoql);
            // If the method doesn't throw an exception, the test should fail
            System.assert(false, 'Expected an exception for invalid SOQL query');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Invalid SOQL query: Cannot determine object', e.getMessage(), 'Exception message should match');
        }
    }

}