public with sharing class ConfigToInsertDto {
    
    public String obj;
    public List<FieldValue> fieldValues;

    public class FieldValue {
        public Field field;
        public String value;
    }

    public class Field {
        public String apiName;
        public String dataType;
    }

}