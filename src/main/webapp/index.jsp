<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Tractor Service Tracker</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            overflow: hidden;
            font-family: Arial, sans-serif;
            background: #87CEEB; /* Light blue sky background */
        }
        .farm-background {
            width: 100%;
            height: 100vh;
            position: absolute;
            top: 0;
            left: 0;
            z-index: -1;
        }
        .sky {
            width: 100%;
            height: 70%;
            background: transparent;
            position: absolute;
            top: 0;
            left: 0;
        }
        .land {
            width: 100%;
            height: 30%;
            background: linear-gradient(to top, #6dbf59, #a0e293); 
            position: absolute;
            bottom: 0;
            left: 0;
        }
        /* Logos */
        .logo-left, .logo-right {
            position: absolute;
            top: 10px;
            width: 120px;
            height: auto;
            z-index: 10;
            border-radius: 50%;
        }
        .logo-left { left: 20px; }
        .logo-right { right: 20px; }
        /* Tractor */
        .scrolling-tractor {
            position: absolute;
            bottom: 30px;
            left: -250px;
            animation: scrollTractor 15s linear infinite;
            z-index: 5;
        }
        .scrolling-tractor img {
            width: 250px;
            height: auto;
        }
        @keyframes scrollTractor {
            0% { transform: translateX(0); }
            100% { transform: translateX(160vw); }
        }
        /* Clouds */
        .cloud { position: absolute; width: 200px; height: auto; opacity: 0.9; z-index: 2; }
        .cloud1 { top: 3%; left: -200px; animation: cloudLeftToRight 30s linear infinite; }
        .cloud2 { top: 7%; right: -200px; animation: cloudRightToLeft 60s linear infinite; }
        .cloud3 { top: 10%; right: -250px; animation: cloudRightToLeft 30s linear infinite; }
        @keyframes cloudLeftToRight {
            0% { transform: translateX(0); }
            100% { transform: translateX(160vw); }
        }
        @keyframes cloudRightToLeft {
            0% { transform: translateX(0); }
            100% { transform: translateX(-160vw); }
        }
        /* Birds */
        .bird { position: absolute; width: 60px; z-index: 4; }
        .bird1 { top: 15%; left: -100px; animation: bird1Anim 20s linear infinite; }
        .bird2 { top: 10%; right: -100px; animation: bird2AnimRightToLeft 25s linear infinite; }
        .bird3 { top: 10%; left: -300px; animation: bird3Anim 30s linear infinite; }
        @keyframes bird1Anim {
            0% { transform: translateX(0); }
            100% { transform: translateX(160vw); }
        }
        @keyframes bird2AnimRightToLeft {
            0% { transform: translateX(0); }
            100% { transform: translateX(-160vw); }
        }
        @keyframes bird3Anim {
            0% { transform: translateX(0); }
            100% { transform: translateX(160vw); }
        }
        /* Farmers */
        .farmer-left, .farmer-right {
            position: absolute;
            bottom: 200px;
            width: 250px;
            height: 450px;
            z-index: 6;
        }
        .farmer-left { left: 30px; }
        .farmer-right { right: 30px; }
        /* Overlay and Cards */
        .overlay {
            background-color: rgba(0, 0, 0, 0.4);
            height: 100vh;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            text-align: center;
            position: relative;
            z-index: 10;
        }
        h1 {
            color: gold;
            font-size: 48px;
            font-weight: 990;
            text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.6);
            margin-bottom: 40px;
            font-family: 'Georgia', serif;
        }
        .role-card {
            background: rgba(255,255,255,0.9);
            padding: 40px;
            margin: 15px;
            border-radius: 15px;
            width: 250px;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            transition: transform 0.3s ease;
            font-family: 'Segoe UI', sans-serif;
            color:#bf9000;
        }
        .role-card p{
            color:#333;
            font-size: 16px;
        }
        .role-card:hover { transform: scale(1.05); }
        .d-flex.justify-content-center { flex-wrap: wrap; }
        a { text-decoration: none; }
    </style>
</head>
<body>
<!-- Background Scene -->
<div class="farm-background">
    <div class="sky"></div>
    <!-- Clouds -->
    <img src="Images/cloud1.png" class="cloud cloud1" alt="Cloud 1" />
    <img src="Images/cloud2.png" class="cloud cloud2" alt="Cloud 2" />
    <img src="Images/cloud3.png" class="cloud cloud3" alt="Cloud 3" />
    <!-- Birds -->
    <img src="Images/bird1.png" class="bird bird1" alt="Bird 1" />
    <img src="Images/bird2.png" class="bird bird2" alt="Bird 2" />
    <img src="Images/bird3.png" class="bird bird3" alt="Bird 3" />
    <!-- Logos -->
    <img src="Images/right-logo.png" class="logo-left" alt="Left Logo" />
    <img src="Images/AB.png" class="logo-right" alt="Right Logo" />
    <!-- Tractor -->
    <div class="scrolling-tractor">
        <img src="Images/Tractor.png" alt="Tractor" />
    </div>
    <!-- Farmers -->
    <img src="Images/Male.png" class="farmer-left" alt="Male Farmer" />
    <img src="Images/Lady.png" class="farmer-right" alt="Female Farmer" />
    <!-- Land -->
    <div class="land"></div>
</div>
<!-- Overlay Content -->
<div class="overlay">
    <h1>AGRI - TRACTOR SERVICE</h1>
    <div class="d-flex justify-content-center">
        <a href="owner/ownerLogin.jsp">
            <div class="role-card">
                <h3>Owner</h3>
                <p>Manage drivers and view dues</p>
            </div>
        </a>
        <a href="driver/driverLogin.jsp">
            <div class="role-card">
                <h3>Driver</h3>
                <p>Log jobs and add customers</p>
            </div>
        </a>
        <a href="customer/customerLogin.jsp">
            <div class="role-card">
                <h3>Customer</h3>
                <p>Check your dues and jobs</p>
            </div>
        </a>
    </div>
</div>
</body>
</html>
