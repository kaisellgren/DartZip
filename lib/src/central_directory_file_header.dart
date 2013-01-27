/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

part of zip;

/**
 * Creates a new instance of the Central Directory File Header.
 */
class CentralDirectoryFileHeader {
  List<int> content;
  LocalFileHeader localFileHeader;

  var versionMadeBy = [0x00, 0x00];
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
  var fileCommentLength;
  var diskNumberStart;
  var internalFileAttributes;
  var externalFileAttributes;
  var localHeaderOffset;
  var filename = '';
  var extraField = [];
  var fileComment = '';

  CentralDirectoryFileHeader();

  /**
   * Creates a new Central Directory File Header based on the given Local File Header.
   */
  CentralDirectoryFileHeader.fromLocalFileHeader(LocalFileHeader lfh) {
    localFileHeader = lfh;

    filename = lfh.filename;
    crc32 = lfh.crc32;
    compressedSize = lfh.compressedSize;
    uncompressedSize = lfh.uncompressedSize;
  }

  /**
   * Returns the bytes for this header.
   */
  List<int> save() {
    var bytes = new List<int>();

    bytes.addAll(Zip.CENTRAL_DIRECTORY_FILE_HEADER_SIGNATURE.charCodes);
    bytes.addAll(versionMadeBy);
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
    bytes.addAll(valueToBytes(fileComment.length, 2));
    bytes.addAll(valueToBytes(diskNumberStart, 2));
    bytes.addAll(valueToBytes(internalFileAttributes, 2));
    bytes.addAll(valueToBytes(externalFileAttributes, 4));
    bytes.addAll(valueToBytes(localHeaderOffset, 4));
    bytes.addAll(filename.charCodes);
    bytes.addAll(extraField);
    bytes.addAll(fileComment.charCodes);

    return bytes;
  }

  /**
   * Instantiates a new Central Directory File Header based on the chunk of data.
   *
   * Every property will be set according to the bytes in the chunk.
   */
  CentralDirectoryFileHeader.fromData(List<int> chunk, List<int> this.content) {
    //  Central directory file header:
    //
    // 	central file header signature   4 bytes  (0x02014b50)
    // 	version made by                 2 bytes
    // 	version needed to extract       2 bytes
    // 	general purpose bit flag        2 bytes
    // 	compression method              2 bytes
    // 	last mod file time              2 bytes
    // 	last mod file date              2 bytes
    // 	crc-32                          4 bytes
    // 	compressed size                 4 bytes
    // 	uncompressed size               4 bytes
    // 	file name length                2 bytes
    // 	extra field length              2 bytes
    // 	file comment length             2 bytes
    // 	disk number start               2 bytes
    // 	internal file attributes        2 bytes
    // 	external file attributes        4 bytes
    // 	relative offset of local header 4 bytes
    //
    // 	file name (variable size)
    // 	extra field (variable size)
    // 	file comment (variable size)

    versionMadeBy = chunk.getRange(4, 2);
    versionNeededToExtract = chunk.getRange(6, 2);
    generalPurposeBitFlag = chunk.getRange(8, 2);
    compressionMethod = chunk.getRange(10, 2);
    lastModifiedFileTime = chunk.getRange(12, 2);
    lastModifiedFileDate = chunk.getRange(14, 2);
    crc32 = bytesToValue(chunk.getRange(16, 4));
    compressedSize = bytesToValue(chunk.getRange(20, 4));
    uncompressedSize = bytesToValue(chunk.getRange(24, 4));
    filenameLength = bytesToValue(chunk.getRange(28, 2));
    extraFieldLength = bytesToValue(chunk.getRange(30, 2));
    fileCommentLength = bytesToValue(chunk.getRange(32, 2));
    diskNumberStart = bytesToValue(chunk.getRange(34, 2));
    internalFileAttributes = bytesToValue(chunk.getRange(36, 2));
    externalFileAttributes = bytesToValue(chunk.getRange(38, 4));
    localHeaderOffset = bytesToValue(chunk.getRange(42, 4));
    filename = new String.fromCharCodes(chunk.getRange(46, filenameLength));
    extraField = chunk.getRange(46 + filenameLength, extraFieldLength);
    fileComment = new String.fromCharCodes(chunk.getRange(46 + filenameLength + extraFieldLength, fileCommentLength));

    // TODO: Are there scenarios where LocalFileHeader.compressedSize != CentralDirectoryFileHeader.compressedSize?
    localFileHeader = new LocalFileHeader.fromData(content.getRange(localHeaderOffset, content.length - localHeaderOffset));
  }
}