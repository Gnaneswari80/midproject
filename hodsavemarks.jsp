<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
String batchYear = (String) session.getAttribute("batchYear");
String subjectId = (String) session.getAttribute("selectedSubjectId");
String sem = (String) session.getAttribute("sem");
String year = (String) session.getAttribute("year");
String department = (String) session.getAttribute("hod_department");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;



//Assume students list and mids are already fetched
List<Map<String,String>> students = new ArrayList<>();
//String[] mids = {"mid1","mid2"};

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

    String[] mids = {"mid1", "mid2"};

    for(String mid : mids) {

        // 1️⃣ Check if record exists
        String checkSql = "SELECT COUNT(*) FROM questionco WHERE qcBatchYear=? AND qcSubjectId=? AND qcSem=? AND qcYear=? AND qcMid=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, sem);
        ps.setString(4, year);
        ps.setString(5, mid);

        rs = ps.executeQuery();
        boolean exists = false;
        if(rs.next()) exists = rs.getInt(1) > 0;
        rs.close();
        ps.close();

        if(exists) {
            // 2️⃣ UPDATE existing record
            StringBuilder updateSql = new StringBuilder("UPDATE questionco SET ");

            // 3 OBJ + 3 ASS + 6*4 Qs = 30 columns
            List<String> cols = new ArrayList<>();
            for(int i=1;i<=3;i++) cols.add("co_obj_" + i + "=?");
            for(int i=1;i<=3;i++) cols.add("co_ass_" + i + "=?");
            for(int q=1;q<=6;q++) {
                for(char sub='a'; sub<='d'; sub++) {
                    cols.add("co_" + q + sub + "=?");
                }
            }
            updateSql.append(String.join(",", cols));
            updateSql.append(" WHERE qcBatchYear=? AND qcSubjectId=? AND qcSem=? AND qcYear=? AND qcMid=?");

            ps = con.prepareStatement(updateSql.toString());
            int index = 1;

            // Set values from request
            for(int i=1;i<=3;i++) ps.setString(index++, request.getParameter(mid+"_obj1_co"+i));
            for(int i=1;i<=3;i++) ps.setString(index++, request.getParameter(mid+"_ass1_co"+i));
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='d';sub++){
                    ps.setString(index++, request.getParameter(mid+"_q"+q+sub+"_co"));
                }
            }
            // WHERE parameters
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            ps.executeUpdate();
            ps.close();
        } else {
            // 3️⃣ INSERT new record
            StringBuilder insertSql = new StringBuilder("INSERT INTO questionco (qcBatchYear, qcSubjectId, qcSem, qcYear, qcMid, ");
            List<String> colNames = new ArrayList<>();
            for(int i=1;i<=3;i++) colNames.add("co_obj_" + i);
            for(int i=1;i<=3;i++) colNames.add("co_ass_" + i);
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    colNames.add("co_" + q + sub);
                }
            }
            insertSql.append(String.join(",", colNames));
            insertSql.append(") VALUES (?,?,?,?,?");
            for(int i=0;i<colNames.size();i++) insertSql.append(",?");
            insertSql.append(")");

            ps = con.prepareStatement(insertSql.toString());
            int index = 1;

            // 5 identifier columns
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            // 30 CO columns
            for(int i=1;i<=3;i++) ps.setString(index++, request.getParameter(mid+"_obj1_co"+i));
            for(int i=1;i<=3;i++) ps.setString(index++, request.getParameter(mid+"_ass1_co"+i));
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    ps.setString(index++, request.getParameter(mid+"_q"+q+sub+"_co"));
                }
            }

            ps.executeUpdate();
            ps.close();
        }
    }

    out.println("<h3 style='color:green;'>CO marks saved/updated successfully!</h3>");
    
    
    
    
    ///////////////////////////////////
 // 1️⃣ Check if record exists
    //String[] mids = {"mid1", "mid2"};

    for(String mid : mids){

        // Check if record exists
        String checkSql = "SELECT COUNT(*) FROM questionlevels WHERE qlBatchYear=? AND qlSubjectId=? AND qlSem=? AND qlYear=? AND qlMid=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, sem);
        ps.setString(4, year);
        ps.setString(5, mid);
        rs = ps.executeQuery();
        boolean exists = false;
        if(rs.next()) exists = rs.getInt(1) > 0;
        rs.close();
        ps.close();

        if(exists){
            // UPDATE existing record
            StringBuilder updateSql = new StringBuilder("UPDATE questionlevels SET ");
            List<String> cols = new ArrayList<>();
            for(int q=1; q<=6; q++){
                for(char sub='a'; sub<='b'; sub++){
                    cols.add("level_" + q + sub + "=?");
                }
            }
            updateSql.append(String.join(",", cols));
            updateSql.append(" WHERE qlBatchYear=? AND qlSubjectId=? AND qlSem=? AND qlYear=? AND qlMid=?");

            ps = con.prepareStatement(updateSql.toString());
            int index = 1;

            // Set level values from request
            for(int q=1; q<=6; q++){
                for(char sub='a'; sub<='b'; sub++){
                    String param = mid + "_q" + q + sub + "_level";
                    String val = request.getParameter(param);
                    if(val == null) val = "0";
                    ps.setString(index++, val);
                }
            }

            // WHERE parameters
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            ps.executeUpdate();
            ps.close();

        } else {
            // INSERT new record
            StringBuilder insertSql = new StringBuilder("INSERT INTO questionlevels (qlBatchYear, qlSubjectId, qlSem, qlYear, qlMid, ");
            List<String> colNames = new ArrayList<>();
            for(int q=1; q<=6; q++){
                for(char sub='a'; sub<='b'; sub++){
                    colNames.add("level_" + q + sub);
                }
            }
            insertSql.append(String.join(",", colNames));
            insertSql.append(") VALUES (?,?,?,?,?");
            for(int i=0;i<colNames.size();i++) insertSql.append(",?");
            insertSql.append(")");

            ps = con.prepareStatement(insertSql.toString());
            int index = 1;

            // 5 identifier columns
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            // Set level values from request
            for(int q=1; q<=6; q++){
                for(char sub='a'; sub<='b'; sub++){
                    String param = mid + "_q" + q + sub + "_level";
                    String val = request.getParameter(param);
                    if(val == null) val = "0";
                    ps.setString(index++, val);
                }
            }

            ps.executeUpdate();
            ps.close();
        }
    }
    out.println("<h3 style='color:green;'>Level marks saved/updated successfully!</h3>");

///////////////////////////////////
    //String[] mids = {"mid1", "mid2"};

    for(String mid : mids){

        // 1️⃣ Check if record exists
        String checkSql = "SELECT COUNT(*) FROM questionmaxmarks WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid=?";
        ps = con.prepareStatement(checkSql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, sem);
        ps.setString(4, year);
        ps.setString(5, mid);

        rs = ps.executeQuery();
        boolean exists = false;
        if(rs.next()) exists = rs.getInt(1) > 0;
        rs.close();
        ps.close();

        if(exists){
            // 2️⃣ UPDATE existing record
            StringBuilder updateSql = new StringBuilder("UPDATE questionmaxmarks SET ");

            List<String> cols = new ArrayList<>();
            for(int i=1;i<=3;i++) cols.add("max_obj_" + i + "=?");
            for(int i=1;i<=3;i++) cols.add("max_ass_" + i + "=?");
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    cols.add("max_" + q + sub + "=?");
                }
            }
            updateSql.append(String.join(",", cols));
            updateSql.append(" WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid=?");

            ps = con.prepareStatement(updateSql.toString());
            int index = 1;

            // Set OBJ max
            for(int i=1;i<=3;i++){
                String val = request.getParameter(mid+"_obj1_max"+i);
                if(val == null || val.trim().isEmpty()) val = "0";
                ps.setInt(index++, Integer.parseInt(val));
            }

            // Set ASS max
            for(int i=1;i<=3;i++){
                String val = request.getParameter(mid+"_ass1_max"+i);
                if(val == null || val.trim().isEmpty()) val = "0";
                ps.setInt(index++, Integer.parseInt(val));
            }

            // Set Q1–Q6 max marks
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    String param = mid+"_q"+q+sub+"_max";
                    String val = request.getParameter(param);
                    if(val == null || val.trim().isEmpty()) val = "0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
            }

            // WHERE parameters
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            ps.executeUpdate();
            ps.close();
        } else {
            // 3️⃣ INSERT new record
            StringBuilder insertSql = new StringBuilder("INSERT INTO questionmaxmarks (qmmBatchYear,qmmSubjectId,qmmSem,qmmYear,qmmMid,");
            List<String> colNames = new ArrayList<>();
            for(int i=1;i<=3;i++) colNames.add("max_obj_" + i);
            for(int i=1;i<=3;i++) colNames.add("max_ass_" + i);
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    colNames.add("max_" + q + sub);
                }
            }
            insertSql.append(String.join(",", colNames));
            insertSql.append(") VALUES (?,?,?,?,?");
            for(int i=0;i<colNames.size();i++) insertSql.append(",?");
            insertSql.append(")");

            ps = con.prepareStatement(insertSql.toString());
            int index = 1;

            // Identifier columns
            ps.setString(index++, batchYear);
            ps.setString(index++, subjectId);
            ps.setString(index++, sem);
            ps.setString(index++, year);
            ps.setString(index++, mid);

            // Set max values (OBJ, ASS, Questions)
            for(int i=1;i<=3;i++){
                String val = request.getParameter(mid+"_obj1_max"+i);
                if(val == null || val.trim().isEmpty()) val = "0";
                ps.setInt(index++, Integer.parseInt(val));
            }
            for(int i=1;i<=3;i++){
                String val = request.getParameter(mid+"_ass1_max"+i);
                if(val == null || val.trim().isEmpty()) val = "0";
                ps.setInt(index++, Integer.parseInt(val));
            }
            for(int q=1;q<=6;q++){
                for(char sub='a';sub<='b';sub++){
                    String param = mid+"_q"+q+sub+"_max";
                    String val = request.getParameter(param);
                    if(val == null || val.trim().isEmpty()) val = "0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
            }

            ps.executeUpdate();
            ps.close();
        }
    }

    out.println("<h3 style='color:green;'>Max marks saved/updated successfully!</h3>");
///////////////////////////////////////////

    // 1️⃣ Fetch all students
 // 1️⃣ Fetch students
    String sqlStudents = "SELECT * FROM studentdetails WHERE student_department=? AND stu_sem=? AND stu_year=? AND stu_batchyear=?";
    ps = con.prepareStatement(sqlStudents);
    ps.setString(1, department);
    ps.setString(2, sem);
    ps.setString(3, year);
    ps.setString(4, batchYear);
    rs = ps.executeQuery();
    while(rs.next()) {
        Map<String,String> stu = new HashMap<>();
        stu.put("student_id", rs.getString("student_id"));
        stu.put("student_name", rs.getString("student_name"));
        students.add(stu);
    }
    rs.close();
    ps.close();

    for(String mid : mids){
        for(Map<String,String> stu : students){
            String sid = stu.get("student_id");

            // 1️⃣ Check if record exists
            String checkSql = "SELECT COUNT(*) FROM studentmidmarks WHERE sid=? AND smmMid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=?";
            ps = con.prepareStatement(checkSql);
            ps.setString(1, sid);
            ps.setString(2, mid);
            ps.setString(3, subjectId);
            ps.setString(4, sem);
            ps.setString(5, year);
            ps.setString(6, batchYear);
            rs = ps.executeQuery();
            boolean exists = false;
            if(rs.next()) exists = rs.getInt(1) > 0;
            rs.close();
            ps.close();

            if(exists){
                // 2️⃣ UPDATE
                StringBuilder updateSql = new StringBuilder("UPDATE studentmidmarks SET ");

                List<String> cols = new ArrayList<>();
                for(int i=1;i<=3;i++) cols.add("marks_obj_" + i + "=?");
                for(int i=1;i<=3;i++) cols.add("marks_ass_" + i + "=?");
                for(int q=1;q<=6;q++){
                    for(char sub='a';sub<='b';sub++){
                        cols.add("marks_" + q + sub + "=?");
                    }
                }
                updateSql.append(String.join(",", cols));
                updateSql.append(" WHERE sid=? AND smmMid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=?");

                ps = con.prepareStatement(updateSql.toString());
                int index = 1;

                // Set OBJ
                for(int i=1;i<=3;i++){
                    String val = request.getParameter(mid+"_obj"+i+"_"+sid);
                    if(val==null || val.trim().isEmpty()) val="0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
                // Set ASS
                for(int i=1;i<=3;i++){
                    String val = request.getParameter(mid+"_ass"+i+"_"+sid);
                    if(val==null || val.trim().isEmpty()) val="0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
                // Set Questions
                for(int q=1;q<=6;q++){
                    for(char sub='a';sub<='b';sub++){
                        String param = mid+"_q"+q+sub+"_"+sid;
                        String val = request.getParameter(param);
                        if(val==null || val.trim().isEmpty()) val="0";
                        ps.setInt(index++, Integer.parseInt(val));
                    }
                }

                // WHERE
                ps.setString(index++, sid);
                ps.setString(index++, mid);
                ps.setString(index++, subjectId);
                ps.setString(index++, sem);
                ps.setString(index++, year);
                ps.setString(index++, batchYear);

                ps.executeUpdate();
                ps.close();
            } else {
                // 3️⃣ INSERT
                StringBuilder insertSql = new StringBuilder("INSERT INTO studentmidmarks (sid, sname, sub_id, student_sem, student_year, sbatch_year, smmDepartment, smmMid, ");
                List<String> cols = new ArrayList<>();
                for(int i=1;i<=3;i++) cols.add("marks_obj_" + i);
                for(int i=1;i<=3;i++) cols.add("marks_ass_" + i);
                for(int q=1;q<=6;q++){
                    for(char sub='a';sub<='b';sub++){
                        cols.add("marks_" + q + sub);
                    }
                }
                insertSql.append(String.join(",", cols));
                insertSql.append(") VALUES (?,?,?,?,?,?,?,?");
                for(int i=0;i<cols.size();i++) insertSql.append(",?");
                insertSql.append(")");

                ps = con.prepareStatement(insertSql.toString());
                int index = 1;

                // Identifier columns
                ps.setString(index++, sid);
                ps.setString(index++, stu.get("student_name")); // sname
                ps.setString(index++, subjectId); // sub_id
                ps.setString(index++, sem);
                ps.setString(index++, year);
                ps.setString(index++, batchYear);
                ps.setString(index++, department);
                ps.setString(index++, mid);

                // OBJ
                for(int i=1;i<=3;i++){
                    String val = request.getParameter(mid+"_obj"+i+"_"+sid);
                    if(val==null || val.trim().isEmpty()) val="0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
                // ASS
                for(int i=1;i<=3;i++){
                    String val = request.getParameter(mid+"_ass"+i+"_"+sid);
                    if(val==null || val.trim().isEmpty()) val="0";
                    ps.setInt(index++, Integer.parseInt(val));
                }
                // Questions
                for(int q=1;q<=6;q++){
                    for(char sub='a';sub<='b';sub++){
                        String param = mid+"_q"+q+sub+"_"+sid;
                        String val = request.getParameter(param);
                        if(val==null || val.trim().isEmpty()) val="0";
                        ps.setInt(index++, Integer.parseInt(val));
                    }
                }

                ps.executeUpdate();
                ps.close();
            }
        }
    }

    out.println("<h3 style='color:green;'>All student marks saved/updated successfully!</h3>");



} catch(Exception e) {
    out.println("<h3 style='color:red;'>Error saving CO marks: " + e + "</h3>");
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(ps != null) try { ps.close(); } catch(Exception e) {}
    if(con != null) try { con.close(); } catch(Exception e) {}
}
%>

<!-- Back button -->
<form action="hodviewmarks.jsp" method="get" style="display:inline;">
    <input type="submit" value="Back" />
</form>

