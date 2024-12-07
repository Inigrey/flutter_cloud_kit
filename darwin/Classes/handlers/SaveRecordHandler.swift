import CloudKit

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

class SaveRecordHandler {
    static func handle(arguments: Dictionary<String, Any>, result: @escaping FlutterResult) -> Void {
        let database: CKDatabase;
        let recordType: String;
        let recordValues: Dictionary<String, Any>;
        
        if let databaseOpt = getDatabaseFromArgs(arguments: arguments) {
            database = databaseOpt;
        } else {
            return result(createFlutterError(message: "Cannot create a database for the provided scope"));
        }
        
        if let recordTypeOpt = getRecordTypeFromArgs(arguments: arguments) {
            recordType = recordTypeOpt;
        } else {
            return result(createFlutterError(message: "Couldn't parse the required parameter 'recordType'"));
        }
        
        if let recordValuesOpt = getRecordValuesFromArgs(arguments: arguments) {
            recordValues = recordValuesOpt;
        } else {
            return result(createFlutterError(message: "Couldn't parse the required parameter 'record'"));
        }
        
        let recordId = getRecordIdFromArgsOrDefault(arguments: arguments);
        database.fetch(withRecordID: recordId) { (record, error) in
            if (record == nil) {
               record = CKRecord(recordType: recordType, recordID: recordId);
            }
            record.setValuesForKeys(recordValues);
            database.save(record) { (record, error) in
                if (error != nil) {
                    return result(createFlutterError(message: error!.localizedDescription));
                }
                if (record == nil) {
                    return result(createFlutterError(message: "Got nil while saving the record"));
                }
                return result(true);
            }
        }
    }
}
