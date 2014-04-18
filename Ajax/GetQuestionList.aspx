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
    int PageId, ClassId, PublicStatus,TotalDataCount, TotalPageCount, StartId, EndId, StartPageId, EndPageId;
    int PageSize = 20;
    int PageSpan = 4;
    bool IsAdmin, IsManager;

    protected void Page_Load(object sender, EventArgs e) {
        if (Session["Role"] == null) {
            Response.Write("登录已超时，请重新登录。");
            Response.End();
        } else {
            IsAdmin = false;
            IsManager = false;
            if (Session["Role"].ToString() == "system") {
                IsAdmin = true;
            }
            if (Session["Role"].ToString() == "manager") {
                IsManager = true;
            }
        }
        if (Request.QueryString["page"] == null) {
            PageId = 1;
        } else {
            PageId = Convert.ToInt32(Request.QueryString["page"]);
        }
        if (Request.QueryString["cid"] == null) {
            ClassId = 0;
        } else {
            ClassId = Convert.ToInt32(Request.QueryString["cid"]);
        }
        if (Request.QueryString["sid"] == null) {
            PublicStatus = 0;
        } else {
            PublicStatus = Convert.ToInt32(Request.QueryString["sid"]);
        }

        SQL = "SELECT TOP " + (PageId * PageSize) + "QuestionList.Title,QuestionList.Dot,QuestionList.Re,QuestionList.VisableLevel,"
            + "QuestionList.AddTime,QuestionList.LastReTime,CPInfo.CPNameShort FROM QuestionList INNER JOIN CPInfo ON QuestionList.AddUserCPId="
            + "CPInfo.Id WHERE ParentId=0";
        if (IsAdmin || IsManager) {
            SQL += " AND QuestionList.VisableLevel>0";
        } else {
            SQL += " AND (QuestionList.VisableLevel=10 OR (QuestionList.VisableLevel=1 AND QuestionList.AddUserCPId=)" + Session["CPId"].ToString() + ")";
        }
        if (ClassId > 0) SQL += " AND DocumentList.ClassId=" + ClassId;
        SQL += " ORDER BY DocumentList.OrderId DESC,DocumentList.Id DESC";
        MZ.CreateDataTable(SQL, "DL");
        Dt = MZ.Tables["DL"];
        StartId = (PageId - 1) * PageSize;
        EndId = PageId * PageSize;
        SQL = "SELECT COUNT(*) FROM DocumentList";
        if (ClassId > 0) SQL += " WHERE ClassId=" + ClassId;
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

</script>
<table class="table table-hover table-striped">
    <thead style="font-weight: bold; font-size: 16px;">
        <tr>
            <td style="width: 10%">#</td>
            <td style="width: 40%">标题</td>
            <td style="width: 20%">分类</td>
            <td style="width: 20%">发布时间</td>
            <td style="width: 10%">操作</td>
        </tr>
    </thead>
    <tbody>
        <%for (int i = StartId; i < EndId && i < Dt.Rows.Count; i++) { %>
        <tr>
            <td><%=Dt.Rows[i][0] %></td>
            <td><%=Dt.Rows[i]["Title"] %></td>
            <td><%=Dt.Rows[i]["ClassName"] %></td>
            <td><%=((DateTime)(Dt.Rows[i]["AddTime"])).ToString("yyyy年MM月dd日") %></td>
            <td><a href="DocumentEdit.aspx?id=<%=Dt.Rows[i][0] %>" class="text-primary">编辑</a></td>
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
