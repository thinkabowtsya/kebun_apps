import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../utils/bluetooth_helper.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothHelper bluetoothHelper = BluetoothHelper();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  void _getDevices() async {
    List<BluetoothDevice> bondedDevices =
        await bluetoothHelper.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });
  }

  void _connectAndPrint(BluetoothDevice device) async {
    await bluetoothHelper.connectToPrinter(device);
    // print(device.address);
    await bluetoothHelper.savePrinterAddress(device.address!);
    await Future.delayed(
        const Duration(seconds: 1)); // delay biar koneksi stabil
    bluetoothHelper.printSample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Printer")),
      body: devices.isEmpty
          ? const Center(child: Text("Tidak ada printer terdeteksi"))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = devices[index];
                return ListTile(
                  title: Text(device.name ?? "Tanpa Nama"),
                  subtitle: Text(device.address ?? ""),
                  onTap: () => _connectAndPrint(device),
                );
              },
            ),
    );
  }
}
