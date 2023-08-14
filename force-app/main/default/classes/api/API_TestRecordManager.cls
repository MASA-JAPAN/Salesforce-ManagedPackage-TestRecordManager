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

}