<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.demo.dao.OwnerDAO, com.demo.mode1.Owner" %>
<%@ page import="java.util.*" %>
<%
    Owner owner = (Owner) session.getAttribute("owner");
    if (owner == null) { response.sendRedirect("ownerLogin.jsp"); return; }
    OwnerDAO dao = new OwnerDAO();
    String section = request.getParameter("section");
    if (section == null) section = "dashboard";
    String message = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Farm Fleet Manager - Dashboard</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
    --sidebar: #264d3d;
    --accent: #f4a442;
    --main-bg: #f9f8f5;
    --white: #fff;
    --success: #34c759;
    --danger: #e74c3c;
    --menu-active: #448d76;
    --text: #222;
    --radius: 25px;
    --card: #fff;
    --shadow: 0 2px 14px rgba(40,50,70,0.07);
}
body {
    margin:0;
    padding:0;
    background: var(--main-bg);
    font-family: 'Segoe UI', Arial, sans-serif;
}
.layout {
    display: flex;
    min-height: 100vh;
}
.sidebar {
    background: var(--sidebar);
    color: #fff;
    width: 250px;
    min-width: 180px;
    padding-top: 36px;
    display:flex;
    flex-direction:column;
}
.sidebar .logo {
    font-weight: bold;
    font-size: 1.7rem;
    color: var(--accent);
    text-align: center;
    margin-bottom: 2rem;
    letter-spacing: 1.5px;
}
.menu {
    list-style:none;
    padding:0; margin:0;
}
.menu li {
    padding: 15px 30px;
    cursor: pointer;
    display: flex;
    align-items: center;
    font-size: 1.08rem;
    border-left: 4px solid transparent;
    transition: 0.15s;
}
.menu li i { margin-right: 15px; font-size:1.2em; }
.menu li.active, .menu li:hover {
    background: var(--menu-active);
    border-left: 4px solid var(--accent);
}
.menu li:last-child{ margin-top:auto; }

@media (max-width: 800px) {
    .sidebar {width:68px; min-width:68px; padding:0;}
    .sidebar .logo {font-size:1.1rem; padding:8px 0;}
    .menu li span {display:none;}
    .menu li i {margin:0;}
}
.content {
    flex:1;
    padding:40px 5vw;
    background: var(--main-bg);
    min-height: 100vh;
}
@media(max-width:600px){.content{padding:25px 1vw;} .sidebar{font-size:0.86em;}}
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

.hbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 25px;
    gap: 12px;
}
.hbar h2 {
    font-size:1.6rem;
    font-weight:700;
    letter-spacing:.5px;
    display: flex; align-items: center;
    gap: 12px;
    color:var(--sidebar);
}
.user {
    color: #33794b;
    background:#dcf8ff;
    border-radius:var(--radius);
    font-weight: 500;
    padding:9px 18px;
}
.logout-btn {
    background:var(--danger);
    color:#fff;
    border:none;
    font-size:1em;
    padding:8px 15px;
    border-radius:8px;
    margin-left:18px;
    cursor:pointer;
    transition:.15s;
}
.logout-btn:hover {background:#c0392b;}
.card {
    background: var(--card);
    border-radius: var(--radius);
    padding: 2.2rem 2.1rem;
    margin: 0 0 37px 0;
    box-shadow: var(--shadow);
    border: 1px solid #f0eee6;
    display:none;
    position:relative;
}
.card.active { display:block; animation:fadein .3s;}
@keyframes fadein {from{opacity:0; transform: translateY(30px);} to{opacity:1;transform: none;}}

.form-row { display:flex; gap:23px; flex-wrap:wrap;}
.form-group { flex:1; min-width:200px;}
.form-label {font-weight:600; color:var(--sidebar);}
input:not([type=submit]),select,textarea {
    padding: 10px;
    border:1.7px solid #daeada;
    border-radius:9px;
    font-size:1.06em;
    width:100%;
    margin-bottom:14px;
}
input[readonly]{background:#f7f7f7;}
.btnp {
    padding: 10px 23px;
    border: none;
    background: linear-gradient(90deg, #2d5a2d, #34b96e 93%);
    color: #fff; border-radius:7px;
    font-weight:600;
    font-size:1em;
    transition:.14s;
    box-shadow: var(--shadow);
    cursor:pointer;
}
.btnp:hover { background:#3ca06e;}
.btn-danger {background:var(--danger);}
.btn-danger:hover {background:#b52b2f;}
.btn-success {background:var(--success);}
.btn-success:hover {background:#229b45;}
.btn-sm { padding:7px 14px; font-size:.93em;}
.table {
    width:100%; border-collapse:collapse; margin-top:20px;
}
th, td {
    padding:12px 9px;
    border-bottom:1.7px solid #eee;
    text-align:left;
    font-size:1em;
}
th { background: #edf5eb; color:#246548; font-weight: 700;}
tr:hover {background: #faf8f2;}
.action-group {display:flex;gap:7px;}
.currency { color: #229b45; font-weight:600;}
.alert {
    border-radius: 7px;
    padding: 1em 1.6em;
    margin-bottom: 1.3em;
    font-size:1.08em;
    background:#ebfff2; color:#0b4e17;
    border-left:7px solid var(--success);
    display: flex; align-items: center; gap:10px;
}
.overview {
    display: flex;
    gap: 40px;
    margin-bottom: 40px;
    flex-wrap:wrap;
}
.overview-box {
    flex:1;
    background: #fff;
    box-shadow: 0 4px 24px rgba(36,77,61,0.05);
    border-radius: 24px;
    padding: 32px 28px 28px 28px;
    min-width:225px;
    display:flex;
    flex-direction:column;
    align-items:flex-start;
}
.overview-box .icon {
    font-size: 2.5rem;
    margin-bottom: 8px;
}
.overview-box.green   .icon { color: #34c759;}
.overview-box.yellow  .icon { color: #e3b200;}
.overview-box.blue    .icon { color: #3887ff;}
.overview-box.red     .icon { color: #e74c3c;}
.overview-box .label {
    text-transform: uppercase;
    color: #888a9a;
    font-size: 1.02rem;
    margin-bottom: 15px;
    font-weight:600;
    letter-spacing: 0.8px;
}
.overview-box .value {
    font-size: 2rem;
    font-weight:800;
    color: #263d2b;
}
.overview-box .small {
    font-size: 1.05rem;
    color: #b8b8bd;
    margin-left: 10px;
    font-weight:400;
}
@media (max-width:1020px){.overview{flex-wrap:wrap;gap:18px;}.overview-box{min-width:180px;}}
@media (max-width:600px){
    .overview{flex-direction:column;gap:18px;}
    .overview-box{width:100%;min-width:0;}
}

.alert-danger {background: #fff3f1; color:var(--danger); border-color:var(--danger);}
</style>
</head>
<body>
<div class="layout">
    <nav class="sidebar">
        <div class="logo"><i class="fas fa-tractor"></i></div>
        <ul class="menu" id="side-menu">
            <li data-section="dashboard" class="<%=section.equals("dashboard")?"active":""%>"><i class="fas fa-home"></i><span>Dashboard</span></li>
            <li data-section="drivers" class="<%=section.startsWith("driver")?"active":""%>"><i class="fas fa-users"></i><span>Drivers</span></li>
            <li data-section="tools" class="<%=section.startsWith("tool")?"active":""%>"><i class="fas fa-tools"></i><span>Tools</span></li>
            <li data-section="customer" class="<%=section.startsWith("customer")?"active":""%>"><i class="fas fa-user-friends"></i><span>Customer</span></li>
            <li data-section="report" class="<%=section.startsWith("report")?"active":""%>"><i class="fas fa-file-alt"></i><span>Reports</span></li>
       
        </ul>
              <div class="logout-wrap">
 			   <a href="/TractorServiceTracker/index.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
			</div>

    </nav>
    <div class="content" id="mainContent">

        <div class="hbar">
            <h2><i class="fas fa-tractor" style="color:var(--accent);"></i> Farm Fleet Manager</h2>
            <div class="user"><i class="fas fa-user"></i> Welcome, <%= owner.getName() %>!</div>
        </div>

        <%-- User Alerts --%>
        <% if (message!=null) { %><div class="alert"><i class="fas fa-check-circle"></i> <%=message%></div><% } %>
        <% if (error!=null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%=error%></div><% } %>

        <!-- Dashboard -->
        <div class="card <%=section.equals("dashboard")?"active":""%>" id="dashboard">
            <h2><i class="fas fa-home" style="color:var(--accent);"></i> Dashboard</h2>
            <!-- Overview -->
<section class="overview">
    <div class="overview-box green">
        <div class="icon"><i class="fas fa-users"></i></div>
        <div class="label">Active Drivers</div>
        <div class="value">
            <%-- Dynamically fetch driver's count --%>
            <%= dao.getActiveDriversCount(owner.getOwnerId()) %>
            <span class="small">+X from last month</span>
        </div>
    </div>
    <div class="overview-box yellow">
        <div class="icon"><i class="fas fa-tools"></i></div>
        <div class="label">Equipment Tools</div>
        <div class="value">
            <%= dao.getToolsCount(owner.getOwnerId()) %>
            <span class="small">Ready for rental</span>
        </div>
    </div>
    <div class="overview-box blue">
        <div class="icon"><i class="fas fa-rupee-sign"></i></div>
        <div class="label">Monthly Revenue</div>
        <div class="value">
            ₹<%= dao.getMonthlyRevenue(owner.getOwnerId()) %>
            <span class="small">+12% from last month</span>
        </div>
    </div>
    <div class="overview-box red">
        <div class="icon"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="label">Pending Dues</div>
        <div class="value">
            ₹<%= dao.getPendingDues(owner.getOwnerId()) %>
            <span class="small">Requires attention</span>
        </div>
    </div>
</section>

        </div>

        <!-- Drivers Menu -->
        <div class="card <%=section.equals("drivers")?"active":""%>" id="drivers">
            <h2><i class="fas fa-users"></i> Drivers</h2>
            <div class="form-row">
                <form action="../OwnerServlet" method="post" style="max-width:400px;flex:1;">
                    <input type="hidden" name="action" value="addDriver">
                    <div class="form-label">Driver Name</div>
                    <input type="text" name="driverName" required>
                    <div class="form-label">Tractor Number</div>
                    <input type="text" name="tractorNumber" required>
                    <div class="form-label">Password</div>
                    <input type="password" name="driverPassword" required>
                    <button type="submit" class="btnp"><i class="fas fa-plus"></i> Add Driver</button>
                </form>
            </div>
            <div style="margin-top:30px;">
            <table class="table">
                <thead>
                    <tr><th>Name</th><th>Tractor</th><th>Date</th><th>Password</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <%
                    try (ResultSet rs = dao.getDrivers(owner.getOwnerId())) {
                        while (rs.next()) {
                %>
                <tr>
                    <form action="../OwnerServlet" method="post" style="display:flex;gap:8px;align-items:center;">
                        <td>
                            <input type="text" name="driverName" value="<%= rs.getString("name") %>" style="width:100px;" required>
                        </td>
                        <td>
                            <input type="text" name="tractorNumber" value="<%= rs.getString("tractor_number") %>" readonly style="width:100px;">
                        </td>
                        <td><%= rs.getDate("created_at") %></td>
                        <td>
                            <input type="text" name="driverPassword" value="<%= rs.getString("password") %>" style="width:100px;" required>
                        </td>
                        <td class="action-group">
                            <input type="hidden" name="action" value="updateDriver">
                            <input type="hidden" name="driverId" value="<%= rs.getInt("driver_id") %>">
                            <button type="submit" class="btnp btn-success btn-sm" title="Update"><i class="fas fa-save"></i></button>
                    </form>
                    <form action="../OwnerServlet" method="post" onsubmit="return confirm('Delete this driver?');" style="display:inline;">
                        <input type="hidden" name="action" value="deleteDriver">
                        <input type="hidden" name="driverId" value="<%= rs.getInt("driver_id") %>">
                        <button type="submit" class="btnp btn-danger btn-sm" title="Delete"><i class="fas fa-trash"></i></button>
                    </form>
                        </td>
                </tr>
                <%  }
                    } catch (Exception e) { out.println("<tr><td colspan='5'>Error loading drivers.</td></tr>"); }
                %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- Tools -->
        <div class="card <%=section.equals("tools")?"active":""%>" id="tools">
            <h2><i class="fas fa-tools"></i> Tools</h2>
            <form action="../OwnerServlet" method="post" style="max-width:350px;margin-bottom:25px;">
                <input type="hidden" name="action" value="addTool">
                <div class="form-label">Tool Type</div>
                <select name="toolName" required>
                    <option value="">Select Tool Type</option>
                    <option>Plough</option><option>Harrow</option><option>Seeder/Planter</option>
                    <option>Cultivator</option><option>Rotavator</option><option>Sprayer</option>
                    <option>Trailer</option><option>Baler</option><option>Reaper</option>
                    <option>Threshing Machine</option><option>Water Tanker</option>
                    <option>Loader/Backhoe</option><option>Subsoiler</option>
                    <option>Pesticide Duster</option><option>Leveler</option>
                </select>
                <div class="form-label">Rate (₹/hr)</div>
                <input type="number" name="rate" step="0.01" required>
                <button type="submit" class="btnp"><i class="fas fa-plus"></i> Add Tool</button>
            </form>
            <table class="table">
                <thead><tr><th>Tool Name</th><th>Rate (₹)</th><th>Actions</th></tr></thead>
                <tbody>
                <%
                    try (ResultSet rs = dao.getTools(owner.getOwnerId())) {
                        while (rs.next()) {
                %>
                <tr>
                    <form action="../OwnerServlet" method="post" style="display:flex;gap:10px;align-items:center;">
                        <td><input type="text" name="toolName" value="<%= rs.getString("tool_name") %>" readonly style="width:100px;"></td>
                        <td><input type="number" name="rate" value="<%= rs.getDouble("rate_per_hour") %>" step="0.1" style="width:90px;" required></td>
                        <td class="action-group">
                            <input type="hidden" name="action" value="updateTool">
                            <input type="hidden" name="toolId" value="<%= rs.getInt("tool_id") %>">
                            <button type="submit" class="btnp btn-success btn-sm" title="Update"><i class="fas fa-save"></i></button>
                    </form>
                    <form action="../OwnerServlet" method="post" onsubmit="return confirm('Delete this tool?');" style="display:inline;">
                        <input type="hidden" name="action" value="deleteTool">
                        <input type="hidden" name="toolId" value="<%= rs.getInt("tool_id") %>">
                        <button type="submit" class="btnp btn-danger btn-sm" title="Delete"><i class="fas fa-trash"></i></button>
                    </form>
                        </td>
                </tr>
                <%  }
                    } catch(Exception e){out.println("<tr><td colspan=3>Can't load tools.</td></tr>");}
                %>
                </tbody>
            </table>
        </div>

        <!-- Customers -->
        <div class="card <%=section.equals("customer")?"active":""%>" id="customer">
            <h2><i class="fas fa-user-friends"></i> Customers & Dues</h2>
            <form action="<%=request.getContextPath()%>/OwnerServlet" method="post" style="max-width:340px;margin-bottom:1em;">
                <input type="hidden" name="action" value="searchCustomer">
                <div class="form-label">By Name/Phone</div>
                <input type="text" name="keyword" placeholder="Type name or mobile">
                <div class="form-label">Job Date</div>
                <input type="date" name="date">
                <button type="submit" class="btnp" style="margin-top:6px;">
                    <i class="fas fa-search"></i> Search
                </button>
            </form>
            <% List<Map<String, Object>> searchData = (List<Map<String, Object>>) request.getAttribute("customerData");
               if (searchData != null && !searchData.isEmpty()) { %>
               <div style="overflow-x:auto;">
               <table class="table">
                 <thead>
                    <tr><th>Date</th><th>Customer</th><th>Driver</th><th>Tool</th><th>Hours</th><th>Rate</th><th>Total</th></tr>
                 </thead>
                 <tbody>
                <%
                double totalCost=0,totalPaid=0,totalDue=0;
                for (Map<String, Object> row: searchData) {
                    double rowTotal=(double)row.get("total");
                    double rowPaid=(double)row.get("amount_paid");
                    double rowDue=(double)row.get("due");
                    totalCost+=rowTotal; totalPaid+=rowPaid; totalDue+=rowDue;
                %>
                    <tr>
                        <td><%=row.get("date")%></td><td><%=row.get("customer")%></td>
                        <td><%=row.get("driver")%></td><td><%=row.get("tool_type")%></td>
                        <td><%=row.get("hours_used")%></td>
                        <td>₹<%=row.get("amount_per_hour")%></td>
                        <td>₹<%=rowTotal%></td>
                    </tr>
                <%}%>
                 </tbody>
               </table>
               </div>
               <div style="margin:1em 0;">
                 <b>Total Cost:</b> ₹<%=totalCost%> | <b>Total Paid:</b> ₹<%=totalPaid%> | <b>Due:</b> ₹<%=totalDue%>
               </div>
               <% if(totalDue>0){ %>
                 <form action="<%=request.getContextPath()%>/OwnerServlet" method="post" style="margin-bottom:15px;">
                    <input type="hidden" name="action" value="updatePayment">
                    <input type="hidden" name="customerId" value="<%=searchData.get(0).get("customer_id")%>">
                    <input type="number" name="paidAmount" min="1" max="<%=totalDue%>" placeholder="₹ Amount" required style="width:170px;">
                    <button class="btnp btn-success btn-sm">Pay Due</button>
                 </form>
               <% } else { %>
                  <div class="alert alert-success"><i class="fas fa-check"></i> No dues.</div>
               <% }
               } else if (request.getAttribute("notFound")!=null) { %>
                <div class="alert alert-danger"><%=request.getAttribute("notFound")%></div>
               <% } %>
            <div style="margin-top:30px;">
            <h3 style="margin-top:0;font-size:1.2em;">Customer Dues Summary</h3>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>Customer</th><th>Total</th><th>Paid</th><th>Due</th><th>Action</th></tr>
                </thead>
                <tbody>
                <%
                try (ResultSet rs = dao.getCustomerDueSummary(owner.getOwnerId())) {
                    while (rs.next()) {
                        double due = rs.getDouble("total_due");
                %>
                    <tr>
                      <td><%=rs.getString("customer")%></td>
                      <td>₹<%=rs.getDouble("total_cost")%></td>
                      <td>₹<%=rs.getDouble("total_paid")%></td>
                      <td>₹<%=due%></td>
                      <td>
                        <%if(due>0){%>
                          <form action="../OwnerServlet" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="updatePayment">
                            <input type="hidden" name="customerId" value="<%=rs.getInt("customer_id")%>">
                            <input type="number" name="paidAmount" max="<%=due%>" min="1" placeholder="₹ Amount" required style="width:90px;">
                            <input type="submit" value="Pay" class="btnp btn-success btn-sm">
                          </form>
                        <%}else{%>
                          <form action="../OwnerServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete this customer?');">
                            <input type="hidden" name="action" value="deleteCustomer">
                            <input type="hidden" name="customerId" value="<%=rs.getInt("customer_id")%>">
                            <button class="btnp btn-danger btn-sm"><i class="fas fa-user-times"></i></button>
                          </form>
                        <%}%>
                      </td>
                    </tr>
                <% }
                }catch(Exception e){}
                %>
                </tbody>
            </table>
            </div>
            </div>
        </div>

        <!-- Reports -->
        <div class="card <%=section.equals("report")?"active":""%>" id="report">
            <h2><i class="fas fa-file-alt"></i> Monthly Reports</h2>
            <form action="<%=request.getContextPath()%>/OwnerServlet" method="post">
                <input type="hidden" name="action" value="generateReport">
                <label>Select Month</label>
                <select name="month" required>
                    <option value="">Month</option>
                    <% for(int m=1;m<=12;m++){ %>
                        <option value="<%=m%>"><%=java.time.Month.of(m).name()%></option>
                    <% } %>
                </select>
                <label>Select Year</label>
                <select name="year" required>
                    <option value="">Year</option>
                    <option value="2025">2025</option>
                    <option value="2024">2024</option>
                </select>
                <br>
                <button type="submit" class="btnp" style="margin-top:7px;"><i class="fas fa-chart-bar"></i> Generate</button>
            </form>
            <% if (request.getAttribute("revenue")!=null) { %>
            <table class="table" style="margin-top:25px;">
                <tr><td><b>Total Revenue</b></td><td>₹<%=request.getAttribute("revenue")%></td></tr>
                <tr><td><b>Unpaid Dues</b></td><td>₹<%=request.getAttribute("unpaid")%></td></tr>
                <tr><td><b>Total Jobs</b></td><td><%=request.getAttribute("jobs")%></td></tr>
            </table>
            <form action="<%=request.getContextPath()%>/OwnerServlet" method="post" style="margin-top:14px;">
                <input type="hidden" name="action" value="exportPDF">
                <input type="hidden" name="month" value="<%=request.getAttribute("month")%>">
                <input type="hidden" name="year" value="<%=request.getAttribute("year")%>">
                <button type="submit" class="btnp btn-danger"><i class="fas fa-file-pdf"></i> Download PDF</button>
            </form>
            <%}%>
        </div>
    </div>
</div>

<script>
// Sidebar navigation SPA behavior
document.querySelectorAll('.menu li[data-section]').forEach(function(li) {
    li.addEventListener('click', function() {
        var section = this.getAttribute('data-section');
        // Hide all cards
        document.querySelectorAll('.card').forEach(function(c){c.classList.remove('active')});
        document.getElementById(section).classList.add('active');
        // Menu highlight
        document.querySelectorAll('.menu li').forEach(function(e){e.classList.remove('active')});
        this.classList.add('active');
        // Change url param (no reload)
        if(history.pushState) history.pushState({}, '', '?section='+section);
    });
});
</script>
</body>
</html>
