<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.CustomerDAO, com.demo.mode1.Customer" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect("customerLogin.jsp");
        return;
    }

    CustomerDAO dao = new CustomerDAO();

    String section = request.getParameter("section");
    if (section == null || section.isEmpty()) section = "dashboard";

    int currentPage = 1, limit = 20;
    if (request.getParameter("page") != null) {
        try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}
    }
    int offset = (currentPage - 1) * limit;

    String filterDate = request.getParameter("filterDate") != null ? request.getParameter("filterDate") : "";
    ResultSet rs;
    int totalJobs;

    if (!filterDate.isEmpty()) {
        rs = dao.getCustomerJobsByDate(customer.getCustomerId(), filterDate);
        totalJobs = 0; // no pagination
    } else {
        totalJobs = dao.countCustomerJobs(customer.getCustomerId());
        rs = dao.getCustomerJobsPaginated(customer.getCustomerId(), limit, offset);
    }

    double totalCost = dao.getCustomerTotalCost(customer.getCustomerId());
    double totalPaid = dao.getCustomerTotalPaid(customer.getCustomerId());
    double totalDue = totalCost - totalPaid;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Customer Dashboard - Farm Fleet Manager</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />

<style>
:root {
    --sidebar: #264d3d;
    --accent: #f4a442;
    --main-bg: #f9f8f5;
    --white: #fff;
    --danger: #e74c3c;
    --success: #34c759;
    --menu-active: #448d76;
    --radius: 22px;
    --card-bg: #fff;
    --shadow: 0 2px 14px rgba(40,50,70,0.07);
}
body, html {
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: var(--main-bg);
    color: #222;
    height: 100%;
}
.layout {
    display: flex;
    min-height: 100vh;
}
.sidebar {
    width: 230px;
    background: var(--sidebar);
    color: white;
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    display: flex;
    flex-direction: column;
    padding-top: 40px;
}
.sidebar .logo {
    font-size: 1.4rem;
    font-weight: bold;
    color: var(--accent);
    text-align: center;
    margin-bottom: 40px;
    letter-spacing: 1.5px;
}
.menu {
    list-style: none;
    padding: 0;
    margin: 0;
    flex-grow: 1;
}
.menu li {
    padding: 14px 28px;
    font-size: 1.1rem;
    user-select: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 12px;
    border-left: 4px solid transparent;
    transition: background 0.3s ease, border-color 0.3s ease;
}
.menu li i {
    font-size: 1.2rem;
    color: var(--accent);
    width: 24px;
    text-align: center;
}
.menu li.active,
.menu li:hover {
    background: var(--menu-active);
    border-left-color: var(--accent);
}
.menu li.active, .menu li:hover { background: var(--menu-active); border-left:4px solid var(--accent);}
.menu li i {font-size:1.16em; color: var(--accent);}
.sidebar .logout-wrap {margin-top:auto; margin-bottom:36px;}
.sidebar .logout-btn {
    color:#fff; background:var(--danger); border-radius:8px; text-align:center;
    text-decoration:none; display:block; font-weight:600;
    padding:11px 0; margin:0 18px; transition:.17s;
    font-size:1.07em; box-shadow:var(--shadow);
    border:none; cursor:pointer;
}
.sidebar .logout-btn:hover { background: #b52b2f; }
@media(max-width:800px){.sidebar{width:62px;min-width:62px;}
.sidebar .logo,.menu li span{display:none;}
.menu li i{margin-left:2px;}
}
.content {
    margin-left: 230px;
    flex-grow: 1;
    padding: 40px 6vw 40px 6vw;
    min-height: 100vh;
    background: var(--card-bg);
    box-sizing: border-box;
}
@media (max-width: 800px) {
    .content {
        margin-left: 60px;
        padding: 20px 3vw 30px 3vw;
    }
}
.hbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    gap: 12px;
}
.hbar h2 {
    font-size: 1.5rem;
    font-weight: 900;
    color: var(--sidebar);
    display: flex;
    align-items: center;
    gap: 10px;
}
.hbar .user {
    padding: 10px 18px;
    background: #d9eed7;
    color: #216b2d;
    border-radius: 18px;
    font-weight: 600;
    font-size: 1rem;
}
.card {
    background: var(--card-bg);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 2em 2.2em 1.5em 2.2em;
    margin-bottom: 2.25em;
    border: 1px solid #e3e9e4;
    display: none;
    position: relative;
}
.card.active {
    display: block;
    animation: fadeIn 0.3s ease forwards;
}
@keyframes fadeIn {
    from {opacity: 0;transform: translateY(20px);}
    to {opacity: 1;transform: translateY(0);}
}
h2 {
    color: var(--sidebar);
    font-size: 1.3rem;
    font-weight: 700;
    margin-bottom: 1.1em;
    display: flex;
    gap: 0.6em;
}
form.form-row {
    display: flex;
    gap: 18px;
    flex-wrap: wrap;
    margin-bottom: 20px;
    max-width: 600px;
}
form .form-group {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 160px;
}
form label {
    margin-bottom: 6px;
    font-weight: 600;
    color: var(--sidebar);
}
form input[type="date"],
form input[type="text"],
form select {
    padding: 12px 14px;
    font-size: 1rem;
    border-radius: 8px;
    border: 1.5px solid #c3dbca;
    background: #f6faf7;
    transition: border-color .25s ease;
}
form input:focus,
form select:focus {
    border-color: var(--accent);
    outline: none;
}
button.btnp {
    background: linear-gradient(90deg, #2d5a2d, #34b96e);
    border: none;
    padding: 12px 28px;
    font-weight: 700;
    font-size: 1.05rem;
    color: white;
    border-radius: 10px;
    box-shadow: var(--shadow);
    cursor: pointer;
    transition: background 0.3s ease;
    align-self: flex-end;
    margin-top: 6px;
}
button.btnp:hover {
    background: #279b2f;
}
.table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 22px;
    box-shadow: 0 2px 15px rgb(0 0 0 / 5%);
    border-radius: 8px;
    overflow: hidden;
}
.table thead tr {
    background: var(--sidebar);
    color: white;
}
.table th, .table td {
    padding: 14px 15px;
    text-align: left;
    border-bottom: 1.5px solid #eee;
    font-size: 1rem;
}
.table tbody tr:hover {
    background: #f0faf0;
}
.alert {
    background: #d4edda;
    border-left: 7px solid var(--success);
    padding: 14px 22px;
    margin-bottom: 18px;
    font-weight: 600;
    font-size: 1.1rem;
    display: flex;
    align-items: center;
    gap: 10px;
    color: #155724;
}
.alert i {
    font-size: 1.3rem;
}
.alert-danger {
    background: #fbd6d6;
    border-left-color: var(--danger);
    color: #721c24;
}

/* Pagination styles */
.pager {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 15px;
    margin-top: 20px;
}
.pager a, .pager button {
    background: var(--accent);
    color: white;
    font-weight: 600;
    border-radius: 6px;
    padding: 9px 18px;
    text-decoration: none;
    cursor: pointer;
    border: none;
    font-size: 1rem;
    transition: background 0.25s ease;
}
.pager a:hover:not(.disabled) {
    background: #d4941d;
}
.pager .disabled, .pager button:disabled {
    background: #ccc;
    cursor: not-allowed;
    color: #666;
}
.pager select {
    padding: 8px 14px;
    font-size: 1rem;
    border-radius: 6px;
    border: 1.5px solid #c3dbca;
    background: #f6faf7;
    outline-offset: 2px;
    min-width: 120px;
}
</style>
</head>
<body>
<div class="layout">
    <nav class="sidebar" aria-label="Sidebar Navigation">
        <div class="logo" aria-label="Brand Logo"><i class="fas fa-user-circle"></i> Customer</div>
        <ul class="menu" role="menu" id="menu">
            <li role="menuitem" tabindex="0" data-section="dashboard" class="<%= section.equals("dashboard") ? "active" : "" %>">
                <i class="fas fa-home"></i> <span>Dashboard</span>
            </li>
            <li role="menuitem" tabindex="0" data-section="jobs" class="<%= section.equals("jobs") ? "active" : "" %>">
                <i class="fas fa-history"></i> <span>Job History</span>
            </li>
            <li role="menuitem" tabindex="0" data-section="pdf" class="<%= section.equals("pdf") ? "active" : "" %>">
                <i class="fas fa-file-pdf"></i> <span>Download PDF</span>
            </li>
        </ul>
        <div class="logout-wrap">
    		  <a href="../index.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
   		 </div>
    </nav>

    <main class="content" tabindex="0" aria-live="polite" aria-atomic="true" id="mainContent">
        <div class="hbar">
            <h2><i class="fas fa-user-circle"></i> Farm Fleet - Customer</h2>
            <div class="user" aria-label="Welcome User"><i class="fas fa-user"></i> Welcome, <%= customer.getName()%> (Mobile: <%= customer.getMobile() %>)</div>
        </div>

        <!-- Dashboard / Summary -->
        <section class="card <%= section.equals("dashboard") ? "active" : "" %>" role="tabpanel" aria-hidden="<%= !section.equals("dashboard") %>">
            <h2><i class="fas fa-home"></i> Dashboard</h2>
            <h3>Your Account Summary</h3>
            <div><strong>Total Cost:</strong> ₹<%= totalCost %></div>
            <div><strong>Total Paid:</strong> ₹<%= totalPaid %></div>
            <div class="<%= totalDue > 0 ? "text-danger" : "text-success" %>"><strong>Total Due:</strong> ₹<%= totalDue %></div>
            <div style="margin-top:1.2em;">
                <button class="btnp" onclick="window.location.href='customerDashboard.jsp?section=jobs'">View Job History</button>
            </div>
        </section>

        <!-- Job History -->
        <section class="card <%= section.equals("jobs") ? "active" : "" %>" role="tabpanel" aria-hidden="<%= !section.equals("jobs") %>">
            <h2><i class="fas fa-history"></i> Job History</h2>
            <form method="get" action="customerDashboard.jsp" class="form-row" style="max-width: 620px; margin-bottom: 1.5em;">
                <input type="hidden" name="section" value="jobs" />
                <div class="form-group">
                    <label for="filterDate">Filter by Date</label>
                    <input type="date" name="filterDate" id="filterDate" value="<%= filterDate %>" />
                </div>
                <div class="form-group" style="min-width: 120px; display:flex; flex-direction: column; justify-content: flex-end;">
                    <button type="submit" class="btnp">Search</button>
                </div>
                
            </form>
            <table class="table" aria-label="Job history table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Tool</th>
                        <th>Hours</th>
                        <th>Rate (₹)</th>
                        <th>Total (₹)</th>
                        <th>Paid (₹)</th>
                        <th>Due (₹)</th>
                    </tr>
                </thead>
                <tbody>
                <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getDate("date") %></td>
                        <td><%= rs.getString("tool_type") %></td>
                        <td><%= rs.getInt("hours_used") %></td>
                        <td>₹<%= rs.getDouble("amount_per_hour") %></td>
                        <td>₹<%= rs.getInt("hours_used") * rs.getDouble("amount_per_hour") %></td>
                        <td>₹<%= rs.getDouble("amount_paid") %></td>
                        <td>₹<%= rs.getInt("hours_used") * rs.getDouble("amount_per_hour") - rs.getDouble("amount_paid") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <% if (filterDate.isEmpty() && totalJobs > limit) {
                int totalPages = (int)Math.ceil((double)totalJobs / limit);
            %>
            <div class="pager" role="navigation" aria-label="Pagination">
                <% if (currentPage > 1) { %>
                    <a href="customerDashboard.jsp?section=jobs&page=<%= currentPage-1 %>" class="btn" aria-label="Previous Page">Prev</a>
                <% } else { %>
                    <button class="btn" disabled aria-label="Previous Page">Prev</button>
                <% } %>
                <form aria-label="Select page number" style="margin: 0;">
                    <select name="page" onchange="this.form.submit()" aria-live="polite" aria-atomic="true">
                        <% for(int i=1; i<=totalPages; i++) { %>
                            <option value="<%= i %>" <%= currentPage == i ? "selected" : "" %>>Page <%= i %></option>
                        <% } %>
                    </select>
                    <input type="hidden" name="section" value="jobs" />
                </form>
                <% if (currentPage < totalPages) { %>
                    <a href="customerDashboard.jsp?section=jobs&page=<%= currentPage+1 %>" class="btn" aria-label="Next Page">Next</a>
                <% } else { %>
                    <button class="btn" disabled aria-label="Next Page">Next</button>
                <% } %>
            </div>
            <% } %>
        </section>
        
        <!-- PDF Download -->
        <section class="card <%= section.equals("pdf") ? "active" : "" %>" role="tabpanel" aria-hidden="<%= !section.equals("pdf") %>">
            <h2><i class="fas fa-file-pdf"></i> Download PDF Report</h2>
            <form action="<%=request.getContextPath()%>/CustomerServlet" method="post" style="max-width:340px;">
                <input type="hidden" name="action" value="exportPDF" />
                <label for="downloadDate">Date (optional)</label>
                <input type="date" name="date" id="downloadDate" value="<%= filterDate %>" />
                <button type="submit" class="btnp btn-danger" style="margin-top: 12px;"><i class="fas fa-file-pdf"></i> Download PDF</button>
            </form>
        </section>
    </main>
</div>

<script>
document.querySelectorAll('.menu li[data-section]').forEach((el) => {
    el.addEventListener('click', () => {
        window.location.href = 'customerDashboard.jsp?section=' + el.getAttribute('data-section');
    });
});
</script>
</body>
</html>
