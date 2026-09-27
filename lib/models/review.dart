class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        author: json['author'] as String,
        rating: (json['rating'] as num).toDouble(),
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  final String author;
  final double rating;
  final String text;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'author': author,
        'rating': rating,
        'text': text,
        'date': date.toIso8601String(),
      };
}
