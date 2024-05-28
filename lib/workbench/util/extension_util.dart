class ExtensionUtil{
  static createSingle({String text= 'Please set single'}) {
    return '''<single><block><line>$text</line></block></single>''';
  }
}