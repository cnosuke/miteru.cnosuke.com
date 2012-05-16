$(function() {
    colors = ['#F2EE2F','#6223E0','#DA2619','#04C628','#E30663'];
    $.each($('h2'), function(i,obj){
        $(obj).css('border-bottom','solid 2px '+colors[i%colors.length]);
    });
});
