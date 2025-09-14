<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page session="true" %>

<%
    if (session == null || session.getAttribute("hod_department") == null) {
        response.sendRedirect("adminLogin.jsp"); // or wherever admin logs in
        return;
    }

    String dept = (String) session.getAttribute("hod_department");
    String currentHODId = null;
    String currentHODName = null;

    // Handle update request
    String newHODId = request.getParameter("new_hod_id");
    String message = null;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();

        // If form submitted, update HOD
        if (newHODId != null && !newHODId.trim().isEmpty()) {
            // Find current HOD
            ps = con.prepareStatement("SELECT faculty_id FROM faculty WHERE faculty_department=? AND faculty_designation='HOD'");
            ps.setString(1, dept);
            rs = ps.executeQuery();
            if (rs.next()) {
                currentHODId = rs.getString("faculty_id");
            }
            rs.close();
            ps.close();

            // Change old HOD to Faculty
            if (currentHODId != null) {
                ps = con.prepareStatement("UPDATE faculty SET faculty_designation='Faculty' WHERE faculty_id=?");
                ps.setString(1, currentHODId);
                ps.executeUpdate();
                ps.close();
            }

            // Set new HOD
            ps = con.prepareStatement("UPDATE faculty SET faculty_designation='HOD' WHERE faculty_id=?");
            ps.setString(1, newHODId);
            ps.executeUpdate();
            ps.close();

            message = "HOD updated successfully!";
        }

        // Get current HOD info
        ps = con.prepareStatement("SELECT faculty_id, faculty_name FROM faculty WHERE faculty_department=? AND faculty_designation='HOD'");
        ps.setString(1, dept);
        rs = ps.executeQuery();
        if (rs.next()) {
            currentHODId = rs.getString("faculty_id");
            currentHODName = rs.getString("faculty_name");
        }
        rs.close();
        ps.close();

    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View / Change HOD</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f0f2f5;
            display: flex;
            justify-content: center;
            padding: 40px;
        }
        .container {
            background: white;
            padding: 25px 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px #aaa;
            width: 400px;
        }
        h2 { text-align: center; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        select, input[type="submit"], button {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ccc;
            cursor: pointer;
            box-sizing: border-box;
            transition: background-color 0.3s ease, border-color 0.3s ease;
        }
        input[type="submit"]:hover, button:hover {
            background-color: #0056b3;
            color: white;
            border-color: #0056b3;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: white;
            border: none;
            font-weight: bold;
        }
        .success { color: green; text-align: center; margin-top: 15px; }
        .error { color: red; text-align: center; margin-top: 15px; }
        /* Back button specific style */
        form.back-form {
            margin-top: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>View / Change HOD</h2>
    <p><strong>Department:</strong> <%= dept %></p>
    <p><strong>Current HOD:</strong> <%= (currentHODName != null ? currentHODName + " (" + currentHODId + ")" : "None") %></p>

    <form method="post" action="">
        <label for="new_hod_id">Select New HOD:</label>
        <select name="new_hod_id" id="new_hod_id" required>
            <option value="">-- Select Faculty --</option>
            <%
                Connection con2 = null;
                PreparedStatement ps2 = null;
                ResultSet rs2 = null;
                try {
                    con2 = DBConnection.getConnection();
                    ps2 = con2.prepareStatement(
                        "SELECT faculty_id, faculty_name FROM faculty WHERE faculty_department=? AND faculty_designation!='HOD'"
                    );
                    ps2.setString(1, dept);
                    rs2 = ps2.executeQuery();
                    while (rs2.next()) {
                        String fid = rs2.getString("faculty_id");
                        String fname = rs2.getString("faculty_name");
            %>
                        <option value="<%= fid %>"><%= fname %> (<%= fid %>)</option>
            <%
                    }
                } catch (Exception e) {
            %>
                    <option disabled>Error loading faculty</option>
            <%
                } finally {
                    try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
                    try { if (ps2 != null) ps2.close(); } catch (Exception e) {}
                    try { if (con2 != null) con2.close(); } catch (Exception e) {}
                }
            %>
        </select>

        <input type="submit" value="Change HOD">
    </form>

    <% if (message != null) { %>
        <div class="<%= message.startsWith("Error") ? "error" : "success" %>"><%= message %></div>
    <% } %>

    <!-- Back button -->
    <form action="hodHomePage.jsp" method="get" class="back-form">
        <button type="submit">&larr; Back to Home</button>
    </form>
</div>

</body>
</html>
