/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

#library('CentralDirectoryFileHeader');

#import('Zip.dart');
#import('Util.dart');
#import('dart:utf');

/**
 * Creates a new instance of the Central Directory File Header.
 */
class CentralDirectoryFileHeader {
  List<int> _data;

  var signature = Zip.CENTRAL_DIRECTORY_FILE_HEADER_SIGNATURE;
  var versionMadeBy;
  var versionNeededToExtract;
  var generalPurposeBitFlag;
  var compressionMethod;
  var lastModifiedFileTime;
  var lastModifiedFileDate;
  var crc32;
  var compressedSize;
  var uncompressedSize;
  var filenameLength;
  var extraFieldLength;
  var fileCommentLength;
  var diskNumberStart;
  var internalFileAttributes;
  var externalFileAttributes;
  var localHeaderOffset;
  var filename;
  var extraField;
  var fileComment;

  CentralDirectoryFileHeader(List<int> data) {
    this._data = data;
    this._process();
  }

/**
* Reads the data and sets the information to class members.
*/
  void _process() {
    //   File header:
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

    this.versionMadeBy = this._data.getRange(4, 2);
    this.versionNeededToExtract = this._data.getRange(6, 2);
    this.generalPurposeBitFlag = this._data.getRange(8, 2);
    this.compressionMethod = this._data.getRange(10, 2);
    this.lastModifiedFileTime = this._data.getRange(12, 2);
    this.lastModifiedFileDate = this._data.getRange(14, 2);
    this.crc32 = this._data.getRange(16, 4);
    this.compressedSize = bytesToValue(this._data.getRange(20, 4));
    this.uncompressedSize = bytesToValue(this._data.getRange(24, 4));
    this.filenameLength = bytesToValue(this._data.getRange(28, 2));
    this.extraFieldLength = bytesToValue(this._data.getRange(30, 2));
    this.fileCommentLength = bytesToValue(this._data.getRange(32, 2));
    this.diskNumberStart = bytesToValue(this._data.getRange(34, 2));
    this.internalFileAttributes = bytesToValue(this._data.getRange(36, 2));
    this.externalFileAttributes = bytesToValue(this._data.getRange(38, 4));
    this.localHeaderOffset = bytesToValue(this._data.getRange(42, 4));
    this.filename = new String.fromCharCodes(this._data.getRange(46, this.filenameLength));
    this.extraField = this._data.getRange(46 + this.filenameLength, this.extraFieldLength);
    this.fileComment = this._data.getRange(46 + this.filenameLength + this.extraFieldLength, this.fileCommentLength);
  }
}