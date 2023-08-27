public with sharing class RecordOperationService {

    @AuraEnabled
    public static void createRecords (List<Object> configToInsertDtoStrings){

        if (configToInsertDtoStrings.size() == 0) {
            throw new RecordOperationServiceException('Choose definitions to create records');
        }

        List<sObject> recordsToCreate = new List<sObject>();

        for (Object configToInsertDtoString : configToInsertDtoStrings) {
            ConfigToInsertDto configToInsert = (ConfigToInsertDto) JSON.deserialize(String.valueOf(configToInsertDtoString), ConfigToInsertDto.class);
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(configToInsert.obj);

            sObject record = objectType.newSObject();
            for (ConfigToInsertDto.FieldValue fieldValue : configToInsert.fieldValues) {

                switch on fieldValue.field.dataType {
                    when 'STRING' {
                        String value = fieldValue.value;
                        record.put(fieldValue.field.apiName, value);
                    }
                    when 'BOOLEAN' {
                        Boolean value = Boolean.valueOf(fieldValue.value);
                        record.put(fieldValue.field.apiName, value);
                    }
                    when 'INTEGER' {
                        String value = fieldValue.value;
                        record.put(fieldValue.field.apiName, Integer.valueOf(value));
                    }
                    when 'DOUBLE' {
                        String value = fieldValue.value;
                        record.put(fieldValue.field.apiName, Double.valueOf(value));
                    }
                    when 'DECIMAL' {
                        String value = fieldValue.value;
                        record.put(fieldValue.field.apiName, Decimal.valueOf(value));
                    }
                    when 'DATETIME' {
                        Datetime value = Datetime.valueOf(fieldValue.value);
                        record.put(fieldValue.field.apiName, value);
                    }
                    when 'DATE' {
                        Date value = Date.valueOf(fieldValue.value);
                        record.put(fieldValue.field.apiName, value);
                    }
                    when else {
                        String value = fieldValue.value;
                        record.put(fieldValue.field.apiName, value);
                    }
                }


            }
            recordsToCreate.add(record);

        }

        insert recordsToCreate;

    }


    public class RecordOperationServiceException extends Exception {}

}