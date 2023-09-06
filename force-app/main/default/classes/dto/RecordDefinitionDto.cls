public with sharing class RecordDefinitionDto {
    public Id id;
    public String name;
    public String obj;
    public List<FieldValue> fieldValues;

    public class FieldValue {
        public String field;
        public String value;
    }
}