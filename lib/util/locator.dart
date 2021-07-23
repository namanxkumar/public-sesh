import 'package:get_it/get_it.dart';
import 'package:testproj/util/nav.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
}
