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
    int PageId, ClassId, PublicStatus, TotalDataCount, TotalPageCount, StartId, EndId, StartPageId, EndPageId;
    int PageSize = 20;
    int PageSpan = 4;
    bool IsAdmin, IsManager;

    protected void Page_Load(object sender, EventArgs e) {
        if (Session["UserRole"] == null) {
            Response.Write("登录已超时，请重新登录。");
            Response.End();
        } else {
            IsAdmin = false;
            IsManager = false;
            if (Session["UserRole"].ToString() == "system") {
                IsAdmin = true;
            }
            if (Session["UserRole"].ToString() == "manager") {
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

        SQL = "SELECT TOP " + (PageId * PageSize) + "QuestionList.Id, QuestionList.Title,ClassList.ClassName,QuestionList.Dot,QuestionList.Re,QuestionList.VisableLevel,"
            + "QuestionList.Status,QuestionList.AddTime,QuestionList.LastReTime,CPInfo.CPNameShort FROM QuestionList INNER JOIN CPInfo ON QuestionList.AddUserCPId="
            + "CPInfo.Id INNER JOIN ClassList ON QuestionList.ClassId=ClassList.Id WHERE QuestionList.ParentId=0 AND QuestionList.Status>0";
        if (IsAdmin || IsManager) {
            SQL += " AND QuestionList.VisableLevel>0";
        } else {
            SQL += " AND (QuestionList.VisableLevel=10 OR (QuestionList.VisableLevel=5 AND QuestionList.AddUserCPId=" + Session["CPId"].ToString() + ")";
        }
        if (ClassId > 0) SQL += " AND DocumentList.ClassId=" + ClassId;
        SQL += " ORDER BY QuestionList.OrderId DESC,QuestionList.Id DESC";
        MZ.CreateDataTable(SQL, "DL");
        Dt = MZ.Tables["DL"];
        StartId = (PageId - 1) * PageSize;
        EndId = PageId * PageSize;
        SQL = "SELECT COUNT(*) FROM QuestionList WHERE ParentId=0 AND Status>0";
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

    protected string GetStatusDisplayName(int status) {
        switch (status) {
            case 1:
                return "<span class=\"label label-warning\">等待回复</span>";
            case 2:
                return "<span class=\"label label-info\">讨论中</span>";
            case 3:
                return "<span class=\"label label-danger\">锁定</span>";
            case 10:
                return "<span class=\"label label-success\">完结</span>";
            default:
                return "<span class=\"label label-default\">未知</span>";
        }
    }

    protected string GetVisableLevelDisplayName(int visable) {
        switch (visable) {
            case 1:
                return "<span style=\"color:#d9534f; font-weight:bold;\">仅自己可见</span>";
            case 5:
                return "<span style=\"color:#5bc0de; font-weight:bold;\">仅本CP可见</span>";
            case 10:
                return "<span style=\"color:#5cb85c; font-weight:bold;\">全部可见</span>";
            default:
                return "<span style=\"color:#999999; font-weight:bold;\">未知</span>";
        }
    }

    protected string GetDateTimeSpanDisplayName(DateTime dt) {
        TimeSpan ts;
        ts = DateTime.Now - dt;
        if (ts.TotalMinutes < 6) {
            return "刚刚";
        } else if (ts.TotalMinutes < 60) {
            return (int)ts.TotalMinutes + "分钟前";
        } else if (ts.TotalHours < 24) {
            return (int)ts.TotalHours + "小时前";
        } else if (ts.TotalDays < 7) {
            return (int)ts.TotalDays + "天以前";
        } else if (ts.TotalDays/7<4) {
            return (int)ts.TotalDays/7+"周以上";
        }else if (ts.TotalDays<60){
            return "1个月以上";    
        } else {
            return "很久了";
        }
    }

</script>
<table class="table table-hover table-striped">
    <thead style="font-weight: bold; font-size: 16px;">
        <tr>
            <td style="width: 5%">#</td>
            <td style="width: 30%">标题</td>
            <td style="width: 10%">分类</td>
            <td style="width: 5%">点击</td>
            <td style="width: 5%">回复</td>
            <td style="width: 9%">发起CP</td>
            <td style="width: 8%">可见级别</td>
            <td style="width: 8%">状态</td>
            <td style="width: 10%">发起时间</td>
            <td style="width: 10%">回复时间</td>
        </tr>
    </thead>
    <tbody>
        <%for (int i = StartId; i < EndId && i < Dt.Rows.Count; i++) { %>
        <tr>
            <td><%=Dt.Rows[i][0] %></td>
            <td><%=Dt.Rows[i]["Title"] %></td>
            <td><%=Dt.Rows[i]["ClassName"] %></td>
            <td><%=Dt.Rows[i]["Dot"] %></td>
            <td><%=Dt.Rows[i]["Re"] %></td>
            <td><%=Dt.Rows[i]["CPNameShort"] %></td>
            <td><%=GetVisableLevelDisplayName((int)Dt.Rows[i]["VisableLevel"]) %></td>
            <td><%=GetStatusDisplayName((int)Dt.Rows[i]["Status"]) %></td>
            <td><%=GetDateTimeSpanDisplayName((DateTime)(Dt.Rows[i]["AddTime"])) %></td>
            <td><%if (Dt.Rows[i]["LastReTime"].ToString()==""){Response.Write("--");}else{Response.Write(GetDateTimeSpanDisplayName((DateTime)(Dt.Rows[i]["LastReTime"])));} %></td>
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
