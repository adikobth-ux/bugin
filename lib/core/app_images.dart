/// Пути к локальным изображениям mock data.
///
/// Когда подключится backend, модели будут получать URL,
/// а [AppImage] сам решит, грузить из сети или из ассетов.
abstract final class AppImages {
  static const _root = 'assets/images';

  static const theGarden = '$_root/place_the_garden.jpg';
  static const theGardenHall = '$_root/place_the_garden_hall.jpg';
  static const theGardenCoffee = '$_root/place_the_garden_coffee.jpg';
  static const theGardenFood = '$_root/place_the_garden_food.jpg';
  static const theGardenNeon = '$_root/place_the_garden_neon.jpg';
  static const coffeeLab = '$_root/place_coffee_lab.jpg';
  static const galaxyBowling = '$_root/place_galaxy_bowling.jpg';
  static const skyLounge = '$_root/place_sky_lounge.jpg';
  static const lunaCinema = '$_root/place_luna_cinema.jpg';
  static const holstStudio = '$_root/place_holst_studio.jpg';
  static const bastauGallery = '$_root/place_bastau_gallery.jpg';

  static const neonNights = '$_root/event_neon_nights.jpg';
  static const rooftopAcoustic = '$_root/event_rooftop_acoustic.jpg';

  static const scenarioWorkDay = '$_root/scenario_work_day.jpg';
  static const scenarioEvening = '$_root/scenario_evening.jpg';
}
