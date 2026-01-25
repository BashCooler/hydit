import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrus_flutter/pages/search.dart';
import 'package:hydrus_flutter/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/hydrus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  timeDilation = 1.0;
  runApp(App(prefs));
}

class App extends StatelessWidget {
  final SharedPreferences prefs;

  const App(this.prefs, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SearchVisibilityCubit()),
        BlocProvider(create: (_) => SettingsCubit(prefs)),
        BlocProvider(create: (_) => ClientCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter App',
        debugShowCheckedModeBanner: false,
        theme: darkTheme(),
        home: SearchPage(),
      ),
    );
  }
}

enum SearchVisibility {visible, hidden}
class SearchVisibilityCubit extends Cubit<SearchVisibility> {
  SearchVisibilityCubit() : super(SearchVisibility.visible);

  void show() => emit(SearchVisibility.visible);
  void hide() => emit(SearchVisibility.hidden);
}

/// I know this thing is weird but it works as long as
/// we don't need to change any states with settings
class SettingsCubit extends Cubit<SharedPreferences> {
  final SharedPreferences _preferences;
  SettingsCubit(this._preferences) : super(_preferences);
  SharedPreferences get prefs => _preferences;
}

class ClientCubit extends Cubit<Client> {
  ClientCubit() : super(Client());
  void update(Client client) => emit(client);
}