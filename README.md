function recalcRow(row) { 
    var studentId = row.querySelector("td").textContent.trim();

    function val(name) {
        var el = row.querySelector("input[name='" + name + "']");
        if (!el) return 0;
        var v = parseInt(el.value);
        return isNaN(v) ? 0 : v;
    }

    var mid1Total = 0, mid2Total = 0;

    // ---- Mid1 ----
    mid1Total = val("mid1_obj1_" + studentId);
    for (var q = 1; q <= 6; q += 2) {
        var sum1 = val("mid1_q" + q + "a_" + studentId) + val("mid1_q" + q + "b_" + studentId);
        var sum2 = val("mid1_q" + (q+1) + "a_" + studentId) + val("mid1_q" + (q+1) + "b_" + studentId);
        mid1Total += Math.max(sum1, sum2);
    }

    // ---- Mid2 ----
    mid2Total = val("mid2_obj1_" + studentId);
    for (var q = 1; q <= 6; q += 2) {
        var sum3 = val("mid2_q" + q + "a_" + studentId) + val("mid2_q" + q + "b_" + studentId);
        var sum4 = val("mid2_q" + (q+1) + "a_" + studentId) + val("mid2_q" + (q+1) + "b_" + studentId);
        mid2Total += Math.max(sum3, sum4);
    }

    // Adjusted
    var mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total/4) + Math.floor(mid1Total/2));
    var mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total/4) + Math.floor(mid2Total/2));

    // ---- Update Mid cells ----
    var midTotalInputs = row.querySelectorAll(".midTotal");
    if (midTotalInputs.length >= 2) {
        midTotalInputs[0].value = (mid1Total < 0) ? "Absent" : (mid1Total + (isSpecialDept ? "" : "-->" + mid1Adjusted));
        midTotalInputs[1].value = (mid2Total < 0) ? "Absent" : (mid2Total + (isSpecialDept ? "" : "-->" + mid2Adjusted));
    }

    // ---- Internal calculation ----
    var baseMid1 = (mid1Total < 0) ? 0 : mid1Adjusted;
    var baseMid2 = (mid2Total < 0) ? 0 : mid2Adjusted;

    var Mid1Ass = val("mid1_ass1_" + studentId);
    var Mid2Ass = val("mid2_ass1_" + studentId);

    var internal = Math.round(Math.max(baseMid1, baseMid2) * 0.8 
                             + Math.min(baseMid1, baseMid2) * 0.2) + Mid1Ass + Mid2Ass;

    var internalInput = row.querySelector(".internal");
    if (internalInput) internalInput.value = (mid1Total < 0 && mid2Total < 0) ? "Absent" : internal;
}
