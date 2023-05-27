public with sharing class RecordOperationService {

    @AuraEnabled
    public static void createRecords(Integer numberOfCreation, Object configToInsertDtoString){

        ConfigToInsertDto configToInsert = (ConfigToInsertDto) JSON.deserialize(String.valueOf(configToInsertDtoString), ConfigToInsertDto.class);

        if (numberOfCreation > 5000) {
            throw new RecordOperationServiceException('Max size is 5000');
        }

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(configToInsert.obj);

        List<sObject> recordsToCreate = new List<sObject>();

        for (Integer i = 0; i < numberOfCreation; i++) {
            sObject record = objectType.newSObject();
            for (ConfigToInsertDto.FieldValue fieldValue : configToInsert.fieldValues) {

                switch on fieldValue.field.dataType {
                    when 'STRING' {
                        String value = fieldValue.value;
                        if (value.contains('{0}')) {
                            value = value.replace('{0}', String.valueOf(i));
                        }
                        record.put(fieldValue.field.apiName, value);
                    }
                    when 'BOOLEAN' {
                        Boolean value = Boolean.valueOf(fieldValue.value);
                        record.put(fieldValue.field.apiName, value);
                    }
                    when 'INTEGER' {
                        String value = fieldValue.value;
                        if (value.contains('{0}')) {
                            value = value.replace('{0}', String.valueOf(i));
                        }
                        record.put(fieldValue.field.apiName, Integer.valueOf(value));
                    }
                    when 'DOUBLE' {
                        String value = fieldValue.value;
                        if (value.contains('{0}')) {
                            value = value.replace('{0}', String.valueOf(i));
                        }
                        record.put(fieldValue.field.apiName, Double.valueOf(value));
                    }
                    when 'DECIMAL' {
                        String value = fieldValue.value;
                        if (value.contains('{0}')) {
                            value = value.replace('{0}', String.valueOf(i));
                        }
                        record.put(fieldValue.field.apiName, Decimal.valueOf(value));
                    }
                    when 'DATETIME' {
                        Datetime value = Datetime.valueOf(fieldValue.value);
                        record.put(fieldValue.field.apiName, Datetime.valueOf(value));
                    }
                    when else {
                        String value = fieldValue.value;
                        if (value.contains('{0}')) {
                            value = value.replace('{0}', String.valueOf(i));
                        }
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