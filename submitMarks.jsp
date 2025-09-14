<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%! 
// Convert null/empty/invalid strings to integer safely
int safeParse(String s) {
    if(s == null || s.trim().isEmpty()) return 0;
    try { return Integer.parseInt(s.trim()); } catch(Exception e) { return 0; }
}
%>

    

<%
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String subjectId = (String) session.getAttribute("subjectId");
    String batchYear = (String) session.getAttribute("batchYear");
    String mid = (String) session.getAttribute("mid");
    String  department=(String) session.getAttribute("department");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    
    

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/midmarks_db","root",""
        );

        // Collect all level values from the form
        String[] levels = new String[12];
        for(int i=0; i<12; i++) {
            levels[i] = request.getParameter("level_" + i);
            if(levels[i] == null) levels[i] = "";
        }

        // Step 1: Check if row exists
        String checkSql = "SELECT * FROM questionlevels WHERE qlBatchYear=? AND qlSubjectId=? AND qlMid=? AND qlSem=? AND qlYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);

        rs = ps.executeQuery();

        if(rs.next()) {
            // Row exists → UPDATE
           String updateSql = "UPDATE questionlevels SET " +
                   "level_1a=?, level_1b=?, " +
                   "level_2a=?, level_2b=?, " +
                   "level_3a=?, level_3b=?, " +
                   "level_4a=?, level_4b=?, " +
                   "level_5a=?, level_5b=?, " +
                   "level_6a=?, level_6b=? " +   // <-- remove comma here
                   "WHERE qlBatchYear=? AND qlSubjectId=? AND qlMid=? AND qlSem=? AND qlYear=?";

            ps = con.prepareStatement(updateSql);
            int i=1;
            for(String lvl : levels) ps.setString(i++, lvl);

            ps.setString(i++, batchYear);
            ps.setString(i++, subjectId);
            ps.setString(i++, mid);
            ps.setString(i++, sem);
            ps.setString(i++, year);

            int n = ps.executeUpdate();
           // out.println("Level row updated successfully.");
        } else {
            // Row does not exist → INSERT
            String insertSql = "INSERT INTO questionlevels (qlBatchYear, qlSubjectId, qlMid, qlSem, qlYear, " +
                   "level_1a, level_1b, level_2a, level_2b, level_3a, level_3b, level_4a, level_4b, level_5a, level_5b, level_6a, level_6b) " +
                   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(insertSql);
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);

            for(int j=0; j<levels.length; j++) {
                ps.setString(6+j, levels[j]);
            }

            int n = ps.executeUpdate();
            
        }
        
        
        ////////////
        // --- CO Section ---
        String[] coValues = new String[18]; // 3 obj + 3 ass + 24 Q1a..6d
        for(int i=0; i<18; i++) {
            coValues[i] = request.getParameter("co_" + i);
            if(coValues[i] == null) coValues[i] = "";
        }

        // Step 1: Check if row exists
        checkSql = "SELECT * FROM questionco WHERE qcBatchYear=? AND qcSubjectId=? AND qcMid=? AND qcSem=? AND qcYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);

        rs = ps.executeQuery();

        if(rs.next()) {
            // Row exists → UPDATE
           String updateSql = "UPDATE questionco SET " +
    "co_obj_1=?, co_obj_2=?, co_obj_3=?, " +
    "co_ass_1=?, co_ass_2=?, co_ass_3=?, " +
    "co_1a=?, co_1b=?, co_2a=?, co_2b=?, co_3a=?, co_3b=?, co_4a=?, co_4b=?, co_5a=?, co_5b=?, co_6a=?, co_6b=? " +
    "WHERE qcBatchYear=? AND qcSubjectId=? AND qcMid=? AND qcSem=? AND qcYear=?";

            ps = con.prepareStatement(updateSql);
            int i=1;
            for(String val : coValues) ps.setString(i++, val);
            ps.setString(i++, batchYear);
            ps.setString(i++, subjectId);
            ps.setString(i++, mid);
            ps.setString(i++, sem);
            ps.setString(i++, year);

            ps.executeUpdate();
        } else {
            // Row does not exist → INSERT
           String insertSql = "INSERT INTO questionco (" +
    "qcBatchYear, qcSubjectId, qcMid, qcSem, qcYear, " +
    "co_obj_1, co_obj_2, co_obj_3, co_ass_1, co_ass_2, co_ass_3, " +
    "co_1a, co_1b, co_2a, co_2b, co_3a, co_3b, co_4a, co_4b, co_5a, co_5b, co_6a, co_6b" +
    ") VALUES (?,?,?,?,?, ?,?,?,?,?,?, ?,?,?,?,?,?, ?,?,?,?,?)";

            ps = con.prepareStatement(insertSql);
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);
            for(int j=0; j<coValues.length; j++) ps.setString(6+j, coValues[j]);

            ps.executeUpdate();
        } 
       ///////////////////////////
        // --- Collect max marks from form ---
        // Order: 3 obj, 3 ass, 24 question max (1a..6d)
        String[] maxMarks = new String[18];
        for(int i=0; i<18; i++){
            maxMarks[i] = request.getParameter("max_" + i);
            if(maxMarks[i]==null || maxMarks[i].equals("")) maxMarks[i] = "0"; // default 0
        }

        // --- Check if row exists ---
        checkSql = "SELECT * FROM questionmaxmarks WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();

        if(rs.next()){
            // Row exists → UPDATE
           String updateSql = "UPDATE questionmaxmarks SET " +
    "max_obj_1=?, max_obj_2=?, max_obj_3=?, " +
    "max_ass_1=?, max_ass_2=?, max_ass_3=?, " +
    "max_1a=?, max_1b=?, max_2a=?, max_2b=?, max_3a=?, max_3b=?, max_4a=?, max_4b=?, max_5a=?, max_5b=?, max_6a=?, max_6b=? " +
    "WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?";


            ps = con.prepareStatement(updateSql);
            int i=1;
            for(String val : maxMarks) ps.setString(i++, val);
            ps.setString(i++, batchYear);
            ps.setString(i++, subjectId);
            ps.setString(i++, mid);
            ps.setString(i++, sem);
            ps.setString(i++, year);

            ps.executeUpdate();
        } else {
            // Row does not exist → INSERT
            String placeholders = String.join(",", java.util.Collections.nCopies(30, "?"));
            String insertSql = "INSERT INTO questionmaxmarks (" +
            	    "qmmBatchyear, qmmSubjectId, qmmMid, qmmSem, qmmYear, " +
            	    "max_obj_1, max_obj_2, max_obj_3, max_ass_1, max_ass_2, max_ass_3, " +
            	    "max_1a, max_1b, max_2a, max_2b, max_3a, max_3b, max_4a, max_4b, max_5a, max_5b, max_6a, max_6b" +
            	    ") VALUES (?,?,?,?,?, ?,?,?,?,?,?, ?,?,?,?,?,?, ?,?,?,?,?)";


            ps = con.prepareStatement(insertSql);
            ps.setString(1, batchYear);
            ps.setString(2, subjectId);
            ps.setString(3, mid);
            ps.setString(4, sem);
            ps.setString(5, year);
            for(int j=0; j<maxMarks.length; j++) ps.setString(6+j, maxMarks[j]);

            ps.executeUpdate();
        }

        ////////////
     // Loop over submitted students
     // --- Collect student IDs from form ---
        Enumeration<String> params = request.getParameterNames();
        List<String> studentIds = new ArrayList<>();
        while(params.hasMoreElements()){
            String param = params.nextElement();
            if(param.startsWith("sid_")){
                studentIds.add(request.getParameter(param));
            }
        }

        // --- Columns to store ---
       String[] cols = {
    "marks_obj_1","marks_obj_2","marks_obj_3",
    "marks_ass_1","marks_ass_2","marks_ass_3",
    "marks_1a","marks_1b",
    "marks_2a","marks_2b",
    "marks_3a","marks_3b",
    "marks_4a","marks_4b",
    "marks_5a","marks_5b",
    "marks_6a","marks_6b"
};


        for(String sid : studentIds){
            String sname = request.getParameter("name_" + sid);

            // --- Check if student record exists ---
            ps = con.prepareStatement(
                "SELECT * FROM studentmidmarks WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?"
            );
            ps.setString(1, sid);
            ps.setString(2, subjectId);
            ps.setString(3, sem);
            ps.setString(4, year);
            ps.setString(5, batchYear);
            ps.setString(6, department);
            ps.setString(7, mid);
            rs = ps.executeQuery();

            if(rs.next()){
                // --- UPDATE existing record ---
                StringBuilder sql = new StringBuilder("UPDATE studentmidmarks SET ");
                for(String col: cols) sql.append(col).append("=?,");
                sql.deleteCharAt(sql.length()-1); // remove last comma
                sql.append(" WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?");

                PreparedStatement ups = con.prepareStatement(sql.toString());
                int idx = 1;
                for(String col: cols){
                    String val = request.getParameter(sid + "_" + col);
                    ups.setInt(idx++, safeParse(val));
                }

                ups.setString(idx++, sid);
                ups.setString(idx++, subjectId);
                ups.setString(idx++, sem);
                ups.setString(idx++, year);
                ups.setString(idx++, batchYear);
                ups.setString(idx++, department);
                ups.setString(idx++, mid);

                ups.executeUpdate();
                ups.close();
            } else {
                // --- INSERT new record ---
                StringBuilder sql = new StringBuilder("INSERT INTO studentmidmarks (sid, sname, sub_id, student_sem, student_year, sbatch_year, smmDepartment, smmMid");
                for(String col: cols) sql.append(",").append(col);
                sql.append(") VALUES (?,?,?,?,?,?,?,?");
                for(int i=0;i<cols.length;i++) sql.append(",?");
                sql.append(")");

                PreparedStatement ins = con.prepareStatement(sql.toString());
                int idx = 1;
                ins.setString(idx++, sid);
                ins.setString(idx++, sname);
                ins.setString(idx++, subjectId);
                ins.setString(idx++, sem);
                ins.setString(idx++, year);
                ins.setString(idx++, batchYear);
                ins.setString(idx++, department);
                ins.setString(idx++, mid);

                for(String col: cols){
                    String val = request.getParameter(sid + "_" + col);
                    ins.setInt(idx++, safeParse(val));
                }
                ins.executeUpdate();
                ins.close();
            }

            rs.close();
        }
        
    } catch(Exception e) {
        out.println("Error saving " + e.getMessage());
    } finally {
        try { if(rs!=null) rs.close(); } catch(Exception ex) {}
        try { if(ps!=null) ps.close(); } catch(Exception ex) {}
        try { if(con!=null) con.close(); } catch(Exception ex) {}
    }
%>


<script type="text/javascript" >alert("saved successfully!");
window.location.href = "enterMarks.jsp"; </script>
