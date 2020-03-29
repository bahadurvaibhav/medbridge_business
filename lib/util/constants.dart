const String TOTAL_PATIENTS = 'TOTAL PATIENTS';
const String TREATMENTS_ONGOING = 'TREATMENTS ONGOING';
const String TREATMENTS_COMPLETED = 'TREATMENTS COMPLETED';
const String ADD_NEW_PATIENT = 'Add New Patient';

const String API_KEY = 'QXmjfzsnC7wzhYsDGUuBnTXMrwTh2xZv';

const String BASE_URL = 'http://connectinghealthcare.in/api/business/';
const String UPLOAD_DOCUMENT_URL = BASE_URL + 'uploadDocument.php';

const int DOCUMENT_MAX_SIZE = 10;
const List<String> ALLOWED_DOCUMENT_EXTENSIONS = [
  '.jpg',
  '.jpeg',
  '.png',
  '.pdf'
];
const String DOCUMENT_MAX_SIZE_EXCEEDED_TITLE = 'File size too big';
const String DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE =
    'Uploaded file is bigger than $DOCUMENT_MAX_SIZE MB';
const String DOCUMENT_INVALID_EXTENSION_TITLE = 'File extension not supported';
const String DOCUMENT_INVALID_EXTENSION_SUBTITLE =
    'Files with following extensions are supported: ';
