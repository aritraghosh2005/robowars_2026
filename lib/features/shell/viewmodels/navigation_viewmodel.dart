import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_viewmodel.g.dart';

@riverpod
class NavigationViewModel extends _$NavigationViewModel {
  @override
  int build() => 0; // Initial index is Home (0)

  void setIndex(int index) {
    state = index;
  }
}
