import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class GoogleAssistantDemo extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  GoogleAssistantDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Google Assistant Demo'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeController.primaryTextColor.value,
            ),
            onPressed: () {
              Utils.hapticFeedback();
              Get.back();
            },
          ),
        ),
        backgroundColor: themeController.primaryBackgroundColor.value,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction section
                _buildSectionTitle(context, 'Voice Control for Ultimate Alarm Clock'),
                _buildSectionDescription(
                  context,
                  'Control your alarms with just your voice using Google Assistant. '
                  'Enable this feature in settings and start using these commands:',
                ),
                const SizedBox(height: 20),

                // Command demonstration cards
                _buildCommandCard(
                  context,
                  'Set an Alarm',
                  'Hey Google, set an alarm for 7:30 AM tomorrow in Ultimate Alarm Clock',
                  Icons.alarm_add,
                  Colors.blue[700]!,
                  width,
                ),
                _buildCommandCard(
                  context,
                  'Create Recurring Alarm',
                  'Hey Google, set a daily alarm for 6:00 AM labeled "Work" in Ultimate Alarm Clock',
                  Icons.repeat,
                  Colors.green[700]!,
                  width,
                ),
                _buildCommandCard(
                  context,
                  'Cancel an Alarm',
                  'Hey Google, cancel my "Work" alarm in Ultimate Alarm Clock',
                  Icons.alarm_off,
                  Colors.red[700]!,
                  width,
                ),
                _buildCommandCard(
                  context,
                  'Enable/Disable an Alarm',
                  'Hey Google, disable my "Weekend" alarm in Ultimate Alarm Clock',
                  Icons.toggle_off,
                  Colors.purple[700]!,
                  width,
                ),
                
                const SizedBox(height: 30),
                
                // Integration with other features
                _buildSectionTitle(context, 'Works with Your Features'),
                _buildFeatureIntegrationCard(
                  context,
                  'Negative Condition Alarms',
                  'Alarms created with Google Assistant can use negative conditions - they\'ll ring when conditions are NOT met.',
                  Icons.do_not_disturb_on,
                  Colors.amber[800]!,
                  width,
                ),
                _buildFeatureIntegrationCard(
                  context,
                  'Sunrise Alarm',
                  'Voice-created alarms will use your sunrise settings, gradually brightening the screen for a gentle wake-up.',
                  Icons.wb_sunny,
                  Colors.orange[700]!,
                  width,
                ),
                
                const SizedBox(height: 30),
                
                // Setup instructions
                _buildSectionTitle(context, 'How to Set Up'),
                _buildSetupStep(context, '1', 'Enable Google Assistant in app settings'),
                _buildSetupStep(context, '2', 'Make sure Google Assistant is set up on your device'),
                _buildSetupStep(context, '3', 'Try the commands shown above'),
                _buildSetupStep(context, '4', 'Enjoy controlling your alarms with voice!'),
                
                const SizedBox(height: 40),
                
                // Demo button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Utils.hapticFeedback();
                      _showDemoAnimation(context);
                    },
                    icon: const Icon(Icons.mic),
                    label: const Text('See Voice Command Demo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeController.primaryColor.value,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.tr,
        style: TextStyle(
          color: themeController.primaryTextColor.value,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionDescription(BuildContext context, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        description.tr,
        style: TextStyle(
          color: themeController.primaryTextColor.value.withOpacity(0.9),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCommandCard(
    BuildContext context,
    String title,
    String command,
    IconData icon,
    Color color,
    double width,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: themeController.secondaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      command.tr,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIntegrationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    double width,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: themeController.secondaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description.tr,
                      style: TextStyle(
                        color: themeController.primaryTextColor.value.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupStep(BuildContext context, String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: themeController.primaryColor.value,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            instruction.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Listening...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '"Set an alarm for 7:30 AM tomorrow"',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Creating alarm for 7:30 AM tomorrow',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Close Demo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
