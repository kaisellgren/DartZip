/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

part of zip;

class LocalFileHeader {
  List<int> content;

  var versionNeededToExtract = [0x00, 0x00];
  var generalPurposeBitFlag = [0x00, 0x00];
  var compressionMethod = [0x00, 0x00];
  var lastModifiedFileTime = [0x00, 0x00];
  var lastModifiedFileDate = [0x00, 0x00];
  int crc32;
  var compressedSize;
  var uncompressedSize;
  var filenameLength;
  var extraFieldLength;
  var filename = '';
  var extraField = [];

  LocalFileHeader();

  /**
   * Returns the bytes for this header.
   */
  List<int> save() {
    var bytes = new List<int>();

    bytes.addAll(Zip.LOCAL_FILE_HEADER_SIGNATURE.charCodes);
    bytes.addAll(versionNeededToExtract);
    bytes.addAll(generalPurposeBitFlag);
    bytes.addAll(compressionMethod);
    bytes.addAll(lastModifiedFileTime);
    bytes.addAll(lastModifiedFileDate);
    bytes.addAll(valueToBytes(crc32, 4));
    bytes.addAll(valueToBytes(compressedSize, 4));
    bytes.addAll(valueToBytes(uncompressedSize, 4));
    bytes.addAll(valueToBytes(filename.length, 2));
    bytes.addAll(valueToBytes(extraField.length, 2));
    bytes.addAll(filename.charCodes);
    bytes.addAll(extraField);
    bytes.addAll(content);

    return bytes;
  }

  /**
   * Instantiates a new Local File Header based on the chunk of data.
   *
   * Every property will be set according to the bytes in the chunk.
   */
  LocalFileHeader.fromData(List<int> chunk) {
    // Local file header:
    //
    // local file header signature     4 bytes  (0x04034b50)
    // version needed to extract       2 bytes
    // general purpose bit flag        2 bytes
    // compression method              2 bytes
    // last mod file time              2 bytes
    // last mod file date              2 bytes
    // crc-32                          4 bytes
    // compressed size                 4 bytes
    // uncompressed size               4 bytes
    // file name length                2 bytes
    // extra field length              2 bytes
    //
    // file name (variable size)
    // extra field (variable size)

    // assert(chunk.sublist(0, 4) == Zip.LOCAL_FILE_HEADER_SIGNATURE); // JPI - removed temporarily

    versionNeededToExtract = chunk.sublist(4, 4+2); // JPI 
    generalPurposeBitFlag = chunk.sublist(6, 6+2); // JPI 
    compressionMethod = chunk.sublist(8, 8+2); // JPI 
    lastModifiedFileTime = chunk.sublist(10, 10+2); // JPI 
    lastModifiedFileDate = chunk.sublist(12, 12+2); // JPI 
    crc32 = bytesToValue(chunk.sublist(14, 14+4)); // JPI 
    compressedSize = bytesToValue(chunk.sublist(18, 18+4)); // JPI 
    uncompressedSize = bytesToValue(chunk.sublist(22, 22+4)); // JPI 
    filenameLength = bytesToValue(chunk.sublist(26, 26+2)); // JPI 
    extraFieldLength = bytesToValue(chunk.sublist(28, 28+2)); // JPI 
    filename = new String.fromCharCodes(chunk.sublist(30, 30+filenameLength)); // JPI 

    if (extraFieldLength>0) { // JPI 
      extraField = chunk.sublist(30 + filenameLength, 30 + filenameLength + extraFieldLength); // JPI 
    }

    content = chunk.sublist(30 + filenameLength + extraFieldLength, 30 + filenameLength + extraFieldLength + compressedSize); // JPI 
  }
}