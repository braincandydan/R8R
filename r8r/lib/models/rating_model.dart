class RatingModel {
  final int wingCrispiness; // 1-5 rating
  final int wingFlavor;     // 1-5 rating
  final int wingSize;       // 1-5 rating
  final int beerSelection;  // 1-5 rating
  final int beerPairing;    // 1-5 rating

  RatingModel({
    required this.wingCrispiness,
    required this.wingFlavor,
    required this.wingSize,
    required this.beerSelection,
    required this.beerPairing,
  });

  // Validate that all ratings are between 1 and 5
  bool get isValid {
    return wingCrispiness >= 1 && wingCrispiness <= 5 &&
           wingFlavor >= 1 && wingFlavor <= 5 &&
           wingSize >= 1 && wingSize <= 5 &&
           beerSelection >= 1 && beerSelection <= 5 &&
           beerPairing >= 1 && beerPairing <= 5;
  }

  // Calculate overall rating (average of all categories)
  double getOverallRating() {
    return (wingCrispiness + wingFlavor + wingSize + beerSelection + beerPairing) / 5.0;
  }

  // Get wing-specific rating (average of wing categories)
  double getWingRating() {
    return (wingCrispiness + wingFlavor + wingSize) / 3.0;
  }

  // Get beer-specific rating (average of beer categories)
  double getBeerRating() {
    return (beerSelection + beerPairing) / 2.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'wingCrispiness': wingCrispiness,
      'wingFlavor': wingFlavor,
      'wingSize': wingSize,
      'beerSelection': beerSelection,
      'beerPairing': beerPairing,
    };
  }

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      wingCrispiness: json['wingCrispiness'] ?? 1,
      wingFlavor: json['wingFlavor'] ?? 1,
      wingSize: json['wingSize'] ?? 1,
      beerSelection: json['beerSelection'] ?? 1,
      beerPairing: json['beerPairing'] ?? 1,
    );
  }

  RatingModel copyWith({
    int? wingCrispiness,
    int? wingFlavor,
    int? wingSize,
    int? beerSelection,
    int? beerPairing,
  }) {
    return RatingModel(
      wingCrispiness: wingCrispiness ?? this.wingCrispiness,
      wingFlavor: wingFlavor ?? this.wingFlavor,
      wingSize: wingSize ?? this.wingSize,
      beerSelection: beerSelection ?? this.beerSelection,
      beerPairing: beerPairing ?? this.beerPairing,
    );
  }

  // Get rating descriptions for UI display
  String getWingCrispinessDescription() {
    switch (wingCrispiness) {
      case 1: return 'Very Soft';
      case 2: return 'Soft';
      case 3: return 'Good';
      case 4: return 'Crispy';
      case 5: return 'Perfect';
      default: return 'Unknown';
    }
  }

  String getWingFlavorDescription() {
    switch (wingFlavor) {
      case 1: return 'Bland';
      case 2: return 'Mild';
      case 3: return 'Good';
      case 4: return 'Great';
      case 5: return 'Amazing';
      default: return 'Unknown';
    }
  }

  String getWingSizeDescription() {
    switch (wingSize) {
      case 1: return 'Very Small';
      case 2: return 'Small';
      case 3: return 'Average';
      case 4: return 'Large';
      case 5: return 'Huge';
      default: return 'Unknown';
    }
  }

  String getBeerSelectionDescription() {
    switch (beerSelection) {
      case 1: return 'Poor';
      case 2: return 'Limited';
      case 3: return 'Decent';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Unknown';
    }
  }

  String getBeerPairingDescription() {
    switch (beerPairing) {
      case 1: return 'Poor Match';
      case 2: return 'Okay';
      case 3: return 'Good';
      case 4: return 'Great';
      case 5: return 'Perfect';
      default: return 'Unknown';
    }
  }
}
