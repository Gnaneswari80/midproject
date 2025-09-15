 <%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Session variables
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
   
    String subject_name = (String) session.getAttribute("selectedSubjectName");
    String batchYear = (String) session.getAttribute("batchYear");
    String subjectId = (String) session.getAttribute("selectedSubjectId");
    String department = (String) session.getAttribute("hod_department");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Store levels for mid1 and mid2
    Map<String, String> mid1Levels = new HashMap<>();
    Map<String, String> mid2Levels = new HashMap<>();
 // Store COs for mid1 and mid2
    
    Map<String,String> mid1COs = new HashMap<String,String>();
       Map<String,String> mid2COs = new HashMap<String,String>();
    // Store MaX for mid1 and mid2    
Map<String, String> mid1Max = new HashMap<>();
       Map<String, String> mid2Max = new HashMap<>();
    		
    // Store marks for each student for mid1 and mid2
       Map<String, Map<String, String>> studentMid1Marks = new HashMap<>();
       Map<String, Map<String, String>> studentMid2Marks = new HashMap<>();
       
       // Store student details
       List<Map<String, String>> students = new ArrayList<>();	

		 
    		
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

        String sql = "SELECT * FROM questionlevels WHERE qlBatchYear=? AND qlSubjectId=? AND qlSem=? AND qlYear=? AND qlMid IN ('mid1','mid2')";
        ps = con.prepareStatement(sql);
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, sem);
        ps.setString(4, year);

        rs = ps.executeQuery();

        while (rs.next()) {
            String mid = rs.getString("qlMid"); // mid1 or mid2
            for (char q = '1'; q <= '6'; q++) {
            	for(char sub='a'; sub<='b'; sub++){
            	    String col = "level_" + q + sub;
            	    String val = rs.getString(col); 
            	    if (val == null || val.equals("0")) val = "";
            	    if (mid.equalsIgnoreCase("mid1")) {
            	        mid1Levels.put(col, val); }
            	    else if (mid.equalsIgnoreCase("mid2")) {
            	        mid2Levels.put(col, val); }
            	}

            }
        }
        
        
        /////////////////////
     

String sql2 = "SELECT * FROM questionco WHERE qcBatchYear=? AND qcSubjectId=? AND qcSem=? AND qcYear=? AND qcMid IN ('mid1','mid2')";
ps = con.prepareStatement(sql2);
ps.setString(1, batchYear);
ps.setString(2, subjectId);
ps.setString(3, sem);
ps.setString(4, year);

rs = ps.executeQuery();

while (rs.next()) {
    String mid = rs.getString("qcMid"); // mid1 or mid2

    // OBJ & ASS
    for (int i=1; i<=3; i++) {
        String col = "co_obj_" + i;
        String val = rs.getString(col);
        if (val == null || val=="0") val = "";
        if (mid.equalsIgnoreCase("mid1")) mid1COs.put(col, val);
        else mid2COs.put(col, val);
    }
    for (int i=1; i<=3; i++) {
        String col = "co_ass_" + i;
        String val = rs.getString(col);
        if (val == null || val=="0") val = "";
        if (mid.equalsIgnoreCase("mid1")) mid1COs.put(col, val);
        else mid2COs.put(col, val);
    }

    // Q1–Q6 (a–d)
    for (int q=1; q<=6; q++) {
        for (char sub='a'; sub<='b'; sub++) {
            String col = "co_" + q + sub;
            String val = rs.getString(col);
            if (val == null || val=="0") val = "";
            if (mid.equalsIgnoreCase("mid1")) mid1COs.put(col, val);
            else mid2COs.put(col, val);
        }
    }
}
///////////////////////////
 String sqlMax = "SELECT * FROM questionmaxmarks WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid IN ('mid1','mid2')";
    ps = con.prepareStatement(sqlMax);
    ps.setString(1, batchYear);
    ps.setString(2, subjectId);
    ps.setString(3, sem);
    ps.setString(4, year);

    rs = ps.executeQuery();

    while(rs.next()) {
        String mid = rs.getString("qmmMid"); // mid1 or mid2

        // OBJ max
        for(int i=1; i<=3; i++){
            String col = "max_obj_" + i;
            String val = rs.getString(col);
            if (val == null || val=="0") val = "";
            if(mid.equalsIgnoreCase("mid1")) mid1Max.put(col, val);
            else mid2Max.put(col, val);
        }

        // ASS max
        for(int i=1; i<=3; i++){
            String col = "max_ass_" + i;
            String val = rs.getString(col);
            if (val == null || val=="0") val = "";
            if(mid.equalsIgnoreCase("mid1")) mid1Max.put(col, val);
            else mid2Max.put(col, val);
        }

        // Questions max Q1–Q6 (a–d)
        for(int q=1; q<=6; q++){
            for(char sub='a'; sub<='d'; sub++){
                String col = "max_" + q + sub;
                String val = rs.getString(col);
                if (val == null || val=="0") val = "";
                if(mid.equalsIgnoreCase("mid1")) mid1Max.put(col, val);
                else mid2Max.put(col, val);
            }
        }
    }
    	
    //////////////////////////////////
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
        
        // 2️⃣ Fetch marks from studentmidmarks
        String sqlMarks = "SELECT * FROM studentmidmarks WHERE smmDepartment=? AND student_sem=? AND student_year=? AND sbatch_year=? AND sub_id=?";
        ps = con.prepareStatement(sqlMarks);
        ps.setString(1, department);
        ps.setString(2, sem);
        ps.setString(3, year);
        ps.setString(4, batchYear);
        ps.setString(5, subjectId );
        rs = ps.executeQuery();
        
        while(rs.next()) {
            String sid = rs.getString("sid");
            String mid = rs.getString("smmMid"); // mid1 or mid2
            
            Map<String,String> marks = new HashMap<>();
            // OBJ1-3
            for(int i=1; i<=3; i++) marks.put("obj" + i, rs.getString("marks_obj_" + i));
            // ASS1-3
            for(int i=1; i<=3; i++) marks.put("ass" + i, rs.getString("marks_ass_" + i));
            // Q1–6 (a–d)
            for(int q=1; q<=6; q++){
                for(char sub='a'; sub<='d'; sub++){
                    String col = "marks_" + q + sub;
                    marks.put(col, rs.getString(col));
                }
            }
            
            if(mid.equalsIgnoreCase("mid1")) studentMid1Marks.put(sid, marks);
            else studentMid2Marks.put(sid, marks);
        }
    
    
    
    
    
        
    } catch (Exception e) {
        out.println("Error fetching question levels: " + e);
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
<!-- Display session values -->
<div style="width:95%; max-width:1200px; margin:10px auto; 
            background:#e3f2fd; padding:15px; border-radius:10px; 
            font-size:16px; line-height:1.8; color:#333; 
            box-shadow:0 2px 8px rgba(0,0,0,0.15);">
    <b>Semester:</b> <%= sem %> &nbsp;&nbsp; 
    <b>Year:</b> <%= year %> &nbsp;&nbsp; 
    <b>Subject Name:</b><%=subject_name %>&nbsp;&nbsp;
    <b>Subject ID:</b> <%= subjectId %> &nbsp;&nbsp; 
    <b>Batch Year:</b> <%= batchYear %> &nbsp;&nbsp; 
    <b>Mid:1&2</b> 
    
</div>

<form action="hodsavemarks.jsp" method="post">


<div style="overflow-x:auto; max-width:200%; border:1px solid #ddd; padding:5px;">
  <table border="1" cellspacing="0" cellpadding="5" style="border-collapse:collapse; min-width:1800px;">
    
    <!-- First header row -->
    <tr>
      <th rowspan="3">Questions</th>
      
      <!-- Mid-1 header -->
      <th colspan="18">Mid-1</th>
      
      <!-- Mid-2 header -->
      <th colspan="18"   >Mid-2</th>
     
      <!-- mid1 value -->
      <th rowspan="5">Mid1 mark</th>
      <!-- mid2 value -->
      <th rowspan="5">Mid2 mark</th>
       <!-- Internal mark -->
      <th rowspan="5">Internal mark</th>
      <!-- Extra CO columns -->
<th colspan="6" rowspan="4">CO Marks</th>
      
     
      
    </tr>

    <!-- Second header row -->
    <tr>
      <!-- Mid-1 OBJ/ASS + Questions -->
      <th colspan="3"    rowspan="3">OBJ1</th>
      <th colspan="3"   rowspan="3">ASS1</th>
      <th colspan="2">1</th>
      <th colspan="2">2</th>
      <th colspan="2">3</th>
      <th colspan="2">4</th>
      <th colspan="2">5</th>
      <th colspan="2">6</th>

      <!-- Mid-2 OBJ/ASS + Questions -->
      <th colspan="3" rowspan="3">OBJ1</th>
      <th colspan="3"   rowspan="3">ASS1</th>
      <th colspan="2">1</th>
      <th colspan="2">2</th>
      <th colspan="2">3</th>
      <th colspan="2">4</th>
      <th colspan="2">5</th>
      <th colspan="2">6</th>

    </tr>

    <!-- Third header row (a–d) -->
    <tr>
      
        <% for(int q=1; q<=6; q++){ %>
  <th>a</th><th>b</th>
<% } %>

    
    <% for(int q=1; q<=6; q++){ %>
  <th>a</th><th>b</th>
<% } %>

    </tr>

  <!-- Level row -->
<tr>
  <th>Level</th>
  <% for(int mid=1; mid<=2; mid++){ 
         Map<String,String> currentMap = (mid==1 ? mid1Levels : mid2Levels); 
         String midStr = "mid" + mid;
  %>
    <% for(int q=1; q<=6; q++){ 
         for(char sub='a'; sub<='b'; sub++){ 
            String col = "level_" + q + sub;
            String val = currentMap.getOrDefault(col, ""); // default 0 if null
    %>
      <td>
        <input type="text" name="mid<%=mid%>_q<%=q%><%=sub%>_level" value="<%= val %>" size="3">
      </td>
    <%   } // end sub
       } // end q
    %>
  <% } // end mid loop %>
  
  
  
  
  
</tr>


    <!-- CO row -->
 <!-- CO row -->
<tr>
  <th>CO</th>
  <% for (int mid = 1; mid <= 2; mid++) { 
         Map<String,String> currentCO = (mid == 1 ? mid1COs : mid2COs);
  %>
      <!-- OBJ1 (3 columns) -->
      <td><input type="text" name="mid<%=mid%>_obj1_co1" value="<%= currentCO.getOrDefault("co_obj_1","") %>" size="3"></td>
      <td><input type="text" name="mid<%=mid%>_obj1_co2" value="<%= currentCO.getOrDefault("co_obj_2","") %>" size="3"></td>
      <td><input type="text" name="mid<%=mid%>_obj1_co3" value="<%= currentCO.getOrDefault("co_obj_3","") %>" size="3"></td>

      <!-- ASS1 (3 columns) -->
      <td><input type="text" name="mid<%=mid%>_ass1_co1" value="<%= currentCO.getOrDefault("co_ass_1","") %>" size="3"></td>
      <td><input type="text" name="mid<%=mid%>_ass1_co2" value="<%= currentCO.getOrDefault("co_ass_2","") %>" size="3"></td>
      <td><input type="text" name="mid<%=mid%>_ass1_co3" value="<%= currentCO.getOrDefault("co_ass_3","") %>" size="3"></td>

      <!-- Q1–Q6 (a–d) -->
      <% for(int q=1; q<=6; q++){ %>
          <td><input type="text" name="mid<%=mid%>_q<%=q%>a_co" value="<%= currentCO.getOrDefault("co_"+q+"a","") %>" size="3"></td>
          <td><input type="text" name="mid<%=mid%>_q<%=q%>b_co" value="<%= currentCO.getOrDefault("co_"+q+"b","") %>" size="3"></td>
         
      <% } %>
      
      
      
      
  <% } %>
  
  
  <th>CO1</th><th>CO2</th><th>CO3</th><th>CO4</th><th>CO5</th><th>CO6</th>
  
</tr>





    <!-- Max marks row -->
    <tr>
  <th>Max</th>
  <% for(int mid=1; mid<=2; mid++){ 
       Map<String,String> currentMax = (mid==1 ? mid1Max : mid2Max);
  %>
    <!-- OBJ -->
    <td><input type="text" class="maxMark"name="mid<%=mid%>_obj1_max1" value="<%= currentMax.getOrDefault("max_obj_1","") %>" size="3"></td>
    <td><input type="text" class="maxMark"name="mid<%=mid%>_obj1_max2" value="<%= currentMax.getOrDefault("max_obj_2","") %>" size="3"></td>
    <td><input type="text"class="maxMark" name="mid<%=mid%>_obj1_max3" value="<%= currentMax.getOrDefault("max_obj_3","") %>" size="3"></td>

    <!-- ASS -->
    <td><input type="text" class="maxMark"name="mid<%=mid%>_ass1_max1" value="<%= currentMax.getOrDefault("max_ass_1","") %>" size="3"></td>
    <td><input type="text" class="maxMark"name="mid<%=mid%>_ass1_max2" value="<%= currentMax.getOrDefault("max_ass_2","") %>" size="3"></td>
    <td><input type="text" class="maxMark"name="mid<%=mid%>_ass1_max3" value="<%= currentMax.getOrDefault("max_ass_3","") %>" size="3"></td>

    <!-- Q1–Q6 -->
    <% for(int q=1; q<=6; q++){ %>
        <td><input type="text" class="maxMark"name="mid<%=mid%>_q<%=q%>a_max" value="<%= currentMax.getOrDefault("max_"+q+"a","") %>" size="3"></td>
        <td><input type="text" class="maxMark"name="mid<%=mid%>_q<%=q%>b_max" value="<%= currentMax.getOrDefault("max_"+q+"b","") %>" size="3"></td>
        
    <% } %>
  <% } %>
   <!-- mid1 max marks -->
  <th>30</th>
   <!-- mid2 max marks -->
  <th>30</th>
  <!-- internal max marks -->
  <th>40</th>
  
  <!-- Extra CO Max Marks -->
  <% for(int i=1; i<=6; i++){ %>
      <td><input type="text" name="co_max<%=i%>" value=40 size="3"></td>
  <% } %>
  
  
  
</tr>


<%
boolean includeOBJ = true; // all courses include OBJ1-3
String dept = (String) session.getAttribute("hod_department");
boolean isSpecialDept = dept.equalsIgnoreCase("MCA") || dept.equalsIgnoreCase("MBA") || dept.equalsIgnoreCase("MTech");

// Student marks rows
for(Map<String,String> student : students){ 
    String studentId = student.get("student_id");
    Map<String,String> marksMid1 = studentMid1Marks.getOrDefault(studentId, new HashMap<>());
    Map<String,String> marksMid2 = studentMid2Marks.getOrDefault(studentId, new HashMap<>());
%>
<tr>
    <td><%= studentId %></td>

    <% for(int mid=1; mid<=2; mid++){
     Map<String,String> marks = (mid==1 ? marksMid1 : marksMid2);
     // ADD THIS:
     Map<String,String> currentMax = (mid==1 ? mid1Max : mid2Max);
   
%>

        <!-- OBJ1-3 -->
<% for(int i=1;i<=3;i++){ %>
 <td>
    <input type="text" 
           name="mid<%=mid%>_obj<%=i%>_<%=studentId%>" 
           class="mid<%=mid%>" 
           data-student="<%=studentId%>"
           data-max='<%= currentMax.getOrDefault("max_obj_"+i,"0") %>'
           value="<%= marks.getOrDefault("obj"+i,"0") %>" size="3">
  </td>
<% } %>

        <!-- ASS1-3 -->
<% for(int i=1;i<=3;i++){ %>
  <td>
    <input type="text" 
           name="mid<%=mid%>_ass<%=i%>_<%=studentId%>" 
           class="mid<%=mid%>" 
           data-student="<%=studentId%>"
           data-max='<%= currentMax.getOrDefault("max_ass_"+i,"0") %>'
           value="<%= marks.getOrDefault("ass"+i,"0") %>" size="3">
  </td>
<% } %>

       <!-- Q1-6 (a-b) -->
<% for(int q=1;q<=6;q++){
     for(char sub='a'; sub<='b'; sub++){
        String col = "marks_" + q + sub;
%>
  <td>
    <input type="text" 
           name="mid<%=mid%>_q<%=q%><%=sub%>_<%=studentId%>" 
           class="mid<%=mid%>" 
           data-student="<%=studentId%>"
           data-max='<%= currentMax.getOrDefault("max_"+q+sub,"0") %>'
           value="<%= marks.getOrDefault(col,"0") %>" size="3">
  </td>
<% }} %>

    <% } %>

    <!-- Calculate Mid1 and Mid2 totals -->
    <%
    int mid1Total = 0;
    int mid2Total = 0;

    if(includeOBJ){
        mid1Total += Integer.parseInt(marksMid1.getOrDefault("obj1","0"));
        mid2Total += Integer.parseInt(marksMid2.getOrDefault("obj1","0"));
    }

    for (int[] pair : new int[][]{{1,2},{3,4},{5,6}}){
        mid1Total += Math.max(
            Integer.parseInt(marksMid1.getOrDefault("marks_"+pair[0]+"a","0")) + Integer.parseInt(marksMid1.getOrDefault("marks_"+pair[0]+"b","0")),
            Integer.parseInt(marksMid1.getOrDefault("marks_"+pair[1]+"a","0")) + Integer.parseInt(marksMid1.getOrDefault("marks_"+pair[1]+"b","0"))
        );
        mid2Total += Math.max(
            Integer.parseInt(marksMid2.getOrDefault("marks_"+pair[0]+"a","0")) + Integer.parseInt(marksMid2.getOrDefault("marks_"+pair[0]+"b","0")),
            Integer.parseInt(marksMid2.getOrDefault("marks_"+pair[1]+"a","0")) + Integer.parseInt(marksMid2.getOrDefault("marks_"+pair[1]+"b","0"))
        );
    }

   
    int baseMid1 = isSpecialDept ? mid1Total : (mid1Total/4 + mid1Total/2);
    int baseMid2 = isSpecialDept ? mid2Total : (mid2Total/4 + mid2Total/2);
 // Add ass1 from both mids for internal calculation
    int Mid1Ass =  Integer.parseInt(marksMid1.getOrDefault("ass1","0"));
    int Mid2Ass =  Integer.parseInt(marksMid2.getOrDefault("ass1","0"));
     int internalMark = (int)(Math.max(baseMid1, baseMid2) * 0.8 
                           + Math.min(baseMid1, baseMid2) * 0.2)+Mid1Ass+Mid2Ass;



    // Adjusted mid calculation for non-special departments
    int mid1Adjusted = isSpecialDept ? mid1Total : (mid1Total/4 + mid1Total/2);
    int mid2Adjusted = isSpecialDept ? mid2Total : (mid2Total/4 + mid2Total/2);
    %>

    <!-- New columns for Mid1 and Mid2 totals per student -->
    <td><input type="text" class="midTotal" readonly value="<%= mid1Total %> <%= isSpecialDept ? "" : "-->" + mid1Adjusted %>"></td>
    <td><input type="text" class="midTotal" readonly value="<%= mid2Total %> <%= isSpecialDept ? "" : "-->" + mid2Adjusted %>"></td>

    <!-- Internal mark -->
    <td><input type="text" class="internal" readonly value="<%=internalMark%>"></td>

    <!-- CO1–CO6 -->
    <% for(int i=1; i<=6; i++){ %>
        <td>
            <input type="text" name="co<%=i%>_<%=studentId%>" value="" size="3">
        </td>
    <% } %>
</tr>
<% } %>

<!-- JS for dynamic calculation -->
<script>
window.onload = function() {
    var dept = "<%= dept %>";
    var isSpecialDept = dept.toUpperCase() === "MCA" || dept.toUpperCase() === "MBA" || dept.toUpperCase() === "MTECH";

    document.querySelectorAll("input[type='text']").forEach(function(input) {
        input.addEventListener("input", function() {
            recalcRow(this.closest("tr"));
        });
    });
 // enforce data-max on all inputs that have it
    function enforceMax(inputEl){
        var maxAttr = inputEl.getAttribute('data-max');
        if(!maxAttr) return;
        var max = parseInt(maxAttr) || 0;
        var val = parseInt(inputEl.value) || 0;
        if(max > 0 && val > max){
            // optionally show a non-blocking message instead of alert
            alert("Entered marks cannot be greater than Max (" + max + ")");
            inputEl.value = max;
        }
    }

    // attach to all inputs that have data-max
   // whenever a max mark is changed, update all related student fields
document.querySelectorAll(".maxMark").forEach(function(maxInput){
    maxInput.addEventListener("input", function(){
        var qname = this.name;  // example: mid1_q1a_max
        var newMax = parseInt(this.value) || 0;

        // find all student inputs for this question
        var qKey = qname.replace("_max",""); 
        document.querySelectorAll("input[name*='" + qKey + "_']").forEach(function(stuInput){
            stuInput.setAttribute("data-max", newMax);
            if(parseInt(stuInput.value) > newMax){
                stuInput.value = newMax;
            }
        });
    });
});

// for each student input: prevent > max
document.querySelectorAll("input[data-max]").forEach(function(inp){
    inp.addEventListener("input", function(){
        var max = parseInt(this.getAttribute("data-max")) || 0;
        var val = parseInt(this.value) || 0;
        if(val > max) this.value = max;
        if(val < 0) this.value = 0;
    });
});

    
    
   
    document.addEventListener("DOMContentLoaded", function(){
        // whenever a max mark is changed, update all related student fields
        document.querySelectorAll(".maxMark").forEach(function(maxInput){
            maxInput.addEventListener("input", function(){
                var qname = this.name;  // example: max_1a, max_2b, etc.
                var newMax = parseInt(this.value) || 0;

                // find all student inputs for this question
                document.querySelectorAll("input[name*='" + qname.replace('max_','') + "']").forEach(function(stuInput){
                    stuInput.setAttribute("data-max", newMax);
                    if(parseInt(stuInput.value) > newMax){
                        stuInput.value = newMax; // trim if above new max
                    }
                });
            });
        });

        // for each student input: prevent > max
        document.querySelectorAll("input[data-max]").forEach(function(inp){
            inp.addEventListener("input", function(){
                var max = parseInt(this.getAttribute("data-max")) || 0;
                var val = parseInt(this.value) || 0;
                if(val > max) this.value = max;
                if(val < 0) this.value = 0;
            });
        });
    });
    

    
    

    function recalcRow(row) {
        var studentId = row.querySelector("td").textContent.trim();

        function val(name) {
            var el = row.querySelector("input[name='" + name + "']");
            return el ? parseInt(el.value) || 0 : 0;
        }

        var mid1Total = val("mid1_obj1_" + studentId);
        var mid2Total = val("mid2_obj1_" + studentId);

        for(var q=1;q<=6;q+=2){
            var sum1 = val("mid1_q"+q+"a_"+studentId) + val("mid1_q"+q+"b_"+studentId);
            var sum2 = val("mid1_q"+(q+1)+"a_"+studentId) + val("mid1_q"+(q+1)+"b_"+studentId);
            mid1Total += Math.max(sum1,sum2);

            var sum3 = val("mid2_q"+q+"a_"+studentId) + val("mid2_q"+q+"b_"+studentId);
            var sum4 = val("mid2_q"+(q+1)+"a_"+studentId) + val("mid2_q"+(q+1)+"b_"+studentId);
            mid2Total += Math.max(sum3,sum4);
        }

        var mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4) + Math.floor(mid1Total/2));
        var mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4) + Math.floor(mid2Total/2));

        var midTotalInputs = row.querySelectorAll(".midTotal");
        if(midTotalInputs.length >= 2){
            midTotalInputs[0].value = mid1Total + (isSpecialDept ? "" : "-->" + mid1Adjusted);
            midTotalInputs[1].value = mid2Total + (isSpecialDept ? "" : "-->" + mid2Adjusted);
        }

        var baseMid1 = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4) + Math.floor(mid1Total/2));
        var baseMid2 = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4) + Math.floor(mid2Total/2));

     // Add ass1 marks for internal calculation
        var Mid1Ass =  val("mid1_ass1_" + studentId);
        var Mid2Ass =  val("mid2_ass1_" + studentId);

        var internal = Math.round(Math.max(baseMid1, baseMid2) * 0.8 
                                + Math.min(baseMid1, baseMid2) * 0.2)+ Mid1Ass+ Mid2Ass;


        var internalInput = row.querySelector(".internal");
        if(internalInput) internalInput.value = internal;
    }
};
</script>




    
  </table>

  
  
<br>
<input type="submit" value="Save/Update" />
</div>
</form>

<!-- Back button -->
<form action="hodsubjectselection.jsp" method="get" style="display:inline;">
    <input type="submit" value="Back" />
</form>



