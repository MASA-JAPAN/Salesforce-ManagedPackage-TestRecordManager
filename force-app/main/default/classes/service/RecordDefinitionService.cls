public with sharing class RecordDefinitionService {

    @AuraEnabled
    public static void upsertDefinition(Object recordDefinitionDtoString){

        throwIfDefinitionIsInvalid(recordDefinitionDtoString);

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);

        RecordDefinition__c recordDefinition = new RecordDefinition__c();

        if (String.isNotEmpty(recordDefinitionDto.id)) {
            recordDefinition.Id = recordDefinitionDto.id;
        }

        recordDefinition.Name = recordDefinitionDto.name;
        recordDefinition.Object__c = recordDefinitionDto.obj;
        recordDefinition.FieldValues__c = JSON.serialize(recordDefinitionDto.keyedFieldValues);

        upsert recordDefinition;

    }

    @AuraEnabled
    public static List<RecordDefinition__c> getRecordDefinitions() {
        return [SELECT Id, Name, Object__c, CreatedDate, FieldValues__c, LastModifiedDate FROM RecordDefinition__c ORDER BY LastModifiedDate DESC];
    }

    @AuraEnabled
    public static void deleteDefinition(Id id) {
        RecordDefinition__c recordDefinitionToDelete = new RecordDefinition__c();
        recordDefinitionToDelete.Id = id;
        delete recordDefinitionToDelete;
    }

    
    @AuraEnabled
    public static void throwIfDefinitionIsInvalid(Object recordDefinitionDtoString){

        Savepoint sp = Database.setSavepoint();
        try {
            RecordOperationService.createRecords(1, recordDefinitionDtoString);
        } catch (Exception e) {
            throw new RecordDefinitionServiceException('Invalid definition: This definition will cause this error [ ' + e.getMessage() + ']');
        }
        Database.rollback(sp);

    }

    public class RecordDefinitionServiceException extends Exception {}

}