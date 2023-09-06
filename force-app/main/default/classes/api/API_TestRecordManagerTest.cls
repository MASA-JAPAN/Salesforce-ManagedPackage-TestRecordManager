@isTest
public class API_TestRecordManagerTest {

    @isTest
    static void testCreateAllDefinedRecords() {
        List<RecordDefinition__c> recordDefinitions = new List<RecordDefinition__c>();
        
        RecordDefinition__c recordDefinition1 = new RecordDefinition__c();
        recordDefinition1.Name = 'Test Definition Name 1';
        recordDefinition1.Object__c = 'Account';
        recordDefinition1.ConfigToInsert__c = '{"obj":"Account","fieldValues":[{"value":"Test-Company1","field":{"dataType":"STRING","apiName":"Name"}}]}';
        recordDefinitions.add(recordDefinition1);

        RecordDefinition__c recordDefinition2 = new RecordDefinition__c();
        recordDefinition2.Name = 'Test Definition Name 2';
        recordDefinition2.Object__c = 'Account';
        recordDefinition2.ConfigToInsert__c = '{"obj":"Account","fieldValues":[{"value":"Test-Company2","field":{"dataType":"STRING","apiName":"Name"}}]}';
        recordDefinitions.add(recordDefinition2);

        insert recordDefinitions;

        Test.startTest();
        API_TestRecordManager.createAllDefinedRecords();
        Test.stopTest();

        List<Account> actualAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(2, actualAccounts.size());
        System.assertEquals('Test-Company1', actualAccounts[0].Name);
        System.assertEquals('Test-Company2', actualAccounts[1].Name);
        
    }

    @isTest
    static void testCreateQueriedDefinedRecords() {
        List<RecordDefinition__c> recordDefinitions = new List<RecordDefinition__c>();
        
        RecordDefinition__c recordDefinition1 = new RecordDefinition__c();
        recordDefinition1.Name = 'Test Definition Name 1';
        recordDefinition1.Object__c = 'Account';
        recordDefinition1.ConfigToInsert__c = '{"obj":"Account","fieldValues":[{"value":"Test-Company1","field":{"dataType":"STRING","apiName":"Name"}}]}';
        recordDefinitions.add(recordDefinition1);

        RecordDefinition__c recordDefinition2 = new RecordDefinition__c();
        recordDefinition2.Name = 'Test Definition Name 2';
        recordDefinition2.Object__c = 'Account';
        recordDefinition2.ConfigToInsert__c = '{"obj":"Account","fieldValues":[{"value":"Test-Company2","field":{"dataType":"STRING","apiName":"Name"}}]}';
        recordDefinitions.add(recordDefinition2);

        insert recordDefinitions;

        Test.startTest();
        API_TestRecordManager.createQueriedDefinedRecords('Test Definition Name 1');
        Test.stopTest();

        List<Account> actualAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(1, actualAccounts.size());
        System.assertEquals('Test-Company1', actualAccounts[0].Name);
    }

    @isTest
    static void testCreateDefinitionsFromSoql() {

        List<Account> accountsToCreate = new List<Account>();
        Account account1 = new Account(Name = 'Company1');
        accountsToCreate.add(account1);
        Account account2 = new Account(Name = 'Company2');
        accountsToCreate.add(account2);
        insert accountsToCreate;

        Test.startTest();
        API_TestRecordManager.createDefinitionsFromSoql('SELECT Name FROM Account');
        Test.stopTest();

        // Assertion    
        List<RecordDefinition__c> recordDefinitions = [SELECT Id, Name, Object__c, ConfigToInsert__c FROM RecordDefinition__c ORDER BY Name];
        System.assertEquals(2, recordDefinitions.size());

        RecordDefinition__c recordDefinition1 = recordDefinitions[0];
        System.assertEquals('Account-Company1', recordDefinition1.Name);
        System.assertEquals('Account', recordDefinition1.Object__c);
        System.assertEquals('{"obj":"Account","fieldValues":[{"value":"Company1","field":{"dataType":"STRING","apiName":"Name"}}]}', recordDefinition1.ConfigToInsert__c);

        RecordDefinition__c recordDefinition2 = recordDefinitions[1];
        System.assertEquals('Account-Company2', recordDefinition2.Name);
        System.assertEquals('Account', recordDefinition2.Object__c);
        System.assertEquals('{"obj":"Account","fieldValues":[{"value":"Company2","field":{"dataType":"STRING","apiName":"Name"}}]}', recordDefinition2.ConfigToInsert__c);

    }
}