/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

#library('EndOfCentralDirectoryRecord');

#import('Zip.dart');
#import('Util.dart');

/**
 * Creates a new instance of the End of Central Directory Record.
 */
class EndOfCentralDirectoryRecord {
  List<int> _chunk;
  var totalCentralDirectoryEntries;
  var centralDirectorySize;
  var centralDirectoryOffset;
  var zipFileCommentLength;
  var zipFileComment;

  EndOfCentralDirectoryRecord(List<int> this._chunk) {
    this._process();
  }

  /**
   * Reads the data and sets the information to class members.
   */
  void _process() {
    // I.  End of central directory record:
    //
    //   end of central dir signature    4 bytes  (0x06054b50)
    //   number of this disk             2 bytes
    //   number of the disk with the
    //   start of the central directory  2 bytes
    //   total number of entries in the
    //   central directory on this disk  2 bytes
    //   total number of entries in
    //   the central directory           2 bytes
    //   size of the central directory   4 bytes
    //   offset of start of central
    //   directory with respect to
    //   the starting disk number        4 bytes
    //   .ZIP file comment length        2 bytes
    //   .ZIP file comment               (variable size)

    this.totalCentralDirectoryEntries = bytesToValue(this._chunk.getRange(10, 2));
    this.centralDirectorySize = bytesToValue(this._chunk.getRange(12, 4));
    this.centralDirectoryOffset = bytesToValue(this._chunk.getRange(16, 4));
    this.zipFileCommentLength = bytesToValue(this._chunk.getRange(20, 2));
    this.zipFileComment = bytesToValue(this._chunk.getRange(22, this.zipFileCommentLength));
  }
}