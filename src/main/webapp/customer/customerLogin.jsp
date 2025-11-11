<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        body {
            background: url('/TractorServiceTracker/Images/back3.jpg') no-repeat center center fixed;
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
        label {
            color: #222;
        }
        .form-control {
            background: rgba(255,255,255,0.75);
            border-radius: 10px;
        }
        .btn-primary {
            background-color: #337ab7;
            border-color: #2e6da4;
        }
        .btn-primary:hover, .btn-primary:focus {
            background-color: #286090;
            border-color: #204d74;
        }
        .text-danger {
            color: #dc3545 !important;
        }
    </style>
</head>
<body>
    <div class="glass-card mx-auto">
        <h2 class="text-center mb-4">Customer Login</h2>
        <form action="../CustomerServlet" method="post" class="mt-4">
            <input type="hidden" name="action" value="login">
            <div class="mb-3">
                <label for="name">Name</label>
                <input type="text" id="name" name="name" class="form-control" required>
            </div>
            <div class="mb-3">
                <label for="mobile">Mobile</label>
                <input type="text" id="mobile" name="mobile" class="form-control" required>
            </div>
            <div class="mb-3">
                <label for="tractorNumber">Tractor Number</label>
                <input type="text" id="tractorNumber" name="tractorNumber" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary w-100">Login</button>
        </form>

        <% if (request.getParameter("error") != null) { %>
            <p class="text-danger text-center mt-3">Invalid credentials! Please try again.</p>
        <% } %>
    </div>
</body>
</html>
