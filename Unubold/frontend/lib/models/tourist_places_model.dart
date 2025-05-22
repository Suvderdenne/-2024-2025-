class TouristPlacesModel {
  final String name;
  final String image;

  TouristPlacesModel({required this.name, required this.image});
}

List<TouristPlacesModel> touristPlaces = [
  TouristPlacesModel(name: "Hotel", image: "assets/icons/mountain.png"),
  TouristPlacesModel(name: "Car", image: "assets/icons/beach.png"),
  TouristPlacesModel(name: "Flight", image: "assets/icons/desert.png"),
  TouristPlacesModel(name: "Train", image: "assets/icons/forest.png"),
];
