/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

library EndOfCentralDirectoryRecord;

import 'zip.dart';
import 'util.dart';

/**
 * Creates a new instance of the End of Central Directory Record.
 */
class EndOfCentralDirectoryRecord {
  var numberOfThisDisk = [0x00, 0x00];
  var numberOfTheDiskWithTheStartOfTheCentralDirectory = [0x00, 0x00];
  var totalCentralDirectoryEntriesOnThisDisk = [0x00, 0x00];
  var totalCentralDirectoryEntries = 0;
  var centralDirectorySize;
  var centralDirectoryOffset;
  var zipFileCommentLength;
  var zipFileComment = '';

  EndOfCentralDirectoryRecord();

  /**
   * Returns the bytes for this header.
   */
  List<int> save() {
    var bytes = new List<int>();

    bytes.addAll(Zip.END_OF_CENTRAL_DIRECTORY_RECORD_SIGNATURE.charCodes());
    bytes.addAll(numberOfThisDisk);
    bytes.addAll(numberOfTheDiskWithTheStartOfTheCentralDirectory);
    bytes.addAll(totalCentralDirectoryEntriesOnThisDisk);
    bytes.addAll(valueToBytes(totalCentralDirectoryEntries, 2));
    bytes.addAll(valueToBytes(centralDirectorySize, 4));
    bytes.addAll(valueToBytes(centralDirectoryOffset, 4));
    bytes.addAll(valueToBytes(zipFileComment.length, 2));
    bytes.addAll(zipFileComment.charCodes());

    return bytes;
  }

  /**
   * Instantiates a new End of Central Directory Record based on the chunk of data.
   *
   * Every property will be set according to the bytes in the chunk.
   */
  EndOfCentralDirectoryRecord.fromData(List<int> chunk) {
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

    numberOfThisDisk = bytesToValue(chunk.getRange(4, 2));
    numberOfTheDiskWithTheStartOfTheCentralDirectory = bytesToValue(chunk.getRange(6, 2));
    totalCentralDirectoryEntriesOnThisDisk = bytesToValue(chunk.getRange(8, 2));
    totalCentralDirectoryEntries = bytesToValue(chunk.getRange(10, 2));
    centralDirectorySize = bytesToValue(chunk.getRange(12, 4));
    centralDirectoryOffset = bytesToValue(chunk.getRange(16, 4));
    zipFileCommentLength = bytesToValue(chunk.getRange(20, 2));
    zipFileComment = new String.fromCharCodes(chunk.getRange(22, zipFileCommentLength));
  }
}