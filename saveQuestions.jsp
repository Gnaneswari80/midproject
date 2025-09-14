<%@ page import="java.sql.*" %>
<%
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String subjectId = (String) session.getAttribute("subjectId");
    String batchYear = (String) session.getAttribute("batchYear");
    String mid= (String) session.getAttribute("mid");   
    String department = (String) session.getAttribute("department");

    String[] qFields = {
        "1a","1b","1c","1d",
        "2a","2b","2c","2d",
        
        "3a","3b","3c","3d",
        "4a","4b","4c","4d",
        "5a","5b","5c","5d",
        "6a","6b","6c","6d"
    };

    String url = "jdbc:mysql://localhost:3306/midmarks_db";
    String user = "root";
    String pass = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);

        // ---------- Levels ----------
        String checkSql = "SELECT COUNT(*) FROM questionlevels WHERE qlBatchYear=? AND qlSubjectId=? AND qlMid=? AND qlSem=? AND qlYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();

        boolean exists = false;
        if(rs.next() && rs.getInt(1) > 0) exists = true;
        rs.close(); ps.close();

        if(exists){
            StringBuilder sb = new StringBuilder("UPDATE questionlevels SET ");
            for(int i=0; i<qFields.length; i++){
                if(i > 0) sb.append(", ");
                sb.append("level_" + qFields[i] + "=?");
            }
            sb.append(" WHERE qlBatchYear=? AND qlSubjectId=? AND qlMid=? AND qlSem=? AND qlYear=?");

            ps = con.prepareStatement(sb.toString());

            int idx = 1;
            for(String f : qFields){
                ps.setString(idx++, request.getParameter("Level_" + f));
            }
            ps.setString(idx++, batchYear);
            ps.setString(idx++, subjectId);
            ps.setString(idx++, mid);
            ps.setString(idx++, sem);
            ps.setString(idx++, year);

            int updated = ps.executeUpdate();
           // out.println("<h3 style='color:blue'>Updated record for " + mid + "</h3>");
        } else {
            StringBuilder sb = new StringBuilder("INSERT INTO questionlevels (qlBatchYear, qlSubjectId, qlMid, qlSem, qlYear");
            for(String f : qFields){ sb.append(", level_" + f); }
            sb.append(") VALUES (?, ?, ?, ?, ?");
            for(int i=0; i<qFields.length; i++){ sb.append(", ?"); }
            sb.append(")");

            ps = con.prepareStatement(sb.toString());
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);

            int idx = 6;
            for(String f : qFields){
                ps.setString(idx++, request.getParameter("Level_" + f));
            }

            int inserted = ps.executeUpdate();
          //  out.println("<h3 style='color:green'>Inserted record for " + mid + "</h3>");
        }
        ps.close();

        // ---------- COs ----------
     // ---------- Save Question CO (only Q1–Q6) ----------
     // ---------- COs (Assignments + Objectives + Questions) ----------
        String[] coFields = {
            "co_obj_1","co_obj_2","co_obj_3",
            "co_ass_1","co_ass_2","co_ass_3",
            "co_1a","co_1b","co_1c","co_1d",
            "co_2a","co_2b","co_2c","co_2d",
            "co_3a","co_3b","co_3c","co_3d",
            "co_4a","co_4b","co_4c","co_4d",
            "co_5a","co_5b","co_5c","co_5d",
            "co_6a","co_6b","co_6c","co_6d"
        };

        checkSql = "SELECT COUNT(*) FROM questionco WHERE qcBatchYear=? AND qcSubjectId=? AND qcMid=? AND qcSem=? AND qcYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();
        exists = (rs.next() && rs.getInt(1) > 0);
        rs.close(); ps.close();

        if(exists){
            // UPDATE
            StringBuilder sb = new StringBuilder("UPDATE questionco SET ");
            for(int i=0; i<coFields.length; i++){
                if(i>0) sb.append(", ");
                sb.append(coFields[i] + "=?");
            }
            sb.append(" WHERE qcBatchYear=? AND qcSubjectId=? AND qcMid=? AND qcSem=? AND qcYear=?");
            
            ps = con.prepareStatement(sb.toString());
            int idx = 1;
            for(String f : coFields){
                ps.setString(idx++, request.getParameter(f));
            }
            ps.setString(idx++, batchYear);
            ps.setString(idx++, subjectId);
            ps.setString(idx++, mid);
            ps.setString(idx++, sem);
            ps.setString(idx++, year);

            ps.executeUpdate();
            ps.close();
           //out.println("<h3 style='color:blue'>Updated Question CO Mapping (Assignments/Objectives included)</h3>");
        } else {
            // INSERT
            StringBuilder sb = new StringBuilder("INSERT INTO questionco (qcBatchYear,qcSubjectId,qcMid,qcSem,qcYear");
            for(String f : coFields) sb.append(",").append(f);
            sb.append(") VALUES (?,?,?,?,?");
            for(int i=0; i<coFields.length; i++) sb.append(",?");
            sb.append(")");

            ps = con.prepareStatement(sb.toString());
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);
            int idx = 6;
            for(String f : coFields){
                ps.setString(idx++, request.getParameter(f));
            }

            ps.executeUpdate();
            ps.close();
          //  out.println("<h3 style='color:green'>Inserted Question CO Mapping (Assignments/Objectives included)</h3>");
        }

     // ---------- Save Max Marks (Obj + Ass) ----------
     // ---------- Save Max Marks (Obj + Ass + Question Parts) ----------
     // --- Handle questionmaxmarks (Assignments + Objectives + Each Question Max Marks) ---
        String[] numericFields = {
            "max_ass_1","max_ass_2","max_ass_3",
            "max_obj_1","max_obj_2","max_obj_3"
        };

        // also include per-question max marks
        String[] questions = {
            "1a","1b","1c","1d",
            "2a","2b","2c","2d",
            "3a","3b","3c","3d",
            "4a","4b","4c","4d",
            "5a","5b","5c","5d",
            "6a","6b","6c","6d"
        };

     // Check if record exists
         checkSql = "SELECT COUNT(*) FROM questionmaxmarks WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();
        exists = false;
        if(rs.next() && rs.getInt(1) > 0) exists = true;
        rs.close(); ps.close();

        if(exists){
            // UPDATE
            StringBuilder sb = new StringBuilder("UPDATE questionmaxmarks SET ");
            for(int i=0;i<numericFields.length;i++) sb.append(numericFields[i]).append("=?,");
            for(int i=0;i<questions.length;i++) sb.append("max_").append(questions[i]).append("=?,");
            sb.setLength(sb.length()-1); // remove last comma
            sb.append(" WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?");
            
            ps = con.prepareStatement(sb.toString());
            
            int idx = 1;
            // set values
            for(String f : numericFields){
                String val = request.getParameter(f);
                if(val==null || val.trim().isEmpty()) ps.setNull(idx++, java.sql.Types.INTEGER);
                else ps.setInt(idx++, Integer.parseInt(val));
            }
            for(String q : questions){
                String val = request.getParameter("max_"+q);
                if(val==null || val.trim().isEmpty()) ps.setNull(idx++, java.sql.Types.INTEGER);
                else ps.setInt(idx++, Integer.parseInt(val));
            }
            // where clause
            ps.setString(idx++, batchYear);
            ps.setString(idx++, subjectId);
            ps.setString(idx++, mid);
            ps.setString(idx++, sem);
            ps.setString(idx++, year);

            ps.executeUpdate();
            ps.close();
           // out.println("<h3 style='color:blue'>Max Marks updated successfully!</h3>");
        } else {
            // INSERT
            StringBuilder sb = new StringBuilder("INSERT INTO questionmaxmarks (qmmBatchYear,qmmSubjectId,qmmMid,qmmSem,qmmYear");
            for(String f: numericFields) sb.append(",").append(f);
            for(String q: questions) sb.append(",max_").append(q);
            sb.append(") VALUES (?,?,?,?,?");
            for(int i=0;i<numericFields.length+questions.length;i++) sb.append(",?");
            sb.append(")");

            ps = con.prepareStatement(sb.toString());
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);

            int idx=6;
            for(String f : numericFields){
                String val = request.getParameter(f);
                if(val==null || val.trim().isEmpty()) ps.setNull(idx++, java.sql.Types.INTEGER);
                else ps.setInt(idx++, Integer.parseInt(val));
            }
            for(String q : questions){
                String val = request.getParameter("max_"+q);
                if(val==null || val.trim().isEmpty()) ps.setNull(idx++, java.sql.Types.INTEGER);
                else ps.setInt(idx++, Integer.parseInt(val));
            }

            ps.executeUpdate();
            ps.close();
            //out.println("<h3 style='color:green'>Max Marks inserted successfully!</h3>");
        }

        
    } catch(Exception e){
        out.println("<h3 style='color:red'>Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e){}
        if(ps != null) try { ps.close(); } catch(Exception e){}
        if(con != null) try { con.close(); } catch(Exception e){}
    }
%>
<script type="text/javascript" >alert("saved successfully!");
window.location.href = "scheme.jsp"; </script>

