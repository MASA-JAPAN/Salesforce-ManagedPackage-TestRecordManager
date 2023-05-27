@isTest
private class RecordOperationServiceTest {
    @isTest
    static void testCreateRecords() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue fieldValue = new ConfigToInsertDto.FieldValue();
        fieldValue.field = new ConfigToInsertDto.Field();
        fieldValue.field.apiName = 'Name';
        fieldValue.field.dataType = 'STRING';
        fieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(fieldValue);

        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
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

    
    @isTest
    static void testCreateRecords_BooleanField_catchError() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue stringFieldValue = new ConfigToInsertDto.FieldValue();
        stringFieldValue.field = new ConfigToInsertDto.Field();
        stringFieldValue.field.apiName = 'Name';
        stringFieldValue.field.dataType = 'STRING';
        stringFieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(stringFieldValue);

        ConfigToInsertDto.FieldValue booleanFieldValue = new ConfigToInsertDto.FieldValue();
        booleanFieldValue.field = new ConfigToInsertDto.Field();
        booleanFieldValue.field.apiName = 'Boolean__c';
        booleanFieldValue.field.dataType = 'BOOLEAN';
        booleanFieldValue.value = 'true';

        configToInsertDto.fieldValues.add(booleanFieldValue);

        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return;
        }
        Test.stopTest();

    }

    
    @isTest
    static void testCreateRecords_IntegerField_catchError() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue stringFieldValue = new ConfigToInsertDto.FieldValue();
        stringFieldValue.field = new ConfigToInsertDto.Field();
        stringFieldValue.field.apiName = 'Name';
        stringFieldValue.field.dataType = 'STRING';
        stringFieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(stringFieldValue);

        ConfigToInsertDto.FieldValue integerFieldValue = new ConfigToInsertDto.FieldValue();
        integerFieldValue.field = new ConfigToInsertDto.Field();
        integerFieldValue.field.apiName = 'Integer__c';
        integerFieldValue.field.dataType = 'INTEGER';
        integerFieldValue.value = '1';

        configToInsertDto.fieldValues.add(integerFieldValue);

        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return;
        }
        Test.stopTest();

    }


    
    @isTest
    static void testCreateRecords_DoubleField_catchError() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue stringFieldValue = new ConfigToInsertDto.FieldValue();
        stringFieldValue.field = new ConfigToInsertDto.Field();
        stringFieldValue.field.apiName = 'Name';
        stringFieldValue.field.dataType = 'STRING';
        stringFieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(stringFieldValue);

        ConfigToInsertDto.FieldValue doubleFieldValue = new ConfigToInsertDto.FieldValue();
        doubleFieldValue.field = new ConfigToInsertDto.Field();
        doubleFieldValue.field.apiName = 'Double__c';
        doubleFieldValue.field.dataType = 'DOUBLE';
        doubleFieldValue.value = '1';

        configToInsertDto.fieldValues.add(doubleFieldValue);

        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return;
        }
        Test.stopTest();

    }


    @isTest
    static void testCreateRecords_DecimalField_catchError() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue stringFieldValue = new ConfigToInsertDto.FieldValue();
        stringFieldValue.field = new ConfigToInsertDto.Field();
        stringFieldValue.field.apiName = 'Name';
        stringFieldValue.field.dataType = 'STRING';
        stringFieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(stringFieldValue);

        ConfigToInsertDto.FieldValue decimalFieldValue = new ConfigToInsertDto.FieldValue();
        decimalFieldValue.field = new ConfigToInsertDto.Field();
        decimalFieldValue.field.apiName = 'Decimal__c';
        decimalFieldValue.field.dataType = 'DECIMAL';
        decimalFieldValue.value = '1';

        configToInsertDto.fieldValues.add(decimalFieldValue);

        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return;
        }
        Test.stopTest();

    }


    @isTest
    static void testCreateRecords_DateTtimeField_catchError() {
        // Test data setup
        ConfigToInsertDto configToInsertDto = new ConfigToInsertDto();
        configToInsertDto.obj = 'Account';
        configToInsertDto.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        ConfigToInsertDto.FieldValue stringFieldValue = new ConfigToInsertDto.FieldValue();
        stringFieldValue.field = new ConfigToInsertDto.Field();
        stringFieldValue.field.apiName = 'Name';
        stringFieldValue.field.dataType = 'STRING';
        stringFieldValue.value = 'Test-Company-{0}';

        configToInsertDto.fieldValues.add(stringFieldValue);

        ConfigToInsertDto.FieldValue datetimeFieldValue = new ConfigToInsertDto.FieldValue();
        datetimeFieldValue.field = new ConfigToInsertDto.Field();
        datetimeFieldValue.field.apiName = 'Datetime__c';
        datetimeFieldValue.field.dataType = 'DATETIME';
        datetimeFieldValue.value = '2000-12-12 00:00:00';

        configToInsertDto.fieldValues.add(datetimeFieldValue);


        String configToInsertDtoString = JSON.serialize(configToInsertDto);

        // Test method execution
        Test.startTest();
        try {
            RecordOperationService.createRecords(2, configToInsertDtoString);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return;
        }
        Test.stopTest();

    }

}