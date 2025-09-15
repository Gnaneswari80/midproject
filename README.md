 
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

    var mid1Total = val("mid1_obj1_" + studentId);
    var mid2Total = val("mid2_obj1_" + studentId);

    for(var q=1;q<=6;q+=2){
        mid1Total += Math.max(val("mid1_q"+q+"a_"+studentId), val("mid1_q"+q+"b_"+studentId));
        mid1Total += Math.max(val("mid1_q"+(q+1)+"a_"+studentId), val("mid1_q"+(q+1)+"b_"+studentId));

        mid2Total += Math.max(val("mid2_q"+q+"a_"+studentId), val("mid2_q"+q+"b_"+studentId));
        mid2Total += Math.max(val("mid2_q"+(q+1)+"a_"+studentId), val("mid2_q"+(q+1)+"b_"+studentId));
    }

    var midTotalInputs = row.querySelectorAll(".midTotal");
    if(midTotalInputs.length >= 2){
        midTotalInputs[0].value = (mid1Total < 0) ? "Absent" : mid1Total;
        midTotalInputs[1].value = (mid2Total < 0) ? "Absent" : mid2Total;
    }
}
