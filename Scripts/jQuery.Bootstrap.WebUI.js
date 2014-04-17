(function($){
	$.showMask = function () {
        if (!$("#MaskDiv").length) {
            $(document.body).append("<div id=\"MaskDiv\" style=\"display:none\"></div>");
        }
        $("#MaskDiv").css({ width: "100%", height: $(document).height() + "px", position: "absolute", left: "0px", top: "0px", opacity: 0.3, background: "#999999", zIndex: 8000 });
        $("select").attr("disabled", "disabled");
        $("#MaskDiv").show();
    };
    $.hideMask = function () {
        $("select").removeAttr("disabled");
        $("#MaskDiv").hide();
    };
	$.fn.SetProgressValue=function(val){
		$(this).css("width",val+"%");	
	};
	$.fn.ShowDialog=function(text){
		$(this).text(text);
		$(this).dialog("open");	
	}
	$.fn.AddOption=function(name,val){
		$(this).append("<option value=\""+val+"\">"+name+"</option>");	
	}
	$.fn.CheckIsEmpty=function(group){
		if ($(this).val()==""){
			$("#"+group).attr("class","form-group has-error");	
		}else{
			$("#"+group).attr("class","form-group has-success");	
		}
	};
})(jQuery);