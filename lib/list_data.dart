import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mastermind_project/list_item.dart';

class ListData extends ChangeNotifier {
  List<ListItem> _list = [];

  void updateList(String encodedList) {
    if (encodedList != null) {
      List decodedList = jsonDecode(encodedList);

      print(decodedList);

      List<ListItem> _listHolder = [];

      decodedList.forEach((item) {
        ListItem itemToAdd = ListItem(
          completed: item['completed'],
          text: item['text'],
        );

        _listHolder.add(itemToAdd);
      });

      _list = _listHolder;

      notifyListeners();
    }
  }

  int get listLength => _list.length;

  String get getListString {
    List _listHolder = [];

    _list.forEach((item) {
      Map<String, dynamic> itemToAdd = {
        "text": item.text,
        "completed": item.completed,
      };

      _listHolder.add(itemToAdd);
    });

    return json.encode(_listHolder);
  }

  String getItemText(int index) => _list[index].text;

  bool getItemStatus(int index) => _list[index].completed;

  bool hasCompleted() {
    List<ListItem> completeds = _list.where((item) => item.completed).toList();

    return completeds.length > 0;
  }

  void clearList() {
    _list = _list.where((item) => !item.completed).toList();

    notifyListeners();
  }

  void addItem(String text) {
    _list.add(ListItem(text: text));

    notifyListeners();
  }

  void toggleItem(int index) {
    _list[index].completed = !_list[index].completed;

    notifyListeners();
  }

  void removeItem(int index) {
    _list.removeAt(index);

    notifyListeners();
  }
}
