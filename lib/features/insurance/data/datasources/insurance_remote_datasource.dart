import '../../../../core/errors/exceptions.dart';
import '../services/insurance_service.dart';
import '../../domain/models/insurance_model.dart';

abstract class InsuranceRemoteDataSource {
  Future<List<InsuranceModel>> getAllInsurance();
}

class InsuranceRemoteDataSourceImpl implements InsuranceRemoteDataSource {
  final InsuranceService insuranceService;

  InsuranceRemoteDataSourceImpl({required this.insuranceService});

  @override
  Future<List<InsuranceModel>> getAllInsurance() async {
    try {
      return await insuranceService.getAllInsurance();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get insurance: $e');
    }
  }
}

