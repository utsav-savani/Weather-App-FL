import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/domain/entities/forecast.dart';
import '/domain/repositories/weather_repository.dart';

class GetForecast {
  final WeatherRepository repository;

  GetForecast(this.repository);

  Future<Either<Failure, Forecast>> call(Params params) {
    if (params.byCoordinates) {
      return repository.getForecastByCoordinates(
        params.latitude!,
        params.longitude!,
      );
    } else {
      return repository.getForecastByCity(params.city!);
    }
  }
}

class Params extends Equatable {
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool byCoordinates;

  const Params({
    this.city,
    this.latitude,
    this.longitude,
    this.byCoordinates = false,
  });

  factory Params.byCity(String city) => Params(city: city);

  factory Params.byCoordinates(double latitude, double longitude) =>
      Params(latitude: latitude, longitude: longitude, byCoordinates: true);

  @override
  List<Object?> get props => [city, latitude, longitude, byCoordinates];
}
