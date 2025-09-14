<%@ page import="java.sql.*" %> 
<%@ page import="db.DBConnection" %>
<%
    String errorMsg = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fid = request.getParameter("fid");
        String password = request.getParameter("password");
        String studentDept = request.getParameter("student_department");

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT faculty_id, faculty_name FROM faculty WHERE faculty_id = ? AND faculty_password = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, fid);
                ps.setString(2, password);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        session.setAttribute("faculty_id", rs.getString("faculty_id"));
                        session.setAttribute("faculty_name", rs.getString("faculty_name"));
                        session.setAttribute("student_department", studentDept);
                        response.sendRedirect("getSubjects.jsp");
                        return;
                    } else {
                        errorMsg = "Invalid Faculty ID or Password.";
                    }
                }
            }
        } catch (Exception e) {
            errorMsg = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Faculty Login</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: Arial, sans-serif;
    }

    body {
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background: linear-gradient(#7ec8e3, #e0f7fa);
        overflow: hidden;
    }

    /* Background cloud layers */
    .cloud-layer {
        position: fixed;
        top: 0;
        left: 0;
        width: 200%;
        height: 100%;
        background-repeat: repeat-x;
        background-size: contain;
        animation: moveClouds 60s linear infinite;
        pointer-events: none;
        opacity: 0.3;
    }

    .cloud-layer.layer1 {
        background-image: radial-gradient(circle at 30% 50%, rgba(255,255,255,0.9) 0%, transparent 70%),
                          radial-gradient(circle at 70% 40%, rgba(255,255,255,0.8) 0%, transparent 60%);
        animation-duration: 100s;
    }

    .cloud-layer.layer2 {
        background-image: radial-gradient(circle at 20% 60%, rgba(255,255,255,0.85) 0%, transparent 70%),
                          radial-gradient(circle at 80% 50%, rgba(255,255,255,0.75) 0%, transparent 60%);
        animation-duration: 160s;
    }

    @keyframes moveClouds {
        from { transform: translateX(0); }
        to { transform: translateX(-50%); }
    }

    /* Login container */
    .login-container {
        background: rgba(255, 255, 255, 0.95);
        padding: 30px 40px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        max-width: 380px;
        width: 100%;
        z-index: 1;
        animation: fadeInUp 1s ease-out;
    }

    @keyframes fadeInUp {
        0% { opacity: 0; transform: translateY(40px); }
        100% { opacity: 1; transform: translateY(0); }
    }

    h2 {
        text-align: center;
        margin-bottom: 20px;
        color: #333;
    }

    label {
        font-weight: bold;
        display: block;
        margin-top: 15px;
        color: #555;
    }

    input, select {
        width: 100%;
        padding: 10px;
        margin-top: 5px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
    }

    input:focus, select:focus {
        border-color: #2196f3;
        outline: none;
        box-shadow: 0 0 6px rgba(33, 150, 243, 0.3);
    }

    input[type="submit"] {
        background: #2196f3;
        color: white;
        border: none;
        margin-top: 20px;
        cursor: pointer;
        font-size: 16px;
        font-weight: bold;
        transition: background 0.3s;
    }

    input[type="submit"]:hover {
        background: #1976d2;
    }

    .error-message {
        color: #d9534f;
        font-weight: bold;
        text-align: center;
        margin-top: 15px;
    }

    .back-button {
        display: inline-block;
        margin-bottom: 10px;
        font-size: 14px;
        text-decoration: none;
        color: #2196f3;
        font-weight: bold;
    }

    .back-button:hover {
        color: #1976d2;
    }
</style>
</head>
<body>

<div class="cloud-layer layer1"></div>
<div class="cloud-layer layer2"></div>

<div class="login-container">
    <a href="index.jsp" class="back-button">&#8592; Back</a>
    <h2>Faculty Login</h2>
    <form method="post">
        <label for="fid">Faculty ID</label>
        <input type="text" name="fid" id="fid" required>

        <label for="password">Password</label>
        <input type="password" name="password" id="password" required>

        <label for="student_department">Student Department</label>
        <select name="student_department" id="student_department" required>
            <option value="" disabled selected>-- Select Department --</option>
            <option value="CSE">CSE</option>
            <option value="ECE">ECE</option>
            <option value="EEE">EEE</option>
            <option value="MCA">MCA</option>
            <option value="MBA">MBA</option>
            <option value="MTech">MTech</option>
        </select>

        <input type="submit" value="Login">
    </form>

    <p class="error-message"><%= errorMsg %></p>
</div>

</body>
</html>

