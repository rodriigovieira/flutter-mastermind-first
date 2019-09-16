import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mastermind_project/constants.dart';
import 'package:mastermind_project/list_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        builder: (BuildContext context) => ListData(),
      )
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String itemText;
  TextEditingController addTodoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String listString = preferences.getString("@data");

      ListData list = Provider.of<ListData>(context);

      list.updateList(listString);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ListData list = Provider.of<ListData>(context);

    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(15.0, 5.0, 0, 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 60.0,
                    ),
                    SizedBox(width: 15.0),
                    Text(
                      "Groceries List",
                      style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Consumer(
                        builder: (
                          BuildContext context,
                          ListData list,
                          Widget child,
                        ) {
                          return Expanded(
                            child: ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(
                                    list.getItemText(index),
                                  ),
                                  leading: Checkbox(
                                    value: list.getItemStatus(index),
                                    onChanged: (bool newValue) async {
                                      list.toggleItem(index);

                                      SharedPreferences preferences =
                                          await SharedPreferences
                                              .getInstance();

                                      await preferences.setString(
                                        "@data",
                                        list.getListString,
                                      );
                                    },
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline),
                                    iconSize: 30.0,
                                    onPressed: () async {
                                      list.removeItem(index);

                                      SharedPreferences preferences =
                                          await SharedPreferences
                                              .getInstance();

                                      await preferences.setString(
                                        "@data",
                                        list.getListString,
                                      );
                                    },
                                  ),
                                );
                              },
                              itemCount: list.listLength,
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: list.hasCompleted(),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            child: GestureDetector(
                              onTap: () => list.clearList(),
                              child: Text(
                                "Clear Completed",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          bottom: 20.0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: addTodoController,
                                decoration: InputDecoration(
                                  hintText: "Enter the item here",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: kMainColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: kMainColor,
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                                onChanged: (String value) {
                                  itemText = value;
                                },
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: kMainColor,
                              child: Icon(
                                Icons.add,
                                size: 35.0,
                              ),
                              onPressed: () async {
                                if (itemText.isEmpty) return;

                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();

                                list.addItem(itemText);

                                await preferences.setString(
                                  "@data",
                                  list.getListString,
                                );

                                addTodoController.clear();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                itemText = "";
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
