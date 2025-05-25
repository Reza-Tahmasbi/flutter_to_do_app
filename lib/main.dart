import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/data/data.dart';
import 'package:todolist/data/repo/repository.dart';
import 'package:todolist/data/source/hive_task_source.dart';
import 'package:todolist/screens/home/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todolist/screens/home/bloc/task_list_bloc.dart';
const taskBoxName = 'tasks';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(
    PriorityAdapter(),
  );
  await Hive.openBox<TaskEntity>(taskBoxName);
  
  final Repository<TaskEntity> repository = Repository(
    localDataSource: HiveTaskDataSource(Hive.box(taskBoxName))
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: primaryColor,
      systemNavigationBarColor: Colors.white,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<Repository<TaskEntity>>(create: (context) => repository),
        BlocProvider(create: (context) => TaskListBloc(repository)),
      ],
      child: const MyApp(),
    ),
  );
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryVarientColor = Color(0xff5C0AFF);
const secondaryTextColor = Color(0xffAFBED0);
const normalPriority = Color(0xffF09819);
const lowPriority = Color(0xff3BE1F1);
const highPriority = primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
            TextTheme(headlineMedium: TextStyle(fontWeight: FontWeight.bold))),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(color: secondaryTextColor),
            iconColor: secondaryTextColor),
        colorScheme: ColorScheme.light(
          primaryFixed: primaryColor,
          primary: primaryVarientColor,
          background: Color(0xffF3F5F8),
          onSurface: primaryTextColor,
          onPrimary: Colors.white,
          onBackground: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
