import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/Done_screen/done_screen.dart';
import 'package:todoapp/modules/archived_screen/archived_screen.dart';
import 'package:todoapp/modules/newtaskesscreen/newtaskes.dart';
import 'package:todoapp/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(initState());
  static AppCubit get(context) => BlocProvider.of(context);
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivedasks = [];
  bool isBottomSheetShown = false;
  IconData fap = Icons.edit;
  int currentIndex = 0;
  Database? database;
  List<Widget> screens = [
    NewtaskScreen(),
    DoneScreen(),
    Archivedscreen(),
  ];

  List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int value) {
    currentIndex = value;
    emit(botomNavBarChange());
  }

  void createDB() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        database
            .execute(
                'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT,date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print(' erorr while creating $error');
        });
      },
      onOpen: (database) {
        getDataFromDB(database);
      },
    ).then((value) {
      database = value;
      emit(creatDbState());
    });
  }

  insertToDB({required title, required date, required time}) async {
    await database?.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        emit(insertDbState());
        getDataFromDB(database);
      }).catchError((error) {
        print('error while inserting $error');
      });
    });
  }

  void getDataFromDB(database) {
    newtasks = [];
    donetasks = [];
    archivedasks = [];
    emit(loadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newtasks.add(element);
        } else if (element['status'] == 'done') {
          donetasks.add(element);
        } else {
          archivedasks.add(element);
        }
      });
      emit(getDbState());
    });
  }

  void changeBottomSheet({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fap = icon;
    emit(changeBottomsheet());
  }

  void updatData({required status, required id}) async {
    database?.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ? ',
      ['$status', id],
    ).then((value) {
      getDataFromDB(database);
      emit(updateDbState());
    });
  }

  void deleteData({required id}) async {
    database?.rawDelete(
      'DELETE FROM tasks WHERE id = ? ',
      [id],
    ).then((value) {
      getDataFromDB(database);
      emit(deleteDbState());
    });
  }
}
