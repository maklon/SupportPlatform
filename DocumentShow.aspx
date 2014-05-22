<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage_NoLogin.master" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    string SQL, Title, Content, LinkUrl, EditUser, EditTime;
    int Id, VisableLevel, Status;
    SqlDataReader Sr;
    bool IsMe, IsAdmin, IsManager;

    protected void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null || Session["UserRole"] == null) {
            IsAdmin = false;
            IsManager = false;
            Session["UserId"] = 0;
        } else {
            if (Session["UserRole"].ToString() == "system") {
                IsAdmin = true;
            } else if (Session["UserRole"].ToString() == "manager") {
                IsManager = true;
            } else {
                IsAdmin = false;
                IsManager = false;
            }
        }
        
        if (Request.QueryString["id"] == null) {
            Response.Redirect("Error.aspx?err=" + Server.UrlEncode("参数错误。"), true);
        } else {
            Id = Convert.ToInt32(Request.QueryString["id"]);
        }
        SQL = "SELECT DocumentList.*,UserInfo.UserName FROM DocumentList INNER JOIN UserInfo ON DocumentList.LastEditUserId=UserInfo.Id WHERE DocumentList.Id=" + Id;
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            LinkUrl = Sr.GetString(4);
            if (LinkUrl != "") {
                Sr.Close();
                Response.Redirect(LinkUrl, true);
            }
            Title = Sr.GetString(2);
            Content = Sr.GetString(3);
            EditTime = Sr.GetDateTime(9).ToString();
            EditUser = Sr.GetString(10);
            Sr.Close();
        } else {
            Sr.Close();
            Response.Redirect("Error.aspx?err=" + Server.UrlEncode("没有满足条件的数据。"), true);
        }
    }

    protected void Page_Unload(object Sender, EventArgs e) {
        MZ = null;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" Runat="Server">
    <style type="text/css">
        #DocumentArea p{
            text-indent:2em;
        }
    </style>
    <script type="text/javascript" src="highlight/highlight.pack.js"></script>
    <link href="highlight/styles/github.css" rel="stylesheet" type="text/css">
    <script type="text/javascript">
        $(document).ready(function () {
            hljs.initHighlightingOnLoad();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" Runat="Server">
    <%if (IsAdmin || IsManager){ %>
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="DocumentEdit.aspx?id=<%=Id %>" class="btn btn-primary">编辑</a> </div>
    <%} %>
    <div class="container" id="DocumentArea">
        <h1 class="text-center" style="font-weight:bold;"><%=Title %></h1>
        <p></p>
        <%=Content %>
        <p class="text-right"><i><%=EditUser+"更新于"+EditTime %></i></p>
    </div>
</asp:Content>

