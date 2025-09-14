<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db.DBConnection" %>
<%@ page session="true" %>
<%
    if (session == null || session.getAttribute("hod_id") == null) {
        response.sendRedirect("hodLogin.jsp");
        return;
    }

    String dept = (String) session.getAttribute("hod_department");
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fid = request.getParameter("faculty_id");
        String fname = request.getParameter("faculty_name");
        String pwd = request.getParameter("faculty_password");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO faculty (faculty_id, faculty_name, faculty_password, faculty_department) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, fid);
            ps.setString(2, fname);
            ps.setString(3, pwd);
            ps.setString(4, dept);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                message = "Faculty added successfully.";
            } else {
                message = "Failed to add faculty.";
            }

            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Faculty</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f9f9f9;
        }

        .container {
            width: 400px;
            margin: 50px auto;
            background: #fff;
            padding: 25px;
            box-shadow: 0 0 10px rgba(0,0,0,0.2);
            border-radius: 10px;
        }

        h2 {
            text-align: center;
            color: #333;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        input[type="text"],
        input[type="password"] {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        input[type="submit"] {
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .back {
            margin-top: 15px;
            text-align: center;
        }

        .message {
            text-align: center;
            margin-top: 10px;
            color: green;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Add Faculty</h2>
    <form method="post" action="addFaculty.jsp">
        <input type="text" name="faculty_id" placeholder="Faculty ID" required />
        <input type="text" name="faculty_name" placeholder="Faculty Name" required />
        <input type="password" name="faculty_password" placeholder="Password" required />
        <input type="submit" value="Add Faculty" />
    </form>

    <div class="message"><%= message %></div>

    <div class="back">
        <a href="hodHomePage.jsp">← Back to Home</a>
    </div>
</div>

</body>
</html>
