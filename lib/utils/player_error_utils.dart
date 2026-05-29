class PlayerErrorUtils {
  static String mapMpvError(String? error) {
    if (error == null || error.isEmpty) return 'An unknown error occurred.';

    final e = error.toLowerCase();
    
    // File/Network Errors
    if (e.contains('no such file') || e.contains('file not found') || e.contains('404')) {
      return 'The file or stream could not be found.';
    }
    if (e.contains('permission denied') || e.contains('403')) {
      return 'Access to this file was denied (check permissions).';
    }
    if (e.contains('connection refused') || e.contains('111')) {
      return 'The server refused the connection.';
    }
    if (e.contains('timed out') || e.contains('timeout')) {
      return 'The connection timed out. Please check your network.';
    }
    if (e.contains('host unreachable') || e.contains('113')) {
      return 'The remote server is unreachable.';
    }

    // Codec/Format Errors
    if (e.contains('unsupported format') || e.contains('demuxer failed')) {
      return 'This video format is not supported.';
    }
    if (e.contains('unsupported codec') || e.contains('decoder failed')) {
      return 'The video codec is not supported by your hardware.';
    }

    // Protocol Errors
    if (e.contains('smb') && e.contains('failed')) {
      return 'SMB connection failed. Verify server details and login.';
    }
    if (e.contains('ftp') && e.contains('failed')) {
      return 'FTP connection failed. Verify server details and login.';
    }

    // Fallback to original if we don't recognize it, but cleaned up
    return 'Playback Error: ${error.replaceAll(RegExp(r'^error:?\s*', caseSensitive: false), '')}';
  }
}
