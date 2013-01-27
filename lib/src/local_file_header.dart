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

    assert(chunk.getRange(0, 4) == Zip.LOCAL_FILE_HEADER_SIGNATURE);

    versionNeededToExtract = chunk.getRange(4, 2);
    generalPurposeBitFlag = chunk.getRange(6, 2);
    compressionMethod = chunk.getRange(8, 2);
    lastModifiedFileTime = chunk.getRange(10, 2);
    lastModifiedFileDate = chunk.getRange(12, 2);
    crc32 = bytesToValue(chunk.getRange(14, 4));
    compressedSize = bytesToValue(chunk.getRange(18, 4));
    uncompressedSize = bytesToValue(chunk.getRange(22, 4));
    filenameLength = bytesToValue(chunk.getRange(26, 2));
    extraFieldLength = bytesToValue(chunk.getRange(28, 2));
    filename = new String.fromCharCodes(chunk.getRange(30, filenameLength));

    if (extraFieldLength) {
      extraField = chunk.getRange(30 + filenameLength, extraFieldLength);
    }

    content = chunk.getRange(30 + filenameLength + extraFieldLength, compressedSize);
  }
}