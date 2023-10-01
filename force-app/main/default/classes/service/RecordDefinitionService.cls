public with sharing class RecordDefinitionService {

    @AuraEnabled
    public static void upsertDefinition(Object recordDefinitionDtoString){

        RecordDefinitionDto recordDefinitionDto = (RecordDefinitionDto) JSON.deserialize(String.valueOf(recordDefinitionDtoString), RecordDefinitionDto.class);
        ConfigToInsertDto configToInsert = makeConfigToInsert(recordDefinitionDto);

        throwIfConfigIsInvalid(new List<ConfigToInsertDto>{configToInsert});

        RecordDefinition__c recordDefinition = new RecordDefinition__c();

        if (String.isNotEmpty(recordDefinitionDto.id)) {
            recordDefinition.Id = recordDefinitionDto.id;
        }

        recordDefinition.Name = recordDefinitionDto.name;
        recordDefinition.Tag__c = recordDefinitionDto.tag;
        recordDefinition.Object__c = recordDefinitionDto.obj;
        recordDefinition.ConfigToInsert__c = JSON.serialize(configToInsert);

        upsert recordDefinition;

    }

    @AuraEnabled
    public static void createDefinitions(List<RecordDefinitionDto> recordDefinitionDtoStrings){

        List<RecordDefinition__c> recordDefinitions = new List<RecordDefinition__c>();
        List<ConfigToInsertDto> configsToInsert = new List<ConfigToInsertDto>();

        for (RecordDefinitionDto recordDefinitionDto : recordDefinitionDtoStrings) {

            ConfigToInsertDto configToInsert = makeConfigToInsert(recordDefinitionDto);
            configsToInsert.add(configToInsert);

            RecordDefinition__c recordDefinition = new RecordDefinition__c();
            recordDefinition.Name = recordDefinitionDto.name;
            recordDefinition.Object__c = recordDefinitionDto.obj;
            recordDefinition.ConfigToInsert__c = JSON.serialize(configToInsert);
            recordDefinitions.add(recordDefinition);
        }

        throwIfConfigIsInvalid(configsToInsert);

        insert recordDefinitions;

    }

    @AuraEnabled
    public static void insertTagsIfUnexisting(List<String> tags){
        
        List<Tag__c> existingTagObjs = [SELECT Id, Name FROM Tag__c WHERE Name = :tags];
        Set<String> existingTags = new Set<String>();

        for (Tag__c tagObj : existingTagObjs) {
            existingTags.add(tagObj.Name);
        }

        List<Tag__c> tagsToInsert = new List<Tag__c>();
        for (String tag : tags) {

            if (!existingTags.contains(tag)) {
                Tag__c tagObj = new Tag__c();
                tagObj.Name = tag;
                tagsToInsert.add(tagObj);
            }

        }

        System.debug(tagsToInsert);

        insert tagsToInsert;

    }

    @AuraEnabled
    public static void deleteTagsIfUnused(List<String> tags){

        List<String> unusedTags = new List<String>();

        List<RecordDefinition__c> definitions = [SELECT Id, Tag__c FROM RecordDefinition__c WHERE Tag__c = :tags];
        Map<String, RecordDefinition__c> tagToDefinitionMap = new Map<String, RecordDefinition__c>();
        for (RecordDefinition__c definition : definitions) {
            tagToDefinitionMap.put(definition.Tag__c, definition);
        }

        for (String tag : tags) {
            if (tagToDefinitionMap.get(tag) == null) {
                unusedTags.add(tag);
            }
        }

        List<Tag__c> tagsToDelete = [SELECT Id FROM Tag__c WHERE Name = :unusedTags];

        System.debug(tagsToDelete);

        delete tagsToDelete;

    }


    @AuraEnabled
    public static List<RecordDefinition__c> getAllRecordDefinitions() {
        return [SELECT Id, Name, Tag__c, Object__c, CreatedDate, ConfigToInsert__c, LastModifiedDate FROM RecordDefinition__c ORDER BY LastModifiedDate DESC];
    }

    @AuraEnabled
    public static List<Tag__c> getAllTags() {
        return [SELECT Id, Name FROM Tag__c ORDER BY Name ASC];
    }

    @AuraEnabled
    public static List<RecordDefinition__c> searchRecordDefinitions(String searchInput) {

        if (String.isEmpty(searchInput)) {
            return getAllRecordDefinitions();
        } else {
            String searchInputForPartialMatch = '%' + searchInput + '%'; 
            return [SELECT Id, Name, Object__c, CreatedDate, ConfigToInsert__c, LastModifiedDate FROM RecordDefinition__c WHERE Name LIKE :searchInputForPartialMatch ORDER BY LastModifiedDate DESC];            
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

        for (RecordDefinitionDto.FieldValue fieldValue : recordDefinition.fieldValues) {
            if (fieldMap.containsKey(fieldValue.field)) {
                ConfigToInsertDto.FieldValue fieldValueOfConfigToInsertDto = new ConfigToInsertDto.FieldValue();
                ConfigToInsertDto.Field field = new ConfigToInsertDto.Field();
                field.apiName = fieldValue.field;
                field.dataType = fieldMap.get(fieldValue.field).getDescribe().getType().name();
                fieldValueOfConfigToInsertDto.field = field;
                fieldValueOfConfigToInsertDto.value = fieldValue.value;
                configToInsert.fieldValues.add(fieldValueOfConfigToInsertDto);
            } else {
                throw new RecordDefinitionServiceException(fieldValue.field + ' does not exist');
            }
        }

        return configToInsert;

    }

    private static void throwIfConfigIsInvalid(List<ConfigToInsertDto> configsToInsert){
        List<Object> configToInsertDtoStrings = new List<Object>();
        for (ConfigToInsertDto config : configsToInsert) {
            configToInsertDtoStrings.add(JSON.serialize(config));
        }

        Savepoint sp = Database.setSavepoint();
        try {
            RecordOperationService.createRecords(configToInsertDtoStrings);
        } catch (Exception e) {
            throw new RecordDefinitionServiceException('Invalid definition: This definition will cause this error [ ' + e.getMessage() + ']');
        }
        Database.rollback(sp);

    }

    public static ParsedSoql parseSoql(String soqlQuery) {
        ParsedSoql parsedSoql = new ParsedSoql();
        
        Pattern objectPattern = Pattern.compile('SELECT\\s+.*?FROM\\s+(\\w+)');
        Matcher objectMatcher = objectPattern.matcher(soqlQuery);
        if (objectMatcher.find()) {
            parsedSoql.obj = objectMatcher.group(1);
        } else {
            throw new IllegalArgumentException('Invalid SOQL query: Cannot determine object');
        }
        
        Pattern fieldPattern = Pattern.compile('SELECT\\s+(.*?)\\s+FROM\\s+\\w+');
        Matcher fieldMatcher = fieldPattern.matcher(soqlQuery);
        if (fieldMatcher.find()) {
            String fieldStr = fieldMatcher.group(1);
            parsedSoql.fields = new List<String>(fieldStr.split('\\s*,\\s*'));
        } else {
            throw new IllegalArgumentException('Invalid SOQL query: Cannot determine fields');
        }
        
        return parsedSoql;
    }

    public class ParsedSoql {
        public String obj;
        public List<String> fields;
    }

    public class RecordDefinitionServiceException extends Exception {}

}