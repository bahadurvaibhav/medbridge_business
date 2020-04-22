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
