global with sharing class API_TestRecordManager {

    global static void createAllDefinedRecords(){

        List<Object> configToInserts = new List<Object>();

        List<RecordDefinition__c> recordDefinitions = [SELECT Id, ConfigToInsert__c FROM RecordDefinition__c];
        for (RecordDefinition__c recordDefinition : recordDefinitions) {
            configToInserts.add(recordDefinition.ConfigToInsert__c);
        }

        RecordOperationService.createRecords(configToInserts);

    } 

    global static void createQueriedDefinedRecords(String searchInput){

        List<Object> configToInserts = new List<Object>();

        List<RecordDefinition__c> recordDefinitions = RecordDefinitionService.searchRecordDefinitions(searchInput);
        for (RecordDefinition__c recordDefinition : recordDefinitions) {
            configToInserts.add(recordDefinition.ConfigToInsert__c);
        }

        RecordOperationService.createRecords(configToInserts);

    } 

    global static void createDefinitionsFromSoql(String soqlQuery){

        List<SObject> recordsForDefinition = new List<SObject>();

        try {
            recordsForDefinition = Database.query(soqlQuery);
        } catch (Exception e) {
            throw new API_TestRecordManagerException('Invalid soql: ' + e.getMessage());
        }

        RecordDefinitionService.ParsedSoql parsedSoql = RecordDefinitionService.parseSOQL(soqlQuery);

        List<RecordDefinitionDto> recordDefinitions = new List<RecordDefinitionDto>();

        for (SObject record : recordsForDefinition) {
            RecordDefinitionDto recordDefinition = new RecordDefinitionDto();
            recordDefinition.name = parsedSoql.obj + '-' + (String)record.get(parsedSoql.fields[0]);
            recordDefinition.obj = parsedSoql.obj;
            recordDefinition.fieldValues = new List<RecordDefinitionDto.FieldValue>();

            for (String field : parsedSoql.fields) {

                String value = String.valueOf(record.get(field));

                if (value == null) {
                    continue;
                }

                RecordDefinitionDto.FieldValue fieldValue = new RecordDefinitionDto.FieldValue();
                fieldValue = new RecordDefinitionDto.FieldValue();
                fieldValue.field = field;
                fieldValue.value = value;
                recordDefinition.fieldValues.add(fieldValue);
            }

            recordDefinitions.add(recordDefinition);

        }

        RecordDefinitionService.createDefinitions(recordDefinitions);

    }

    public class API_TestRecordManagerException extends Exception {}

}