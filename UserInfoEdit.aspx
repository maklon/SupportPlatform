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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="Text_UserName">登录名</label>
                    <input type="text" value="" id="Text_UserName" class="form-control" placeholder="登录平台时使用的名称" />
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="List_Role">角色</label>
                    <select id="List_Role" class="form-control">
                        <option value="">请选择用户角色</option>
                        <option value="system">系统管理员</option>
                        <option value="manager">平台管理员</option>
                        <option value="user">平台用户</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="Text_Password1">登录密码</label>
                    <input type="password" value="" id="Text_Password1" class="form-control" placeholder="登录平台时使用的密码" />
                </div>
            </div>
            <div class="col-md-6">
                <label for="Text_Password2">密码确认</label>
                <input type="password" value="" id="Text_Password2" class="form-control" placeholder="再次输入密码以确认是否一致" />
            </div>
        </div>
        <div class="form-group">
        	<label for="List_CP">隶属用户组</label>
            <select id="List_CP" class="form-control">
                        <option value="">请选择用户隶属CP</option>
                        <%while(Sr.Read()){ %>
                <option value="<%=Sr.GetInt32(0) %>"><%=Sr.GetString(1) %></option>
                <%} Sr.Close(); %>
                    </select>
        </div>
        <div class="form-group text-center">
            <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddnewDoc();">
            <input id="btn_update" type="button" value="更新" class="btn btn-success" onclick="UpdateDoc();">
            <input id="btn_delete" type="button" value="删除" class="btn btn-danger" onclick="DeleteDoc();">
        </div>
    </div>
</asp:Content>

