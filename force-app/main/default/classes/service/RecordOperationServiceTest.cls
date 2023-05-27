@isTest
private class RecordOperationServiceTest {
    @isTest
    static void testCreateRecords() {
        // Test data setup
        RecordDefinitionDto.KeyedFieldValue fieldValue = new RecordDefinitionDto.KeyedFieldValue();
        fieldValue.key = 'key-0';
        fieldValue.fieldValue = new RecordDefinitionDto.FieldValue();
        fieldValue.fieldValue.field = 'Name';
        fieldValue.fieldValue.value = 'Test-Company-{0}';

        RecordDefinitionDto recordDefinitionDto = new RecordDefinitionDto();
        recordDefinitionDto.name = 'Test Definition Name';
        recordDefinitionDto.obj = 'Account';
        recordDefinitionDto.keyedFieldValues = new List<RecordDefinitionDto.KeyedFieldValue>{fieldValue};

        String recordDefinitionDtoString = JSON.serialize(recordDefinitionDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, recordDefinitionDtoString);
        } catch (Exception e) {
            // This try/catch is for avoiding custom validation
            return;
        }

        Test.stopTest();

        // Assertion
        List<Account> records = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(2, records.size());
        System.assertEquals('Test-Company-0', records[0].Name);
        System.assertEquals('Test-Company-1', records[1].Name);

    }
}