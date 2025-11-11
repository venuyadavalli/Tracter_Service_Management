<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Forgot Password</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5" style="max-width: 400px;">
    <h2 class="text-center">Forgot Password</h2>
	<form action="../OwnerServlet" method="post">
    <!-- This tells the servlet which block to run -->
    <input type="hidden" name="action" value="forgotPassword">

    <label>Mobile:</label>
    <input type="text" name="mobile" required><br><br>

    <label>Vehicle Number:</label>
    <input type="text" name="vehicleNo" required><br><br>

    <button type="submit">Get Password</button>
</form>

<% if (request.getAttribute("smsSuccess") != null) { %>
    <div class="alert alert-success text-center mt-3">
        <%= request.getAttribute("smsSuccess") %>
    </div>
    <div class="text-center mt-3">
        <a href="owner/ownerLogin.jsp" class="btn btn-primary">Go to Login</a>
    </div>
<% } %>





    <% if (request.getParameter("error") != null) { %>
        <p class="text-danger text-center mt-3">No account found with these details.</p>
    <% } %>
</div>
</body>
</html>
