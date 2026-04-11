class CategoryModel {
  final int? id;
  final String? name;
  final String? type;

  CategoryModel({this.id, this.name, this.type});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type};
  }
}

class CostumModel {
  final int? id;
  final String? photoUrl;
  final String? name;
  final String? nameAnime;
  final String? namaCosplayer;
  final String? size;
  final int? stock;
  final int? priceday;
  final String? lokasi;
  final String? desc;
  final int? sourceAnimeCategoryId;
  final int? brandCostumCategoryId;
  final String? paxel;
  final double? beratJnt;
  final int? rentedStock;
  final int? availableStock;
  final CategoryModel? sourceAnimeCategory;
  final CategoryModel? brandCostumCategory;

  CostumModel({
    this.id,
    this.photoUrl,
    this.name,
    this.nameAnime,
    this.namaCosplayer,
    this.size,
    this.stock,
    this.priceday,
    this.lokasi,
    this.desc,
    this.sourceAnimeCategoryId,
    this.brandCostumCategoryId,
    this.paxel,
    this.beratJnt,
    this.rentedStock,
    this.availableStock,
    this.sourceAnimeCategory,
    this.brandCostumCategory,
  });

  factory CostumModel.fromJson(Map<String, dynamic> json) {
    return CostumModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      photoUrl: json['photo_url'] as String?,
      name: json['name'] as String?,
      nameAnime: json['name_anime'] as String?,
      namaCosplayer: json['nama_cosplayer'] as String?,
      size: json['size'] as String?,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString())
          : null,
      priceday: json['priceday'] != null
          ? double.tryParse(json['priceday'].toString())?.toInt()
          : null,
      lokasi: json['lokasi'] as String?,
      desc: json['desc'] as String?,
      sourceAnimeCategoryId: json['source_anime_category_id'] != null
          ? int.tryParse(json['source_anime_category_id'].toString())
          : null,
      brandCostumCategoryId: json['brand_costum_category_id'] != null
          ? int.tryParse(json['brand_costum_category_id'].toString())
          : null,
      paxel: json['paxel'] as String?,
      beratJnt: json['berat_jnt'] != null
          ? double.tryParse(json['berat_jnt'].toString())
          : null,
      rentedStock: json['rented_stock'] != null
          ? int.tryParse(json['rented_stock'].toString())
          : null,
      availableStock: json['available_stock'] != null
          ? int.tryParse(json['available_stock'].toString())
          : null,
      sourceAnimeCategory: json['source_anime_category'] != null
          ? CategoryModel.fromJson(json['source_anime_category'])
          : null,
      brandCostumCategory: json['brand_costum_category'] != null
          ? CategoryModel.fromJson(json['brand_costum_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_url': photoUrl,
      'name': name,
      'name_anime': nameAnime,
      'nama_cosplayer': namaCosplayer,
      'size': size,
      'stock': stock,
      'priceday': priceday,
      'lokasi': lokasi,
      'desc': desc,
      'source_anime_category_id': sourceAnimeCategoryId,
      'brand_costum_category_id': brandCostumCategoryId,
      'paxel': paxel,
      'berat_jnt': beratJnt,
      'rented_stock': rentedStock,
      'available_stock': availableStock,
      'source_anime_category': sourceAnimeCategory?.toJson(),
      'brand_costum_category': brandCostumCategory?.toJson(),
    };
  }
}
