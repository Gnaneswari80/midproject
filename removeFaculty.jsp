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
    String messageColor = "green";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fid = request.getParameter("faculty_id");

        try {
            Connection conn = DBConnection.getConnection();

            // Check if faculty is assigned to any subject
            PreparedStatement checkPs = conn.prepareStatement("SELECT COUNT(*) FROM subjects WHERE fid = ?");
            checkPs.setString(1, fid);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                message = "Cannot delete. Faculty is assigned to one or more subjects. Unassign them first.";
                messageColor = "red";
            } else {
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM faculty WHERE faculty_id = ? AND faculty_department = ?"
                );
                ps.setString(1, fid);
                ps.setString(2, dept);

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    message = "Faculty removed successfully.";
                    messageColor = "green";
                } else {
                    message = "Faculty not found or doesn't belong to your department.";
                    messageColor = "red";
                }
                ps.close();
            }

            rs.close();
            checkPs.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
            messageColor = "red";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Remove Faculty</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f8f8f8;
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

        input[type="text"] {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        input[type="submit"] {
            padding: 10px;
            background-color: #ff4d4d;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .message {
            text-align: center;
            margin-top: 10px;
            color: <%= messageColor %>;
        }

        .back {
            margin-top: 20px;
            text-align: center;
        }

        .back a {
            text-decoration: none;
            color: black;
            font-weight: bold;
            font-size: 14px;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Remove Faculty</h2>
    <form method="post" action="removeFaculty.jsp">
        <input type="text" name="faculty_id" placeholder="Faculty ID to Remove" required />
        <input type="submit" value="Remove Faculty" />
    </form>

    <div class="message"><%= message %></div>

    <div class="back">
        <a href="hodHomePage.jsp">← Back to Home</a>
    </div>
</div>

</body>
</html>
