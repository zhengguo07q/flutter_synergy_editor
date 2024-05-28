import 'package:flutter/widgets.dart';
import 'package:slate/slate.dart';

import '../../updater/document_controller.dart';

typedef EmbedBuilder = Widget Function(BuildContext context,
    DocumentController controller, Node node, bool readOnly);

class Embed{
  static bool isEmbed(Node node){
    if(node.type == "") {
      return true;
    }
    return false;
  }

  // Refer to https://www.fileformat.info/info/unicode/char/fffc/index.htm
  static const kObjectReplacementCharacter = '\uFFFC';
  static const kObjectReplacementInt = 65532;
}