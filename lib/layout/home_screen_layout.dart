import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/Done_screen/done_screen.dart';
import 'package:todoapp/modules/archived_screen/archived_screen.dart';
import 'package:todoapp/modules/newtaskesscreen/newtaskes.dart';
import 'package:todoapp/shared/components/components.dart';
import 'package:todoapp/shared/components/constants.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';

class Todo extends StatelessWidget {
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();

  var titlecontroller = TextEditingController();
  var timecontroller = TextEditingController();
  var datecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDB(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is insertDbState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) => Scaffold(
          key: scaffoldkey,
          appBar: AppBar(
            title: Text(
              AppCubit.get(context).titles[AppCubit.get(context).currentIndex],
            ),
          ),
          body: state is! loadingState
              ? AppCubit.get(context)
                  .screens[AppCubit.get(context).currentIndex]
              : const Center(child: CircularProgressIndicator()),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
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
                scaffoldkey.currentState
                    ?.showBottomSheet(
                      (context) => Container(
                        color: Colors.grey[200],
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
                    )
                    .closed
                    .then((value) {
                  AppCubit.get(context).changeBottomSheet(
                    isShow: false,
                    icon: Icons.edit,
                  );
                });

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
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.red,
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
