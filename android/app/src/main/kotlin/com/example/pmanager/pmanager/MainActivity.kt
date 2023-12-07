package com.example.pmanager.pmanager



import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import android.util.Log


class MainActivity: FlutterActivity() {
    private val CHANNEL = "permission_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            if (call.method == "getPermissions") {
                //com.apkmirror.helper.prod
                //Log.d("Check", "received: ${call.arguments}")
                val grantedPermissions: MutableList<String> = checkPermissionsForApp(this@MainActivity, call.arguments.toString())
                //val batteryLevel = 501;//getBatteryLevel()

                if (grantedPermissions.isNullOrEmpty()) {
                    // The list is empty or null
                    result.error("UNAVAILABLE", "Some error occured.", null)
                } else {
                    // The list contains granted permissions
                    result.success(grantedPermissions)
                }

            } else {
                result.notImplemented()
            }
        }
    }

    private fun tellMeBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun checkPermissionsForApp(context: Context, packageName: String): MutableList<String> {
        val grantedPermissions = mutableListOf<String>()
        try {
            val pm: PackageManager = context.packageManager

            // Get PackageInfo for the specified package name
            val packageInfo: PackageInfo = pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)

            // Check if permissions are declared in the manifest
            if (packageInfo.requestedPermissions != null) {
                for (permission: String in packageInfo.requestedPermissions) {
                    try {
                        val permissionInfo: PermissionInfo = pm.getPermissionInfo(permission, 0)
                        //Log.d("PermissionChecker", "Permission: ${permissionInfo.name}")
                        // Check if the permission is granted
                        val permissionStatus = pm.checkPermission(permission, packageName)
                        if (permissionStatus == PackageManager.PERMISSION_GRANTED) {
                            grantedPermissions.add(permissionInfo.name)
                            //Log.d("PermissionChecker", "Granted Permission: ${permissionInfo.name}")
                        }
                    } catch (e: PackageManager.NameNotFoundException) {
                        //e.printStackTrace()
                    }
                }
            }
        } catch (e: PackageManager.NameNotFoundException) {
            //e.printStackTrace()
        }
        return grantedPermissions
    }


}

