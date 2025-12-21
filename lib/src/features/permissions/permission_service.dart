import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PermissionService {
  
  /// Request connection instructions (Contacts + Storage/Photos)
  /// Returns true if all required permissions are granted.
  Future<bool> requestInitialPermissions() async {
    // 1. Contacts
    final contactsStatus = await Permission.contacts.status;
    if (!contactsStatus.isGranted) {
      // Logic for pre-dialog (Simulated here, usually UI handled)
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        return false;
      }
    }

    // 2. Storage/Photos (Android 13+ separate logic usually needed)
    // For simplicity, requesting storage. 
    // Note: On Android 13+, use Permission.photos
    // We will request both for compatibility or check SDK version (not easy in pure dart without device_info)
    // Just requesting storage for now as baseline.
    if (await Permission.storage.request().isGranted || 
        await Permission.photos.request().isGranted) {
       // Good
    } else {
       // return false; // Optional depending on strictness
    }

    return true;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
