
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




