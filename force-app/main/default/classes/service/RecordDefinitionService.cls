public with sharing class RecordDefinitionService {

    @AuraEnabled
    public static void upsertDefinition(Object recordDefinitionDtoString){

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);
        ConfigToInsertDto configToInsert = makeConfigToInsert(recordDefinitionDto);

        RecordDefinition__c recordDefinition = new RecordDefinition__c();

        if (String.isNotEmpty(recordDefinitionDto.id)) {
            recordDefinition.Id = recordDefinitionDto.id;
        }

        recordDefinition.Name = recordDefinitionDto.name;
        recordDefinition.Object__c = recordDefinitionDto.obj;
        recordDefinition.FieldValuesToEdit__c = JSON.serialize(recordDefinitionDto.keyedFieldValues);
        recordDefinition.ConfigToInsert__c = JSON.serialize(configToInsert);

        upsert recordDefinition;

    }

    @AuraEnabled
    public static List<RecordDefinition__c> getAllRecordDefinitions() {
        return [SELECT Id, Name, Object__c, CreatedDate, FieldValuesToEdit__c, ConfigToInsert__c, LastModifiedDate FROM RecordDefinition__c ORDER BY LastModifiedDate DESC];
    }

    @AuraEnabled
    public static List<RecordDefinition__c> searchRecordDefinitions(String searchInput) {

        if (String.isEmpty(searchInput)) {
            return getAllRecordDefinitions();
        } else {
            String searchInputForPartialMatch = '%' + searchInput + '%'; 
            return [SELECT Id, Name, Object__c, CreatedDate, FieldValuesToEdit__c, ConfigToInsert__c, LastModifiedDate FROM RecordDefinition__c WHERE Name LIKE :searchInputForPartialMatch ORDER BY LastModifiedDate DESC];            
        }

    }

    @AuraEnabled
    public static void deleteDefinition(Id id) {
        RecordDefinition__c recordDefinitionToDelete = new RecordDefinition__c();
        recordDefinitionToDelete.Id = id;
        delete recordDefinitionToDelete;
    }

    private static ConfigToInsertDto makeConfigToInsert(RecordDefinitionDto recordDefinition){
        ConfigToInsertDto configToInsert = new ConfigToInsertDto();
        configToInsert.obj = recordDefinition.obj;
        configToInsert.fieldValues = new List<ConfigToInsertDto.FieldValue>();

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(recordDefinition.obj);

        if (sobjectType == null) {
            throw new RecordDefinitionServiceException('Object does not exist');
        }

        Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();

        for (RecordDefinitionDto.KeyedFieldValue keyedFieldValue : recordDefinition.keyedFieldValues) {
            if (fieldMap.containsKey(keyedFieldValue.fieldValue.field)) {
                ConfigToInsertDto.FieldValue fieldValue = new ConfigToInsertDto.FieldValue();
                ConfigToInsertDto.Field field = new ConfigToInsertDto.Field();
                field.apiName = keyedFieldValue.fieldValue.field;
                field.dataType = fieldMap.get(keyedFieldValue.fieldValue.field).getDescribe().getType().name();
                fieldValue.field = field;
                fieldValue.value = keyedFieldValue.fieldValue.value;
                configToInsert.fieldValues.add(fieldValue);
            } else {
                throw new RecordDefinitionServiceException(keyedFieldValue.fieldValue.field + ' does not exist');
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            RecordOperationService.createRecords(new List<Object>{JSON.serialize(configToInsert)});
        } catch (Exception e) {
            throw new RecordDefinitionServiceException('Invalid definition: This definition will cause this error [ ' + e.getMessage() + ']');
        }
        Database.rollback(sp);

        return configToInsert;

    }

    public class RecordDefinitionServiceException extends Exception {}

}