package com.demo.servlet;

import com.demo.SmsUtil;
import com.demo.dao.OwnerDAO;
import com.demo.mode1.Owner;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.ResultSet;

@WebServlet("/OwnerServlet")
public class OwnerServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String action = request.getParameter("action");
        OwnerDAO dao = new OwnerDAO();

        // For all actions except login/register/forgot, require a session owner
        Owner ownerSession = null;
        if (!"login".equals(action) && !"register".equals(action) && !"forgotPassword".equals(action)) {
            ownerSession = (Owner) request.getSession().getAttribute("owner");
            if (ownerSession == null) {
                response.sendRedirect("owner/ownerLogin.jsp");
                return;
            }
        }

        // Register
        if ("register".equals(action)) {
            String name = request.getParameter("name").trim();
            String mobile = request.getParameter("mobile").trim();
            String vehicleNo = request.getParameter("vehicleNo").trim().toUpperCase();
            String password = request.getParameter("password").trim();

            // Validate vehicle number (new owners only)
            if (!vehicleNo.matches("^[A-Z]{2}\\d{2}[A-Z]{1,3}\\d{1,4}$")) {
                response.sendRedirect("owner/ownerRegister.jsp?invalidVehicle=1");
                return;
            }

            dao.registerOwner(name, mobile, vehicleNo, password);
            response.sendRedirect("owner/ownerLogin.jsp");
            return;
        }

        // Login
        if ("login".equals(action)) {
            String mobile = request.getParameter("mobile").trim();
            String vehicleNo = request.getParameter("vehicleNo").trim().toUpperCase();
            String password = request.getParameter("password").trim();

            Owner owner = dao.validateOwner(mobile, vehicleNo, password);
            if (owner != null) {
                request.getSession().setAttribute("owner", owner);
                response.sendRedirect("owner/ownerDashboard.jsp");
            } else {
                response.sendRedirect("owner/ownerLogin.jsp?error=1");
            }
            return;
        }

        // Forgot Password
        if ("forgotPassword".equals(action)) {
            String mobile = request.getParameter("mobile").trim();
            String vehicleNo = request.getParameter("vehicleNo").trim().toUpperCase();
            String password = dao.getPasswordByMobileAndVehicle(mobile, vehicleNo);

            if (password != null) {
                SmsUtil.sendPasswordSms(mobile, password);
                response.sendRedirect("owner/ownerLogin.jsp?resetSent=1");
            } else {
                response.sendRedirect("owner/ownerLogin.jsp?error=1");
            }
            return;
        }

        // Owner ID for authenticated actions
        int ownerId = ownerSession.getOwnerId();

        try {
            if ("addDriver".equals(action)) {
                String name = request.getParameter("driverName");
                String tractor = request.getParameter("tractorNumber");
                String driverPassword = request.getParameter("driverPassword");
                dao.addDriver(ownerId, name, tractor, driverPassword);
                response.sendRedirect("owner/ownerDashboard.jsp?section=drivers&success=Driver+added+successfully");
                return;
            }

            if ("deleteDriver".equals(action)) {
                int driverId = Integer.parseInt(request.getParameter("driverId"));
                dao.deleteDriver(driverId, ownerId);
                response.sendRedirect("owner/ownerDashboard.jsp?section=drivers&success=Driver+deleted+successfully");
                return;
            }
            
            if ("updateDriver".equals(action)) {
                int driverId = Integer.parseInt(request.getParameter("driverId"));
                String name = request.getParameter("driverName");
                String tractorNumber = request.getParameter("tractorNumber");
                String driverPassword = request.getParameter("driverPassword");
                
                if (tractorNumber == null || tractorNumber.trim().isEmpty()) {
                    tractorNumber = dao.getTractorNumberByDriverId(driverId, ownerId);
                }
                
                dao.updateDriver(driverId, ownerId, name, tractorNumber, driverPassword);
                response.sendRedirect("owner/ownerDashboard.jsp?section=drivers&success=Driver+updated+successfully");
                return;
            }

            if ("markPaid".equals(action)) {
                int jobId = Integer.parseInt(request.getParameter("jobId"));
                double paidAmount = Double.parseDouble(request.getParameter("paidAmount"));
                dao.updatePayment(jobId, paidAmount);
                response.sendRedirect("owner/ownerDashboard.jsp?section=customer&success=Payment+updated");
                return;
            }

            if ("generateReport".equals(action)) {
                int month = Integer.parseInt(request.getParameter("month"));
                int year = Integer.parseInt(request.getParameter("year"));
                ResultSet rs = dao.getMonthlyReport(ownerId, month, year);
                if (rs.next()) {
                    request.setAttribute("revenue", rs.getDouble("total_revenue"));
                    request.setAttribute("unpaid", rs.getDouble("unpaid_dues"));
                    request.setAttribute("jobs", rs.getInt("total_jobs"));
                }
                request.setAttribute("month", month);
                request.setAttribute("year", year);
                request.getRequestDispatcher("owner/ownerDashboard.jsp?section=report").forward(request, response);
                return;
            }

            if ("addTool".equals(action)) {
                String toolName = request.getParameter("toolName");
                double rate = Double.parseDouble(request.getParameter("rate"));
                dao.addTool(ownerId, toolName, rate);
                response.sendRedirect("owner/ownerDashboard.jsp?section=tools&success=Tool+added+successfully");
                return;
            }

            if ("updateTool".equals(action)) {
                int toolId = Integer.parseInt(request.getParameter("toolId"));
                String name = request.getParameter("toolName");
                double rate = Double.parseDouble(request.getParameter("rate"));
                dao.updateTool(toolId, ownerId, name, rate);
                response.sendRedirect("owner/ownerDashboard.jsp?section=tools&success=Tool+updated+successfully");
                return;
            }

            if ("deleteTool".equals(action)) {
                int toolId = Integer.parseInt(request.getParameter("toolId"));
                dao.deleteTool(toolId, ownerId);
                response.sendRedirect("owner/ownerDashboard.jsp?section=tools&success=Tool+deleted+successfully");
                return;
            }

            if ("updatePayment".equals(action)) {
                int customerId = Integer.parseInt(request.getParameter("customerId"));
                double paidAmount = Double.parseDouble(request.getParameter("paidAmount"));
                dao.updateCustomerPayment(customerId, paidAmount);
                response.sendRedirect("owner/ownerDashboard.jsp?section=customer&success=Payment+updated+successfully");
                return;
            }

            if ("deleteCustomer".equals(action)) {
                int customerId = Integer.parseInt(request.getParameter("customerId"));
                dao.deleteCustomer(customerId);
                response.sendRedirect("owner/ownerDashboard.jsp?section=customer&success=Customer+deleted+successfully");
                return;
            }

            if ("searchCustomer".equals(action)) {
                String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
                String date = request.getParameter("date") != null ? request.getParameter("date") : "";
                List<Map<String, Object>> customerData = dao.searchCustomerJobs(ownerId, keyword, date);
                if (customerData.isEmpty()) {
                    request.setAttribute("notFound", "No active customer found for given filters.");
                } else {
                    request.setAttribute("customerData", customerData);
                }
                request.getRequestDispatcher("owner/ownerDashboard.jsp?section=customer&success=Search+completed").forward(request, response);
                return;
            }

            if ("exportPDF".equals(action)) {
                int month = Integer.parseInt(request.getParameter("month"));
                int year = Integer.parseInt(request.getParameter("year"));
                ResultSet rs = dao.getMonthlyReport(ownerId, month, year);
                ResultSet details = dao.getMonthlyJobDetails(ownerId, month, year);

                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=MonthlyReport.pdf");

                Document document = new Document();
                PdfWriter.getInstance(document, response.getOutputStream());
                document.open();

                Paragraph title = new Paragraph("Monthly Report");
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);

                Paragraph sub = new Paragraph("Month: " + month + "/" + year + "\n\n");
                sub.setAlignment(Element.ALIGN_CENTER);
                document.add(sub);

                if (rs.next()) {
                    document.add(new Paragraph("Total Revenue: ₹" + rs.getDouble("total_revenue")));
                    document.add(new Paragraph("Unpaid Dues: ₹" + rs.getDouble("unpaid_dues")));
                    document.add(new Paragraph("Total Jobs: " + rs.getInt("total_jobs")));
                    document.add(new Paragraph("\n"));
                }

                PdfPTable table = new PdfPTable(6);
                table.setWidthPercentage(100);
                Font headFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                table.addCell(new PdfPCell(new Paragraph("Date", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Customer", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Driver", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Tool", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Hours", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Rate (₹)", headFont)));

                while (details.next()) {
                    table.addCell(details.getDate("date").toString());
                    table.addCell(details.getString("customer"));
                    table.addCell(details.getString("driver"));
                    table.addCell(details.getString("tool_type"));
                    table.addCell(String.valueOf(details.getInt("hours_used")));
                    table.addCell("₹" + details.getDouble("amount_per_hour"));
                }
                document.add(table);
                document.close();
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "owner/ownerDashboard.jsp?section=" + getSectionForAction(action) + "&error=An+error+occurred");
        }
    }

    // Helper method for error redirection
    private String getSectionForAction(String action) {
        switch (action) {
            case "addDriver":
            case "updateDriver":
            case "deleteDriver": return "drivers";
            case "addTool":
            case "updateTool":
            case "deleteTool": return "tools";
            case "updatePayment":
            case "deleteCustomer":
            case "searchCustomer":
            case "markPaid": return "customer";
            case "generateReport":
            case "exportPDF": return "report";
            default: return "dashboard";
        }
    
    }
}
