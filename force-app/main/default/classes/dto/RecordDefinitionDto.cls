public with sharing class RecordDefinitionDto {
    public Id id;
    public String name;
    public String obj;
    public List<KeyedFieldValue> keyedFieldValues;

    public class KeyedFieldValue {
        public String key;
        public FieldValue fieldValue;
    }

    public class FieldValue {
        public String field;
        public String value;
    }
}