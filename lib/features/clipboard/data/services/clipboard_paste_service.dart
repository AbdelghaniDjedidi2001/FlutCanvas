export 'clipboard_paste_stub.dart'
    if (dart.library.html) 'clipboard_paste_web.dart'
    if (dart.library.io) 'clipboard_paste_io.dart';
