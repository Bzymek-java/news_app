/// Klasa do filtrowania
/// Nie dziala aplikacja naprawic
class NewsFilter {
  final String title;
  final String category;
  final String description;

  const NewsFilter({
    required this.title,
    required this.category,
    this.description = '',
  });
}