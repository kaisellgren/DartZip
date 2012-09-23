/*!
 * DartZip
 *
 * Copyright (C) 2012, Kai Sellgren
 * Licensed under the MIT License.
 * http://www.opensource.org/licenses/mit-license.php
 */

library CentralDirectory;

import 'zip.dart';
import 'central_directory_file_header.dart';
import 'util.dart';

/**
 * Creates a new instance of the Central Directory.
 */
class CentralDirectory {
  List<int> _chunk;
  List<int> _data;

  static final FILE_HEADER_STATIC_SIZE = 46; // The static size of the file header.

  List<CentralDirectoryFileHeader> fileHeaders;
  var digitalSignature;

  CentralDirectory(List<int> this._chunk, List<int> this._data) {
    this.fileHeaders = [];
    this._process();
  }

  /**
   * Reads the data and sets the information to class members.
   */
  void _process() {
    // [file header 1]
    //   .
    //   .
    //   .
    //   [file header n]
    //   [digital signature]
    //
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

    var position = 0;
    final signatureSize = Zip.CENTRAL_DIRECTORY_FILE_HEADER_SIGNATURE.length;
    final signatureCodes = Zip.CENTRAL_DIRECTORY_FILE_HEADER_SIGNATURE.charCodes();

    // Create file headers. Loop until we have gone through the entire buffer.
    while (true) {
      // Calculate sizes for dynamic parts.
      final filenameSize = bytesToValue(this._chunk.getRange(28, 2));
      final extraFieldSize = bytesToValue(this._chunk.getRange(30, 2));
      final fileCommentSize = bytesToValue(this._chunk.getRange(32, 2));

      final dynamicSize = filenameSize + fileCommentSize + extraFieldSize;
      final totalFileHeaderSize = dynamicSize + FILE_HEADER_STATIC_SIZE;

      // Push a new file header.
      if (this._chunk.length >= position + totalFileHeaderSize) {
        final buffer = this._chunk.getRange(position, totalFileHeaderSize);
        this.fileHeaders.add(new CentralDirectoryFileHeader(buffer, this._data));

        // Move the position pointer forward.
        position += totalFileHeaderSize;

        // Break out of the loop if the next 4 bytes do not match the right file header signature.
        if (this._chunk.length >= position + signatureSize && !listsAreEqual(this._chunk.getRange(position, signatureSize), signatureCodes)) {
          break;
        }
      } else {
        break;
      }
    }

    // TODO: Process the possible digital signature.
  }
}