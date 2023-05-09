public with sharing class RecordDefinitionService {

    @AuraEnabled
    public static void createDefinition(Object recordDefinitionDtoString){

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);

        RecordDefinition__c recordDefinition = new RecordDefinition__c();
        recordDefinition.Name = recordDefinitionDto.id;
        recordDefinition.Name = recordDefinitionDto.name;
        recordDefinition.Object__c = recordDefinitionDto.obj;
        recordDefinition.Record_Values__c = JSON.serialize(recordDefinitionDto.fieldToValueWithKeys);

        Database.upsert(recordDefinition);
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordDefinition__c> getRecordDefinitions() {
        return [SELECT Id, Name, Object__c, CreatedDate, Record_Values__c, LastModifiedDate FROM RecordDefinition__c];
    }

}