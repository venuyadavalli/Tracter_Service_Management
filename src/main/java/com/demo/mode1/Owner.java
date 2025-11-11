package com.demo.mode1;

public class Owner {
    private int ownerId;
    private String name;
    private String mobile;
    private String vehicleNumber;
    private String password;  // Added for login/session use

    public Owner(int ownerId, String name, String mobile, String vehicleNumber, String password) {
        this.ownerId = ownerId;
        this.name = name;
        this.mobile = mobile;
        this.vehicleNumber = vehicleNumber;
        this.password = password;
    }

    public int getOwnerId() { return ownerId; }
    public String getName() { return name; }
    public String getMobile() { return mobile; }
    public String getVehicleNumber() { return vehicleNumber; }
    public String getPassword() { return password; }
}
