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
        String subjectName = request.getParameter("subject_name");
        String year = request.getParameter("year");
        String sem = request.getParameter("sem");
        String fid = request.getParameter("fid");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO subjects (subject_id, subject_name, year, sem, dept, fid) VALUES (?, ?, ?, ?, ?, ?)"
            );
            ps.setString(1, subjectId);
            ps.setString(2, subjectName);
            ps.setString(3, year);
            ps.setString(4, sem);
            ps.setString(5, dept);
            ps.setString(6, fid);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                message = "Subject added successfully.";
            } else {
                message = "Failed to add subject.";
            }

            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            message = "Something went wrong, subject not added";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Subject</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f1f1f1;
        }

        .container {
            width: 450px;
            margin: 50px auto;
            padding: 25px;
            background-color: white;
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

        input, select {
            padding: 10px;
            margin: 8px 0;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        input[type="submit"] {
            background-color: #28a745;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }

        .back {
            margin-top: 15px;
            text-align: center;
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
    <h2>Add New Subject</h2>
    <form method="post" action="addNewSubject.jsp">
        <input type="text" name="subject_id" placeholder="Subject ID" required />
        <input type="text" name="subject_name" placeholder="Subject Name" required />

        <select name="year" required>
            <option value="">-- Select Year --</option>
            <option value="1">1st Year</option>
            <option value="2">2nd Year</option>
            <option value="3">3rd Year</option>
            <option value="4">4th Year</option>
        </select>

        <select name="sem" required>
            <option value="">-- Select Semester --</option>
            <option value="1">1st Sem</option>
            <option value="2">2nd Sem</option>
            <option value="3">3rd Sem</option>
            <option value="4">4th Sem</option>
            <option value="5">5th Sem</option>
            <option value="6">6th Sem</option>
            <option value="7">7th Sem</option>
            <option value="8">8th Sem</option>
        </select>

        <input type="text" name="fid" placeholder="Faculty ID (fid)" required />

        <input type="submit" value="Add Subject" />
    </form>

    <div class="back">
        <a href="hodHomePage.jsp">← Back to Home</a>
    </div>
</div>

<% if (!message.isEmpty()) { %>
<script>
    alert("<%= message %>");
</script>
<% } %>

</body>
</html>
