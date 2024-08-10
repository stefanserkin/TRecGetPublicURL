// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

TREX1__Course_Session__c courseSession = [SELECT Id, Name FROM TREX1__Course_Session__c LIMIT 1];
System.debug('::::: courseSession type --> ' + courseSession.getSObjectType());