// abstract class SearchEvent {}

// class SearchQueryChanged extends SearchEvent {
//   final String query;
//   SearchQueryChanged(this.query);
// }

// class SearchCleared extends SearchEvent {}
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class SearchImageSelected extends SearchEvent {
  final String imagePath;
  SearchImageSelected(this.imagePath);
}

class SearchCleared extends SearchEvent {}