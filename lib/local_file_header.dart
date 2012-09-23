/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

library LocalFileHeader;

import 'zip.dart';
import 'util.dart';
import 'dart:utf';

class LocalFileHeader {
  List<int> _chunk;
  List<int> content;
  var versionNeededToExtract;
  var generalPurposeBitFlag;
  var compressionMethod;
  var lastModFileTime;
  var lastModifiedFileTime;
  var lastModifiedFileDate;
  var crc32;
  var compressedSize;
  var uncompressedSize;
  var filenameLength;
  var extraFieldLength;
  var filename;
  var extraField;

  LocalFileHeader(List<int> this._chunk) {
    this._process();
  }

  void _process() {
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

    assert(this._chunk.getRange(0, 4) == Zip.LOCAL_FILE_HEADER_SIGNATURE);

    this.versionNeededToExtract = this._chunk.getRange(4, 2);
    this.generalPurposeBitFlag = this._chunk.getRange(6, 2);
    this.compressionMethod = this._chunk.getRange(8, 2);
    this.lastModifiedFileTime = this._chunk.getRange(10, 2);
    this.lastModifiedFileDate = this._chunk.getRange(12, 2);
    this.crc32 = this._chunk.getRange(14, 4);
    this.compressedSize = bytesToValue(this._chunk.getRange(18, 4));
    this.uncompressedSize = bytesToValue(this._chunk.getRange(22, 4));
    this.filenameLength = bytesToValue(this._chunk.getRange(26, 2));
    this.extraFieldLength = bytesToValue(this._chunk.getRange(28, 2));
    this.filename = new String.fromCharCodes(this._chunk.getRange(30, this.filenameLength));

    if (this.extraFieldLength) {
      this.extraField = this._chunk.getRange(30 + this.filenameLength, this.extraFieldLength);
    }

    this.content = this._chunk.getRange(30 + this.filenameLength + this.extraFieldLength, this.compressedSize);
  }
}