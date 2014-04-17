<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string SQL, TypeId;
    string[] TypeNames = { "", "文档", "咨询" };

    void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) Response.Redirect("Login.html", true);
        if (Session["UserRole"].ToString().IndexOf("system") == -1) Response.Redirect("Error.aspx?err=" + Server.UrlEncode("你没有权限进入此页面"), true);
        TypeId = Request.QueryString["tid"];
        if (string.IsNullOrEmpty(TypeId) || !General.IsMatch(TypeId, "^[1-2]$")) {
            SQL = "SELECT * FROM ClassList";
        } else {
            SQL = "SELECT * FROM ClassList WHERE TypeId=" + TypeId;
        }
        Sr = MZ.GetReader(SQL);

    }

    void Page_Unload(object Sender, EventArgs e) {
        MZ = null;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript">
        var Id;
        var jObject;

        $(document).ready(function () {
            SwitchMenu("MenuClass");
            $("#Dialog_ClassInfo").dialog({
                autoOpen: false,
                Modal: true,
                width: 500,
                height: 250
            });

            $("#Dialog_Info").dialog({
                autoOpen: false,
                buttons: {
                    "确定": function () {
                        $(this).dialog("close");
                    }
                }
            });
        });

        function ShowClass(id, name, type) {
            $("#Text_ClassName").val(name);
            $("#List_ClassType").val(type);
            Id = id;
            if (Id == 0) {
                $("#btn_addnew").show();
                $("#btn_update").hide();
                $("#btn_delete").hide();
            } else {
                $("#btn_addnew").hide();
                $("#btn_update").show();
                $("#btn_delete").show();
            }
            $("#Dialog_ClassInfo").dialog("open");
        }

        function AddNewClass() {
            if ($("#Text_ClassName").val() == "" || $("#List_ClassType").val() == "") return;
            if (confirm("你确定要添加这个分类信息吗？") == false) return;
            $("#btn_addnew").attr("disabled", "disabled");
            $.post("Ajax/ClassOperate.aspx", { id: 0,action:"ADDNEW", name: $("#Text_ClassName").val(), type: $("#List_ClassType").val() }, function (data) {
                $("#btn_addnew").removeAttr("disabled");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_ClassInfo").dialog("close");
                    $("#Dialog_Info").ShowDialog("分类添加成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function UpdateClass() {
            if ($("#Text_ClassName").val() == "" || $("#List_ClassType").val() == "") return;
            $("#btn_update").attr("disabled", "disabled");
            $("#btn_delete").attr("disabled", "disabled");
            $.post("Ajax/ClassOperate.aspx", { id: Id,Action:"UPDATE", name: $("#Text_ClassName").val(), type: $("#List_ClassType").val() }, function (data) {
                $("#btn_update").removeAttr("disabled");
                $("#btn_delete").removeAttr("disabled");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_ClassInfo").dialog("close");
                    $("#Dialog_Info").ShowDialog("分类更新成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function DeleteClass() {
            if (confirm("你确定要删除这条分类信息吗？") == false) return;
            $("#btn_update").attr("disabled", "disabled");
            $("#btn_delete").attr("disabled", "disabled");
            $.post("Ajax/ClassOperate.aspx", {id:Id,action:"DELETE"},function(data){
                $("#btn_update").removeAttr("disabled");
                $("#btn_delete").removeAttr("disabled");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_ClassInfo").dialog("close");
                    $("#Dialog_Info").ShowDialog("分类删除成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;">
        <a href="?tid=0" class="label label-info">全部分类</a>&nbsp;<a href="?tid=1" class="label label-info">文档</a>&nbsp;<a href="?tid=2" class="label label-info">咨询</a>&nbsp;
        <a href="javascript:void(0);" onclick="ShowClass(0,'','');" class="btn btn-primary">添加新分类</a>
    </div>
    <div class="container" style="width: 500px;">
        <table class="table table-hover table-striped">
            <thead style="font-weight: bold; font-size: 16px;">
                <tr>
                    <td style="width: 10%">#</td>
                    <td style="width: 50%">分类名称</td>
                    <td style="width: 20%">所属类别</td>
                    <td style="width: 20%">操作</td>
                </tr>
            </thead>
            <tbody>
                <%while (Sr.Read()) { %>
                <tr>
                    <td><%=Sr.GetInt32(0) %></td>
                    <td><%=Sr.GetString(2) %></td>
                    <td><%=TypeNames[Sr.GetInt32(1)] %></td>
                    <td><a href="javascript:void(0);" onclick="ShowClass(<%=Sr.GetInt32(0) %>,'<%=Sr.GetString(2) %>','<%=Sr.GetInt32(1) %>');" class="text-primary">编辑</a></td>
                </tr>
                <%} Sr.Close(); %>
            </tbody>
        </table>

    </div>
    <div id="Dialog_ClassInfo" style="width: 500px;" title="分类信息">
        <form role="form" class="form-horizontal">
            <div class="form-group" id="form-classname">
                <label for="Text_ClassName" class="col-md-3 control-label">*分类名称：</label>
                <div class="col-md-9">
                    <input id="Text_ClassName" type="text" class="form-control" placeholder="分类的名称(最多10个汉字)" maxlength="10" onblur="$(this).CheckIsEmpty('form-classname');" />
                </div>
            </div>
            <div class="form-group" id="form-typename">
                <label for="List_ClassType" class="col-md-3 control-label">*所属类型：</label>
                <div class="col-md-9">
                    <select id="List_ClassType" class="form-control" onblur="$(this).CheckIsEmpty('form-typename');">
                        <option value="" selected="selected">请选择分类类型</option>
                        <option value="1">文档</option>
                        <option value="2">咨询</option>
                    </select>
                </div>
            </div>
            <div class="form-group" style="text-align: center;">
                <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddNewClass();">
                <input id="btn_update" type="button" value="编辑" class="btn btn-info" onclick="UpdateClass();">
                <input id="btn_delete" type="button" value="删除" class="btn btn-danger" onclick="DeleteClass();">
            </div>
        </form>
    </div>
    <div id="Dialog_Info" title="信息"></div>
</asp:Content>

