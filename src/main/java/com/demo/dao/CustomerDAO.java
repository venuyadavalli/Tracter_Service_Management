package com.demo.dao;

import java.sql.*;
import com.demo.DBConnection;
import com.demo.mode1.Customer;

public class CustomerDAO {

    public Customer validateCustomer(String name, String mobile) {
        Customer customer = null;
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM customer WHERE name=? AND mobile=? AND active=1";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, mobile);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                customer = new Customer(
                    rs.getInt("customer_id"),
                    rs.getString("name"),
                    rs.getString("mobile"),
                    rs.getInt("driver_id")
                );
            }
        } catch (Exception e) { e.printStackTrace(); }
        return customer;
    }

    public ResultSet getCustomerJobsPaginated(int customerId, int limit, int offset) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT tool_type, hours_used, amount_per_hour, amount_paid, date " +
                     "FROM job WHERE customer_id=? ORDER BY date DESC LIMIT ? OFFSET ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, customerId);
        ps.setInt(2, limit);
        ps.setInt(3, offset);
        return ps.executeQuery();
    }

    public ResultSet getCustomerJobsByDate(int customerId, String date) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT tool_type, hours_used, amount_per_hour, amount_paid, date " +
                     "FROM job WHERE customer_id=? AND date=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, customerId);
        ps.setString(2, date);
        return ps.executeQuery();
    }

    public int countCustomerJobs(int customerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM job WHERE customer_id=?");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        rs.next();
        int count = rs.getInt(1);
        rs.close(); ps.close(); con.close();
        return count;
    }

    public double getCustomerTotalCost(int customerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT SUM(hours_used * amount_per_hour) FROM job WHERE customer_id=?"
        );
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        rs.next();
        double value = rs.getDouble(1);
        rs.close(); ps.close(); con.close();
        return value;
    }

    public double getCustomerTotalPaid(int customerId) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT SUM(amount_paid) FROM job WHERE customer_id=?"
        );
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        rs.next();
        double value = rs.getDouble(1);
        rs.close(); ps.close(); con.close();
        return value;
    }
    
    public ResultSet getCustomerJobs(int customerId, String date) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "SELECT j.date, d.name AS driver_name, o.name AS owner_name, " +
                     "t.tool_name AS tool_type, j.hours_used, j.amount_per_hour " +
                     "FROM job j " +
                     "JOIN driver d ON j.driver_id = d.driver_id " +
                     "JOIN owner o ON d.owner_id = o.owner_id " +
                     "JOIN tools t ON j.tool_id = t.tool_id " +
                     "WHERE j.customer_id=?";
        if (date != null && !date.isEmpty()) {
            sql += " AND j.date=?";
        }
        PreparedStatement ps = con.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ps.setInt(1, customerId);
        if (date != null && !date.isEmpty()) {
            ps.setString(2, date);
        }
        return ps.executeQuery();
    }


}
