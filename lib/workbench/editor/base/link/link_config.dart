import 'package:flutter/painting.dart';
import 'package:slate/slate.dart';


const linkPrefixes = [
  'mailto:', // email
  'tel:', // telephone
  'sms:', // SMS
  'callto:',
  'wtai:',
  'market:',
  'geopoint:',
  'ymsgr:',
  'msnim:',
  'gtalk:', // Google Talk
  'skype:',
  'sip:', // Lync
  'whatsapp:',
  'http'
];

enum LinkMenuAction {
  launch,
  copy,
  remove,
  none,
}


/// 获得链接范围
TextRange getLinkRange(Node node) {
  // var start = node.documentOffset;
  // var length = node.length;
  // var prev = node.previous;
  // final linkAttr = node.attributes[Attribute.link.key]!;
  // while (prev != null) {
  //   if (prev.style.attributes[Attribute.link.key] == linkAttr) {
  //     start = prev.documentOffset;
  //     length += prev.length;
  //     prev = prev.previous;
  //   } else {
  //     break;
  //   }
  // }
  //
  // var next = node.next;
  // while (next != null) {
  //   if (next.style.attributes[Attribute.link.key] == linkAttr) {
  //     length += next.length;
  //     next = next.next;
  //   } else {
  //     break;
  //   }
  // }
  // return TextRange(start: start, end: start + length);
  return const TextRange(start: 0, end: 0);
}

