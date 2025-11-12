package com.demo.servlet;

import com.demo.SmsUtil;
import com.demo.dao.DriverDAO;
import com.demo.mode1.Customer;
import com.demo.mode1.Driver;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.ResultSet;

@WebServlet("/DriverServlet")
public class DriverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DriverDAO dao = new DriverDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        Driver driver = (Driver) session.getAttribute("driver");

        try {
        	if ("login".equals(action)) {
        	    String tractorNumber = request.getParameter("tractorNumber");
        	    String password = request.getParameter("password");
        	    Driver loggedIn = dao.validateDriver(tractorNumber, password);
        	    if (loggedIn != null) {
        	        session.setAttribute("driver", loggedIn);
        	        // Recommended: always use the section param
        	        response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=dashboard&success=Login+successful");
        	    } else {
        	        response.sendRedirect(request.getContextPath() + "driver/driverLogin.jsp?error=1");
        	    }
        	    return;
        	}
        	else {
                // For all other actions, driver session is needed
                if (driver == null) {
                    response.sendRedirect(request.getContextPath() + "driver/driverLogin.jsp");
                    return;
                }

                int driverId = driver.getDriverId();

                switch (action) {
                    case "addCustomer":
                        String name = request.getParameter("customerName");
                        String mobile = request.getParameter("customerMobile");
                        int custId = dao.addCustomer(driverId, name, mobile);
                        if (custId <= 0) {
                            response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=customers&error=Customer+addition+failed");
                        } else {
                            request.getSession().setAttribute("lastAddedCustomerId", custId);
                            response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=customers&success=Customer+added&customerId=" + custId);
                        }
                        break;

                    case "addJob":
                        try {
                            int customerId = Integer.parseInt(request.getParameter("customerId"));
                            int toolId = Integer.parseInt(request.getParameter("toolId"));
                            int hours = Integer.parseInt(request.getParameter("hours"));
                            String jobDate = request.getParameter("jobDate");
                            double rate = Double.parseDouble(request.getParameter("rate").trim());
                            double total = rate * hours;

                            boolean jobAdded = dao.addJobExistingCustomer(driverId, customerId, toolId, hours, rate, total, jobDate);
                            if (jobAdded) {
                                try {
                                    Customer customer = dao.getCustomerById(customerId);
                                    if (customer != null) {
                                        SmsUtil.sendSms(customer.getMobile(), customer.getName(), jobDate, driver.getName(), hours, rate, total);
                                    }
                                } catch (Exception smsEx) {
                                    smsEx.printStackTrace();
                                }
                            }
                            response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=jobs&success=Job+added+successfully");
                        } catch (Exception e) {
                            e.printStackTrace();
                            response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=jobs&error=Failed+to+add+job");
                        }
                        break;

                    case "updateJob":
                        int jobId = Integer.parseInt(request.getParameter("jobId"));
                        int custIdUpdate = Integer.parseInt(request.getParameter("customerId"));
                        int toolIdUpdate = Integer.parseInt(request.getParameter("toolId"));
                        int hoursUpdate = Integer.parseInt(request.getParameter("hours"));
                        String dateUpdate = request.getParameter("jobDate");
                        dao.updateJob(jobId, custIdUpdate, toolIdUpdate, hoursUpdate, dateUpdate);

                        // Preserve filters if present
                        String searchCustomer = request.getParameter("searchName");
                        String searchDate = request.getParameter("searchDate");
                        String page = request.getParameter("currentPage");

                        StringBuilder redirect = new StringBuilder("driver/driverDashboard.jsp?section=jobs&success=Job+updated");
                        if (searchCustomer != null && !searchCustomer.isEmpty()) redirect.append("&searchCustomer=").append(searchCustomer);
                        if (searchDate != null && !searchDate.isEmpty()) redirect.append("&searchDate=").append(searchDate);
                        if (page != null && !page.isEmpty()) redirect.append("&page=").append(page);
                        response.sendRedirect(redirect.toString());
                        break;

                    case "searchCustomer":
                        String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
                        String date = request.getParameter("date") != null ? request.getParameter("date") : "";
                        var customerData = dao.searchCustomers(driverId, keyword, date);
                        if (customerData.isEmpty()) {
                            request.setAttribute("notFound", "No active customer found for given filters.");
                        } else {
                            request.setAttribute("customerData", customerData);
                        }
                        // Set section as request attribute for forwarded JSP to show correct tab
                        request.setAttribute("section", "searchcustomer");
                        request.getRequestDispatcher("driver/driverDashboard.jsp").forward(request, response);
                        break;


                    // Add other cases for payments, logout, etc. respecting section parameter as above

                    default:
                        response.sendRedirect("driver/driverDashboard.jsp?section=dashboard");
                        break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "driver/driverDashboard.jsp?section=dashboard&error=Unexpected+server+error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}


