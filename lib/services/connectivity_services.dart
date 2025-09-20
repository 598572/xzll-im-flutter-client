import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/models/enum/connectivity_status.dart';

class ConnectivityServices extends GetxService {
  @override
  void onInit() {
    super.onInit();
    Connectivity connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen(_onNetworkStatusChanged);
  }

  void _onNetworkStatusChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      AppEvent.networkStatus.sink.add(ConnectivityStatus.none);
    } else {
      AppEvent.networkStatus.sink.add(ConnectivityStatus.normal);
    }
  }
}
