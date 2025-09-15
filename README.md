<!-- JS for dynamic calculation -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    const dept = "<%= dept %>" || "";
    const isSpecialDept = dept.toUpperCase() === "MCA" || dept.toUpperCase() === "MBA" || dept.toUpperCase() === "MTECH";

    // attach input listener to all text inputs (student marks + max fields)
    document.querySelectorAll('input[type="text"]').forEach(function(input){
        input.addEventListener('input', function(){ 
            const tr = this.closest('tr');
            if(tr) recalcRow(tr);
        });
    });

    // When a max mark (.maxMark) changes, update data-max on student inputs for that question
    document.querySelectorAll('.maxMark').forEach(function(maxInput){
        maxInput.addEventListener('input', function(){
            const qname = this.name.replace(/_max$/, ''); // e.g. "mid1_q1a_max" -> "mid1_q1a"
            const newMax = parseInt(this.value, 10) || 0;
            // update student inputs whose name starts with qname (e.g. "mid1_q1a_")
            document.querySelectorAll("input[name^='" + qname + "_']").forEach(function(stuInput){
                stuInput.setAttribute('data-max', newMax);
                const cur = parseInt(stuInput.value,10);
                if(!isNaN(cur) && cur > newMax) stuInput.value = newMax;
            });
        });
    });

    // Enforce data-max on student inputs but allow -1 (absent)
    document.querySelectorAll('input[data-max]').forEach(function(inp){
        inp.addEventListener('input', function(){
            const max = parseInt(this.getAttribute('data-max'),10) || 0;
            const s = this.value.trim();
            if(s === '') return;
            const n = parseInt(s,10);
            if(isNaN(n)) { this.value = ''; return; }
            if(n > max) this.value = max;
            if(n < -1) this.value = -1; // allow only -1 as negative (absent)
        });
    });

    // helper to read number from a named input in the given row
    function getNumberFromInput(row, name) {
        const el = row.querySelector("input[name='" + name + "']");
        if(!el) return 0; // missing field -> treat as 0
        const s = el.value.trim();
        if(s === '') return 0;
        if(s === '-1') return -1; // explicit absent marker
        const n = parseInt(s,10);
        return isNaN(n) ? 0 : n;
    }

    // main recalculation per row
    function recalcRow(row) {
        if(!row) return;
        const firstTd = row.querySelector('td');
        if(!firstTd) return;
        const studentId = firstTd.textContent.trim();
        if(!studentId) return;

        // compute mid1Total and mid2Total and detect absent if any question/input = -1
        let mid1Absent = false, mid2Absent = false;
        let mid1Total = 0, mid2Total = 0;

        // OBJ1-3 (include all three)
        for(let i=1;i<=3;i++){
            const v1 = getNumberFromInput(row, 'mid1_obj' + i + '_' + studentId);
            if(v1 === -1) mid1Absent = true;
            mid1Total += (v1 === -1 ? 0 : v1);

            const v2 = getNumberFromInput(row, 'mid2_obj' + i + '_' + studentId);
            if(v2 === -1) mid2Absent = true;
            mid2Total += (v2 === -1 ? 0 : v2);
        }

        // pairs: (1,2), (3,4), (5,6) — for each mid choose max(sum(pairA), sum(pairB))
        const pairs = [[1,2],[3,4],[5,6]];
        pairs.forEach(function(pair){
            // mid1
            const a1 = getNumberFromInput(row, 'mid1_q' + pair[0] + 'a_' + studentId);
            const b1 = getNumberFromInput(row, 'mid1_q' + pair[0] + 'b_' + studentId);
            const a2 = getNumberFromInput(row, 'mid1_q' + pair[1] + 'a_' + studentId);
            const b2 = getNumberFromInput(row, 'mid1_q' + pair[1] + 'b_' + studentId);
            if(a1 === -1 || b1 === -1 || a2 === -1 || b2 === -1) mid1Absent = true;
            const sumA = (a1 === -1 ? 0 : a1) + (b1 === -1 ? 0 : b1);
            const sumB = (a2 === -1 ? 0 : a2) + (b2 === -1 ? 0 : b2);
            mid1Total += Math.max(sumA, sumB);

            // mid2
            const c1 = getNumberFromInput(row, 'mid2_q' + pair[0] + 'a_' + studentId);
            const d1 = getNumberFromInput(row, 'mid2_q' + pair[0] + 'b_' + studentId);
            const c2 = getNumberFromInput(row, 'mid2_q' + pair[1] + 'a_' + studentId);
            const d2 = getNumberFromInput(row, 'mid2_q' + pair[1] + 'b_' + studentId);
            if(c1 === -1 || d1 === -1 || c2 === -1 || d2 === -1) mid2Absent = true;
            const sumC = (c1 === -1 ? 0 : c1) + (d1 === -1 ? 0 : d1);
            const sumD = (c2 === -1 ? 0 : c2) + (d2 === -1 ? 0 : d2);
            mid2Total += Math.max(sumC, sumD);
        });

        // adjusted values (only meaningful if not absent). For special depts show raw totals; for others show "total --> adjusted"
        const mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4) + Math.floor(mid1Total/2));
        const mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4) + Math.floor(mid2Total/2));

        // Update Mid1 and Mid2 columns (expect 2 .midTotal inputs per row)
        const midTotalInputs = row.querySelectorAll('.midTotal');
        if(midTotalInputs.length >= 2){
            midTotalInputs[0].value = mid1Absent ? 'Absent' : (mid1Total + (isSpecialDept ? '' : '-->' + mid1Adjusted));
            midTotalInputs[1].value = mid2Absent ? 'Absent' : (mid2Total + (isSpecialDept ? '' : '-->' + mid2Adjusted));
        }

        // Internal calculation:
        // - If both mids absent => Internal = "Absent"
        // - Else treat absent mid as 0 base; include ass1 from both mids (but if ass is -1 treat it as 0)
        const mid1AssRaw = getNumberFromInput(row, 'mid1_ass1_' + studentId);
        const mid2AssRaw = getNumberFromInput(row, 'mid2_ass1_' + studentId);
        const mid1Ass = (mid1AssRaw === -1 ? 0 : mid1AssRaw);
        const mid2Ass = (mid2AssRaw === -1 ? 0 : mid2AssRaw);

        const base1 = mid1Absent ? 0 : mid1Adjusted;
        const base2 = mid2Absent ? 0 : mid2Adjusted;

        const internalInput = row.querySelector('.internal');
        if(internalInput){
            if(mid1Absent && mid2Absent){
                internalInput.value = 'Absent';
            } else {
                const internalCalc = Math.round(Math.max(base1, base2) * 0.8 + Math.min(base1, base2) * 0.2);
                internalInput.value = internalCalc + mid1Ass + mid2Ass;
            }
        }
    }

    // initial calculate for all existing rows
    document.querySelectorAll('table tr').forEach(function(tr){ recalcRow(tr); });
});
</script>
