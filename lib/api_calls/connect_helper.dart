import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:smartfixapp/api_calls/api_call.dart';
import 'package:smartfixapp/utils/app_constants.dart';

class ConnectHelper {
  final _flutterSecureStorage = const FlutterSecureStorage();
  final apiHelper = ApiHelper();
  // final _commonService = CommonService();

  /// To Save the data in the Device.
  /// [key] key of the data.
  /// [value] data that is to be stored in device.
  void saveValueSecurely({required String key, required String value}) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }
 Future<ResponseModel> login({
    required bool isLoading,
    required String phoneNo,
    required String password,
  }) async =>
      await apiHelper.makeRequest(
        'login',
        Request.post,
        {
          "mobile": phoneNo,
          "password": password,
        },
        isLoading,
        {
          // 'Content-Type': 'application/json',
        },
      );
      Future<ResponseModel> register({
    required String name,
    required String email,
    required String phoneNo,
    required String password,
    required bool isLoading,
  }) async =>
      await apiHelper.makeRequest(
        'register',
        Request.post,
        {
          "name": name,
          "email": email,
          "mobile": phoneNo,
          "password": password,
        },
        isLoading,
        {
          // 'Content-Type': 'application/json',
        },
      );
  /// To get Saved data from the Device.
  /// [key] key of the Data.
  Future<String> getSavedValue({required String key}) async {
    var value = await _flutterSecureStorage.read(key: key);
    if (value != null) {
      return value.toString();
    } else {
      return 'en';
    }
  }

  /// To delete particular key data in device.
  /// [key] key of the Data.
  void deleteSavedValue({required String key}) async {
    await _flutterSecureStorage.delete(key: key);
  }

  /// To delete all app related data from device.
  void deleteAllSavedValues() async {
    await _flutterSecureStorage.deleteAll();
  }

  /// API for Sign up
  ///
  Future<ResponseModel> signUp({
    required String userName,
    required String password,
    required bool isLoading,
  }) async =>
      await apiHelper.makeRequest(
        'auth/token',
        Request.post,
        {
          "grant_type": KeyConstants.grantType,
          "client_id": KeyConstants.clientId,
          "client_secret": KeyConstants.clientSecret,
          "username": userName,
          "password": password,
        },
        isLoading,
        {
          'Content-Type': 'application/json',
        },
      );

  /// API to get Contact details
  ///
  Future<ResponseModel?> sendOTP(String phoneNumber) async {
    // final token = getSavedValue(key: KeyConstants.accessToken);
    return await apiHelper.makeRequest(
      'Account/SendOtp',
      Request.post,
      {
        'PhoneNumber': phoneNumber,
      },
      true,
      {'Content-Type': 'application/x-www-form-urlencoded'},
    );
  }

  /// API to get profile
  ///
  Future<ResponseModel?> getProfile({bool isLoading = false}) async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'Profile',
      Request.get,
      null,
      isLoading,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// API to verify OTP
  ///
  Future<ResponseModel?> verifyOTP(
      {required String phoneNumber, required String otp}) async {
    // final token = getSavedValue(key: KeyConstants.accessToken);
    return await apiHelper.makeRequest(
      'account/VerifyOtp',
      Request.post,
      {
        'PhoneNumber': phoneNumber,
        'OTP': otp,
      },
      true,
      {'Content-Type': 'application/x-www-form-urlencoded'},
    );
  }

  /// API to book a service
  ///
  Future<ResponseModel?> bookService({
    required String date,
    required String timeSlot,
    required String cityId,
    required String service,
    required String txnId,
    required Profile userProfile,
  }) async {
    // final token = await _commonService.getValue(AppConstants.token);
    return await apiHelper.makeRequest(
      'createNewOrder',
      Request.post,
      // {
      //   'Date': date,
      //   'TimeSlot': timeSlot,
      //   'CityId': cityId,
      //   'Service': service,
      //   'TransactionId': txnId,
      // },
      {
        "userId": userProfile.userId,
        "date": date,
        "vendorId": "",
        "bookingTime": timeSlot,
        "address": "",
        "city": "",
        "state": "",
        "phone": "${userProfile.phoneNumber}",
        "serviceId": service,
        "cityId": cityId,
        "name": "${userProfile.fullName}"
      },
      true,
      {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
  }

  /// Get catagory
  ///
  Future<ResponseModel?> getCatagory() async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getCategory',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Location
  ///
  Future<ResponseModel?> getLocation() async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getCity',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Location
  ///
  Future<ResponseModel?> getOrdersByUserId(id) async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getOrdersByUserId/$id',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Location
  ///
  Future<ResponseModel?> getCompletedOrdersByUserId(id) async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getCompletedOrdersByUserId/$id',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Timeslots
  ///
  Future<ResponseModel?> getTimeslots() async {
    // final token = await _commonService.getValue(AppConstants.token);
    return await apiHelper.makeRequest(
      'timeslot',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Banners
  ///
  Future<ResponseModel?> getBanner() async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'Common/GetSilder',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Popular Services
  ///
  Future<ResponseModel?> getPopularServices() async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getServices',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Trending Services
  ///
  Future<ResponseModel?> getTrending() async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getServices',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Subcatagory Data
  ///
  Future<ResponseModel?> getSubcatagory({required String id}) async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getSubCategoryByCategory/$id',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Service Details by Id
  ///
  Future<ResponseModel?> getServiceDetailsById({required String id}) async {
    // final token = await _commonService.getValue(AppConstants.token);
    return await apiHelper.makeRequest(
      'service/details?Id=$id',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get Services
  ///
  Future<ResponseModel?> getServices({required String categoryId}) async {
    // final token = await _commonService.getValue(AppConstants.token);
    // log('TOKEN ######### : $token');
    return await apiHelper.makeRequest(
      'getserviceBySubCategory/$categoryId',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get upcoming booking
  ///
  Future<ResponseModel?> getUpcomingBooking() async {
    // final token = await _commonService.getValue(AppConstants.token);
    return await apiHelper.makeRequest(
      'Booking/GetUpComingList',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get completed booking
  ///
  Future<ResponseModel?> getCompletedBooking() async {
    // final token = await _commonService.getValue(AppConstants.token);
    return await apiHelper.makeRequest(
      'Booking/GetCompletedList',
      Request.get,
      null,
      false,
      {
        // 'Authorization': 'Bearer $token',
      },
    );
  }

  /// update profile
  ///
  Future<ResponseModel?> updateProfile(UserProfile userProfile) async {
    // final token = await _commonService.getValue(AppConstants.token);
    log(userProfile.toJson().toString());
    return await apiHelper.makeRequest(
      'Profile/Update',
      Request.post,
      jsonEncode(userProfile.toJson()),
      false,
      {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Connect Call
  ///
  Future<ResponseModel?> connectCall(
      {required String from, required String to}) async {
    return await apiHelper.makeRequest(
      'https://${AppConstants.exotelAPI}:${AppConstants.exotelTOKEN}@${AppConstants.exotelSUBDOMAIN}/v1/Accounts/${AppConstants.exotelSID}/Calls/connect',
      Request.exotelCall,
      {
        'From': from,
        'To': to,
        'CallerId': '095138-86363',
      },
      true,
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
  }
}
