<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String batchYear = (String) session.getAttribute("batchYear");
    String subjectId = (String) session.getAttribute("subjectId");
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String mid = (String) session.getAttribute("mid");
    String dept = (String) session.getAttribute("department"); // MCA/MBA

    String studentId = request.getParameter("sid");
    String method = request.getMethod();

    String url = "jdbc:mysql://localhost:3306/midmarks_db";
    String user = "root";
    String pass = "";

    Map<String,String> maxMap = new HashMap<>();
    Map<String,String> studentMarks = new HashMap<>();
    String studentName = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pass);

        // ---------- SAVE MARKS (when POST) ----------
        if("POST".equalsIgnoreCase(method) && studentId != null && !studentId.trim().equals("")) {
            String sname = request.getParameter("sname");

            // Collect marks_xxx params
            Enumeration<String> params = request.getParameterNames();
            Map<String,String> marksMap = new HashMap<>();
            while(params.hasMoreElements()){
                String p = params.nextElement();
                if(p.startsWith("marks_")){
                    String val = request.getParameter(p);
                    if(val == null || val.trim().equals("")) val = "0";
                    marksMap.put(p, val);
                }
            }

            // Check if student record exists
            PreparedStatement check = con.prepareStatement(
                "SELECT COUNT(*) FROM studentmidmarks WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?"
            );
            check.setString(1, studentId);
            check.setString(2, subjectId);
            check.setString(3, sem);
            check.setString(4, year);
            check.setString(5, batchYear);
            check.setString(6, dept);
            check.setString(7, mid);
            ResultSet rsCheck = check.executeQuery();
            rsCheck.next();
            boolean exists = rsCheck.getInt(1) > 0;
            rsCheck.close();
            check.close();

            if(exists){
                // Update
                StringBuilder sql = new StringBuilder("UPDATE studentmidmarks SET sname=?");
                for(String col : marksMap.keySet()){
                    sql.append(", ").append(col).append("=?");
                }
                sql.append(" WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?");

                PreparedStatement ps = con.prepareStatement(sql.toString());
                int idx = 1;
                ps.setString(idx++, sname);
                for(String col : marksMap.keySet()){
                    ps.setString(idx++, marksMap.get(col));
                }
                ps.setString(idx++, studentId);
                ps.setString(idx++, subjectId);
                ps.setString(idx++, sem);
                ps.setString(idx++, year);
                ps.setString(idx++, batchYear);
                ps.setString(idx++, dept);
                ps.setString(idx++, mid);
                ps.executeUpdate();
                ps.close();
            } else {
                // Insert
                StringBuilder cols = new StringBuilder("sid,sname,sub_id,student_sem,student_year,sbatch_year,smmDepartment,smmMid");
                StringBuilder vals = new StringBuilder("?,?,?,?,?,?,?,?");
                for(String col : marksMap.keySet()){
                    cols.append(", ").append(col);
                    vals.append(", ?");
                }
                PreparedStatement ps = con.prepareStatement("INSERT INTO studentmidmarks ("+cols+") VALUES ("+vals+")");
                int idx = 1;
                ps.setString(idx++, studentId);
                ps.setString(idx++, sname);
                ps.setString(idx++, subjectId);
                ps.setString(idx++, sem);
                ps.setString(idx++, year);
                ps.setString(idx++, batchYear);
                ps.setString(idx++, dept);
                ps.setString(idx++, mid);
                for(String col : marksMap.keySet()){
                    ps.setString(idx++, marksMap.get(col));
                }
                ps.executeUpdate();
                ps.close();
            }

            // After save, clear studentId so form is fresh for next student
            studentId = null;
        }

        // ---------- FETCH QUESTION PATTERN ----------
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM questionmaxmarks WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid=?"
        );
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, sem);
        ps.setString(4, year);
        ps.setString(5, mid);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            ResultSetMetaData md = rs.getMetaData();
            for(int i=1;i<=md.getColumnCount();i++){
                String col = md.getColumnName(i);
                String val = rs.getString(i);
                if(col.startsWith("max_") && val != null && !val.trim().equals("") && !val.equals("0")){
                    maxMap.put(col,val);
                }
            }
        }
        rs.close(); ps.close();

        // ---------- FETCH STUDENT DETAILS ----------
        if(studentId != null && !studentId.trim().equals("")){
            ps = con.prepareStatement("SELECT student_name FROM studentdetails WHERE student_id=?");
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            if(rs.next()){
                studentName = rs.getString("student_name");
            }
            rs.close(); ps.close();

            ps = con.prepareStatement(
                "SELECT * FROM studentmidmarks WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?"
            );
            ps.setString(1, studentId);
            ps.setString(2, subjectId);
            ps.setString(3, sem);
            ps.setString(4, year);
            ps.setString(5, batchYear);
            ps.setString(6, dept);
            ps.setString(7, mid);
            rs = ps.executeQuery();
            if(rs.next()){
                ResultSetMetaData md = rs.getMetaData();
                for(int i=1;i<=md.getColumnCount();i++){
                    String col = md.getColumnName(i);
                    String val = rs.getString(i);
                    if(col.startsWith("marks_")){
                        studentMarks.put(col,val);
                    }
                }
            }
            rs.close(); ps.close();
        }

        con.close();
    } catch(Exception e){
        out.println("<h3 style='color:red'>Error: "+e.getMessage()+"</h3>");
       // e.printStackTrace(out);
    }
%>

<html>
<head>
<title>Student Marks Entry</title>
<style>
body{font-family:Arial;background:#f5f6fa;}
form{background:#fff;padding:20px;margin:20px auto;width:90%;max-width:1000px;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,0.2);}
table{border-collapse:collapse;width:100%;}
th,td{border:1px solid #ccc;padding:8px;text-align:center;}
th{background:#007bff;color:#fff;}
</style>
</head>
<body>

<h2 align="center">Enter Student Marks</h2>

<form method="get" action="marksEntry.jsp">
  <label>Enter Student ID: </label>
  <input type="text" name="sid" value="<%= (studentId==null?"":studentId) %>">
  <button type="submit">Fetch</button>
</form>

<% if(studentId != null && !studentId.equals("")) { %>
<form method="post" action="marksEntry.jsp">
  <input type="hidden" name="sid" value="<%=studentId%>">
  <input type="hidden" name="sname" value="<%=studentName%>">

  <h3>Student: <%= studentName %> (ID: <%=studentId%>)</h3>
  <table>
    <tr><th>Question</th><th>Max Marks</th><th>Obtained</th></tr>
    <% for(String col : maxMap.keySet()) { 
         String q = col.replace("max_","");
         String obtained = studentMarks.get("marks_"+q);
    %>
      <tr>
        <td><%= q.toUpperCase() %></td>
        <td><%= maxMap.get(col) %></td>
        <td><input type="number" name="marks_<%=q%>" value="<%= (obtained==null?"":obtained) %>" min="0" max="<%= maxMap.get(col) %>"></td>
      </tr>
    <% } %>
  </table>
  <br>
  <button type="submit">Save / Next</button>
</form>
<% } %>

</body>
</html>

