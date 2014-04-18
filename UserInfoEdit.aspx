<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr, Cr;
    string SQL;
    bool IsAdmin;
    bool IsManager;
    int Id, CPId;
    string UserName, Password, Role;

    protected void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) Response.Redirect("Login.html", true);
        if (Session["UserRole"] == null && Session["UserRole"].ToString().IndexOf("system") == -1) {
            IsAdmin = false;
        } else {
            IsAdmin = true;
        }
        if (!IsAdmin) Response.Redirect("Error.aspx?err=" + Server.UrlEncode("你没有权限访问此页。"), true);
        if (Request.QueryString["id"] == null) {
            Id = 0; CPId = 0;
            UserName = ""; Password = ""; Role = "";
        } else {
            Id = Convert.ToInt32(Request.QueryString["id"]);
            if (Id == 0) {
                Id = 0; CPId = 0; ;
                UserName = ""; Password = ""; Role = "";
            } else {
                SQL = "SELECT * FROM UserInfo WHERE Id=" + Id;
                Sr = MZ.GetReader(SQL);
                if (Sr.Read()) {
                    UserName = Sr.GetString(1);
                    Password = Sr.GetString(2);
                    Role = Sr.GetString(3);
                    CPId = Sr.GetInt32(4);
                    Sr.Close();
                } else {
                    Sr.Close();
                    Response.Redirect("Error.aspx?err=" + Server.UrlEncode("没有满足条件的数据。"), true);
                }
            }
        }

        SQL = "SELECT Id,CPName FROM CPInfo";
        Sr = MZ.GetReader(SQL);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript">
        var Id = <%=Id%>;
        var jObject;

        $(document).ready(function () {
            SwitchMenu("MenuUser");

            $("#Dialog_Info").dialog({
                autoOpen: false,
                buttons: {
                    "确定": function () {
                        $(this).dialog("close");
                    }
                }
            });

            $("#Dialog_OperateWaitting").dialog({
                autoOpen: false,
                modal: true,
                width: 400,
                closeText: "hide"
            });
        });

        function AddnewUser() {
            if ($("#Text_UserName").val() == "" || $("#List_Role").val() == "" || $("#List_CP").val() == "") return;
            if ($("#Text_Password1").val() == "" || $("#Text_Password2").val() == "") return;
            if ($("#Text_Password1").val()!=$("#Text_Password2").val()){
                $("#Dialog_Info").ShowDialog("密码前后不一致。");
                return;
            }
            if (confirm("你确定要添加这个用户吗？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $.post("Ajax/UserInfoOperate.aspx", {
                id: 0, action: "ADDNEW", uname: $("#Text_UserName").val(), pwd: $("#Text_Password1").val(),
                role: $("#List_Role").val(), cpid: $("#List_CP").val()
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Text_Name").val("");
                    $("#List_Role").val("");
                    $("#List_CP").val("");
                    $("#Text_Pwd1").val("");
                    $("#Text_Pwd2").val("");
                    $("#Dialog_Info").ShowDialog("用户添加成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function UpdateUser() {
            if ($("#Text_UserName").val() == "" || $("#List_Role").val() == "" || $("#List_CP").val() == "") return;
            if ($("#Text_Password1").val() == "" || $("#Text_Password2").val() == "") return;
            if ($("#Text_Password1").val()!=$("#Text_Password2").val()){
                $("#Dialog_Info").ShowDialog("密码前后不一致。");
                return;
            }
            if (confirm("你确定要修改这个用户的信息吗？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $.post("Ajax/UserInfoOperate.aspx", {
                id: Id, action: "UPDATE", uname: $("#Text_UserName").val(), pwd: $("#Text_Password1").val(),
                role: $("#List_Role").val(), cpid: $("#List_CP").val()
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("用户信息更新成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function DeleteUser() {
            if (confirm("你确定要删除这个用户吗？\n***删除用户操作无法撤消！***") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $.post("Ajax/UserInfoOperate.aspx", { id: Id, action: "DELETE" }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("用户信息已删除。");
                    $("#btn_update").attr("disabled", "disabled");
                    $("#btn_delete").attr("disabled", "disabled");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="javascript:void(0);" onclick="window.history.back();" class="btn btn-primary">返回</a> </div>
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <div class="form-group" id="Gp_Name">
                    <label for="Text_UserName">登录名</label>
                    <input type="text" value="<%=UserName %>" id="Text_UserName" class="form-control" placeholder="登录平台时使用的名称" onblur="$(this).CheckIsEmpty('Gp_Name');" />
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group" id="Gp_Role">
                    <label for="List_Role">角色</label>
                    <select id="List_Role" class="form-control" onblur="$(this).CheckIsEmpty('Gp_Role');">
                        <option value=""<%if (Role == "") { Response.Write(" selected=\"selected\""); } %>>请选择用户角色</option>
                        <option value="system"<%if (Role == "system") { Response.Write(" selected=\"selected\""); } %>>系统管理员</option>
                        <option value="manager"<%if (Role == "manager") { Response.Write(" selected=\"selected\""); } %>>平台管理员</option>
                        <option value="user"<%if (Role == "user") { Response.Write(" selected=\"selected\""); } %>>平台用户</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group" id="Gp_Pwd1">
                    <label for="Text_Password1">登录密码</label>
                    <input type="password" value="<%=Password %>" id="Text_Password1" class="form-control" placeholder="登录平台时使用的密码" onblur="$(this).CheckIsEmpty('Gp_Pwd1');" />
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group" id="Gp_Pwd2">
                    <label for="Text_Password2">密码确认</label>
                    <input type="password" value="<%=Password %>" id="Text_Password2" class="form-control" placeholder="再次输入密码以确认是否一致" onblur="$(this).CheckIsEmpty('Gp_Pwd2');" />
                </div>
            </div>
        </div>
        <div class="form-group" id="Gp_CP">
            <label for="List_CP">隶属用户组</label>
            <select id="List_CP" class="form-control" onblur="$(this).CheckIsEmpty('Gp_CP');">
                <option value=""<%if (CPId==0) { Response.Write(" selected=\"selected\""); } %>>请选择用户隶属CP</option>
                <%while (Sr.Read()) { %>
                <option value="<%=Sr.GetInt32(0) %>"<%if (CPId == Sr.GetInt32(0)) { Response.Write(" selected=\"selected\""); } %>><%=Sr.GetString(1) %></option>
                <%} Sr.Close(); %>
            </select>
        </div>
        <div class="form-group text-center">
            <%if (Id==0){ %>
            <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddnewUser();">
            <%}else{ %>
            <input id="btn_update" type="button" value="更新" class="btn btn-success" onclick="UpdateUser();">
            <input id="btn_delete" type="button" value="删除" class="btn btn-danger" onclick="DeleteUser();">
            <%} %>
        </div>
    </div>
    <div id="Dialog_Info" title="信息"></div>
    <div id="Dialog_OperateWaitting" title="数据传递中...">
        <div class="caption text-center" id="Dialog_UploadWaitting_Text">正在传递数据</div>
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
        </div>
    </div>
</asp:Content>

