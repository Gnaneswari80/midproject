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
        String studentId = request.getParameter("student_id");
        String studentName = request.getParameter("student_name");
        String sem = request.getParameter("sem");
        String year = request.getParameter("year");
        String batchYear = request.getParameter("batch_year");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO studentdetails (student_id, student_name, student_department,stu_sem,stu_year,stu_batchyear) VALUES (?,?,?,?,?, ?)"
            );
            ps.setString(1, studentId);
            ps.setString(2, studentName);
            ps.setString(3, dept);
            ps.setString(4, sem);
            ps.setString(5, year);
            ps.setString(6, batchYear);
     
            int rows = ps.executeUpdate();

           /* PreparedStatement ps2 = conn.prepareStatement(
                "INSERT INTO studentmidmarks (sid, sname, student_sem, student_year, sbatch_year,smmdepartment) VALUES (?, ?, ?, ?, ?, ?)"
            );
            ps2.setString(1, studentId);
            ps2.setString(2, studentName);
            ps2.setString(3, sem);
            ps2.setString(4, year);
            ps2.setString(5, batchYear);
            ps2.setString(6, dept);
            ps2.executeUpdate();*/

            message = "New student added successfully.";

            ps.close();
           // ps2.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            message =  e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Batch</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f5f5f5;
        }
        .container {
            width: 500px;
            margin: 50px auto;
            padding: 25px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.2);
        }
        h2 {
            text-align: center;
        }
        form {
            display: flex;
            flex-direction: column;
        }
        input, select {
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        input[type="submit"] {
            background-color: #007BFF;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }
        .back {
            text-align: center;
            margin-top: 15px;
        }
        .back a {
            text-decoration: none;
            color: #007BFF;
        }
    </style>
</head>
<body>

<% if (!message.isEmpty()) { %>
<script>
    alert("<%= message.replace("\"", "\\\"") %>");
</script>
<% } %>

<div class="container">
    <h2>Add New Batch - Student Entry</h2>
    <form method="post" action="addNewBatch.jsp">
        <input type="text" name="student_id" placeholder="Student ID" required />
        <input type="text" name="student_name" placeholder="Student Name" required />

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

        <select name="year" required>
            <option value="">-- Select Year --</option>
            <option value="1">1st Year</option>
            <option value="2">2nd Year</option>
            <option value="3">3rd Year</option>
            <option value="4">4th Year</option>
        </select>

        <input type="text" name="batch_year" placeholder="Batch Year (e.g. 2025)" required />

        <input type="submit" value="Add Student" />
    </form>

    <div class="back">
        <a href="hodHomePage.jsp">← Back to Home</a>
    </div>
</div>
</body>
</html>

