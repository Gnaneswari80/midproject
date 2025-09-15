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

        function checkAbsent(midPrefix) {
            var inputs = Array.from(row.querySelectorAll("input[name^='" + midPrefix + "_'][name$='_" + studentId + "']"));
            return inputs.some(i => parseInt(i.value,10) === -1);
        }

        function toggleMidReadonly(midPrefix, absent) {
            var inputs = Array.from(row.querySelectorAll("input[name^='" + midPrefix + "_'][name$='_" + studentId + "']"));
            inputs.forEach(i => {
                i.readOnly = absent;
                if(absent) i.classList.add('absentMid');
                else i.classList.remove('absentMid');
            });
        }

        // Check which mids are absent
        var mid1Absent = checkAbsent("mid1");
        var mid2Absent = checkAbsent("mid2");

        toggleMidReadonly("mid1", mid1Absent);
        toggleMidReadonly("mid2", mid2Absent);

        // Calculate totals (treat -1 as 0)
        var mid1Total = mid1Absent ? 0 : val("mid1_obj1_" + studentId);
        var mid2Total = mid2Absent ? 0 : val("mid2_obj1_" + studentId);

        for(var q=1;q<=6;q+=2){
            var m1a = val("mid1_q"+q+"a_"+studentId); var m1b = val("mid1_q"+q+"b_"+studentId);
            var m1c = val("mid1_q"+(q+1)+"a_"+studentId); var m1d = val("mid1_q"+(q+1)+"b_"+studentId);
            mid1Total += Math.max(m1a===-1?0:m1a, m1b===-1?0:m1b) + Math.max(m1c===-1?0:m1c, m1d===-1?0:m1d);

            var n1a = val("mid2_q"+q+"a_"+studentId); var n1b = val("mid2_q"+q+"b_"+studentId);
            var n1c = val("mid2_q"+(q+1)+"a_"+studentId); var n1d = val("mid2_q"+(q+1)+"b_"+studentId);
            mid2Total += Math.max(n1a===-1?0:n1a, n1b===-1?0:n1b) + Math.max(n1c===-1?0:n1c, n1d===-1?0:n1d);
        }

        var mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4) + Math.floor(mid1Total/2));
        var mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4) + Math.floor(mid2Total/2));

        // Update mid columns
        var midTotalInputs = row.querySelectorAll(".midTotal");
        if(midTotalInputs.length >= 2){
            midTotalInputs[0].value = mid1Absent ? "Absent" : (mid1Total + (isSpecialDept ? "" : "-->" + mid1Adjusted));
            midTotalInputs[1].value = mid2Absent ? "Absent" : (mid2Total + (isSpecialDept ? "" : "-->" + mid2Adjusted));
        }

        // Internal
        var mid1Ass = val("mid1_ass1_" + studentId);
        var mid2Ass = val("mid2_ass1_" + studentId);

        var internalEl = row.querySelector(".internal");
        if(internalEl){
            if(mid1Absent && mid2Absent){
                internalEl.value = "Absent";
            } else {
                var base1 = mid1Absent ? 0 : mid1Adjusted;
                var base2 = mid2Absent ? 0 : mid2Adjusted;
                internalEl.value = Math.round(Math.max(base1, base2)*0.8 + Math.min(base1, base2)*0.2) + mid1Ass + mid2Ass;
            }
        }
    }

    // Attach recalc to all input changes
    document.querySelectorAll("input[type='text']").forEach(function(inp){
        inp.addEventListener("input", function(){
            recalcRow(this.closest("tr"));
        });
    });

    // Initial pass
    document.querySelectorAll("table tr").forEach(function(tr){ recalcRow(tr); });
});
</script>

<style>
input.absentMid { background:#f5f5f5; color:#666; }
</style>
