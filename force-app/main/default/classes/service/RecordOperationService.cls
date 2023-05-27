public with sharing class RecordOperationService {

    @AuraEnabled
    public static void createRecords(Integer numberOfCreation, Object recordDefinitionDtoString){

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);

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
            for (RecordDefinitionDto.KeyedFieldValue keyedFieldValue : recordDefinitionDto.keyedFieldValues) {
                String value = keyedFieldValue.fieldValue.value;
                if (value.contains('{0}')) {
                    value = value.replace('{0}', String.valueOf(i));
                }
                record.put(keyedFieldValue.fieldValue.field, value);
            }
            recordsToCreate.add(record);
        }

        insert recordsToCreate;

    }

    public class RecordOperationServiceException extends Exception {}

}