public with sharing class RecordDefinitionDto {
    public Id id;
    public String name;
    public String obj;
    public List<FieldToValueWithKey> fieldToValueWithKeys;

    public class FieldToValueWithKey {
        public String key;
        public FieldToValue fieldToValue;
    }

    public class FieldToValue {
        public String field;
        public String value;
    }
}