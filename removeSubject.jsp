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
        String subjectId = request.getParameter("subject_id");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM subjects WHERE subject_id = ? AND dept = ?");
            ps.setString(1, subjectId);
            ps.setString(2, dept);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                message = "Subject removed successfully.";
            } else {
                message = "Subject ID not found or doesn't belong to your department.";
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
    <title>Remove Subject</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f0f2f5;
        }

        .container {
            width: 400px;
            margin: 60px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #333;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        input[type="text"] {
            padding: 10px;
            margin: 10px 0;
            font-size: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        input[type="submit"] {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 12px;
            cursor: pointer;
            border-radius: 5px;
            font-size: 16px;
        }

        input[type="submit"]:hover {
            background-color: #b02a37;
        }

        .message {
            text-align: center;
            color: green;
            margin-top: 10px;
        }

        .back {
            text-align: center;
            margin-top: 20px;
        }

        .back a {
            text-decoration: none;
            color: #007BFF;
        }

        .back a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Remove Subject</h2>
    <form method="post" action="removeSubject.jsp">
        <input type="text" name="subject_id" placeholder="Enter Subject ID" required />
        <input type="submit" value="Remove Subject" />
    </form>

    <div class="message"><%= message %></div>

    <div class="back">
        <a href="hodHomePage.jsp">← Back to Home</a>
    </div>
</div>

</body>
</html>
