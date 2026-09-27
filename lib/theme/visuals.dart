import 'package:flutter/material.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/theme/app_colors.dart';

/// Иконки и цвета для доменных сущностей — в одном месте,
/// чтобы «Свидание» везде было розовым с сердцем.
abstract final class Visuals {
  static IconData placeIcon(PlaceCategory category) => switch (category) {
        PlaceCategory.cafe => Icons.local_cafe_outlined,
        PlaceCategory.coffeeShop => Icons.coffee_outlined,
        PlaceCategory.restaurant => Icons.restaurant_outlined,
        PlaceCategory.bowling => Icons.sports_esports_outlined,
        PlaceCategory.cinema => Icons.movie_outlined,
        PlaceCategory.park => Icons.directions_walk_rounded,
        PlaceCategory.gallery => Icons.palette_outlined,
        PlaceCategory.studio => Icons.brush_outlined,
      };

  static Tone placeTone(PlaceCategory category) => switch (category) {
        PlaceCategory.cafe || PlaceCategory.coffeeShop => Tone.mint,
        PlaceCategory.restaurant => Tone.peach,
        PlaceCategory.bowling || PlaceCategory.cinema => Tone.violet,
        PlaceCategory.park => Tone.mint,
        PlaceCategory.gallery || PlaceCategory.studio => Tone.blue,
      };

  static IconData eventIcon(EventCategory category) => switch (category) {
        EventCategory.concert => Icons.music_note_outlined,
        EventCategory.cinema => Icons.movie_outlined,
        EventCategory.theatre => Icons.theater_comedy_outlined,
        EventCategory.exhibition => Icons.palette_outlined,
        EventCategory.workshop => Icons.brush_outlined,
        EventCategory.standup => Icons.mic_none_rounded,
      };

  static Tone eventTone(EventCategory category) => switch (category) {
        EventCategory.concert => Tone.violet,
        EventCategory.cinema => Tone.blue,
        EventCategory.theatre => Tone.pink,
        EventCategory.exhibition => Tone.peach,
        EventCategory.workshop => Tone.mint,
        EventCategory.standup => Tone.peach,
      };

  static IconData amenityIcon(AmenityType type) => switch (type) {
        AmenityType.wifi => Icons.wifi_rounded,
        AmenityType.sockets => Icons.power_outlined,
        AmenityType.pets => Icons.pets_outlined,
        AmenityType.smoking => Icons.smoke_free_outlined,
        AmenityType.payment => Icons.credit_card_outlined,
        AmenityType.parking => Icons.local_parking_outlined,
      };

  static IconData interestIcon(Interest interest) => switch (interest) {
        Interest.dates => Icons.favorite_border_rounded,
        Interest.active => Icons.fitness_center_rounded,
        Interest.coffee => Icons.local_cafe_outlined,
        Interest.concerts => Icons.music_note_outlined,
        Interest.art => Icons.palette_outlined,
        Interest.cinema => Icons.movie_outlined,
        Interest.food => Icons.restaurant_outlined,
      };

  static Tone interestTone(Interest interest) => switch (interest) {
        Interest.dates => Tone.pink,
        Interest.active => Tone.violet,
        Interest.coffee => Tone.mint,
        Interest.concerts => Tone.blue,
        Interest.art => Tone.peach,
        Interest.cinema => Tone.violet,
        Interest.food => Tone.peach,
      };

  static IconData travelIcon(TravelMode mode) => switch (mode) {
        TravelMode.walk => Icons.directions_walk_rounded,
        TravelMode.taxi => Icons.local_taxi_outlined,
      };

  /// Иконка и цвет распознанного параметра запроса.
  static (IconData, Tone) param(IntentParam param) => switch (param.type) {
        ParamType.occasion => switch (param.code) {
            'date' => (Icons.favorite_border_rounded, Tone.pink),
            'friends' => (Icons.groups_outlined, Tone.violet),
            'work' => (Icons.laptop_outlined, Tone.blue),
            'family' => (Icons.family_restroom, Tone.peach),
            _ => (Icons.person_outline_rounded, Tone.mint),
          },
        ParamType.time => (
            param.code == 'evening' || param.code == 'night'
                ? Icons.dark_mode_outlined
                : Icons.wb_sunny_outlined,
            Tone.violet,
          ),
        ParamType.budget => (Icons.account_balance_wallet_outlined, Tone.mint),
        ParamType.mood => switch (param.code) {
            'beautiful' => (Icons.diamond_outlined, Tone.peach),
            'calm' => (Icons.spa_outlined, Tone.mint),
            'active' => (Icons.bolt_rounded, Tone.violet),
            _ => (Icons.lightbulb_outline, Tone.peach),
          },
        ParamType.location => (Icons.place_outlined, Tone.brand),
      };
}
