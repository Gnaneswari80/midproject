<%@ page import="java.sql.*" %> 
<%@ page import="db.DBConnection" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Update Student Details</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 30px;
      background-color: #f4f4f9;
    }
    h2 { text-align: center; color: #333; }
    form { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: center; margin-bottom: 30px; }
    label { font-weight: bold; }
    input[type="text"], select { padding: 6px; width: 150px; }
    input[type="submit"], button { padding: 8px 15px; background-color: #007bff; border: none; color: white; cursor: pointer; border-radius: 5px; }
    input[type="submit"]:hover, button:hover { background-color: #0056b3; }
    table { width: 100%; border-collapse: collapse; background-color: white; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: #007bff; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .message { color: red; text-align: center; margin-top: 20px; }
  </style>
</head>
<body>

<h2>Update Student Details</h2>

<!-- Filter Form -->
<form method="post">
  <label>Batch Year:</label>
  <input type="text" name="batch_year" value="<%= request.getParameter("batch_year")==null?"":request.getParameter("batch_year") %>" required>

  <label>Year:</label>
  <select name="year" required>
    <option value="">Select</option>
    <% for(int y=1; y<=4; y++){ %>
      <option value="<%=y%>" <%= (""+y).equals(request.getParameter("year"))?"selected":"" %>><%=y%></option>
    <% } %>
  </select>

  <label>Semester:</label>
  <select name="sem">
    <option value="">All</option>
    <% for(int s=1; s<=8; s++){ %>
      <option value="<%=s%>" <%= (""+s).equals(request.getParameter("sem"))?"selected":"" %>><%=s%></option>
    <% } %>
  </select>

  <input type="submit" value="Fetch Students">
</form>

<%
  String dept = (String) session.getAttribute("hod_department");
  String role = (String) session.getAttribute("hod_designation"); // "Admin" or "HOD"
  String batch = request.getParameter("batch_year");
  String year  = request.getParameter("year");
  String sem   = request.getParameter("sem");
  String popupMsg = null;

  Connection conn = DBConnection.getConnection();

  if (request.getParameter("update") != null) {
    // Handle update
    String originalSid = request.getParameter("original_sid");
    String sid = request.getParameter("sid");
    String sname = request.getParameter("sname");
    String syear = request.getParameter("syear");
    String ssem = request.getParameter("ssem");
    String sbatch = request.getParameter("sbatch");
    String sdept = request.getParameter("sdept");

    PreparedStatement ups = conn.prepareStatement(
      "UPDATE studentdetails SET student_id=?, student_name=?, stu_year=?, stu_sem=?, stu_batchyear=?, student_department=? WHERE student_id=?"
    );
    ups.setString(1, sid);
    ups.setString(2, sname);
    ups.setString(3, syear);
    ups.setString(4, ssem);
    ups.setString(5, sbatch);
    ups.setString(6, sdept);
    ups.setString(7, originalSid);

    int updated = ups.executeUpdate();
    if(updated > 0){
        popupMsg = "Student ID " + sid + " updated successfully!";
    } else {
        popupMsg = "Update failed for Student ID " + sid;
    }
  }

  if (batch != null && year != null && dept != null) {
    String sql;
    if ("Admin".equalsIgnoreCase(role)) {
      sql = "SELECT * FROM studentdetails WHERE stu_batchyear=? AND stu_year=?";
    } else {
      sql = "SELECT * FROM studentdetails WHERE stu_batchyear=? AND stu_year=? AND student_department=?";
    }
    if (sem != null && !sem.isEmpty()) {
      sql += " AND stu_sem=?";
    }

    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setString(1, batch);
    ps.setString(2, year);
    if (!"Admin".equalsIgnoreCase(role)) {
      ps.setString(3, dept);
      if (sem != null && !sem.isEmpty()) ps.setString(4, sem);
    } else {
      if (sem != null && !sem.isEmpty()) ps.setString(3, sem);
    }
    ResultSet rs = ps.executeQuery();

    boolean any = false;
%>
    <table>
      <tr>
        <th>ID</th><th>Name</th><th>Sem</th><th>Year</th><th>Batch</th><th>Dept</th><th>Action</th>
      </tr>
<%
    while (rs.next()) {
      any = true;
%>
      <tr>
        <form method="post">
          <td>
            <input type="hidden" name="original_sid" value="<%= rs.getString("student_id") %>">
            <input type="text" name="sid" value="<%= rs.getString("student_id") %>" 
              <%= "Admin".equalsIgnoreCase(role) ? "" : "readonly" %> >
          </td>
          <td><input type="text" name="sname" value="<%= rs.getString("student_name") %>" required></td>
          <td><input type="text" name="ssem" value="<%= rs.getString("stu_sem") %>" required></td>
          <td><input type="text" name="syear" value="<%= rs.getString("stu_year") %>" required></td>
          <td><input type="text" name="sbatch" value="<%= rs.getString("stu_batchyear") %>" required></td>
          <td>
            <input type="text" name="sdept" value="<%= rs.getString("student_department") %>" 
              <%= "Admin".equalsIgnoreCase(role) ? "" : "readonly" %> >
          </td>
          <td>
            <input type="hidden" name="batch_year" value="<%= batch %>">
            <input type="hidden" name="year" value="<%= year %>">
            <input type="hidden" name="sem" value="<%= sem == null ? "" : sem %>">
            <input type="submit" name="update" value="Update">
          </td>
        </form>
      </tr>
<%
    }
    if (!any) {
%>
      <tr><td colspan="7" class="message">No students found.</td></tr>
<%
    }
    conn.close();
%>
    </table>
<%
  }

  // Show popup if message exists
  if (popupMsg != null) {
%>
<script>
    alert("<%= popupMsg %>");
    // Reload with the same filter
    window.location.href = "updateStudents.jsp?batch_year=<%= batch %>&year=<%= year %>&sem=<%= sem == null ? "" : sem %>";
</script>
<%
  }
%>

<br>
<form action="hodHomePage.jsp" method="get" style="text-align: center;">
  <input type="submit" value="Back to HOD Home">
</form>

</body>
</html>

