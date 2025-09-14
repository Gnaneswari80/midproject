<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<!DOCTYPE html>
<html>
<head>
    <title>MidMarks System - Home</title>
    <style>
        /* Base styling */
        body {
            margin: 0;
            padding: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #002147, #004e92);
            color: #fff;
            overflow-x: hidden;
            animation: fadeIn 1.2s ease-in-out;
        }

        /* Fade-in animation */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Header section */
        .header {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
            padding: 20px 40px;
            background: rgba(0, 0, 0, 0.25);
            backdrop-filter: blur(6px);
        }

        .header img {
            transition: transform 0.5s ease;
        }

        .header img.large-header {
            width: 60%;
            max-width: 900px;
            height: auto;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }

        .header img.small-logo {
            width: 120px;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            margin-right: 20px;
        }

        .header img:hover {
            transform: scale(1.03);
        }

        .marquee-text {
            color: #ffdf6c;
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
            animation: textGlow 2s ease-in-out infinite alternate;
        }

        @keyframes textGlow {
            0% { text-shadow: 0 0 5px #ffdf6c, 0 0 10px #ffb400; }
            100% { text-shadow: 0 0 15px #ffb400, 0 0 30px #ffdf6c; }
        }

        /* Main container */
        .container {
            background-color: rgba(255, 255, 255, 0.95);
            color: #333;
            margin: 50px auto;
            padding: 40px 30px;
            width: 50%;
            text-align: center;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            animation: slideUp 1s ease-in-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h2 {
            font-size: 28px;
            margin-bottom: 30px;
            color: #002147;
        }

        /* Buttons */
        a {
            display: inline-block;
            margin: 15px 10px;
            padding: 14px 30px;
            font-size: 17px;
            font-weight: bold;
            color: #fff;
            background: linear-gradient(90deg, #007BFF, #0056b3);
            border: none;
            border-radius: 50px;
            text-decoration: none;
            transition: all 0.3s ease-in-out;
            box-shadow: 0 4px 12px rgba(0, 91, 187, 0.4);
        }

        a:hover {
            background: linear-gradient(90deg, #0056b3, #003f7f);
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 6px 18px rgba(0, 91, 187, 0.6);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                width: 90%;
                padding: 30px 20px;
            }

            .header img.large-header {
                width: 95%;
                margin-top: 10px;
            }

            .header img.small-logo {
                width: 80px;
                margin-right: 10px;
            }
        }
    </style>
</head>
<body>

    <div class="header" style="display: flex; align-items: center; justify-content: flex-start; flex-wrap: wrap; padding: 20px 40px; background: rgba(0, 0, 0, 0.25); backdrop-filter: blur(6px);">
    
    <!-- Small logo on left (larger + shifted left) -->
    <img src="https://www.sietk.org/images/sietk-logo.png" 
         alt="SIETK Logo" 
         class="small-logo"
         style="width: 180px; height: auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); margin-right: 30px; margin-left: 10px;">

    <!-- Original large header image -->
    <img src="https://www.sietk.org/images/1.png" 
         alt="Siddhartha Institute of Engineering & Technology, Puttur" 
         class="large-header">
 
 <!-- SIETK logo moved to the right -->
<img src="https://www.sietk.org/images/sietk-logo.png" 
     alt="SIETK Logo" 
     style="width: 180px; height: auto; border-radius: 8px; 
            box-shadow: 0 4px 12px rgba(0,0,0,0.3); margin-left: 40px;">


    <!-- Marquee below images -->
    <div style="width: 100%; margin-top: 10px;">
        <marquee class="marquee-text" behavior="scroll" direction="left">
            Siddharth Institute of Engineering & Technology, Puttur
        </marquee>
    </div>
</div>



    <div class="container">
        <h2>Welcome to MidMarks Management System</h2>
        <a href="facultylogin.jsp">Faculty Login</a>
        <a href="hodLogin.jsp">Admin/HOD Login</a>
    </div>

</body>
</html>
