enum TechnicianCategory {
  plumbing,
  electric,
  cleaning,
  security,
  painting,
  furniture,
  other,
}

class TechnicianModel {
  final String id;
  final String name;
  final TechnicianCategory category;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final String phoneNumber;
  final String biography;
  final List<String> skills;
  final List<ReviewModel> reviews;
  final bool isAvailable;

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.category,
    required this.photoUrl,
    required this.rating,
    required this.reviewCount,
    required this.phoneNumber,
    required this.biography,
    required this.skills,
    required this.reviews,
    this.isAvailable = true,
  });

  String get categoryDisplayName {
    switch (category) {
      case TechnicianCategory.plumbing:
        return 'Sıhhi Tesisat';
      case TechnicianCategory.electric:
        return 'Elektrik';
      case TechnicianCategory.cleaning:
        return 'Temizlik';
      case TechnicianCategory.security:
        return 'Güvenlik / Çilingir';
      case TechnicianCategory.painting:
        return 'Boya & Badana';
      case TechnicianCategory.furniture:
        return 'Mobilya Montaj';
      case TechnicianCategory.other:
        return 'Diğer';
    }
  }
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
