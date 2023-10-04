//const String apiUrl = "http://localhost:5048/api/v1";
const String apiUrl = "http://10.0.2.2:5048/api/v1";

String joinUrl(String append) => "$apiUrl/$append";

void appPrint(String message) => print("Zendrivers: $message");