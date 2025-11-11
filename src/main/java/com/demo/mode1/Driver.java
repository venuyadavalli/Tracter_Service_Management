package com.demo.mode1;

public class Driver {
    private int driverId;
    private String name;
    private String tractorNumber;
    private int ownerId;

    public Driver(int driverId, String name, String tractorNumber, int ownerId) {
        this.driverId = driverId;
        this.name = name;
        this.tractorNumber = tractorNumber;
        this.ownerId = ownerId;
    }

    public int getDriverId() { return driverId; }
    public String getName() { return name; }
    public String getTractorNumber() { return tractorNumber; }
    public int getOwnerId() { return ownerId; }
}

