/*
 * package com.demo.mode1;
 * 
 * public class Customer { private int customerId; private String name; private
 * String mobile; private int driverId;
 * 
 * public Customer(int customerId, String name, String mobile, int driverId) {
 * this.customerId = customerId; this.name = name; this.mobile = mobile;
 * this.driverId = driverId; }
 * 
 * public int getCustomerId() { return customerId; } public String getName() {
 * return name; } public String getMobile() { return mobile; } public int
 * getDriverId() { return driverId; }
 * 
 * 
 * }
 */

package com.demo.mode1;

public class Customer {
    private int customerId;
    private String name;
    private String mobile;
    private int driverId;

    // Empty constructor for flexibility
    public Customer() {}

    // Full constructor
    public Customer(int customerId, String name, String mobile, int driverId) {
        this.customerId = customerId;
        this.name = name;
        this.mobile = mobile;
        this.driverId = driverId;
    }

    // Getters and Setters
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }

    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }
}


