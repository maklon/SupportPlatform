<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>

<%@ Page Language="C#" %>

<script runat="server">
    DS MZ = new DS(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    DataTable Dt;
    string SQL;
    int PageId, TotalDataCount, TotalPageCount, StartId, EndId, StartPageId, EndPageId;
    int PageSize = 20;
    int PageSpan = 4;
    string Role = "";

    protected void Page_Load(object sender, EventArgs e) {
        if (Request.QueryString["page"] == null) {
            PageId = 1;
        } else {
            PageId = Convert.ToInt32(Request.QueryString["page"]);
        }
        Role = Request.QueryString["role"];
        if (Role == null) {
            Role = "";
        } else {
            DB.SQLFiltrate(ref Role);
        }

        SQL = "SELECT TOP " + (PageId * PageSize) + " UserInfo.Id,UserInfo.UserName,UserInfo.Role,CPInfo.CPName "
            + "FROM UserInfo INNER JOIN CPInfo ON UserInfo.CPId=CPInfo.Id";
        if (Role != "") SQL += " WHERE UserInfo.Role='" + Role + "'";
        MZ.CreateDataTable(SQL, "UL");
        Dt = MZ.Tables["UL"];
        StartId = (PageId - 1) * PageSize;
        EndId = PageId * PageSize;
        SQL = "SELECT COUNT(*) FROM UserInfo";
        if (Role != "") SQL += " WHERE Role='" + Role + "'";
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            TotalDataCount = Sr.GetInt32(0);
            TotalPageCount = (TotalDataCount - 1) / PageSize + 1;
            Sr.Close();
            StartPageId = PageId - PageSpan;
            EndPageId = PageId + PageSpan;
            if (StartPageId < 1) StartPageId = 1;
            if (EndPageId > TotalPageCount) EndPageId = TotalPageCount;
        } else {
            Sr.Close();
            TotalDataCount = 0;
            TotalPageCount = 1;
            StartPageId = 1;
            EndPageId = 1;
        }
    }

    protected void Page_Unload(object sender, EventArgs e) {
        MZ = null;
        Dt = null;
    }

    protected string GetRoleDisplayName(string role) {
        if (role == "system") {
            return "系统管理员";
        } else if (role == "manager") {
            return "平台管理员";
        } else if (role == "user") {
            return "平台用户";
        } else {
            return role;
        }
    }

</script>
<table class="table table-hover table-striped">
    <thead style="font-weight: bold; font-size: 16px;">
        <tr>
            <td style="width: 10%">#</td>
            <td style="width: 30%">用户名</td>
            <td style="width: 20%">角色</td>
            <td style="width: 30%">所属CP</td>
            <td style="width: 10%">操作</td>
        </tr>
    </thead>
    <tbody>
        <%for (int i = StartId; i < EndId && i < Dt.Rows.Count; i++) { %>
        <tr>
            <td><%=Dt.Rows[i][0] %></td>
            <td><%=Dt.Rows[i]["UserName"] %></td>
            <td><%=GetRoleDisplayName(Dt.Rows[i]["Role"].ToString()) %></td>
            <td><%=Dt.Rows[i]["CPName"] %></td>
            <td><a href="UserInfoEdit.aspx?id=<%=Dt.Rows[i][0] %>" class="text-primary">编辑</a></td>
        </tr>
        <%} %>
    </tbody>
</table>
<div class="text-right">
    <ul class="pagination">
        <li<%if (PageId == 1) { Response.Write(" class=\"disabled\""); } %>><a href="javascript:void(0);" onclick="GetData(1);">&laquo;</a></li>
        <%for (int i = StartPageId; i <= EndPageId; i++) { %>
        <li<%if (i == PageId) { Response.Write(" class=\"active\""); } %>><a href="javascript:void(0);" onclick="GetData(<%=i %>);"><%=i %></a></li>
        <%} %>
        <li<%if (PageId == TotalPageCount) { Response.Write(" class=\"disabled\""); } %>><a href="javascript:void(0);" onclick="GetData(<%=TotalPageCount %>);">&raquo;</a>
        </li>
    </ul>
</div>
