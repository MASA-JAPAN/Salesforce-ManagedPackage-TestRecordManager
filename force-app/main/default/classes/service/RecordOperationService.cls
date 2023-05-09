public with sharing class RecordOperationService {

    @AuraEnabled
    public static void createRecords(Integer numberOfCreation, RecordDefinitionDto recordDefinitionDto){

        if (numberOfCreation > 5000) {
            throw new RecordOperationServiceException('Max size is 5000');
        }

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(recordDefinitionDto.obj);
        if (objectType == null) {
            throw new RecordOperationServiceException('Object does not exist');
        }
        
        List<sObject> recordsToCreate = new List<sObject>();

        for (Integer i = 0; i < numberOfCreation; i++) {
            sObject record = objectType.newSObject();
            for (RecordDefinitionDto.FieldToValueWithKey fieldToValueWithKey : recordDefinitionDto.fieldToValueWithKeys) {
                String value = fieldToValueWithKey.fieldToValue.value;
                if (value.contains('{0}')) {
                    value.replace('{0}', String.valueOf(i));
                }
                record.put(fieldToValueWithKey.fieldToValue.field, value);
            }
            recordsToCreate.add(record);
        }

        Database.SaveResult[] saveResults = Database.insert(recordsToCreate, false);

        RecordCreationLog__c log = new RecordCreationLog__c();

        Integer success = 0;
        List<Id> createdRecordIds = new List<Id>();
        Integer error = 0;
        String errorMessage = '';

        for (Database.SaveResult result : saveResults) {
            if (result.isSuccess()) {
                success++;
                createdRecordIds.add(result.getId());
            } else {
                error++;
                errorMessage += '[' + result.getErrors() + ']';
            }
        }

        log.Object__c = recordDefinitionDto.obj;
        log.Success__c = success;
        log.Created_Record_Ids__c = createdRecordIds.toString();
        log.Error__c = error;
        log.Error_Message__c = errorMessage.abbreviate(131072); // max size of error message

        insert log;

    }

    public class RecordOperationServiceException extends Exception {}

}