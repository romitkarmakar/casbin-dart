import 'dart:io';
import 'dart:convert';

class Config {
  final String DEFAULT_SECTION = "default";
  final String DEFAULT_COMMENT = "#";
  final String DEFAULT_COMMENT_SEM = ';';
  final String DEFAULT_MULTILINE_SEPARATOR = '\\';

  Map<String, Map<String, String>> data;

  Config(String confName) {
    data = new Map();
    parse(confName);
  }

  Config.fromText(String text) {
    data = new Map();
    parseBuffer(text);
  }

  addConfig(String section, String option, String value) {
    if (section == "") section = DEFAULT_SECTION;
    if (data[section] == null) data[section] = new Map();
    data[section][option] = value;
  }

  parse(String fName) {
    File fFile = new File(fName);
    String text = fFile.readAsStringSync();

    parseBuffer(text);
  }

  parseBuffer(String buf) {
    String section;
    int lineNum = 0;
    bool canWrite = false;
    String temp = "";
    LineSplitter ls = new LineSplitter();

    List<String> buffer = ls.convert(buf);

    buffer.forEach((String line) {
      line = line.trim();
      if (canWrite) write(section, lineNum, line);
      lineNum++;

      if (line.startsWith(DEFAULT_COMMENT_SEM) || line.startsWith(DEFAULT_COMMENT)) return;
      else if(line.startsWith("[") && line.endsWith("]")) {
        write(section, lineNum, temp);
        section = line.substring(1, line.length - 1);
      } else if(line.endsWith(DEFAULT_MULTILINE_SEPARATOR)) temp += line.substring(0, line.length - 1);
      else temp += line;
    });

    write(section, lineNum, temp);
  }

  write(String section, int linenum, String b) {
    List<String> optionVal = b.split("=");
    String option = optionVal[0].trim();
    String value = optionVal[1].trim();

    addConfig(section, option, value);
  }

  set(String key, String value) {
    String section;
    String option;

    List<String> keys = key.split("::");
    if(keys.length >= 2) {
      section = keys[0];
      option = keys[1];
    } else option = keys[0];

    addConfig(section, option, value);
  }

  get(String key) {
    String section;
    String option;

    List<String> keys = key.split("::");
    if(keys.length >= 2) {
      section = keys[0];
      option = keys[1];
    } else option = keys[0];

    String value = data[section][option];

    return value;
  }
}
