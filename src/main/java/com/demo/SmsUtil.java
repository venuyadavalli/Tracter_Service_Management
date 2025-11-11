package com.demo;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import io.github.cdimascio.dotenv.Dotenv;


public class SmsUtil {

    // Twilio credentials
	private static final Dotenv dotenv = Dotenv.load();
	public static final String ACCOUNT_SID = dotenv.get("TWILIO_ACCOUNT_SID");
	public static final String AUTH_TOKEN = dotenv.get("TWILIO_AUTH_TOKEN");
	public static final String TWILIO_NUMBER = dotenv.get("TWILIO_NUMBER");
	
	


    static {
        Twilio.init(ACCOUNT_SID, AUTH_TOKEN);
        System.out.println("SID: " + ACCOUNT_SID);
        System.out.println("Token: " + AUTH_TOKEN);
        System.out.println("Number: " + TWILIO_NUMBER);

    }

    /** 
     * Old SMS method (no tool, keeps older code working)
     */
    public static void sendSms(String toPhone, String customerName, String jobDate,
                                String driverName, int hours, double rate, double total) {
        String messageText = String.format(
            "Sent from your TRACTOR SERVICE\nHello %s, your job is scheduled on %s.\nDriver: %s.\nHours: %d, Rate: ₹%.2f/hr, Total: ₹%.2f.\nThank you!",
            customerName, jobDate, driverName, hours, rate, total
        );

        Message message = Message.creator(
                new PhoneNumber("+91" + toPhone),
                new PhoneNumber(TWILIO_NUMBER),
                messageText
        ).create();

        System.out.println("Job SMS Sent! SID: " + message.getSid());
    }

    /**
     * New SMS method (with tool name)
     */
    public static void sendSms(String toPhone, String customerName, String jobDate,
                                String driverName, String toolName, int hours, double rate, double total) {
        String messageText = String.format(
            "Sent from your TRACTOR SERVICE\n" +
            "Hello %s, your job is scheduled on %s.\n" +
            "Driver: %s.\n" +
            "Tool: %s.\n" +
            "Hours: %d, Rate: ₹%.2f/hr, Total: ₹%.2f.\n" +
            "Thank you!",
            customerName, jobDate, driverName, toolName, hours, rate, total
        );

        Message message = Message.creator(
                new PhoneNumber("+91" + toPhone),
                new PhoneNumber(TWILIO_NUMBER),
                messageText
        ).create();

        System.out.println("Job SMS Sent (with Tool)! SID: " + message.getSid());
    }

    /**
     * Password SMS (used for Forgot Password)
     */
    public static void sendPasswordSms(String toPhone, String password) {
        String messageText = "Your Tractor Service account password is: " + password;

        Message message = Message.creator(
                new PhoneNumber("+91" + toPhone),
                new PhoneNumber(TWILIO_NUMBER),
                messageText
        ).create();

        System.out.println("Password SMS Sent! SID: " + message.getSid());
    }
}
