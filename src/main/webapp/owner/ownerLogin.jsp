<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Owner Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        body {
            /* Full background with cover */
            background: url('${pageContext.request.contextPath}/TractorServiceTracker/Images/back4.jpg') no-repeat center center fixed;
            background-size: cover;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.35);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.2);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.25);
            padding: 40px 30px;
            max-width: 400px;
            width: 100%;
        }
        .glass-card h2 {
            font-weight: 700;
            color: #176B34;
            text-shadow: 0 2px 8px rgba(100, 100, 100, 0.05);
        }
        .form-label {
            color: #222;
        }
        .form-control {
            background: rgba(255,255,255,0.75);
            border-radius: 10px;
        }
        .btn-success {
            background-color: #53c66e;
        }
        .btn-success:hover, .btn-success:focus {
            background-color: #218838;
        }
        .text-info {
            color: #1464ba !important;
        }
        a {
            color: #218838;
            text-decoration: underline;
        }
        a:hover {
            text-decoration: none;
            color: #145a28;
        }
    </style>
</head>
<body>
    <div class="glass-card mx-auto">
        <h2 class="text-center mb-4">Owner Login</h2>
        <form action="${pageContext.request.contextPath}/OwnerServlet" method="post" class="mt-4">
            <input type="hidden" name="action" value="login">
            <div class="mb-3">
                <label for="mobile" class="form-label">Mobile</label>
                <input type="text" id="mobile" name="mobile" class="form-control" required>
            </div>
            <div class="mb-3">
                <label for="vehicleNo" class="form-label">Vehicle Number</label>
                <input type="text" id="vehicleNo" name="vehicleNo" class="form-control"
                       placeholder="e.g. MH01AB1234" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-success w-100">Login</button>
        </form>

        <% if (request.getParameter("resetSent") != null) { %>
            <p class="text-info text-center mt-3">
                Your password has been sent to your registered mobile.
            </p>
        <% } %>

        <p class="text-center mt-4 mb-0">
            <a href="ownerRegister.jsp">Create a new account</a> |
            <a href="OwnerForgotPassword.jsp">Forgot Password?</a>
        </p>
    </div>
</body>
</html>
