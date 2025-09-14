<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>  
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%@ page session="true" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HOD / Admin Login</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f0f2f5; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .login-container { background: white; padding: 25px 30px; border-radius: 8px; box-shadow: 0 0 10px #aaa; width: 320px; }
        h2 { text-align: center; margin-bottom: 20px; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        input, select { width: 100%; padding: 8px 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; }
        input[type="submit"] { margin-top: 20px; background: #007bff; color: white; border: none; font-weight: bold; cursor: pointer; }
        input[type="submit"]:hover { background: #0056b3; }
        .error { margin-top: 15px; padding: 10px; background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; border-radius: 4px; text-align: center; font-weight: bold; }
        .info-text { font-size: 12px; color: #555; margin-top: 5px; }
    </style>
</head>
<body>

<div class="login-container">
    <h2>HOD / Admin Login</h2>
    <form method="post" action="hodLogin.jsp">
        <label for="hod_id">User ID:</label>
        <input type="text" name="hod_id" id="hod_id" required>

        <label for="hod_password">Password:</label>
        <input type="password" name="hod_password" id="hod_password" required>

        <label for="hod_department">Department:</label>
        <select name="hod_department" id="hod_department" required>
            <option value="">Select Department</option>
            <option value="MCA">MCA</option>
            <option value="MBA">MBA</option>
            <option value="MTech">MTech</option>
            <option value="CSE">CSE</option>
            <option value="ECE">ECE</option>
            <option value="EEE">EEE</option>
        </select>
        <p class="info-text">
            For Admins: Select the department you want to manage.<br>
            For HODs: Select your own department.
        </p>

        <input type="submit" value="Login">
    </form>

<%
    String hod_id = request.getParameter("hod_id");
    String hod_password = request.getParameter("hod_password");
    String hod_department = request.getParameter("hod_department");

    if (hod_id != null && hod_password != null && hod_department != null 
        && !hod_id.trim().isEmpty() && !hod_password.trim().isEmpty() && !hod_department.trim().isEmpty()) {
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = DBConnection.getConnection();

            // First check if it's an admin (only id & pass check, no dept)
            ps = con.prepareStatement(
                "SELECT faculty_name, faculty_designation FROM faculty " +
                "WHERE faculty_id = ? AND faculty_password = ? AND faculty_designation = 'Admin'"
            );
            ps.setString(1, hod_id);
            ps.setString(2, hod_password);
            rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("hod_id", hod_id);
                session.setAttribute("hod_department", hod_department); // Admin chooses dept from dropdown
                session.setAttribute("hod_name", rs.getString("faculty_name"));
                session.setAttribute("hod_designation", "Admin");
                response.sendRedirect("hodHomePage.jsp");
                return;
            }
            rs.close();
            ps.close();

            // Otherwise check if it's a HOD for that dept
            ps = con.prepareStatement(
                "SELECT faculty_name, faculty_designation FROM faculty " +
                "WHERE faculty_id = ? AND faculty_password = ? " +
                "AND faculty_department = ? AND faculty_designation = 'HOD'"
            );
            ps.setString(1, hod_id);
            ps.setString(2, hod_password);
            ps.setString(3, hod_department);
            
            rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("hod_id", hod_id);
                session.setAttribute("hod_department", hod_department);
                session.setAttribute("hod_name", rs.getString("faculty_name"));
                session.setAttribute("hod_designation", "HOD");
                response.sendRedirect("hodHomePage.jsp");
                return;
            } else {
%>
                <div class="error">Invalid credentials.</div>
<%
            }
        } catch (Exception e) {
%>
            <div class="error">Error: <%= e.getMessage() %></div>
<%
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (ps != null) ps.close(); } catch(Exception e) {}
            try { if (con != null) con.close(); } catch(Exception e) {}
        }
    }
%>

</div>

</body>
</html>
