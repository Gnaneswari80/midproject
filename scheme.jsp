<%@ page import="java.sql.*" %>
<%
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String subjectId = (String) session.getAttribute("subjectId");
    String subject_name = (String) session.getAttribute("subject_name");
    String batchYear = (String) session.getAttribute("batchYear");
    String mid = (String) session.getAttribute("mid");

    String url = "jdbc:mysql://localhost:3306/midmarks_db";
    String user = "root";
    String pass = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    java.util.Map<String,String> levelsMap = new java.util.HashMap<>();
    java.util.Map<String,String> coMap     = new java.util.HashMap<>();
    java.util.Map<String,String> maxMap    = new java.util.HashMap<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);

        // Fetch levels
        ps = con.prepareStatement(
            "SELECT * FROM questionlevels WHERE qlBatchYear=? AND qlSubjectId=? AND qlMid=? AND qlSem=? AND qlYear=?"
        );
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();
        if (rs.next()) {
            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                levelsMap.put(md.getColumnName(i), rs.getString(i));
            }
        }
        rs.close(); ps.close();

        // Fetch COs
        ps = con.prepareStatement(
            "SELECT * FROM questionco WHERE qcBatchYear=? AND qcSubjectId=? AND qcMid=? AND qcSem=? AND qcYear=?"
        );
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();
        if (rs.next()) {
            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                coMap.put(md.getColumnName(i), rs.getString(i));
            }
        }
        rs.close(); ps.close();

        // Fetch Max Marks
        ps = con.prepareStatement(
            "SELECT * FROM questionmaxmarks WHERE qmmBatchYear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?"
        );
        ps.setString(1, batchYear);
        ps.setString(2, subjectId);
        ps.setString(3, mid);
        ps.setString(4, sem);
        ps.setString(5, year);
        rs = ps.executeQuery();
        if (rs.next()) {
            ResultSetMetaData md = rs.getMetaData();
            for (int i = 1; i <= md.getColumnCount(); i++) {
                maxMap.put(md.getColumnName(i), rs.getString(i));
            }
        }
        rs.close(); ps.close();

    } catch (Exception e) {
        out.println("<h3 style='color:red'>Error: " + e.getMessage() + "</h3>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Faculty Question Entry</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background:#f0f2f5; margin:0; padding:0; }
        h2 { text-align:center; margin:20px 0; color:#333; }
        form { width:95%; max-width:1200px; margin:20px auto; background:#fff; padding:30px; border-radius:15px; box-shadow:0 4px 15px rgba(0,0,0,0.2); }
        .section { margin-bottom:30px; padding:15px; border-radius:10px; background:linear-gradient(to right, #e0f7fa, #f1f8e9); }
        .section label { font-weight:bold; margin-right:10px; }
        .section input[type="text"], .section input[type="number"] { width:100px; margin-right:15px; }
        table { width:100%; border-collapse: collapse; margin-top:20px; font-size:14px; }
        th, td { border:1px solid #ccc; padding:10px; text-align:center; }
        th { background:#007bff; color:#fff; font-weight:600; }
        tr:hover { background:#f1f1f1; }
        input[type=number] { border:1px solid #aaa; border-radius:5px; padding:5px; }
        select { border-radius:5px; padding:5px; }
        button { padding:10px 30px; margin-top:20px; background:#007bff; color:#fff; border:none; border-radius:8px; cursor:pointer; transition:0.3s; }
        button:hover { background:#0056b3; }
        .back-button { background:#f44336; margin-top:15px; }
        .back-button:hover { background:#d32f2f; }

        @media(max-width:768px){
            .section input[type="text"], .section input[type="number"] { width:80px; margin-bottom:5px; }
            table { font-size:12px; }
        }

        /* Colors per pair */
        .pair-1 { background-color: #b3e5fc; }  /* light blue */
        .pair-2 { background-color: #ffe082; }  /* yellow */
        .pair-3 { background-color: #ffab91; }  /* orange */
        .pair-4 { background-color: #c5e1a5; }  /* green */
        .pair-5 { background-color: #d1c4e9; }  /* purple */
        .pair-6 { background-color: #ffccbc; }  /* peach */

        /* Max marks coloring */
        input.marks-input.valid { background-color:#c8e6c9; }   /* green */
        input.marks-input.invalid { background-color:#f8d7da; } /* red */
    </style>

    <script>
    document.addEventListener("DOMContentLoaded", function() {
        // Auto-fill Assignments
        const ass1 = document.querySelector("input[name='max_ass_1']");
        const ass2 = document.querySelector("input[name='max_ass_2']");
        const ass3 = document.querySelector("input[name='max_ass_3']");

        ass1.addEventListener("input", function() {
            ass2.value = this.value;
            ass3.value = this.value;
        });

        // Auto-fill Objectives
        const obj1 = document.querySelector("input[name='max_obj_1']");
        const obj2 = document.querySelector("input[name='max_obj_2']");
        const obj3 = document.querySelector("input[name='max_obj_3']");

        obj1.addEventListener("input", function() {
            obj2.value = this.value;
            obj3.value = this.value;
        });

        // Auto-fill Assignment COs
        const coAss1 = document.querySelector("input[name='co_ass_1']");
        const coAss2 = document.querySelector("input[name='co_ass_2']");
        const coAss3 = document.querySelector("input[name='co_ass_3']");

        if (coAss1) {
            coAss1.addEventListener("input", function() {
                if (coAss2) coAss2.value = this.value;
                if (coAss3) coAss3.value = this.value;
            });
        }

        // Auto-fill Objective COs
        const coObj1 = document.querySelector("input[name='co_obj_1']");
        const coObj2 = document.querySelector("input[name='co_obj_2']");
        const coObj3 = document.querySelector("input[name='co_obj_3']");

        if (coObj1) {
            coObj1.addEventListener("input", function() {
                if (coObj2) coObj2.value = this.value;
                if (coObj3) coObj3.value = this.value;
            });
        }

        // Question pairs color & validation
        const questionPairs = [
            ["1a","1b"], ["2a","2b"], ["3a","3b"],
            ["4a","4b"], ["5a","5b"], ["6a","6b"]
        ];

        questionPairs.forEach((pair, index) => {
            pair.forEach(q => {
                const co = document.querySelector("select[name='co_" + q + "']");
                const level = document.querySelector("select[name='Level_" + q + "']");

                function updateColor() {
                    if (co.value || level.value) {
                        co.className = "pair-" + (index+1);
                        level.className = "pair-" + (index+1);
                    } else {
                        co.className = "";
                        level.className = "";
                    }
                }

                co.addEventListener("change", updateColor);
                level.addEventListener("change", updateColor);
                updateColor(); // initial
            });
        });

        // Max marks sum <=10 validation per pair
        questionPairs.forEach((pair) => {
            const pairInputs = pair.map(q => document.querySelector("input[name='max_" + q + "']"));
            pairInputs.forEach(input => {
                function validate() {
                    let sum = pairInputs.reduce((acc,i) => acc + parseInt(i.value || 0), 0);
                    if (sum > 10) {
                        let otherSum = sum - parseInt(input.value || 0);
                        input.value = 10 - otherSum;
                        sum = 10;
                    }
                    pairInputs.forEach(i => {
                        if (sum <= 10) {
                            i.classList.add("valid");
                            i.classList.remove("invalid");
                        } else {
                            i.classList.add("invalid");
                            i.classList.remove("valid");
                        }
                    });
                }
                input.addEventListener("input", validate);
                validate(); // initial
            });
        });
    });
    </script>
</head>
<body>
   <h2>Faculty Question Entry</h2>

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
    <b>Mid:</b> <%= mid %>
    
</div>


    <form action="saveQuestions.jsp" method="post">
        <!-- Assignments Section -->
       <!-- Assignments + Objectives Section -->
<div class="section">
  
    
    <%-- Assignments --%>
    <h4>Assignments</h4>
    <%
    String[] assignments = {"1","2","3"};
    for(String a: assignments){
        String defaultCo = "";
        if(!a.equals("1")) {
            defaultCo = "Co" + a;   // ass2 → Co2, ass3 → Co3
        }
    %>
        <% if(a.equals("1")) { %>
            <!-- Assignment 1 visible -->
           
            <input type="text"  placeholder="enter co"class="co-ass" name="co_ass_<%=a%>" 
                   value="<%= coMap.getOrDefault("co_ass_"+a, "") %>">
            <input type="number" placeholder="enter max marks"name="max_ass_<%=a%>" 
                   value="<%= maxMap.getOrDefault("max_ass_"+a,"") %>" 
                   min="0" max="10">
            <br><br>
        <% } else { %>
            <!-- Assignment 2 & 3 hidden -->
            <input type="hidden" placeholder="enter co" name="co_ass_<%=a%>" 
                   value="<%= coMap.getOrDefault("co_ass_"+a, defaultCo) %>">
            <input type="hidden" placeholder="enter max marks"name="max_ass_<%=a%>" 
                   value="<%= maxMap.getOrDefault("max_ass_"+a,"") %>">
        <% } %>
    <% } %>

    <%-- Objectives --%>
    <h4>Objectives</h4>
    <%
    String[] objectives = {"1","2","3"};
    for(String o: objectives){
        String defaultCo = "";
        if(!o.equals("1")) {
            defaultCo = "Co" + o;   // obj2 → Co2, obj3 → Co3
        }
    %>
        <% if(o.equals("1")) { %>
            <!-- Objective 1 visible -->
           
            <input type="text" placeholder="enter co"class="co-obj" name="co_obj_<%=o%>" 
                   value="<%= coMap.getOrDefault("co_obj_"+o, "") %>">
            <input type="number" placeholder="enter max mark"name="max_obj_<%=o%>" 
                   value="<%= maxMap.getOrDefault("max_obj_"+o,"") %>" 
                   min="0" max="10">
            <br><br>
        <% } else { %>
            <!-- Objective 2 & 3 hidden -->
            <input type="hidden" placeholder="enter co"name="co_obj_<%=o%>" 
                   value="<%= coMap.getOrDefault("co_obj_"+o, defaultCo) %>">
            <input type="hidden" placeholder="max mark"name="max_obj_<%=o%>" 
                   value="<%= maxMap.getOrDefault("max_obj_"+o,"") %>">
        <% } %>
    <% } %>
</div>


        <!-- Questions Table -->
        <table>
            <tr>
                <th>Question</th>
                <th>CO</th>
                <th>Level</th>
                <th>Max Marks</th>
            </tr>

            <%
            String[] questions = {"1a","1b","2a","2b","3a","3b","4a","4b","5a","5b","6a","6b"};
            for (String q: questions) {
            %>
            <tr>
                <td><%=q%></td>
                <td>
                    <select name="co_<%=q%>">
                        <option value="">Select CO</option>
                        <% for (int i=1; i<=6; i++) {
                            String val = "CO"+i;
                            String sel = val.equals(coMap.getOrDefault("co_"+q,"")) ? "selected" : "";
                        %>
                            <option value="<%=val%>" <%=sel%>><%=val%></option>
                        <% } %>
                    </select>
                </td>
                <td>
                    <select name="Level_<%=q%>">
                        <option value="">Select Level</option>
                        <% for (int i=1; i<=6; i++) {
                            String val = "L"+i;
                            String sel = val.equals(levelsMap.getOrDefault("level_"+q,"")) ? "selected" : "";
                        %>
                            <option value="<%=val%>" <%=sel%>><%=val%></option>
                        <% } %>
                    </select>
                </td>
                <td>
                    <input type="number" name="max_<%=q%>" min="0" max="10" 
                           value="<%= maxMap.getOrDefault("max_"+q,"") %>" 
                           class="marks-input" 
                           data-group="<%=q.charAt(0) %>">
                </td>
            </tr>
            <% } %>
        </table>

        <button type="submit">Save Questions</button>
    </form>

    <form action="enterSingleStudentMarks.jsp" method="get">
        <button type="submit" class="back-button">&larr; Back</button>
    </form>
</body>
</html>
