 <script>
document.addEventListener('DOMContentLoaded', function() {
    var dept = "<%= dept %>";
    var isSpecialDept = dept.toUpperCase() === "MCA" || dept.toUpperCase() === "MBA" || dept.toUpperCase() === "MTECH";

    function recalcRow(row) {
        if(!row) return;
        var studentId = row.querySelector('td').textContent.trim();
        if(!studentId) return;

        function val(name) {
            var el = row.querySelector("input[name='" + name + "']");
            if(!el) return 0;
            var v = parseInt(el.value,10);
            return isNaN(v) ? 0 : v;
        }

        function checkMidAbsent(midPrefix) {
            // Only check question inputs 1a,1b,...6b
            for(var q=1;q<=6;q++){
                ['a','b'].forEach(function(part){
                    var inputName = midPrefix+"_q"+q+part+"_"+studentId;
                    var el = row.querySelector("input[name='" + inputName + "']");
                    if(el && parseInt(el.value,10)===-1){
                        return true;
                    }
                });
            }
            return false;
        }

        function toggleMidReadonly(midPrefix, absent) {
            // Only disable question inputs
            for(var q=1;q<=6;q++){
                ['a','b'].forEach(function(part){
                    var inputName = midPrefix+"_q"+q+part+"_"+studentId;
                    var el = row.querySelector("input[name='" + inputName + "']");
                    if(el){
                        el.readOnly = absent;
                        if(absent) el.classList.add('absentMid');
                        else el.classList.remove('absentMid');
                    }
                });
            }
        }

        var mid1Absent = checkMidAbsent("mid1");
        var mid2Absent = checkMidAbsent("mid2");

        toggleMidReadonly("mid1", mid1Absent);
        toggleMidReadonly("mid2", mid2Absent);

        // Calculate totals
        var mid1Total = val("mid1_obj1_"+studentId);
        var mid2Total = val("mid2_obj1_"+studentId);

        for(var q=1;q<=6;q+=2){
            mid1Total += Math.max(val("mid1_q"+q+"a_"+studentId)===-1?0:val("mid1_q"+q+"a_"+studentId),
                                  val("mid1_q"+q+"b_"+studentId)===-1?0:val("mid1_q"+q+"b_"+studentId));
            mid1Total += Math.max(val("mid1_q"+(q+1)+"a_"+studentId)===-1?0:val("mid1_q"+(q+1)+"a_"+studentId),
                                  val("mid1_q"+(q+1)+"b_"+studentId)===-1?0:val("mid1_q"+(q+1)+"b_"+studentId));

            mid2Total += Math.max(val("mid2_q"+q+"a_"+studentId)===-1?0:val("mid2_q"+q+"a_"+studentId),
                                  val("mid2_q"+q+"b_"+studentId)===-1?0:val("mid2_q"+q+"b_"+studentId));
            mid2Total += Math.max(val("mid2_q"+(q+1)+"a_"+studentId)===-1?0:val("mid2_q"+(q+1)+"a_"+studentId),
                                  val("mid2_q"+(q+1)+"b_"+studentId)===-1?0:val("mid2_q"+(q+1)+"b_"+studentId));
        }

        var mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4)+Math.floor(mid1Total/2));
        var mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4)+Math.floor(mid2Total/2));

        // Update mid totals
        var midTotalInputs = row.querySelectorAll(".midTotal");
        if(midTotalInputs.length>=2){
            midTotalInputs[0].value = mid1Absent ? "Absent" : (mid1Total + (isSpecialDept?"":"-->"+mid1Adjusted));
            midTotalInputs[1].value = mid2Absent ? "Absent" : (mid2Total + (isSpecialDept?"":"-->"+mid2Adjusted));
        }

        // Internal marks
        var mid1Ass = val("mid1_ass1_"+studentId);
        var mid2Ass = val("mid2_ass1_"+studentId);

        var internalEl = row.querySelector(".internal");
        if(internalEl){
            if(mid1Absent && mid2Absent) internalEl.value = "Absent";
            else {
                var base1 = mid1Absent ? 0 : mid1Adjusted;
                var base2 = mid2Absent ? 0 : mid2Adjusted;
                internalEl.value = Math.round(Math.max(base1,base2)*0.8 + Math.min(base1,base2)*0.2) + mid1Ass + mid2Ass;
            }
        }
    }

    // Attach recalc to all input changes
    document.querySelectorAll("input[type='text']").forEach(function(inp){
        inp.addEventListener("input", function(){ recalcRow(this.closest("tr")); });
    });

    // Initial pass
    document.querySelectorAll("table tr").forEach(function(tr){ recalcRow(tr); });
});
</script>

<style>
input.absentMid { background:#f5f5f5; color:#666; }
</style>
