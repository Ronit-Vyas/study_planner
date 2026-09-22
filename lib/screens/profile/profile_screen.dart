import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalCourses = 0;
  int totalTasks = 0;
  int completedTasks = 0;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final courses = await LocalStorageService.getCourses();
    final tasks = await LocalStorageService.getAllTasks();
    final notifs = await LocalStorageService.getNotificationsEnabled();

    if (!mounted) return;
    setState(() {
      totalCourses = courses.length;
      totalTasks = tasks.length;
      completedTasks = tasks.where((t) => t.completed).length;
      notificationsEnabled = notifs;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: const Text('Daily Study Reminders'),
                    subtitle: const Text('Receive alerts for pending tasks & deadlines'),
                    value: notificationsEnabled,
                    onChanged: (val) async {
                      await LocalStorageService.setNotificationsEnabled(val);
                      setSheetState(() {
                        notificationsEnabled = val;
                      });
                      setState(() {
                        notificationsEnabled = val;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await NotificationService.showNotification(
                          id: 999,
                          title: '🔔 Test Study Reminder',
                          body: 'Notifications are active! Your study plan is on track.',
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test notification sent!')),
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Send Test Notification'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final userName = user?.name ?? 'Student';
    final userEmail = user?.email ?? 'student@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.indigo,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              userEmail,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            // Study Statistics Card (Local Data)
            Card(
              elevation: 0,
              color: Colors.indigo.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Courses', '$totalCourses'),
                    Container(height: 35, width: 1, color: Colors.grey.shade300),
                    _buildStatItem('Total Tasks', '$totalTasks'),
                    Container(height: 35, width: 1, color: Colors.grey.shade300),
                    _buildStatItem('Completed', '$completedTasks'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage_outlined, color: Colors.indigo),
                    title: const Text('Storage Mode'),
                    subtitle: const Text('Courses & tasks stored locally on device'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    subtitle: Text(notificationsEnabled ? 'Enabled' : 'Disabled'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showNotificationSettings,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}