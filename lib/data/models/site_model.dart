class SiteModel {
  final String id;
  final String name;
  final String address;
  final int unitCount;
  final int blockCount;
  final String? imageUrl;

  const SiteModel({
    required this.id,
    required this.name,
    required this.address,
    required this.unitCount,
    required this.blockCount,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'unitCount': unitCount,
    'blockCount': blockCount,
    'imageUrl': imageUrl,
  };

  factory SiteModel.fromJson(Map<String, dynamic> json) => SiteModel(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    unitCount: json['unitCount'],
    blockCount: json['blockCount'],
    imageUrl: json['imageUrl'],
  );
}
