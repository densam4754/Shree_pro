import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/taxpayer_entity.dart';
import '../../domain/repo/taxpayer_repository.dart';
import '../datasources/taxpayer_remote_datasource.dart';

class TaxpayerRepositoryImpl implements TaxpayerRepository {
  final TaxpayerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaxpayerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<List<TaxpayerEntity>> getAllTaxpayers() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final taxpayers = await remoteDataSource.getAllTaxpayers();
      return Right(taxpayers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

