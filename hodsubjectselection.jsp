<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Retrieve necessary session attributes
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String dep = (String) session.getAttribute("hod_department");

    if (sem == null || year == null || dep == null) {
%>
        <p style="color:red;">Please select semester, year, and department first.</p>
<%
        return;
    }

    // If subject is selected, save in session and redirect
    String selectedSubjectId = request.getParameter("selectedSubjectId");
    String selectedSubjectName = null;

    if (selectedSubjectId != null && !selectedSubjectId.trim().isEmpty()) {
        // Get subject name from hidden input corresponding to the selected subject
        selectedSubjectName = request.getParameter("subjectName_" + selectedSubjectId);

        session.setAttribute("selectedSubjectId", selectedSubjectId);
        session.setAttribute("selectedSubjectName", selectedSubjectName);

        response.sendRedirect("hodviewmarks.jsp");
        return; // Prevent further execution after redirect
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>HOD Subject Selection</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f8f9fa;
            position: relative;
        }
        h2 {
            color: #333;
        }
        form {
            margin-top: 20px;
        }
        button.subject-btn {
            margin: 5px;
            padding: 10px 25px;
            font-size: 1rem;
            cursor: pointer;
            border: none;
            border-radius: 5px;
            background-color: #007bff;
            color: white;
            transition: background-color 0.3s ease;
        }
        button.subject-btn:hover {
            background-color: #0056b3;
        }
        p.no-subjects {
            color: #555;
            font-style: italic;
        }
        /* Back button styling */
        button.back-btn {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 6px 12px;
            font-size: 14px;
            cursor: pointer;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }
        button.back-btn:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>

    <button class="back-btn" onclick="window.location.href='hodselection.jsp'">&larr; Back</button>

    <h2>Select Subject for Semester: <%= sem %>, Year: <%= year %>, Department: <%= dep.toUpperCase() %></h2>

<%
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/midmarks_db";
        String user = "root";
        String password = "";
        conn = DriverManager.getConnection(url, user, password);

        String sql = "SELECT subject_id, subject_name FROM subjects WHERE sem=? AND year=? AND dept=?";
        pst = conn.prepareStatement(sql);
        pst.setString(1, sem);
        pst.setString(2, year);
        pst.setString(3, dep);
        rs = pst.executeQuery();

        boolean found = false;
%>

<form method="post" action="hodsubjectselection.jsp">
    <%
        while (rs.next()) {
            found = true;
            String subjectId = rs.getString("subject_id");
            String subjectName = rs.getString("subject_name");
    %>
        <button type="submit" name="selectedSubjectId" value="<%= subjectId %>" class="subject-btn">
            <%= subjectName %> (<%= subjectId %>)
        </button>
        <input type="hidden" name="subjectName_<%= subjectId %>" value="<%= subjectName %>" />
    <%
        }

        if (!found) {
    %>
        <p class="no-subjects">No subjects found for the selected semester, year, and department.</p>
    <%
        }
    %>
</form>

<%
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (pst != null) pst.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>

</body>
</html>
