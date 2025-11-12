package com.demo.servlet;

import com.demo.dao.CustomerDAO;
import com.demo.mode1.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import java.io.IOException;
import java.sql.ResultSet;


@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String action = request.getParameter("action");
        CustomerDAO dao = new CustomerDAO();

        if ("login".equals(action)) {
            String name = request.getParameter("name");
            String mobile = request.getParameter("mobile");
            Customer customer = dao.validateCustomer(name, mobile);

            if (customer != null) {
                request.getSession().setAttribute("customer", customer);
                response.sendRedirect(request.getContextPath() + "customer/customerDashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "customer/customerLogin.jsp?error=1");
            }
        }
        else if ("exportPDF".equals(action)) {
            Customer customer = (Customer) request.getSession().getAttribute("customer");
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "customer/customerLogin.jsp");
                return;
            }

            String date = request.getParameter("date") != null ? request.getParameter("date") : "";

            try {
                CustomerDAO dao2 = new CustomerDAO();
                ResultSet rs = dao2.getCustomerJobs(customer.getCustomerId(), date);

                // Fetch Owner Name (optional)
                String ownerName = "N/A";
                if (rs.isBeforeFirst()) {
                    rs.next();
                    ownerName = rs.getString("owner_name") != null ? rs.getString("owner_name") : "N/A";
                    rs.beforeFirst();
                }

                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=CustomerReport.pdf");

                Document document = new Document();
                PdfWriter.getInstance(document, response.getOutputStream());
                document.open();

                // Header
                Paragraph title = new Paragraph("Customer Job Report");
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);

                document.add(new Paragraph("Customer: " + customer.getName()));
                document.add(new Paragraph("Owner: " + ownerName));
                if (!date.isEmpty()) {
                    document.add(new Paragraph("For Date: " + date));
                }
                document.add(new Paragraph("\n"));

                // 6-column Table: Date, Tool, Driver, Hours, Rate, Total
                PdfPTable table = new PdfPTable(6);
                table.setWidthPercentage(100);
                table.setSpacingBefore(10f);
                table.setSpacingAfter(10f);
                table.setWidths(new float[]{2f, 3f, 3f, 1.5f, 2f, 2f});  // Adjust column widths

                Font headFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                table.addCell(new PdfPCell(new Paragraph("Date", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Tool", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Driver", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Hours", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Rate (₹)", headFont)));
                table.addCell(new PdfPCell(new Paragraph("Total (₹)", headFont)));

                double grandTotal = 0;
                while (rs.next()) {
                    int hours = rs.getInt("hours_used");
                    double rate = rs.getDouble("amount_per_hour");
                    double total = hours * rate;
                    grandTotal += total;

                    table.addCell(rs.getDate("date").toString());
                    table.addCell(rs.getString("tool_type"));   // Now including Tool name
                    table.addCell(rs.getString("driver_name"));
                    table.addCell(String.valueOf(hours));
                    table.addCell("₹" + rate);
                    table.addCell("₹" + total);
                }

                document.add(table);
                document.add(new Paragraph("\nGrand Total: ₹" + grandTotal));

                document.close();
                response.getOutputStream().flush();
                response.getOutputStream().close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }



    }
}
