import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/Done_screen/done_screen.dart';
import 'package:todoapp/modules/archived_screen/archived_screen.dart';
import 'package:todoapp/modules/newtaskesscreen/newtaskes.dart';
import 'package:todoapp/shared/Styles/styles.dart';
import 'package:todoapp/shared/components/components.dart';
import 'package:todoapp/shared/components/constants.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';

class Todo extends StatelessWidget {
  //variables
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titlecontroller = TextEditingController();
  var timecontroller = TextEditingController();
  var datecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //bloc create
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDB(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is insertDbState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) => Scaffold(
          extendBodyBehindAppBar: true,
          key: scaffoldkey,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              AppCubit.get(context).titles[AppCubit.get(context).currentIndex],
              style: TextStyle(
                color: Colors.grey[200],
              ),
            ),
          ),

          /*if the current state is loadingState show circular progress 
            indicator else show normal screens
          */

          body: state is! loadingState
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 129, 21, 21),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: AppCubit.get(context)
                      .screens[AppCubit.get(context).currentIndex],
                )
              : const Center(child: CircularProgressIndicator()),

          //floating action button section

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 28, 181, 224),
            onPressed: () {
              /*if button pressed while bottom sheet is opend
                and form is valid send data to database
                and change icon and close bottom sheet  
              */

              if (AppCubit.get(context).isBottomSheetShown) {
                if (formkey.currentState!.validate()) {
                  AppCubit.get(context).insertToDB(
                    title: titlecontroller.text,
                    date: datecontroller.text,
                    time: timecontroller.text,
                  );
                  AppCubit.get(context).isBottomSheetShown = false;
                  AppCubit.get(context).fap = Icons.add;
                }
              } else {
                /* if bottom sheet is closed show it 
                */
                scaffoldkey.currentState
                    ?.showBottomSheet(
                      (context) => Container(
                        //form section
                        color: const Color.fromARGB(255, 129, 21, 21),
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DefultTFF(
                                  controrller: titlecontroller,
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                  keyboardtype: TextInputType.text,
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'please add title';
                                    }
                                  }),
                              const SizedBox(
                                height: 15.0,
                              ),
                              DefultTFF(
                                controrller: timecontroller,
                                label: 'Task time',
                                prefix: Icons.watch,
                                keyboardtype: TextInputType.datetime,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'please add time';
                                  }
                                },
                                ontap: () {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) => timecontroller.text =
                                          value!.format(context));
                                },
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              DefultTFF(
                                controrller: datecontroller,
                                label: 'Task date',
                                prefix: Icons.date_range,
                                keyboardtype: TextInputType.datetime,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'please add date';
                                  }
                                },
                                ontap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2023-02-10'),
                                  ).then((value) => datecontroller.text =
                                      DateFormat.yMMMd().format(value!));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ) //when u close the bottom sheet by down swipechange values
                    .closed
                    .then((value) {
                  AppCubit.get(context).changeBottomSheet(
                    isShow: false,
                    icon: Icons.edit,
                  );
                });
                //after finshing and closing the bottom sheet by button change values
                AppCubit.get(context).changeBottomSheet(
                  isShow: true,
                  icon: Icons.add,
                );
              }
            },
            child: Icon(
              AppCubit.get(context).fap,
            ),
          ),
          //bottom nav bar section
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            unselectedItemColor: Colors.black,
            backgroundColor: const Color.fromARGB(255, 129, 21, 21),
            selectedItemColor: const Color.fromARGB(255, 28, 181, 224),
            currentIndex: AppCubit.get(context).currentIndex,
            onTap: (value) {
              AppCubit.get(context).changeIndex(value);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.task,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check,
                ),
                label: 'done',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.archive,
                ),
                label: 'archived',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
