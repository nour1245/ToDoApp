import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/shared/cubit/cubit.dart';

//defult button
Widget DefultButtn({
  var height = 50.0,
  var color = Colors.blue,
  var width = double.infinity,
  required String text,
  required Function function,
  var fontweight = FontWeight.bold,
  bool isUperCase = true,
}) =>
    Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: MaterialButton(
        onPressed: () {
          function();
        },
        child: Text(
          isUperCase ? text.toUpperCase() : text,
          style: TextStyle(
            fontWeight: fontweight,
          ),
        ),
      ),
    );

//defult text form field
Widget DefultTFF({
  required TextEditingController controrller,
  required String label,
  required IconData prefix,
  required TextInputType keyboardtype,
  required Function validate,
  bool isPassword = false,
  IconData? suffix,
  Function? ontap,
  Function? onchange,
  Function? onfield,
  Function? onsubmit,
  Function? suffixpresed,
  isclickable = true,
}) =>
    TextFormField(
      style: TextStyle(
        color: Colors.white,
      ),
      enabled: isclickable,
      onChanged: (value) {
        onchange!();
      },
      onTap: () {
        ontap!();
      },
      onFieldSubmitted: (value) => onsubmit!(),
      obscureText: isPassword,
      controller: controrller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          prefix,
        ),
        labelStyle: TextStyle(color: Colors.white),
        suffixStyle: TextStyle(color: Colors.white),
        errorStyle: TextStyle(color: Colors.white),
        suffixIcon: suffix != null
            ? IconButton(
                icon: Icon(suffix),
                onPressed: () {
                  suffixpresed!();
                },
              )
            : null,
      ),
      keyboardType: keyboardtype,
      validator: (value) {
        return validate(value);
      },
    );
//reuseable widget to bulid the list item(task)
Widget bulidTaskItem(Map model, context) => Dismissible(
      background: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ],
      ),
      direction: DismissDirection.endToStart,
      key: Key(model['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(
          id: model['id'],
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text('${model['time']}'),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            IconButton(
              color: Colors.green,
              onPressed: () {
                AppCubit.get(context).updatData(
                  status: 'done',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.check_circle,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(
              color: Colors.amber,
              onPressed: () {
                AppCubit.get(context).updatData(
                  status: 'archiv',
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.archive,
              ),
            ),
          ],
        ),
      ),
    );
//widget to bulid the list or show no tasks yet
Widget tasksbuilder({
  required tasks,
}) =>
    ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (BuildContext context) => ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[300],
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return bulidTaskItem(tasks[index], context);
        },
      ),
      fallback: (BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              size: 100.0,
              Icons.crisis_alert,
              color: Colors.grey,
            ),
            Text(
              'No Taskes Yet',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
