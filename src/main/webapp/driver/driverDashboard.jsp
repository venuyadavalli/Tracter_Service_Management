<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.demo.dao.DriverDAO, com.demo.mode1.Driver" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Retrieve driver from session (login validation)
    Driver driver = (Driver) session.getAttribute("driver");
    if (driver == null) {
        response.sendRedirect("driverLogin.jsp");
        return;
    }

    // Initialize DAO
    DriverDAO dao = new DriverDAO();

    // Determine active section for tabs
    String section = request.getParameter("section");
    if (section == null || section.isEmpty()) {
        section = "dashboard";
    }

    // Pagination setup
    int currentPage = 1, limit = 20;
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (Exception ignored) { }
    }
    int offset = (currentPage - 1) * limit;

    // Search filters
    String searchCustomer = request.getParameter("searchCustomer") != null ? request.getParameter("searchCustomer").trim() : "";
    String searchDate = request.getParameter("searchDate") != null ? request.getParameter("searchDate").trim() : "";
    boolean isSearchMode = (!searchCustomer.isEmpty() || !searchDate.isEmpty());

    // Feedback messages
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    // Overview data (using newly implemented DAO methods)
    int activeCustomersCount = 0;
    int getToogetAvailableToolsCountlsCount = 0;
    double getTotalEarnings = 0.0;
    double getPendingDues = 0.0;

    try {
    	activeCustomersCount = dao.getActiveCustomersCount(driver.getDriverId());
    	getToogetAvailableToolsCountlsCount = dao.getToogetAvailableToolsCountlsCount(driver.getOwnerId());
        getTotalEarnings = dao.getTotalEarningsThisMonth(driver.getDriverId());
        getPendingDues = dao.getPendingDues(driver.getDriverId());
    } catch (Exception e) {
        e.printStackTrace();
    }
%>



<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Farm Fleet Manager - Driver Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
:root {
    --sidebar: #264d3d;
    --accent: #f4a442;
    --main-bg: #f9f8f5;
    --menu-active: #448d76;
    --danger: #e74c3c;
    --success: #34c759;
    --radius: 22px;
    --shadow: 0 2px 14px rgba(40,50,70,0.08);
}
body { margin:0; padding:0; background: var(--main-bg); font-family:'Segoe UI',Arial,sans-serif;}
.layout { display: flex; min-height: 100vh; }
.sidebar {
    background: var(--sidebar); color: #fff; width:230px;
    display:flex; flex-direction:column; position:fixed; height:100vh; left:0; top:0;
    z-index:999; justify-content:flex-start;
}
.sidebar .logo {
    font-size: 1.3rem; font-weight:bold; color: var(--accent); text-align:center;
    margin:38px 0 32px 0;
}
.menu { list-style:none; padding:0; margin:0; flex-grow:1;}
.menu li {
    padding: 14px 28px; cursor:pointer; border-left:4px solid transparent;
    display:flex; align-items:center; gap:11px; transition:0.15s;
    font-size:1.1rem; user-select:none;
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
.content { flex:1; margin-left:230px; padding:38px 7vw 60px 7vw; background:var(--main-bg); }
@media(max-width:800px){.content{margin-left:62px; padding:18px 3vw;}
.menu li span{display:none;} }
.hbar {
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom: 30px; gap:13px;
}
.hbar h2 { font-size: 1.39em; color:var(--sidebar); font-weight:700; display:flex; align-items:center; gap:13px;}
.user { color:#33794b;background:#dcf8ff;border-radius:var(--radius);font-weight:500; padding:8px 18px;}
.alert {
    background: #d4edda; color: #155724; border-left:6px solid var(--success);
    padding: .9em 1.4em; border-radius:8px; font-weight:600; font-size:1.02em; margin-bottom:16px;
    display:flex; align-items:center; gap:.6em;
}
.alert-danger{background:#f8d7da;color:#721c24;border-left-color:var(--danger);}
.card { background: #fff; border-radius:var(--radius); box-shadow:var(--shadow);
    padding:2em 2em 1.4em 2em; margin-bottom:2.2em; border:1px solid #ecf0ef;
    display:none; position:relative;}
.card.active {display:block; animation:fadein .35s;}
@keyframes fadein {from{opacity:0;transform:translateY(18px);}to{opacity:1;}}
h2 {font-size:1.21rem;color:var(--sidebar);font-weight:650;margin-bottom:.9em;display:flex;gap:.6em;}

.form-wrap{max-width:480px;margin:0 auto;}
.form-row{display:flex;gap:13px;margin-bottom:14px;flex-wrap:wrap;}
.form-group{flex:1;display:flex;flex-direction:column;min-width:140px;}
.form-group label{font-weight:580;color:var(--sidebar);margin-bottom:5px;}
input[type="text"],input[type="number"],input[type="date"],select{
    padding:11px; border:1.6px solid #b2d2b2; border-radius:8px; margin-bottom:0; font-size:1.05em;
    background:#f6faf7;
}
input:focus, select:focus { border-color: var(--accent);}
button.btnp {
  background: linear-gradient(90deg, #2d5a2d, #34b96e 93%);
  color:#fff; border-radius:8px;border:none;padding:11px 25px;
  font-weight:650;font-size:1.06em; box-shadow:var(--shadow);
  transition:.17s; cursor:pointer; margin-top:.5em;
}
button.btnp:hover {background:#218c68;}
.table {
    width:100%;border-collapse:collapse;margin-top:18px;margin-bottom:10px;background:#fff;
    box-shadow:0 2px 12px #eaeaea;
}
.btnp-disabled {
  background: #ccc !important;
  cursor: not-allowed !important;
  color: #666 !important;
  pointer-events: none !important;
  box-shadow: none !important;
}
.overview {
    display: flex;
    gap: 2rem;
    margin-bottom: 3rem;
    flex-wrap: wrap;
}
.overview-box {
    flex: 1 1 220px;
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.05);
    padding: 2.5rem 2rem;
    display: flex;
    flex-direction: column;
    user-select: none;
}
.overview-box .icon {
    font-size: 3.4rem;
    margin-bottom: 1rem;
}
.overview-box.green .icon { color: #34c759; }
.overview-box.yellow .icon { color: #d4b100; }
.overview-box.blue .icon { color: #1e88e5; }
.overview-box.red .icon { color: #d32f2f; }
.overview-box .label {
    font-weight: 600;
    font-size: 1.1rem;
    color: #666;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    margin-bottom: 0.5rem;
}
.overview-box .value {
    font-weight: 800;
    font-size: 2.8rem;
    color: #222;
}

@media (max-width: 768px) {
    .overview {
        flex-direction: column;
    }
}


th, td {padding:11px 12px;text-align:left;border-bottom:1.5px solid #eee; font-size:1em;}
th { background:#f1f6f3;color:#246548;}
tr:hover {background: #f9f8ea;}
.pager {display:flex; justify-content:center; gap:13px;margin:21px 0;}
.pager select{padding:7px 13px;border-radius:6px;}
@media(max-width:620px){.form-row{flex-direction:column;}}
</style>
</head>
<body>
<div class="layout">
  <nav class="sidebar">
    <div class="logo"><i class="fas fa-tractor"></i> </div>
    <ul class="menu">
      <li data-section="dashboard" class="<%=section.equals("dashboard")?"active":""%>">
        <i class="fas fa-home"></i><span>Dashboard</span>
      </li>
      <li data-section="addcustomer" class="<%=section.equals("addcustomer")?"active":""%>">
        <i class="fas fa-user-plus"></i><span>Add Customer</span>
      </li>
      <li data-section="addjob" class="<%=section.equals("addjob")?"active":""%>">
        <i class="fas fa-briefcase"></i><span>Add Job</span>
      </li>
      <li data-section="searchjobs" class="<%=section.equals("searchjobs")?"active":""%>">
        <i class="fas fa-search"></i><span>Search Jobs</span>
      </li>
      <li data-section="jobs" class="<%=section.equals("jobs")?"active":""%>">
        <i class="fas fa-list"></i><span>My Jobs</span>
      </li>
    </ul>
    <div class="logout-wrap">
      <a href="../index.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
  </nav>
  <div class="content">

    <div class="hbar">
      <h2><i class="fas fa-tractor" style="color:var(--accent)"></i> Farm Fleet Manager</h2>
      <div class="user"><i class="fas fa-user"></i> <%= driver.getName() %> (Tractor: <%= driver.getTractorNumber() %>)</div>
    </div>
    <% if (success!=null) { %><div class="alert"><i class="fas fa-check-circle"></i> <%=success.replace("+"," ")%></div><% } %>
    <% if (error!=null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%=error.replace("+"," ")%></div><% } %>

    <!-- Dashboard -->
    <div class="card <%=section.equals("dashboard")?"active":""%>">
     <section class="overview">
    <div class="overview-box green">
        <div class="icon"><i class="fas fa-clipboard-list"></i></div>
        <div class="label">Active Jobs</div>
        <div class="value"><%= activeCustomersCount %></div>
    </div>
    <div class="overview-box yellow">
        <div class="icon"><i class="fas fa-tools"></i></div>
        <div class="label">Tools Available</div>
        <div class="value"><%= getToogetAvailableToolsCountlsCount %></div>
    </div>
     <%-- <div class="overview-box blue">
        <div class="icon"><i class="fas fa-coins"></i></div>
        <div class="label">Earnings This Month</div>
        <div class="value">₹<%= String.format("%.2f", getTotalEarningsThisMonth) %></div>
    </div> 
    <div class="overview-box red">
        <div class="icon"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="label">Pending Dues</div>
        <div class="value">₹<%= String.format("%.2f", getPendingDues) %></div>
    </div> --%>
</section>


    </div>

    <!-- Add Customer -->
    <div class="card <%=section.equals("addcustomer")?"active":""%>">
      <h2><i class="fas fa-user-plus"></i> Add Customer</h2>
      <form action="../DriverServlet" method="post" class="form-wrap" autocomplete="off">
        <input type="hidden" name="action" value="addCustomer">
        <div class="form-row">
          <div class="form-group">
            <label>Customer Name</label>
            <input type="text" name="customerName" required>
          </div>
          <div class="form-group">
            <label>Mobile Number</label>
            <input type="text" name="customerMobile" required>
          </div>
        </div>
        <button type="submit" class="btnp"><i class="fas fa-plus"></i> Add Customer</button>
      </form>
    </div>

    <!-- Add Job -->
    <div class="card <%=section.equals("addjob")?"active":""%>">
      <h2><i class="fas fa-briefcase"></i> Add Job</h2>
      <form action="../DriverServlet" method="post" class="form-wrap" autocomplete="off" id="jobForm">
        <input type="hidden" name="action" value="addJob">
        <div class="form-row">
          <div class="form-group">
            <label>Customer</label>
            <select name="customerId" required>
            <option value="">Select Customer</option>
            <%
                List<Map<String, String>> customers = dao.getCustomersList(driver.getDriverId());
                for (Map<String, String> cust : customers) {
            %>
                <option value="<%= cust.get("id") %>"><%= cust.get("name") %> (<%= cust.get("mobile") %>)</option>
            <% } %>
            </select>
          </div>
          <div class="form-group">
            <label>Tool</label>
            <select name="toolId" id="toolSelect" required>
              <option value="">Select Tool</option>
              <%
                int ownerId = driver.getOwnerId();
                try (ResultSet rs = dao.getOwnerTools(ownerId)) {
                  while (rs.next()) {
              %>
                <option value="<%= rs.getInt("tool_id") %>" data-rate="<%= rs.getDouble("rate_per_hour") %>">
                  <%= rs.getString("tool_name") %> (₹<%= rs.getDouble("rate_per_hour") %>/hr)
                </option>
              <% } } catch (Exception e) { } %>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Hours Worked</label>
            <input type="number" name="hours" id="hours" min="1" required>
          </div>
          <div class="form-group">
            <label>Date</label>
            <input type="date" id="jobDate" name="jobDate" required>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label>Rate (₹)</label>
            <input type="text" name="rate" id="rate" readonly>
          </div>
          <div class="form-group">
            <label>Total (₹)</label>
            <input type="text" name="total" id="total" readonly>
          </div>
        </div>
        <button type="submit" class="btnp"><i class="fas fa-save"></i> Save Job</button>
      </form>
    </div>

    <!-- Search Jobs -->
    <!-- Search Jobs -->
<div class="card <%=section.equals("searchjobs")?"active":""%>">
  <h2><i class="fas fa-search"></i> Search Jobs</h2>
  <form method="get" action="driverDashboard.jsp" class="form-wrap">
    <input type="hidden" name="section" value="searchjobs"/>
    <div class="form-row">
      <div class="form-group">
        <label>Customer Name or Phone</label>
        <input type="text" name="searchCustomer" value="<%=searchCustomer%>">
      </div>
      <div class="form-group">
        <label>Date</label>
        <input type="date" name="searchDate" value="<%=searchDate%>">
      </div>
      <div class="form-group" style="min-width:120px; display:flex; align-items:center; gap:8px;">
  <button type="submit" class="btnp"><i class="fas fa-search"></i> Search</button>
  <% if (isSearchMode) { %>
    <a href="driverDashboard.jsp?section=searchjobs" class="btnp btn-danger" style="margin-left:10px;">Clear</a>
  <% } %>
</div>

    </div>
  </form>
  <% if (isSearchMode) {
    ResultSet rs = dao.searchJobsByCustomerAndDate(driver.getDriverId(), searchCustomer, searchDate);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
  %>
  <table class="table">
    <thead>
    <tr>
      <th>Customer</th><th>Tool</th><th>Hours</th><th>Rate</th><th>Date</th>
      <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <% while(rs.next()) { %>
    <tr>
      <form action="../DriverServlet" method="post" style="display:flex;align-items:center;gap:10px;">
        <input type="hidden" name="action" value="updateJob">
        <input type="hidden" name="jobId" value="<%= rs.getInt("job_id") %>">
        <td>
        <select name="customerId" required>
        <%
            List<Map<String, String>> custList = dao.getCustomersList(driver.getDriverId());
            for (Map<String, String> cust : custList) {
              String selected = cust.get("id").equals(String.valueOf(rs.getInt("customer_id"))) ? "selected" : "";
        %>
          <option value="<%= cust.get("id") %>" <%= selected %> >
            <%= cust.get("name") %> (<%= cust.get("mobile") %>)
          </option>
        <% } %>
        </select>
        </td>
        <td>
            <select name="toolId" required>
            <%
              try (ResultSet tRs = dao.getOwnerTools(driver.getOwnerId())) {
                while (tRs.next()) {
                  String selected = tRs.getInt("tool_id") == rs.getInt("tool_id") ? "selected" : "";
            %>
              <option value="<%= tRs.getInt("tool_id") %>" <%= selected %>>
                <%= tRs.getString("tool_name") %> (₹<%= tRs.getDouble("rate_per_hour") %>/hr)
              </option>
            <% } } %>
            </select>
        </td>
        <td><input type="number" name="hours" value="<%= rs.getInt("hours_used") %>" min="1"></td>
        <td>₹<%= rs.getDouble("amount_per_hour") %></td>
        <td><input type="date" name="jobDate" value="<%= sdf.format(rs.getDate("date")) %>"></td>
        <td>
          <button type="submit" class="btnp btn-success btn-sm">Update</button>
        </td>
      </form>
    </tr>
    <% } rs.close(); %>
    </tbody>
  </table>
  <% } %>
</div>


    <!-- My Jobs -->
    <div class="card <%=section.equals("jobs")?"active":""%>">
      <h2><i class="fas fa-list"></i> My Jobs</h2>
      <%
        ResultSet rs;
        int totalJobs;
        if(isSearchMode){
          rs = dao.searchJobsByCustomerAndDate(driver.getDriverId(), searchCustomer, searchDate);
          totalJobs = 0;
        }else{
          totalJobs = dao.getTotalJobsCount(driver.getDriverId());
          rs = dao.getJobsPaginated(driver.getDriverId(), offset, limit);
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
      %>
      <table class="table">
        <thead>
        <tr>
          <th>Customer</th>
          <th>Tool</th>
          <th>Hours</th>
          <th>Rate</th>
          <th>Date</th>
        </tr>
        </thead>
        <tbody>
        <% while(rs.next()){ %>
        <tr>
          <td><%= rs.getString("customer") %></td>
          <td><%= rs.getString("tool_type") %></td>
          <td><%= rs.getInt("hours_used") %></td>
          <td>₹<%= rs.getDouble("amount_per_hour") %></td>
          <td><%= sdf.format(rs.getDate("date")) %></td>
        </tr>
        <% } rs.close(); %>
        </tbody>
      </table>

      <% if (!isSearchMode) {
        int totalPages = (int) Math.ceil((double) totalJobs / limit);
        if (totalPages > 1) { %>
        <div class="pager">
          <a href="driverDashboard.jsp?section=jobs&page=<%=currentPage-1%>" class="btnp <%=currentPage==1?"btn-danger disabled":""%>" <% if(currentPage==1){%>disabled<%}%>>Prev</a>
          <select onchange="location.href='driverDashboard.jsp?section=jobs&page='+this.value" style="width:120px">
            <% for (int i = 1; i <= totalPages; i++) { %>
              <option value="<%=i%>" <%=currentPage==i?"selected":""%>>Page <%=i%></option>
            <% } %>
          </select>
          <a href="driverDashboard.jsp?section=jobs&page=<%=currentPage+1%>" class="btnp <%=currentPage==totalPages?"btn-danger disabled":""%>" <% if(currentPage==totalPages){%>disabled<%}%>>Next</a>
        </div>
        <% }
      } %>
    </div>
  </div>
</div>

<script>
document.querySelectorAll('.menu li[data-section]').forEach(function(li){
  li.addEventListener('click',function(){
    window.location.href = 'driverDashboard.jsp?section=' + this.getAttribute('data-section');
  });
});
document.addEventListener('DOMContentLoaded', () => {
  const today = new Date().toISOString().split('T')[0];
  const jobDateElem = document.getElementById('jobDate');
  if(jobDateElem) jobDateElem.value = today;
  const toolSelect = document.getElementById('toolSelect');
  const hoursInput = document.getElementById('hours');
  const rateInput = document.getElementById('rate');
  const totalInput = document.getElementById('total');
  function calculateTotal() {
      const rate = parseFloat(rateInput.value) || 0;
      const hours = parseFloat(hoursInput.value) || 0;
      totalInput.value = (rate * hours)||"";
  }
  if(toolSelect){ toolSelect.addEventListener('change',()=>{
      const selectedOption = toolSelect.options[toolSelect.selectedIndex];
      rateInput.value = selectedOption.getAttribute('data-rate') || 0;
      calculateTotal();
  }); }
  if(hoursInput){ hoursInput.addEventListener('input', calculateTotal); }
});
</script>
</body>
</html>
