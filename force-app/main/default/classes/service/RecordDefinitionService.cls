public with sharing class RecordDefinitionService {

    @AuraEnabled
    public static void upsertDefinition(Object recordDefinitionDtoString){

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);

        RecordDefinition__c recordDefinition = new RecordDefinition__c();

        if (String.isNotEmpty(recordDefinitionDto.id)) {
            recordDefinition.Id = recordDefinitionDto.id;
        }

        recordDefinition.Name = recordDefinitionDto.name;
        recordDefinition.Object__c = recordDefinitionDto.obj;
        recordDefinition.Field_Values__c = JSON.serialize(recordDefinitionDto.keyedFieldValues);

        Database.upsert(recordDefinition);
    }

    @AuraEnabled
    public static List<RecordDefinition__c> getRecordDefinitions() {
        return [SELECT Id, Name, Object__c, CreatedDate, Field_Values__c, LastModifiedDate FROM RecordDefinition__c ORDER BY LastModifiedDate DESC];
    }

}