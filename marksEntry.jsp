<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // --- Session variables ---
    String batchYear = (String) session.getAttribute("batchYear");
    String subjectId = (String) session.getAttribute("subjectId");
    String subject_name = (String) session.getAttribute("subject_name");
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String mid = (String) session.getAttribute("mid");
    String dept = (String) session.getAttribute("department"); // MCA/MBA

    // --- Database connection ---
    String url = "jdbc:mysql://localhost:3306/midmarks_db";
    String user = "root";
    String pass = "";

    int Totalsum=0;

    // --- Request parameters ---
    boolean studentExists = false;  // flag
    String studentId = request.getParameter("sid");
    if(studentId != null && studentId.trim().equals("")) studentId = null;

    String action = request.getParameter("action");  // "save" or null
    String direction = request.getParameter("direction"); // "next" or "prev"
    if(direction == null) direction = "next";

    String studentName = "";
    Map<String,String> maxMap = new LinkedHashMap<>();
    Map<String,String> studentMarks = new HashMap<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(url, user, pass);

        // --- Load question max marks ---
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
            for(int i=1; i<=md.getColumnCount(); i++){
                String col = md.getColumnName(i);
                String val = rs.getString(i);
                if(col.startsWith("max_") && val != null && !val.equals("0")){
                    maxMap.put(col, val);
                }
            }
        }
        rs.close(); ps.close();

        // --- Save marks if form submitted ---
        if("save".equals(action) && studentId != null && !studentId.trim().equals("")){
            StringBuilder updateCols = new StringBuilder();
            StringBuilder insertCols = new StringBuilder();
            StringBuilder insertVals = new StringBuilder();

            boolean isAbsent = request.getParameter("absent") != null;

            for(String col : maxMap.keySet()){
                String q = col.replace("max_", "");
                String obtained;

                if(isAbsent){
                    obtained = "-1";   // absent → save -1
                } else {
                    obtained = request.getParameter("marks_" + q);
                    if(obtained == null || obtained.trim().equals("")) obtained = "0";
                }

                updateCols.append(col.replace("max_", "marks_") + "='" + obtained + "',");
                insertCols.append(col.replace("max_", "marks_") + ",");
                insertVals.append("'" + obtained + "',");
            }

            if(updateCols.length() > 0) updateCols.setLength(updateCols.length()-1);
            if(insertCols.length() > 0) insertCols.setLength(insertCols.length()-1);
            if(insertVals.length() > 0) insertVals.setLength(insertVals.length()-1);

            PreparedStatement check = con.prepareStatement(
                "SELECT sid FROM studentmidmarks WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?"
            );
            check.setString(1, studentId);
            check.setString(2, subjectId);
            check.setString(3, sem);
            check.setString(4, year);
            check.setString(5, batchYear);
            check.setString(6, dept);
            check.setString(7, mid);
            ResultSet rsCheck = check.executeQuery();

            if(rsCheck.next()){
                PreparedStatement psUpdate = con.prepareStatement(
                    "UPDATE studentmidmarks SET " + updateCols.toString() +
                    " WHERE sid=? AND sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmDepartment=? AND smmMid=?"
                );
                psUpdate.setString(1, studentId);
                psUpdate.setString(2, subjectId);
                psUpdate.setString(3, sem);
                psUpdate.setString(4, year);
                psUpdate.setString(5, batchYear);
                psUpdate.setString(6, dept);
                psUpdate.setString(7, mid);
                psUpdate.executeUpdate();
                psUpdate.close();
            } else {
                Statement stInsert = con.createStatement();
                stInsert.executeUpdate(
                    "INSERT INTO studentmidmarks (sid, sname, sub_id, student_sem, student_year, sbatch_year, smmDepartment, smmMid, "+insertCols.toString()+") " +
                    "VALUES ('"+studentId+"',(SELECT student_name FROM studentdetails WHERE student_id='"+studentId+"'),'"+subjectId+"','"+sem+"','"+year+"','"+batchYear+"','"+dept+"','"+mid+"',"+insertVals.toString()+")"
                );
                stInsert.close();
            }
            rsCheck.close(); check.close();
        }

        // --- Determine which student to load ---
        if(studentId == null || "save".equals(action)){
            String op = (direction.equals("prev") ? "DESC" : "ASC");
            ps = con.prepareStatement(
                "SELECT student_id, student_name FROM studentdetails " +
                "WHERE stu_sem=? AND stu_year=? AND stu_batchyear=? AND student_department=? " +
                (studentId != null ? "AND student_id" + (direction.equals("prev")?"<":" >") + "? " : "") +
                "ORDER BY student_id " + op + " LIMIT 1"
            );
            ps.setString(1, sem);
            ps.setString(2, year);
            ps.setString(3, batchYear);
            ps.setString(4, dept);
            if(studentId != null) ps.setString(5, studentId);
            rs = ps.executeQuery();
            if(rs.next()){
                studentId = rs.getString("student_id");
                studentName = rs.getString("student_name");
            } else {
                // Circular: fetch first/last student
                ps.close();
                ps = con.prepareStatement(
                    "SELECT student_id, student_name FROM studentdetails " +
                    "WHERE stu_sem=? AND stu_year=? AND stu_batchyear=? AND student_department=? " +
                    "ORDER BY student_id " + (direction.equals("prev")?"DESC":"ASC") + " LIMIT 1"
                );
                ps.setString(1, sem);
                ps.setString(2, year);
                ps.setString(3, batchYear);
                ps.setString(4, dept);
                rs = ps.executeQuery();
                if(rs.next()){
                    studentId = rs.getString("student_id");
                    studentName = rs.getString("student_name");
                }
            }
            rs.close(); ps.close();
        }

        // --- Validate entered studentId ---
        if (studentId != null) {
            ps = con.prepareStatement("SELECT * FROM studentdetails WHERE student_id=?");
            ps.setString(1, studentId);
            rs = ps.executeQuery();
            if (rs.next()) {
                studentExists = true;
            }
            rs.close(); ps.close();
        }

        if (studentId != null && !studentExists) {
%>
<script>
    alert("Invalid Student ID");
</script>
<%
        }

        // --- Load marks for current student ---
        if(studentId != null && !studentId.trim().equals("")){
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
                    if(col.startsWith("marks_")) studentMarks.put(col, rs.getString(i));
                }
            }
            rs.close(); ps.close();
        }

        con.close();
    } catch(Exception e){
        out.println("<h3 style='color:red'>Error: "+e.getMessage()+"</h3>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Student Marks Entry</title>
<link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
<style>
/* --- Your existing CSS from previous code (for table, card, inputs, buttons, colors) --- */
body { font-family: 'Roboto', sans-serif; background:#e9ecef; margin:0; padding:0;}
.container { max-width:1100px; margin:30px auto; padding:20px;}
.card { background:#fff; border-radius:12px; padding:30px; box-shadow:0 6px 20px rgba(0,0,0,0.1);}
h2{text-align:center;color:#007bff;margin-bottom:30px;}
input[type=text], input[type=number]{padding:6px 10px; border-radius:5px; border:1px solid #ccc; width:100%; box-sizing:border-box;}
button{padding:10px 20px; border-radius:6px; cursor:pointer; font-weight:bold; border:none; transition:0.3s;}
button:hover{opacity:0.85;}
.prev-btn{background:#f0ad4e;color:#fff;}
.next-btn{background:#28a745;color:#fff;}
.back-btn{background:#dc3545;color:#fff;}
table{width:100%;border-collapse:collapse;margin-top:20px;overflow-x:auto;}
th,td{border:1px solid #dee2e6;padding:10px;text-align:center;}
th{background:linear-gradient(90deg,#007bff,#00c0ff);color:#fff;}
tr:nth-child(even){background:#f8f9fa;}
tr:hover{background:#e2f0ff;}
.qpair1{background:#0056b3 !important;color:#fff;font-weight:bold;}
.qpair2{background:#c82333 !important;color:#fff;font-weight:bold;}
.qpair3{background:#218838 !important;color:#fff;font-weight:bold;}
.considered{background:#ffc107 !important;color:#000;font-weight:bold;text-align:center;}
input:focus{border-color:#007bff;outline:none;}
.form-group{display:flex;align-items:center;margin-bottom:15px;gap:10px;}
label{width:150px;font-weight:bold;}
</style>

<script>
function copyObj(val){document.getElementById("obj2").value=val; document.getElementById("obj3").value=val;}
function copyAss(val){document.getElementById("ass2").value=val; document.getElementById("ass3").value=val;}

function toggleAbsent(checkbox){
    const isAbsent = checkbox.checked;
    const marksInputs = document.querySelectorAll("input.marks");
    marksInputs.forEach(inp=>{
        if(!inp.hasAttribute("data-prev")) inp.setAttribute("data-prev", inp.value);
        if(isAbsent){ inp.value=-1; inp.disabled=true; }
        else{ inp.disabled=false; inp.value=(inp.getAttribute("data-prev")==="-1")?"0":inp.getAttribute("data-prev"); }
    });
    recalcTotal();
}

function recalcTotal(){
    let totalSum=0;
    const pairs=[[1,2],[3,4],[5,6]];
    pairs.forEach(pair=>{
        const q1=pair[0], q2=pair[1]; let sum1=0,sum2=0;
        document.querySelectorAll("input[data-main='"+q1+"']").forEach(inp=>{
            let val = parseInt(inp.value || "0");
            let max = parseInt(inp.max || "0");
            if(val > max) inp.value = max; // Prevent exceeding max
            sum1 += parseInt(inp.value || "0");
        });
        document.querySelectorAll("input[data-main='"+q2+"']").forEach(inp=>{
            let val = parseInt(inp.value || "0");
            let max = parseInt(inp.max || "0");
            if(val > max) inp.value = max; // Prevent exceeding max
            sum2 += parseInt(inp.value || "0");
        });
        totalSum += (sum1 >= sum2 ? sum1 : sum2);
        const td = document.getElementById('considered_'+q1);
        if(td){
            const absentCheck=document.getElementById('absentCheck');
            td.textContent=(absentCheck && absentCheck.checked)?"-1":(sum1>=sum2?q1:q2);
        }
    });
    const totalSpan=document.getElementById("totalMarks");
    const absentCheck=document.getElementById('absentCheck');
    totalSpan.innerText=(absentCheck && absentCheck.checked)?"ABSENT":totalSum;
}

// Add real-time max validation to all marks inputs
document.addEventListener("DOMContentLoaded",function(){
    recalcTotal();
    document.querySelectorAll("input.marks").forEach(inp=>{
        inp.addEventListener("input", function(){
            let val = parseInt(this.value || "0");
            let max = parseInt(this.max || "0");
            if(val > max) this.value = max; // enforce max
            recalcTotal();
        });
    });
});

document.addEventListener("DOMContentLoaded",function(){
    recalcTotal();
    document.querySelectorAll("input.marks").forEach(inp=>{
        if(!inp.hasAttribute("data-prev")) inp.setAttribute("data-prev", inp.value);
        inp.addEventListener("input",function(){ inp.setAttribute("data-prev", inp.value); recalcTotal(); });
    });
    const absentCheck=document.getElementById('absentCheck');
    if(absentCheck&&absentCheck.checked) toggleAbsent(absentCheck);
});
</script>
</head>
<body>
<div class="container">
<div class="card">
<h2>Enter Student Marks</h2>


<!-- Display session values -->
<div style="width:95%; max-width:1200px; margin:10px auto; 
            background:#e3f2fd; padding:15px; border-radius:10px; 
            font-size:16px; line-height:1.8; color:#333; 
            box-shadow:0 2px 8px rgba(0,0,0,0.15);">
    <b>Semester:</b> <%= sem %> &nbsp;&nbsp; 
    <b>Year:</b> <%= year %> &nbsp;&nbsp; 
    <b>Subject ID:</b> <%= subjectId %> &nbsp;&nbsp; 
    <b>Subject Name:</b><%=subject_name %>&nbsp;&nbsp;
    <b>Batch Year:</b> <%= batchYear %> &nbsp;&nbsp; 
    <b>Mid:</b> <%= mid %>
</div>

<form method="get" action="marksEntry.jsp">
    <div class="form-group">
        <label>Enter Student ID:</label>
        <input type="text" name="sid" value="<%= (studentId==null?"":studentId) %>">
        <button type="submit">Fetch</button>
    </div>
</form>

<% if(studentId != null) { %>
<form method="post" action="marksEntry.jsp">
<input type="hidden" name="action" value="save">
<input type="hidden" name="sid" value="<%=studentId%>">
<input type="hidden" name="direction" id="direction" value="next">

<h3>Student: <%= studentName %> (ID: <%=studentId%>)</h3>

<label style="display:block; margin:10px 0; font-weight:bold; color:#d63384;">
    <input type="checkbox" id="absentCheck" name="absent"
        <%= studentMarks.containsValue("-1") ? "checked" : "" %>
        onchange="toggleAbsent(this)">
    Mark as Absent
</label>

<table>
<tr>
<th>Question</th><th>Max Marks</th><th>Obtained</th><th>Question</th><th>Max Marks</th><th>Obtained</th><th>Considered Question</th>
</tr>

<tr>
<td>OBJ</td>
<td><%= maxMap.getOrDefault("max_obj_1","0") %></td>
<td>
<%
String objVal1=studentMarks.getOrDefault("marks_obj_1","0");
String objVal2=studentMarks.getOrDefault("marks_obj_2","0");
String objVal3=studentMarks.getOrDefault("marks_obj_3","0");
%>
<input type="number" id="obj1" name="marks_obj_1" value="<%= objVal1 %>" data-original="<%= objVal1 %>" min="0" max="<%= maxMap.getOrDefault("max_obj_1","0") %>" oninput="copyObj(this.value)" class="marks">
<input type="hidden" id="obj2" name="marks_obj_2" value="<%= objVal2 %>" data-original="<%= objVal2 %>">
<input type="hidden" id="obj3" name="marks_obj_3" value="<%= objVal3 %>" data-original="<%= objVal3 %>">
</td>
</tr>

<tr>
<td>ASS</td>
<td><%= maxMap.getOrDefault("max_ass_1","0") %></td>
<td>
<%
String assVal1=studentMarks.getOrDefault("marks_ass_1","0");
String assVal2=studentMarks.getOrDefault("marks_ass_2","0");
String assVal3=studentMarks.getOrDefault("marks_ass_3","0");
%>
<input type="number" id="ass1" name="marks_ass_1" value="<%= assVal1 %>" data-original="<%= assVal1 %>" min="0" max="<%= maxMap.getOrDefault("max_ass_1","0") %>" oninput="copyAss(this.value)" class="marks">
<input type="hidden" id="ass2" name="marks_ass_2" value="<%= assVal2 %>" data-original="<%= assVal2 %>">
<input type="hidden" id="ass3" name="marks_ass_3" value="<%= assVal3 %>" data-original="<%= assVal3 %>">
</td>
</tr>

<%-- Dynamically generate question rows --%>
<%
String[][] pairs={{"1","2"},{"3","4"},{"5","6"}};
String[] pairClasses={"qpair1","qpair2","qpair3"};
for(int p=0;p<pairs.length;p++){
    String[] pair=pairs[p]; String rowClass=pairClasses[p]; 
    String q1=pair[0]; String q2=pair[1];
    List<String> q1Cols=new ArrayList<>(); List<String> q2Cols=new ArrayList<>();
    for(String col:maxMap.keySet()){
        String q=col.replace("max_","");
        String mainNum=q.replaceAll("[a-zA-Z]$","");
        if(mainNum.equals(q1)) q1Cols.add(q);
        if(mainNum.equals(q2)) q2Cols.add(q);
    }
    if(q1Cols.isEmpty()&&q2Cols.isEmpty()) continue;
    int rowCount=Math.max(q1Cols.size(),q2Cols.size()); if(rowCount==0) rowCount=1;
    int sum1=0,sum2=0;
    for(String c:q1Cols) sum1+=Integer.parseInt(studentMarks.getOrDefault("marks_"+c,"0"));
    for(String c:q2Cols) sum2+=Integer.parseInt(studentMarks.getOrDefault("marks_"+c,"0"));
    String considered=(sum1>=sum2?q1:q2);
    if(sum1>=sum2) Totalsum+=sum1; else Totalsum+=sum2;
    for(int i=0;i<rowCount;i++){
        out.println("<tr class='"+rowClass+"'>");
        if(i<q1Cols.size()){ String val=studentMarks.getOrDefault("marks_"+q1Cols.get(i),"0");
        out.println("<td>"+q1Cols.get(i)+"</td><td>"+maxMap.get("max_"+q1Cols.get(i))+"</td><td><input type='number' class='marks' data-main='"+q1+"' name='marks_"+q1Cols.get(i)+"' value='"+val+"' data-original='"+val+"' min='0' max='"+maxMap.get("max_"+q1Cols.get(i))+"'></td>");}
        else out.println("<td></td><td></td><td></td>");
        if(i<q2Cols.size()){ String val=studentMarks.getOrDefault("marks_"+q2Cols.get(i),"0");
        out.println("<td>"+q2Cols.get(i)+"</td><td>"+maxMap.get("max_"+q2Cols.get(i))+"</td><td><input type='number' class='marks' data-main='"+q2+"' name='marks_"+q2Cols.get(i)+"' value='"+val+"' data-original='"+val+"' min='0' max='"+maxMap.get("max_"+q2Cols.get(i))+"'></td>");}
        else out.println("<td></td><td></td><td></td>");
        if(i==0) out.println("<td rowspan='"+rowCount+"' class='considered' id='considered_"+q1+"'>"+considered+"</td>");
        out.println("</tr>");
    }
}
%>

</table>

<h3 style="color:crimson; font-weight:bold; margin:15px 0; text-align:center;">
    <%= mid %> Mark: <span id="totalMarks"><%= studentMarks.containsValue("-1") ? "ABSENT" : Totalsum %></span>
</h3>

<div style="margin-top:20px; display:flex; justify-content:space-between;">
    <button type="submit" class="prev-btn" onclick="document.getElementById('direction').value='prev';">Previous</button>
    <button type="submit" class="next-btn" onclick="document.getElementById('direction').value='next';">Next</button>
</div>
</form>
<% } else { %>
<h3 style="color:green; text-align:center; margin-top:40px;">All students completed!</h3>
<% } %>

<form action="enterSingleStudentMarks.jsp" method="get" style="margin-top:30px; text-align:center;">
    <button type="submit" class="back-btn">&larr; Back</button>
</form>

</div>
</div>
</body>
</html>
