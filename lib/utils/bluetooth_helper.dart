import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothHelper {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _printer.getBondedDevices();
    } catch (e) {
      print("Error getting devices: $e");
      return [];
    }
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      await _printer.connect(device);
    } catch (e) {
      print("Connection failed: $e");
    }
  }

  Future<bool> isConnected() async {
    return await _printer.isConnected ?? false;
  }

  Future<void> printSample() async {
    bool connected = await isConnected();
    if (connected) {
      _printer.printNewLine();
      _printer.printCustom("STRUK CONTOH", 3, 1);
      _printer.printCustom("Terima Kasih!", 2, 1);
      _printer.printNewLine();
      _printer.paperCut();
    }
  }

  void disconnect() {
    _printer.disconnect();
  }

   Future<void> savePrinterAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("printer_address", address);
  }

  Future<String?> getSavedPrinterAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("printer_address");
  }
}
