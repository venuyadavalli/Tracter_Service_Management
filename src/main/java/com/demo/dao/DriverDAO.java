package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.demo.DBConnection;
import com.demo.mode1.Customer;
import com.demo.mode1.Driver;

public class DriverDAO {

    // Login validation
    public Driver validateDriver(String tractorNumber, String password) {
        Driver driver = null;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM driver WHERE tractor_number=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, tractorNumber);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                driver = new Driver(rs.getInt("driver_id"), rs.getString("name"),
                        rs.getString("tractor_number"), rs.getInt("owner_id"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return driver;
    }

    // Add Customer (avoid duplicates of active ones)
    public int addCustomer(int driverId, String name, String mobile) {
        try (Connection con = DBConnection.getConnection()) {
            // Check if customer already exists
            PreparedStatement check = con.prepareStatement("SELECT customer_id FROM customer WHERE mobile=? AND active=1");
            check.setString(1, mobile);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                return rs.getInt("customer_id"); // return existing customerId
            }
            rs.close();
            check.close();

            // Insert new customer
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO customer (name, mobile, driver_id, active) VALUES (?, ?, ?, 1)",
                PreparedStatement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, name);
            ps.setString(2, mobile);
            ps.setInt(3, driverId);
            ps.executeUpdate();

            // Get the auto-generated customer_id
            ResultSet keys = ps.getGeneratedKeys();
            int newCustomerId = -1;
            if (keys.next()) {
                newCustomerId = keys.getInt(1);
            }

            keys.close();
            ps.close();

            return newCustomerId;
        } catch (Exception e) {
            e.printStackTrace();
            return -1; // indicate failure
        }
    }


    // Fetch tools for dropdown
    public ResultSet getOwnerTools(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT tool_id, tool_name, rate_per_hour FROM tools WHERE owner_id=? AND active=1");
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }

    // Get customers for dropdown
    public List<Map<String, String>> getCustomersList(int driverId) throws Exception {
        List<Map<String, String>> customers = new ArrayList<>();
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT customer_id, name, mobile FROM customer WHERE driver_id=? AND active=1 ORDER BY name");
        ps.setInt(1, driverId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> row = new HashMap<>();
            row.put("id", rs.getString("customer_id"));
            row.put("name", rs.getString("name"));
            row.put("mobile", rs.getString("mobile"));
            customers.add(row);
        }
        rs.close(); ps.close(); con.close();
        return customers;
    }

    public List<Map<String, String>> searchCustomers(int driverId, String keyword, String date) throws Exception {
        List<Map<String, String>> customers = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder(
                "SELECT customer_id, name, mobile, created_at FROM customer WHERE driver_id = ? AND active = 1"
            );

            if (keyword != null && !keyword.isEmpty()) {
                sql.append(" AND (name LIKE ? OR mobile LIKE ?)");
            }
            if (date != null && !date.isEmpty()) {
                sql.append(" AND DATE(created_at) = ?");
            }

            sql.append(" ORDER BY created_at DESC");

            PreparedStatement ps = con.prepareStatement(sql.toString());
            ps.setInt(1, driverId);
            int index = 2;
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(index++, "%" + keyword + "%");
                ps.setString(index++, "%" + keyword + "%");
            }
            if (date != null && !date.isEmpty()) {
                ps.setString(index++, date);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("id", String.valueOf(rs.getInt("customer_id")));
                row.put("name", rs.getString("name"));
                row.put("mobile", rs.getString("mobile"));
                row.put("created_at", rs.getTimestamp("created_at").toString());
                customers.add(row);
            }
            rs.close();
            ps.close();
        }
        return customers;
    }



 // Insert job and return success status
    public boolean addJobExistingCustomer(int driverId, int customerId, int toolId,
                                          int hours, double rate, double total, String date) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO job (customer_id, driver_id, tool_id, tool_type, hours_used, amount_per_hour, amount_paid, total, date) " +
            "VALUES (?, ?, ?, (SELECT tool_name FROM tools WHERE tool_id=?), ?, ?, 0, ?, ?)"
        );
        ps.setInt(1, customerId);
        ps.setInt(2, driverId);
        ps.setInt(3, toolId);
        ps.setInt(4, toolId);
        ps.setInt(5, hours);
        ps.setDouble(6, rate);
        ps.setDouble(7, total);
        ps.setString(8, date);

        int rowsInserted = ps.executeUpdate();
        ps.close();
        con.close();

        return rowsInserted > 0;
    }

    // Fetch customer details for SMS
    public Customer getCustomerById(int customerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT customer_id, name, mobile, driver_id FROM customer WHERE customer_id=?");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();

        Customer customer = null;
        if (rs.next()) {
            customer = new Customer();
            customer.setCustomerId(rs.getInt("customer_id"));
            customer.setName(rs.getString("name"));
            customer.setMobile(rs.getString("mobile"));
            customer.setDriverId(rs.getInt("driver_id"));
        }

        rs.close();
        ps.close();
        con.close();

        return customer;
    }




    // Search Jobs (with optional date)
    public ResultSet searchJobsByCustomerAndDate(int driverId, String keyword, String date) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT j.job_id, j.customer_id, c.name AS customer, c.mobile, j.tool_id, " +
                     "t.tool_name AS tool_type, j.hours_used, j.amount_per_hour, j.date " +
                     "FROM job j JOIN customer c ON j.customer_id=c.customer_id " +
                     "JOIN tools t ON j.tool_id=t.tool_id " +
                     "WHERE j.driver_id=? AND (c.name LIKE ? OR c.mobile LIKE ?)";
        if (date != null && !date.isEmpty()) sql += " AND j.date=?";
        sql += " ORDER BY j.date DESC";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, driverId);
        ps.setString(2, "%" + keyword + "%");
        ps.setString(3, "%" + keyword + "%");
        if (date != null && !date.isEmpty()) ps.setString(4, date);
        return ps.executeQuery();
    }

    // Pagination: Count total jobs
    public int getTotalJobsCount(int driverId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM job WHERE driver_id=?");
        ps.setInt(1, driverId);
        ResultSet rs = ps.executeQuery();
        rs.next();
        int count = rs.getInt(1);
        rs.close(); ps.close(); con.close();
        return count;
    }

    // Pagination: Fetch jobs (20 per page)
    public ResultSet getJobsPaginated(int driverId, int offset, int limit) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT j.job_id, j.customer_id, c.name AS customer, j.tool_id, t.tool_name AS tool_type, " +
                     "j.hours_used, j.amount_per_hour, j.date " +
                     "FROM job j JOIN customer c ON j.customer_id=c.customer_id " +
                     "JOIN tools t ON j.tool_id=t.tool_id " +
                     "WHERE j.driver_id=? ORDER BY j.date DESC LIMIT ? OFFSET ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, driverId);
        ps.setInt(2, limit);
        ps.setInt(3, offset);
        return ps.executeQuery();
    }
    
    public int getJobsCount(int driverId) throws Exception {
        int count = 0;
        Connection con = DBConnection.getConnection();
        String sql = "SELECT COUNT(*) AS total FROM job WHERE driver_id = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, driverId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            count = rs.getInt("total");
        }
        rs.close();
        ps.close();
        con.close();
        return count;
    }


    // Update job (customer/tool/hours/date)
    public void updateJob(int jobId, int customerId, int toolId, int hours, String date) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "UPDATE job SET customer_id=?, tool_id=?, hours_used=?, date=?, " +
            "amount_per_hour=(SELECT rate_per_hour FROM tools WHERE tool_id=?) WHERE job_id=?");
        ps.setInt(1, customerId);
        ps.setInt(2, toolId);
        ps.setInt(3, hours);
        ps.setString(4, date);
        ps.setInt(5, toolId);
        ps.setInt(6, jobId);
        ps.executeUpdate();
        ps.close(); con.close();
    }
    public int getActiveCustomersCount(int driverId) throws Exception {
        int count = 0;
        String sql = "SELECT COUNT(*) AS cnt FROM customer WHERE driver_id=? AND active=1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("cnt");
                }
            }
        }
        return count;
    }


 // To count only active jobs for this driver
    public int getToogetAvailableToolsCountlsCount(int ownerId) throws Exception {
        int count = 0;
        String sql = "SELECT COUNT(*) AS count FROM tools WHERE owner_id = ? AND active = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("count");
                }
            }
        }
        return count;
    }


    public double getTotalEarningsThisMonth(int driverId) throws Exception {
        String sql = "SELECT COALESCE(SUM(hours_used*amount_per_hour),0) AS total FROM job WHERE driver_id=? AND MONTH(date)=MONTH(CURRENT_DATE()) AND YEAR(date)=YEAR(CURRENT_DATE())";
        try(Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)){
            ps.setInt(1, driverId);
            try(ResultSet rs=ps.executeQuery()){
                if(rs.next()) {
                    return rs.getDouble("total");
                }
            }
        }
        return 0.0;
    }

    public double getPendingDues(int driverId) throws Exception {
        String sql = "SELECT COALESCE(SUM(hours_used*amount_per_hour - amount_paid),0) AS due FROM job WHERE driver_id=? AND (hours_used*amount_per_hour > amount_paid)";
        try(Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)){
            ps.setInt(1, driverId);
            try(ResultSet rs=ps.executeQuery()){
                if(rs.next()) {
                    return rs.getDouble("due");
                }
            }
        }
        return 0.0;
    }

}
