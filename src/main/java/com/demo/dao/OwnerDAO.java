package com.demo.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

import com.demo.DBConnection;
import com.demo.mode1.Owner;

public class OwnerDAO {

    // Register new owner
    public boolean registerOwner(String name, String mobile, String vehicleNo, String password) {
        try (Connection con = DBConnection.getConnection()) {
            vehicleNo = vehicleNo != null ? vehicleNo.trim().toUpperCase() : "";
            if (!vehicleNo.matches("^[A-Z]{2}[0-9]{2}[A-Z]{1,3}[0-9]{1,4}$")) {
                System.out.println("Invalid Vehicle Number format: " + vehicleNo);
                return false;
            }

            String sql = "INSERT INTO owner (name, mobile, vehicle_number, password) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, mobile);
            ps.setString(3, vehicleNo);
            ps.setString(4, password);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Validate owner login
    public Owner validateOwner(String mobile, String vehicleNo, String password) {
        Owner owner = null;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM owner WHERE mobile=? AND vehicle_number=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, mobile);
            ps.setString(2, vehicleNo);
            ps.setString(3, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                owner = new Owner(
                    rs.getInt("owner_id"),
                    rs.getString("name"),
                    rs.getString("mobile"),
                    rs.getString("vehicle_number"),
                    rs.getString("password") // ensure password is set
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return owner;
    }

    // Check owner by mobile & vehicle
    public boolean ownerExists(String mobile, String vehicleNo) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT 1 FROM owner WHERE mobile=? AND vehicle_number=?")) {
            ps.setString(1, mobile);
            ps.setString(2, vehicleNo);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getPasswordByMobileAndVehicle(String mobile, String vehicleNo) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT password FROM owner WHERE mobile=? AND vehicle_number=?")) {
            ps.setString(1, mobile);
            ps.setString(2, vehicleNo);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("password");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }



    
    // Add a new driver for this owner
    public boolean addDriver(int ownerId, String name, String tractorNumber, String password) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO driver (name, tractor_number, password, owner_id) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, tractorNumber);
            ps.setString(3, password);
            ps.setInt(4, ownerId);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get drivers
    public ResultSet getDrivers(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT driver_id, name, tractor_number, password, created_at FROM driver WHERE owner_id=? AND active=1"
        );
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }


    
    public void deleteDriver(int driverId, int ownerId) throws Exception {
        String sql = "UPDATE driver SET active=0 WHERE driver_id=? AND owner_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, ownerId);
            ps.executeUpdate();
        }
    }

    public void updateDriver(int driverId, int ownerId, String name, String tractorNumber, String password) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "UPDATE driver SET name=?, password=? WHERE driver_id=? AND owner_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, password);
            ps.setInt(3, driverId);
            ps.setInt(4, ownerId);
            ps.executeUpdate();
        }
    }
    
    public String getTractorNumberByDriverId(int driverId, int ownerId) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT tractor_number FROM driver WHERE driver_id=? AND owner_id=?"
            );
            ps.setInt(1, driverId);
            ps.setInt(2, ownerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("tractor_number");
            }
        }
        return "";
    }

    
   



    // List all jobs with dues for this owner
    public ResultSet getCustomerDues(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT j.job_id, c.name AS customer, d.name AS driver, j.tool_type, j.hours_used, " +
                "j.amount_per_hour, j.amount_paid, (j.hours_used * j.amount_per_hour) AS total, " +
                "(j.hours_used * j.amount_per_hour - j.amount_paid) AS due, j.date " +
                "FROM job j " +
                "JOIN customer c ON j.customer_id=c.customer_id " +
                "JOIN driver d ON j.driver_id=d.driver_id " +
                "WHERE d.owner_id=? AND c.active=1";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }

    // Mark full job as paid (used when clicking "Pay Full")
    public void markJobPaid(int jobId) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "UPDATE job SET amount_paid = (hours_used * amount_per_hour) WHERE job_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.executeUpdate();
        }
    }

    // Monthly summary for reports
    public ResultSet getMonthlyReport(int ownerId, int month, int year) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT SUM(hours_used * amount_per_hour) AS total_revenue, " +
                "SUM(CASE WHEN (hours_used * amount_per_hour - amount_paid) > 0 THEN (hours_used * amount_per_hour - amount_paid) ELSE 0 END) AS unpaid_dues, " +
                "COUNT(job_id) AS total_jobs " +
                "FROM job j JOIN driver d ON j.driver_id=d.driver_id " +
                "WHERE d.owner_id=? AND MONTH(j.date)=? AND YEAR(j.date)=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        ps.setInt(2, month);
        ps.setInt(3, year);
        return ps.executeQuery();
    }

    // Add payment (partial or full) to a job
    public void updatePayment(int jobId, double paidAmount) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "UPDATE job SET amount_paid = amount_paid + ? WHERE job_id=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setDouble(1, paidAmount);
        ps.setInt(2, jobId);
        ps.executeUpdate();
    }

    // Add a new tool for owner
    public void addTool(int ownerId, String toolName, double rate) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "INSERT INTO tools (owner_id, tool_name, rate_per_hour, active) VALUES (?, ?, ?, 1)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        ps.setString(2, toolName);
        ps.setDouble(3, rate);
        ps.executeUpdate();
    }

    // Get active tools only
    public ResultSet getTools(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
                "SELECT tool_id, tool_name, rate_per_hour FROM tools WHERE owner_id=? AND active=1"
        );
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }

    // Soft delete tool (hide from driver)
    public void deleteTool(int toolId, int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
                "UPDATE tools SET active=0 WHERE tool_id=? AND owner_id=?"
        );
        ps.setInt(1, toolId);
        ps.setInt(2, ownerId);
        ps.executeUpdate();
    }

    // Update only tool rate (not name)
    public void updateTool(int toolId, int ownerId, String toolName, double rate) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
                "UPDATE tools SET rate_per_hour=? WHERE tool_id=? AND owner_id=?"
        );
        ps.setDouble(1, rate);
        ps.setInt(2, toolId);
        ps.setInt(3, ownerId);
        ps.executeUpdate();
    }

    // Tools dropdown for driver
    public ResultSet getOwnerTools(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
                "SELECT tool_id, tool_name, rate_per_hour FROM tools WHERE owner_id=? AND active=1"
        );
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }

    // Get customer summary for dues table
    public ResultSet getCustomerDueSummary(int ownerId) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT c.customer_id, c.name AS customer, " +
                "SUM(j.hours_used * j.amount_per_hour) AS total_cost, " +
                "SUM(j.amount_paid) AS total_paid, " +
                "GREATEST(SUM(j.hours_used * j.amount_per_hour) - SUM(j.amount_paid), 0) AS total_due " +
                "FROM job j " +
                "JOIN customer c ON j.customer_id = c.customer_id " +
                "JOIN driver d ON j.driver_id = d.driver_id " +
                "WHERE d.owner_id = ? AND c.active = 1 " +
                "GROUP BY c.customer_id, c.name";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        return ps.executeQuery();
    }

    // Update payment across multiple jobs (distribute paidAmount)
    public void updateCustomerPayment(int customerId, double paidAmount) throws Exception {
        Connection con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            PreparedStatement ps = con.prepareStatement(
                    "SELECT job_id, (hours_used * amount_per_hour - amount_paid) AS due " +
                            "FROM job WHERE customer_id=? AND (hours_used * amount_per_hour - amount_paid) > 0 ORDER BY date"
            );
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();

            double remaining = paidAmount;

            while (rs.next() && remaining > 0) {
                int jobId = rs.getInt("job_id");
                double due = rs.getDouble("due");

                double payThisJob = Math.min(remaining, due);
                remaining -= payThisJob;

                PreparedStatement ps2 = con.prepareStatement(
                        "UPDATE job SET amount_paid = amount_paid + ? WHERE job_id=?"
                );
                ps2.setDouble(1, payThisJob);
                ps2.setInt(2, jobId);
                ps2.executeUpdate();
                ps2.close();
            }
            con.commit();
        } catch (Exception e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    // Soft delete customer (hide but keep jobs/payments intact)
    public void deleteCustomer(int customerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
                "UPDATE customer SET active=0 WHERE customer_id=?"
        );
        ps.setInt(1, customerId);
        ps.executeUpdate();
    }
    

    
	/*
	 * public List<Map<String, Object>> searchCustomerDetails(int ownerId, String
	 * phone) throws Exception { List<Map<String, Object>> results = new
	 * ArrayList<>(); Connection con = DBConnection.getConnection();
	 * 
	 * String sql =
	 * "SELECT c.customer_id, c.name AS customer, c.mobile, d.name AS driver, j.tool_type, "
	 * + "j.hours_used, j.amount_per_hour, j.amount_paid, j.date, " +
	 * "(j.hours_used * j.amount_per_hour) AS total, " +
	 * "(j.hours_used * j.amount_per_hour - j.amount_paid) AS due " + "FROM job j "
	 * + "JOIN customer c ON j.customer_id = c.customer_id " +
	 * "JOIN driver d ON j.driver_id = d.driver_id " +
	 * "WHERE c.mobile = ? AND d.owner_id = ? AND c.active = 1";
	 * 
	 * PreparedStatement ps = con.prepareStatement(sql); ps.setString(1, phone);
	 * ps.setInt(2, ownerId); ResultSet rs = ps.executeQuery();
	 * 
	 * while (rs.next()) { Map<String, Object> row = new HashMap<>();
	 * row.put("customer_id", rs.getInt("customer_id")); row.put("customer",
	 * rs.getString("customer")); row.put("mobile", rs.getString("mobile"));
	 * row.put("driver", rs.getString("driver")); row.put("tool_type",
	 * rs.getString("tool_type")); row.put("hours_used", rs.getInt("hours_used"));
	 * row.put("amount_per_hour", rs.getDouble("amount_per_hour"));
	 * row.put("amount_paid", rs.getDouble("amount_paid")); row.put("date",
	 * rs.getDate("date")); row.put("total", rs.getDouble("total")); row.put("due",
	 * rs.getDouble("due")); results.add(row); }
	 * 
	 * rs.close(); ps.close(); con.close(); return results; }
	 */
    
    public List<Map<String, Object>> searchCustomerJobs(int ownerId, String keyword, String date) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection con = DBConnection.getConnection();

        String sql = "SELECT j.date, c.customer_id, c.name AS customer, c.mobile, " +
                     "d.name AS driver, t.tool_name AS tool_type, j.hours_used, j.amount_per_hour, " +
                     "(j.hours_used * j.amount_per_hour) AS total, j.amount_paid, " +
                     "(j.hours_used * j.amount_per_hour - j.amount_paid) AS due " +
                     "FROM job j " +
                     "JOIN customer c ON j.customer_id = c.customer_id " +
                     "JOIN driver d ON j.driver_id = d.driver_id " +
                     "JOIN tools t ON j.tool_id = t.tool_id " +
                     "WHERE d.owner_id=?";

        if (keyword != null && !keyword.isEmpty()) {
            sql += " AND (c.name LIKE ? OR c.mobile LIKE ?)";
        }
        if (date != null && !date.isEmpty()) {
            sql += " AND j.date=?";
        }
        sql += " ORDER BY j.date DESC";

        PreparedStatement ps = con.prepareStatement(sql);
        int idx = 1;
        ps.setInt(idx++, ownerId);
        if (keyword != null && !keyword.isEmpty()) {
            ps.setString(idx++, "%" + keyword + "%");
            ps.setString(idx++, "%" + keyword + "%");
        }
        if (date != null && !date.isEmpty()) {
            ps.setString(idx++, date);
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("date", rs.getDate("date"));
            row.put("customer_id", rs.getInt("customer_id"));
            row.put("customer", rs.getString("customer"));
            row.put("mobile", rs.getString("mobile"));
            row.put("driver", rs.getString("driver"));
            row.put("tool_type", rs.getString("tool_type"));
            row.put("hours_used", rs.getInt("hours_used"));
            row.put("amount_per_hour", rs.getDouble("amount_per_hour"));
            row.put("total", rs.getDouble("total"));
            row.put("amount_paid", rs.getDouble("amount_paid"));
            row.put("due", rs.getDouble("due"));
            list.add(row);
        }
        con.close();
        return list;
    }
 // Fetch all job details for a given month/year (for PDF export)
	/*
	 * public ResultSet getMonthlyJobDetails(int ownerId, int month, int year)
	 * throws Exception { Connection con = DBConnection.getConnection(); String sql
	 * = "SELECT j.date, c.name AS customer, d.name AS driver, " +
	 * "t.tool_name AS tool, j.hours_used, j.amount_per_hour, " +
	 * "(j.hours_used * j.amount_per_hour) AS total " + "FROM job j " +
	 * "JOIN customer c ON j.customer_id = c.customer_id " +
	 * "JOIN driver d ON j.driver_id = d.driver_id " +
	 * "JOIN tools t ON j.tool_id = t.tool_id " +
	 * "WHERE d.owner_id=? AND MONTH(j.date)=? AND YEAR(j.date)=? " +
	 * "ORDER BY j.date ASC"; PreparedStatement ps = con.prepareStatement(sql);
	 * ps.setInt(1, ownerId); ps.setInt(2, month); ps.setInt(3, year); return
	 * ps.executeQuery(); }
	 */
    
    public ResultSet getMonthlyJobDetails(int ownerId, int month, int year) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT j.date, c.name AS customer, d.name AS driver, t.tool_name AS tool_type, " +
                     "j.hours_used, j.amount_per_hour " +
                     "FROM job j " +
                     "JOIN customer c ON j.customer_id=c.customer_id " +
                     "JOIN driver d ON j.driver_id=d.driver_id " +
                     "JOIN tools t ON j.tool_id=t.tool_id " +
                     "WHERE d.owner_id=? AND MONTH(j.date)=? AND YEAR(j.date)=? " +
                     "ORDER BY j.date ASC";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        ps.setInt(2, month);
        ps.setInt(3, year);
        return ps.executeQuery();
    }

 // Count total drivers for this owner
    public ResultSet getDriverCount(int ownerId) throws Exception {
        String sql = "SELECT COUNT(*) FROM driver WHERE owner_id = ?";
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        return ps.executeQuery();  // Caller (JSP) will close ResultSet
    }

    // Count total tools for this owner
    public ResultSet getToolCount(int ownerId) throws Exception {
        String sql = "SELECT COUNT(*) FROM tools WHERE owner_id = ?";
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        return ps.executeQuery();  // Caller (JSP) will close ResultSet
    }
    
 // Return total count of active drivers
    public int getActiveDriversCount(int ownerId) throws Exception {
        int count = 0;
        String sql = "SELECT COUNT(*) AS count FROM driver WHERE owner_id = ? AND active = 1";
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

    // Return total count of active tools
    public int getToolsCount(int ownerId) throws Exception {
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

    // Return current month revenue
    public double getMonthlyRevenue(int ownerId) throws Exception {
        double revenue = 0.0;
        String sql = "SELECT COALESCE(SUM(hours_used * amount_per_hour), 0) AS revenue " +
                     "FROM job j JOIN driver d ON j.driver_id = d.driver_id " +
                     "WHERE d.owner_id = ? AND MONTH(j.date) = MONTH(CURDATE()) AND YEAR(j.date) = YEAR(CURDATE())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    revenue = rs.getDouble("revenue");
                }
            }
        }
        return revenue;
    }

    // Return total pending dues
    public double getPendingDues(int ownerId) throws Exception {
        double dues = 0.0;
        String sql = "SELECT COALESCE(SUM(hours_used * amount_per_hour - amount_paid),0) AS total_due " +
                     "FROM job j JOIN driver d ON j.driver_id = d.driver_id " +
                     "WHERE d.owner_id = ? AND (hours_used * amount_per_hour - amount_paid) > 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    dues = rs.getDouble("total_due");
                }
            }
        }
        return dues;
    }

    
    
}
