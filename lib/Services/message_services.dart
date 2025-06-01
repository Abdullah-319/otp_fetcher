import 'package:another_telephony/telephony.dart';
import 'package:otp_fetcher/Secrets/secrets.dart';
import 'package:otp_fetcher/main.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageServices {
  // Prevent instantiation
  MessageServices._();

  /// Extracts OTP (4–8 digit number) from message
  static String? extractOtp(String message) {
    final regex = RegExp(r'\b\d{4,8}\b');
    final match = regex.firstMatch(message);
    return match?.group(0);
  }

  /// Sends OTP as SMS using Telephony plugin
  static Future<void> sendOtpAsSms(
    String otp,
    String recipientNumber,
    Telephony telephony,
  ) async {
    await telephony.sendSms(
      to: recipientNumber,
      message: "Forwarded OTP: $otp",
      statusListener: (SendStatus status) {
        print("SMS sent status: $status");
        if (status == SendStatus.SENT) {
          print("✅ SMS sent successfully to $recipientNumber with OTP: $otp");
        } else if (status == SendStatus.DELIVERED) {
          print("📦 SMS delivered to $recipientNumber with OTP: $otp");
        } else {
          print("❌ Failed to send SMS to $recipientNumber with OTP: $otp");
        }
      },
    );
  }

  /// Sends OTP via WhatsApp (requires user interaction)
  static Future<void> sendOtpToWhatsapp(String otp, String phone) async {
    final message = Uri.encodeComponent("OTP: $otp");
    final url = "https://wa.me/$phone?text=$message";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("❌ Could not launch WhatsApp URL.");
    }
  }

  /// Starts SMS listener and forwards OTP automatically
  static Future<void> startSmsListener(Telephony telephony) async {
    print("Lisrtening for incoming SMS...");
    final bool? permissionsGranted =
        await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          if (message.address == SenderPhone) {
            print("Received SMS from $SenderPhone");
            final otp = extractOtp(message.body ?? '');
            print(
              otp != null ? "Extracted OTP: $otp" : "No OTP found in message.",
            );
            print("Received SMS: ${message.body}");
            if (otp != null) {
              sendOtpAsSms(otp, ReceiverPhone, telephony);
              // sendOtpToWhatsapp(otp, PhoneNumber);
            }
          }
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    } else {
      print("❌ SMS permissions not granted.");
    }
  }
}
