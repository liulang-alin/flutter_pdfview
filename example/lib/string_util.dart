class StringUtil{
  static String breakWord(String s) {
    if (null==s || s.isEmpty) {
      return s;
    }
    String breakWord = ' ';
    for (var element in s.runes) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    }
    return breakWord;
  }

  static bool isNotEmpty(String s){
    return null!=s&&s.isNotEmpty;
  }

  static bool isEmpty(String s){
    return s==null || s.isEmpty;
  }

}