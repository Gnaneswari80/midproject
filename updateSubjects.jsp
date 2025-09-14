<%@ page import="java.sql.*, java.util.*" %>  
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    PreparedStatement facStmt = null;
    ResultSet facultyRs = null;

    String hodDept = (String) session.getAttribute("hod_department");
    String hodRole = (String) session.getAttribute("hod_designation"); // "Admin" or "HOD"

    if (hodDept == null || hodRole == null) {
        response.sendRedirect("hodLogin.jsp");
        return;
    }

    String message = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

        // Handle delete
        String deleteId = request.getParameter("delete_id");
        if (deleteId != null) {
            PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM subjects WHERE subject_id = ?");
            deleteStmt.setString(1, deleteId);
            int rows = deleteStmt.executeUpdate();
            if (rows > 0) {
                message = "Subject deleted successfully.";
            } else {
                message = "Failed to delete subject.";
            }
            deleteStmt.close();
        }

        // Handle update
        if (request.getParameter("update") != null) {
            String originalSubId = request.getParameter("original_subject_id");
            String subId = request.getParameter("subject_id");
            String subName = request.getParameter("subject_name");
            String sem = request.getParameter("sem");
            String year = request.getParameter("year");
            String dept = request.getParameter("dept");
            String fid = request.getParameter("faculty");

            PreparedStatement updateStmt = conn.prepareStatement(
                "UPDATE subjects SET subject_id=?, subject_name=?, sem=?, year=?, dept=?, fid=? WHERE subject_id=?"
            );
            updateStmt.setString(1, subId);
            updateStmt.setString(2, subName);
            updateStmt.setString(3, sem);
            updateStmt.setString(4, year);
            updateStmt.setString(5, dept);
            updateStmt.setString(6, fid);
            updateStmt.setString(7, originalSubId);

            int rows = updateStmt.executeUpdate();
            if (rows > 0) {
                message = "Subject updated successfully.";
            } else {
                message = "Failed to update subject.";
            }
            updateStmt.close();
        }

        // Load faculty list (only from the same department)
        facStmt = conn.prepareStatement("SELECT faculty_id, faculty_name, faculty_department FROM faculty WHERE faculty_department = ?");
        facStmt.setString(1, hodDept);
        facultyRs = facStmt.executeQuery();
        List<String[]> facultyList = new ArrayList<>();
        while (facultyRs.next()) {
            facultyList.add(new String[]{
                facultyRs.getString("faculty_id"),
                facultyRs.getString("faculty_name"),
                facultyRs.getString("faculty_department")
            });
        }

        // Load subjects (Admin & HOD both see only their department)
        stmt = conn.prepareStatement("SELECT * FROM subjects WHERE dept = ?");
        stmt.setString(1, hodDept);
        rs = stmt.executeQuery();
%>

<html>
<head>
    <title>Update Subjects</title>
    <style>
        table {
            width: 95%;
            border-collapse: collapse;
            margin: 30px auto;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        input[type="text"], select {
            width: 100%;
            padding: 5px;
        }
        input[type="submit"], a.delete-button {
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
        }
        input[type="submit"] {
            background-color: #4CAF50;
        }
        a.delete-button {
            background-color: #f44336;
            text-decoration: none;
        }
        a.delete-button:hover {
            background-color: #d32f2f;
        }
        .nav-home {
            margin: 20px auto;
            text-align: center;
        }
        .nav-home a {
            background-color: #2196F3;
            padding: 10px 20px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .nav-home a:hover {
            background-color: #0b7dda;
        }
    </style>
</head>
<body>

<h2 style="text-align:center;">
    Update Subjects - Department: <%= hodDept.toUpperCase() %>
</h2>
<table>
    <tr>
        <th>Subject ID</th>
        <th>Subject Name</th>
        <th>Semester</th>
        <th>Year</th>
        <th>Department</th>
        <th>Faculty</th>
        <th>Actions</th>
    </tr>

<%
    while (rs.next()) {
        String subjectId = rs.getString("subject_id");
        String subjectName = rs.getString("subject_name");
        String sem = rs.getString("sem");
        String year = rs.getString("year");
        String dept = rs.getString("dept");
        String fid = rs.getString("fid");
%>
    <form method="post">
        <tr>
            <td>
                <input type="hidden" name="original_subject_id" value="<%= subjectId %>">
                <input type="text" name="subject_id" value="<%= subjectId %>"
                       <%= "Admin".equalsIgnoreCase(hodRole) ? "" : "readonly" %> >
            </td>
            <td><input type="text" name="subject_name" value="<%= subjectName %>"></td>
            <td><input type="text" name="sem" value="<%= sem %>"></td>
            <td><input type="text" name="year" value="<%= year %>"></td>
            <td>
                <input type="text" name="dept" value="<%= dept %>"
                       <%= "Admin".equalsIgnoreCase(hodRole) ? "" : "readonly" %> >
            </td>
            <td>
                <select name="faculty">
                    <option value="">-- Select Faculty --</option>
                    <% for (String[] faculty : facultyList) {
                        String optionValue = faculty[0];
                        String optionText = faculty[0] + " - " + faculty[1] + " (" + faculty[2].toUpperCase() + ")";
                        String selected = optionValue.equals(fid) ? "selected" : "";
                    %>
                        <option value="<%= optionValue %>" <%= selected %>><%= optionText %></option>
                    <% } %>
                </select>
            </td>
            <td style="white-space: nowrap;">
                <input type="submit" name="update" value="Update">
                <a href="updateSubjects.jsp?delete_id=<%= subjectId %>" 
                   class="delete-button" 
                   onclick="return confirm('Are you sure you want to delete this subject?');">Delete</a>
            </td>
        </tr>
    </form>
<%
    }
%>
</table>

<div class="nav-home">
    <a href="hodHomePage.jsp">Back to HOD Home</a>
</div>

<% if (!message.isEmpty()) { %>
<script>
    alert("<%= message %>");
</script>
<% } %>

<%
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (facultyRs != null) facultyRs.close(); } catch (Exception e) {}
        try { if (facStmt != null) facStmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

</body>
</html>
