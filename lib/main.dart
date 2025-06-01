import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:otp_fetcher/Secrets/secrets.dart';
import 'package:otp_fetcher/Services/message_services.dart';
import 'package:otp_fetcher/views/homepage.dart';

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  final Telephony telephony = Telephony.instance;
  final otp = MessageServices.extractOtp(message.body ?? '');
  if (otp != null) {
    // NOTE: You can't use Flutter UI libraries here
    MessageServices.sendOtpAsSms(otp, ReceiverPhone, telephony);
    // sendOtpToWhatsapp(otp, PhoneNumber);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Telephony telephony = Telephony.instance;
  MessageServices.startSmsListener(telephony);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // // Methods to extract OTP and send it via SMS or WhatsApp
  // String? extractOtp(String message) {
  //   final regex = RegExp(r'\b\d{4,8}\b');
  //   final match = regex.firstMatch(message);
  //   return match?.group(0);
  // }

  // void sendOtpAsSms(
  //   String otp,
  //   String recipientNumber,
  //   Telephony telephony,
  // ) async {
  //   await telephony.sendSms(
  //     to: recipientNumber,
  //     message: "Forwarded OTP: $otp",
  //     statusListener: (SendStatus status) {
  //       print("SMS sent status: $status");
  //       if (status == SendStatus.SENT) {
  //         print("✅ SMS sent successfully to $recipientNumber with OTP: $otp");
  //       } else if (status == SendStatus.DELIVERED) {
  //         print("📦 SMS delivered to $recipientNumber with OTP: $otp");
  //       } else {
  //         print("❌ Failed to send SMS to $recipientNumber with OTP: $otp");
  //       }
  //     },
  //   );
  // }

  // // For WhatsApp (must be opened by user tap)
  // void sendOtpToWhatsapp(String otp, String phone) async {
  //   final message = Uri.encodeComponent("OTP: $otp");
  //   final url = "https://wa.me/$phone?text=$message";
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //   }
  // }

  // // Listener to start listening for incoming SMS messages

  // void startSmsListener(Telephony telephony) async {
  //   // ✅ Ask for SMS permissions
  //   final bool? permissionsGranted = await telephony.requestSmsPermissions;
  //   if (permissionsGranted ?? false) {
  //     // ✅ Permissions granted: listen to SMS
  //     telephony.listenIncomingSms(
  //       onNewMessage: (SmsMessage message) {
  //         final otp = extractOtp(message.body ?? '');
  //         if (otp != null) {
  //           sendOtpAsSms(otp, PhoneNumber, telephony);
  //           // sendOtpToWhatsapp(otp, PhoneNumber);
  //         }
  //       },
  //       onBackgroundMessage: backgroundMessageHandler,
  //     );
  //   } else {
  //     // ❌ Show message to user
  //     print("SMS permissions not granted.");
  //   }
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OTP Fetcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: Homepage(),
    );
  }
}
