class Category {
  final String categoryId;
  final String categoryName;
  final int? parentId;

  Category({
    required this.categoryId,
    required this.categoryName,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? '',
      parentId: int.tryParse(json['parent_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'parent_id': parentId,
    };
  }
}
