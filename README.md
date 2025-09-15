function recalcRow(row) {
    var studentId = row.querySelector("td").textContent.trim();

    // safe parser: returns integer or null (if empty / non-numeric)
    function valRaw(name) {
        var el = row.querySelector("input[name='" + name + "']");
        if (!el) return null;
        var s = el.value.trim();
        if (s === "") return null;
        var v = parseInt(s, 10);
        return isNaN(v) ? null : v;
    }

    // checks a list of fields for any negative (<0) value
    function hasNegative(prefixes) {
        for (var i = 0; i < prefixes.length; i++) {
            var v = valRaw(prefixes[i] + studentId);
            if (v !== null && v < 0) return true;
        }
        return false;
    }

    // build lists of fields to check for mid1/mid2
    var mid1Fields = [];
    var mid2Fields = [];
    // OBJ1-3 and ASS1-3
    for (var i = 1; i <= 3; i++) {
        mid1Fields.push("mid1_obj" + i + "_");
        mid2Fields.push("mid2_obj" + i + "_");
        mid1Fields.push("mid1_ass" + i + "_");
        mid2Fields.push("mid2_ass" + i + "_");
    }
    // Q1..6 (a,b)
    for (var q = 1; q <= 6; q++) {
        for (var sub of ['a','b']) {
            mid1Fields.push("mid1_q" + q + sub + "_");
            mid2Fields.push("mid2_q" + q + sub + "_");
        }
    }

    var absentMid1 = hasNegative(mid1Fields);
    var absentMid2 = hasNegative(mid2Fields);

    // compute totals ONLY if not absent, otherwise totals stay 0 (and we'll display "Absent")
    var mid1Total = 0, mid2Total = 0;

    if (!absentMid1) {
        // NOTE: original logic used only obj1 — keep same behaviour (change if you want obj2/3 included)
        var o1 = valRaw("mid1_obj1_" + studentId) || 0;
        mid1Total += o1;

        // pairs: (1a+1b) vs (2a+2b), (3a+3b) vs (4a+4b), (5a+5b) vs (6a+6b)
        for (var p = 1; p <= 6; p += 2) {
            var a = valRaw("mid1_q" + p + "a_" + studentId) || 0;
            var b = valRaw("mid1_q" + p + "b_" + studentId) || 0;
            var c = valRaw("mid1_q" + (p + 1) + "a_" + studentId) || 0;
            var d = valRaw("mid1_q" + (p + 1) + "b_" + studentId) || 0;
            var pair1 = a + b;
            var pair2 = c + d;
            mid1Total += Math.max(pair1, pair2);
        }
    }

    if (!absentMid2) {
        var o2 = valRaw("mid2_obj1_" + studentId) || 0;
        mid2Total += o2;

        for (var p2 = 1; p2 <= 6; p2 += 2) {
            var aa = valRaw("mid2_q" + p2 + "a_" + studentId) || 0;
            var bb = valRaw("mid2_q" + p2 + "b_" + studentId) || 0;
            var cc = valRaw("mid2_q" + (p2 + 1) + "a_" + studentId) || 0;
            var dd = valRaw("mid2_q" + (p2 + 1) + "b_" + studentId) || 0;
            var pairA = aa + bb;
            var pairB = cc + dd;
            mid2Total += Math.max(pairA, pairB);
        }
    }

    // ASS1 marks (for addition to internal). If ASS1 is negative, treat that mid as absent (and don't add negative)
    var mid1AssRaw = valRaw("mid1_ass1_" + studentId);
    if (mid1AssRaw !== null && mid1AssRaw < 0) absentMid1 = true;
    var mid1Ass = (mid1AssRaw !== null && mid1AssRaw > 0) ? mid1AssRaw : (mid1AssRaw === 0 ? 0 : (mid1AssRaw === null ? 0 : (mid1AssRaw < 0 ? 0 : mid1AssRaw)));

    var mid2AssRaw = valRaw("mid2_ass1_" + studentId);
    if (mid2AssRaw !== null && mid2AssRaw < 0) absentMid2 = true;
    var mid2Ass = (mid2AssRaw !== null && mid2AssRaw > 0) ? mid2AssRaw : (mid2AssRaw === 0 ? 0 : (mid2AssRaw === null ? 0 : (mid2AssRaw < 0 ? 0 : mid2AssRaw)));

    // compute adjusted values (non-special dept shows "--> adjusted")
    var mid1Adjusted = isSpecialDept ? mid1Total : (Math.floor(mid1Total / 4) + Math.floor(mid1Total / 2));
    var mid2Adjusted = isSpecialDept ? mid2Total : (Math.floor(mid2Total / 4) + Math.floor(mid2Total / 2));

    // update mid columns (".midTotal" should target the two mid columns)
    var midTotalInputs = row.querySelectorAll(".midTotal");
    if (midTotalInputs.length >= 2) {
        midTotalInputs[0].value = absentMid1 ? "Absent" : (mid1Total + (isSpecialDept ? "" : "-->" + mid1Adjusted));
        midTotalInputs[1].value = absentMid2 ? "Absent" : (mid2Total + (isSpecialDept ? "" : "-->" + mid2Adjusted));
    }

    // Internal calculation:
    var internalInput = row.querySelector(".internal");
    if (internalInput) {
        if (absentMid1 && absentMid2) {
            internalInput.value = "Absent";
        } else {
            // treat absent mid as 0 for internal computation
            var baseMid1 = absentMid1 ? 0 : (isSpecialDept ? mid1Total : mid1Adjusted);
            var baseMid2 = absentMid2 ? 0 : (isSpecialDept ? mid2Total : mid2Adjusted);

            var internal = Math.round(Math.max(baseMid1, baseMid2) * 0.8 + Math.min(baseMid1, baseMid2) * 0.2)
                           + (absentMid1 ? 0 : mid1Ass)
                           + (absentMid2 ? 0 : mid2Ass);

            internalInput.value = internal;
        }
    }
}
