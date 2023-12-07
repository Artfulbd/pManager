import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_apps/device_apps.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFA9B388),
        appBarTheme:  const AppBarTheme(
          color: Color(0xFF5C8374), // Dark Gray Background
        ),
        tabBarTheme:  const TabBarTheme(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.blue,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  List<AppInfo> allApps = [];
  List<AppInfo> selectedApps = [];
  static const platform = MethodChannel('permission_channel');
  List<PermissionInfo> permissions = [];
  
  void setPermissionInfo(){
    permissions.add(PermissionInfo("Call log", Icons.call_split_outlined, "This permission allows an app to access the user's call log", "CALL_LOG", []));
    permissions.add(PermissionInfo("Camera", Icons.camera_alt, "This permission allows an app to access the device's camera hardware", "CAMERA", []));
    permissions.add(PermissionInfo("Contacts", Icons.contact_mail_outlined, "This permission allows an app to read the user's contact data", "CONTACTS", []));
    permissions.add(PermissionInfo("Approximate Location", Icons.pin_drop_sharp, "This permission allows an app to access approximate location information.", "COARSE_LOCATION", []));
    permissions.add(PermissionInfo("Accurate location", Icons.location_pin, "This permission allows an app to access precise location information using GPS ", "FINE_LOCATION", []));
    permissions.add(PermissionInfo("Microphone", Icons.mic, "This permission allows an app to access the device's microphone and record audio.", "D_AUDIO", []));
    permissions.add(PermissionInfo("Telephone", Icons.add_call, "This permission allows an app to directly initiate a phone call without the user having to confirm the call.", "CALL_PHONE", []));
    permissions.add(PermissionInfo("Biometric", Icons.fingerprint_rounded, "This permission allows an app to access the device's fingerprint sensor for authentication purposes.", "USE_BIOMETRIC", []));
    permissions.add(PermissionInfo("Read SMS", Icons.sms, "This permission allows an app to read SMS messages stored on the device.", "READ_SMS", []));
    permissions.add(PermissionInfo("Receive ",Icons.sms_failed_rounded, "This permission allows an app to receive SMS messages.", "RECEIVE_SMS", []));
    permissions.add(PermissionInfo("Internet access", Icons.language_sharp, "This permission allows an app to open network sockets and send/receive data over the internet.", "INTERNET", []));
    permissions.add(PermissionInfo("WiFi info",Icons.wifi, "This permission allows an app to view information about the device's Wi-Fi connectivity.", "WIFI", []));
    permissions.add(PermissionInfo("Other apps info",Icons.app_settings_alt ,"This permission allows an app to query other normal app on the device, regardless of manifest declarations.", "QUERY_ALL_PACKAGES", []));
    permissions.add(PermissionInfo("Bluetooth",Icons.bluetooth, "This permission allows an app to control the device's Bluetooth functionality", "BLUETOOTH", []));
    permissions.add(PermissionInfo("Download without notification",Icons.download, "This permission allows an app to download files through the download manager without any notification being shown to the user.", "DOWNLOAD_WITHOUT_NOTIFICATION", []));
    permissions.add(PermissionInfo("Audio settings", Icons.settings_voice_outlined, "This permission allows an app to change audio settings such as volume and routing AUDIO for the entire system.", "AUDIO_SETTINGS", []));
    permissions.add(PermissionInfo("Vibrate",Icons.vibration, "This permission allows an app to access the device's vibrator and control its vibration functionality.", "VIBRATE", []));
    permissions.add(PermissionInfo("NFC",Icons.nfc, "This permission allows an app to access the device's Near Field Communication (NFC) functionalities.", "NFC", []));
    permissions.add(PermissionInfo("External Storage",Icons.sd_storage, "This permission allows an app to access the external storage of the device.", "EXTERNAL_STORAGE", []));
    permissions.add(PermissionInfo("Read call broadcast",Icons.broadcast_on_home, "This permission allows an app to read cell broadcast messages received by the device.", "READ_CELL_BROADCASTS", []));
    permissions.add(PermissionInfo("Disable keyguard",Icons.key_off_rounded, "This permission allows an app to disable the keyguard, allowing the device to remain unlocked or bypassing the lock screen temporarily.", "DISABLE_KEYGUARD", []));
    permissions.add(PermissionInfo("Battery status",Icons.battery_6_bar_sharp, "This permission allows an app to read live battery status of the device.", "BATTERY_STATS", []));
    permissions.add(PermissionInfo("Device configuration",Icons.settings_accessibility, "This permission allows an app to access Device's configuration data.", "READ_DEVICE_CONFIG", []));
    permissions.add(PermissionInfo("Reset fingerprint lock",Icons.fingerprint_sharp, "This is a system-level permission that allows an app to reset the lockout state of the fingerprint scanner. This permission is only granted to system apps.", "RESET_FINGERPRINT_LOCKOUT", []));
    permissions.add(PermissionInfo("System logs",Icons.backup_table_sharp, "This is a system-level permission that allows an app to read from the system’s various log files", "READ_LOGS", []));
    permissions.add(PermissionInfo("VPN control",Icons.vpn_lock_outlined, "This is a system-level permission that allows an app to control Device's VPN connection.", "CONTROL_VPN", []));
    permissions.add(PermissionInfo("Calender",Icons.calendar_month, "This permission allows an app to read the user's calendar data including events, appointments.", "READ_CALENDAR", []));
    permissions.add(PermissionInfo("Media data",Icons.play_arrow, "This permission allows an app to access from external storage. This includes reading media files such as audio, video, and images.", "MEDIA", []));
  }

  List<PermissionInfo> listPermissions(List<AppInfo> allApps, List<PermissionInfo> permissions){
    bool hasPermission;
    for(int i = 0; i< permissions.length; i++){
      permissions[i].apps = [];
      for(AppInfo app in allApps){
        hasPermission = app.permissions.any((element) => element.contains(permissions[i].compare_string));
        if(hasPermission) permissions[i].apps.add(app);
      }
    }
    setState(() {});
    //print("All app count: ${allApps.length}  || Permission count index 0 : ${permissions[0].apps.length}");
    return permissions;
  }

  Future<List<String>> _getPermissionList(String pkg_name) async {
    String state;
    List<String> my_list = [];
    try {
      final List<dynamic>? result = await platform.invokeMethod('getPermissions',pkg_name);
      if (result != null && result.isNotEmpty) {
        my_list = result.cast<String>();
      }

    } on PlatformException catch (e) {
      state = "Failed to get permission: '${e.message}'.";
    }
    //print(state);
    return my_list;
  }

  Future<void> getAllAppInfo() async {
    if(allApps.isNotEmpty) return;
    List<Application> apps = await DeviceApps.getInstalledApplications(includeSystemApps: true, includeAppIcons: true);



    List<String> permission_list = [];
    String dt;

    for(Application app in apps){
      // Print or process the permissions for each app
      dt = DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis).toString();
      dt = DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis));

    /*
      print('Name: ${app.appName}');
      print('Is system app: ${app.systemApp}');
      print('Pkg name: ${app.packageName}');

      print('Install time: ${dt}\n\n');
      print('File Path: ${app.apkFilePath}');
      print('Category: ${app.category}');
      print('Data dir: ${app.dataDir}');

      print('Pkg name: ${app.packageName}');
      print('V name: ${app.versionName}');
      */

      permission_list = await _getPermissionList(app.packageName);
      //print(app.systemApp);
      allApps.add(AppInfo(app.appName, app.versionName!, app.packageName, dt, app.systemApp, permission_list));
    }
    setState(() {});
  }

  late TabController _tabController;
  int _currentIndex = 0;
  bool _isInstalled = true;

  @override
  void initState() {
    super.initState();
    _isInstalled = true;
    _tabController = TabController(length: 2, vsync: this);
    allApps = [];
    getAllAppInfo();
    setPermissionInfo();
  }

  @override
  Widget build(BuildContext context) {

    print("Build was called, length of apps : ${allApps.length}");
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF9),
      appBar: AppBar(
        title: const Text(
          'Permission Manager',
          textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white
            )
        ),
        centerTitle: true,
        bottom: _currentIndex == 0
            ? TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE9F3EC),
                unselectedLabelColor: const Color(0xFFC1D7CE),
                onTap: (index) {
                  _isInstalled = index == 0;
                  setState(() {});
                },
                tabs: const [
                  Tab(text: 'INSTALLED', ),
                  Tab(text: 'SYSTEM'),
                ],
            )
            : null,
      ),
     //body: _buildBody(),
      body: allApps.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5F6F52),
                backgroundColor: Color(0xFF9FBB73),
              ),
            )
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B4242),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_sharp),
            label: 'All apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Permissions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outlined),
            label: 'About',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    String where = _isInstalled ? "Installed **********\n" : "System*********\n";
    print(where);

    return _currentIndex == 0
        ? HomePageSection(
            apps: _getAppsList(),
            onTap: (appInfo) {
              _navigateToAppDetails(context, appInfo);
            },
          )
        : _currentIndex == 1 ? SearchPage(permissions: listPermissions(allApps, permissions)) : AboutPage();// permissions

  }

  List<AppInfo> _getAppsList() {
    // Generate dynamic app data here
    String where = _isInstalled ? "Installed" : "System";
    selectedApps = [];

    for(AppInfo app in allApps){
      if(!_isInstalled && app.is_system_app) selectedApps.add(app);

      if(_isInstalled && !app.is_system_app) selectedApps.add(app);
    }
    print("Size of targeted list: ${selectedApps.length}  ${where}");


    return selectedApps;
  }

  List<PermissionInfo> _getPermissionInfoForThisApp(AppInfo appInfo){
    List<PermissionInfo> appPermissions = [];
    bool has_permission;
    for(PermissionInfo permissionInfo in permissions){
      has_permission = appInfo.permissions.any((element) => element.contains(permissionInfo.compare_string));
      if(has_permission)  appPermissions.add(permissionInfo);

    }
    print("${appInfo.name} has ${appPermissions.length} permissions.");
    return appPermissions;
  }

  void _navigateToAppDetails(BuildContext context, AppInfo appInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppDetailsPage(appInfo: appInfo, appPermissions: _getPermissionInfoForThisApp(appInfo)),
      ),
    );
  }
}

class HomePageSection extends StatelessWidget {
  final List<AppInfo> apps;
  final Function(AppInfo) onTap;

  HomePageSection({required this.apps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (apps.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTap(apps[index]);
                  },
                  child: Card(
                    color: const Color(0xFFECF6E7),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: const Icon(Icons.apps_rounded, color: Colors.black54),
                      title: Text(
                        '${apps[index].name} ',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Installed: ${apps[index].dateInstalled}\n'
                                'Version: ${apps[index].version} \n'
                                'Pkg name:${apps[index].packageName}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

}


class AppInfo {
  final String name;
  final String dateInstalled;
  final String version;
  final String packageName;
  final bool is_system_app;
  final List<String> permissions;

  AppInfo(
      this.name,
      this.version,
      this.packageName,
      this.dateInstalled,
      this.is_system_app,
      this.permissions
      );
}

class PermissionInfo{
  final String name;
  final String details;
  final String compare_string;
  final IconData icon;
  List<AppInfo> apps;

  PermissionInfo(this.name, this.icon, this.details, this.compare_string, this.apps);
  
}

class AppDetailsPage extends StatefulWidget {
  final AppInfo appInfo;
  final List<PermissionInfo> appPermissions;

  AppDetailsPage({required this.appInfo, required this.appPermissions});

  @override
  _AppDetailsPageState createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFFFF9),
        appBar: AppBar(
          title: const Text('App Details'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appInfo.name,
                  style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4242)),
                ),
                Text(
                  'Version: ${widget.appInfo.version}',
                  style: const TextStyle(
                      color: Color(0xFFB6BBC4)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Package Name: ${widget.appInfo.packageName}',
                  style: const TextStyle(fontSize: 16,
                      color: Color(0xFFB6BBC4)),
                ),
                Text(
                  'Date Installed: ${widget.appInfo.dateInstalled}',
                  style: const TextStyle(fontSize: 16,
                      color: Color(0xFFB6BBC4)),
                ),
                Text(
                  'Permissions: (${widget.appPermissions.length})',
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB6BBC4)),
                ),
                const SizedBox(height: 10),
                // Generate Switch widgets for each permission
                //...widget.appInfo.permissions.map((permission)
                ...widget.appPermissions.map((permission) {

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 15),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Icon(
                            permission.icon,
                            size: 24,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            permission.name,
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF67729D)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        permission.details,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF67729D)),
                      ),
                      const SizedBox(height: 2),
                      const Divider(
                        color: Color(0xFF5F6F52),
                        thickness: 1,
                      ),
                    ],
                  );
                }).toList()
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF79AC78),
          onPressed: (){
            print('Tapped on Item ${widget.appInfo.packageName}');
            Tools.openAppSettings(widget.appInfo.name ,widget.appInfo.packageName);
          },
          child: const Icon(Icons.settings, color: Color(0xFF22092C)),
        ),
    );
  }
}

//PreferredSize(
//         preferredSize: const Size.fromHeight(5.0),
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(5.0),
        child: AppBar(
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              size: 100.0,
              color: Color(0xFF79AC78),
            ),
            SizedBox(height: 20.0),
            Text(
              'pManager',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            Text(
              'This application serves as a comprehensive permission manager, developed as part of the INSE6130 Operating System Security course project (Fall2023).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Color(0xFF092635)),
            ),
            SizedBox(height: 10.0),
            Text(
              'While Android typically conceals certain permissions by default, our app ensures transparency by revealing and effectively managing them.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Color(0xFF092635)),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final List<PermissionInfo> permissions;

  SearchPage({required this.permissions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(5.0),
        child: AppBar(
          centerTitle: true,
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: _buildPermissionList(context),
        ),
      ],
    );
  }

  Widget _buildPermissionList(BuildContext context) {
    //print("Permission count: ${permissions.length}");
    return ListView.builder(
      itemCount: permissions.length,
      itemBuilder: (context, index) {
        return Card(
          color: const Color(0xFFECF6E7),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Icon(permissions[index].icon),
            title: Text(
              permissions[index].name,
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  permissions[index].details,  // Add your custom string here
                  style: const TextStyle(color: Color(0xFF58674A)),
                ),
                Text(
                  'Apps Count: ${permissions[index].apps.length}',
                  style: const TextStyle(color: Color(0xFF5F6F52)),
                ),
              ],
            ),
            onTap: () {
              _navigateToPermissionApps(context, permissions[index]);
            },
          ),
        );
      },
    );
  }


  void _navigateToPermissionApps(BuildContext context, PermissionInfo permissionInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PermissionAppsPage(permissionInfo: permissionInfo),
      ),
    );
  }
}

class PermissionAppsPage extends StatelessWidget {
  final PermissionInfo permissionInfo;

  PermissionAppsPage({required this.permissionInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF9),
      appBar: AppBar(
        title: const Text('Apps with Permission', style: const TextStyle( color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(permissionInfo.icon, size: 23.0,),
                      SizedBox(width: 5,),
                      Text(
                        permissionInfo.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF58674A)),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  Text(
                    '${permissionInfo.details}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'App Count: ${permissionInfo.apps.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 7.0)
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: permissionInfo.apps.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFFECF6E7),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        permissionInfo.apps[index].name,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // Add your onTap logic here
                        print('Tapped on Item ${permissionInfo.apps[index].packageName}');
                        Tools.openAppSettings(permissionInfo.apps[index].name ,permissionInfo.apps[index].packageName);
                      },
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Installed: ${permissionInfo.apps[index].dateInstalled}\n'
                                'Version: ${permissionInfo.apps[index].version} \n'
                                'Package Name: ${permissionInfo.apps[index].packageName}\n',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class Tools{
  static void showToast(String text, int duration_in_second) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG, // Duration of the toast
      gravity: ToastGravity.BOTTOM, // Toast gravity (top, center, bottom)
      timeInSecForIosWeb: duration_in_second, // Time duration for iOS
      backgroundColor: Colors.black54, // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }

  static void openAppSettings(String app_name, String packageName) async {
    try {
      DeviceApps.openAppSettings(packageName);
      Tools.showToast('Please click on Permissions, then modify accordingly.', 2);
    } catch (e) {
      // Handle the exception
      print('Cannot open: $e');
      Tools.showToast('Cannot open about page for $app_name', 2);
    }
  }

}
