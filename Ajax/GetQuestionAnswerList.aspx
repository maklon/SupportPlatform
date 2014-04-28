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
    int PageId, Id, PublicStatus, TotalDataCount, TotalPageCount, StartId, EndId, StartPageId, EndPageId;
    int PageSize = 10;
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
        if (Request.QueryString["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request.QueryString["id"]);
        }
        if (Id == 0) {
            Response.Write("<div class=\"caption text-center\">暂时没有回复</div>");
            Response.End();
        }
        SQL = "SELECT TOP " + (PageId * PageSize) + " QuestionList.*,UserInfo.UserName,CPInfo.CPNameShort FROM QuestionList "
            + "INNER JOIN UserInfo ON QuestionList.AddUserId=UserInfo.Id "
            + "INNER JOIN CPInfo ON QuestionList.AddUserCPId=CPInfo.Id "
            + "WHERE QuestionList.Status>0 AND QuestionList.ParentId=" + Id;

        MZ.CreateDataTable(SQL, "DL");
        Dt = MZ.Tables["DL"];

        if (Dt.Rows.Count == 0) {
            Response.Write("<div class=\"caption text-center\">暂时没有回复</div>");
            Response.End();
        }
        StartId = (PageId - 1) * PageSize;
        EndId = PageId * PageSize;
        SQL = "SELECT COUNT(*) FROM QuestionList WHERE Status>0 AND ParentId=" + Id;

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
        } else if (ts.TotalDays / 7 < 4) {
            return (int)ts.TotalDays / 7 + "周以上";
        } else if (ts.TotalDays < 60) {
            return "1个月以上";
        } else {
            return "很久了";
        }
    }

</script>
<%for (int i = StartId; i < EndId && i < Dt.Rows.Count; i++) { %>
<div class="QuestionParent">
    <div class="QuestionContent QuestionContent_Re">
        <div class="LeftPanel">
            <p>回复人：<%=Dt.Rows[i]["UserName"] %></p>
            <p>所属CP：<%=Dt.Rows[i]["CPNameShort"] %></p>
            <p>回复时间：</p>
            <p><%=Dt.Rows[i]["AddTime"] %></p>
            <p><%if ((int)Dt.Rows[i]["Status"]==5) {%>
                <h3 class="text-center"><span class="label label-info">参考答案</span></h3>
                <%}else if((int)Dt.Rows[i]["Status"]==6){ %>
                <h3 class="text-center"><span class="label label-success">最佳答案</span></h3>
                <%} %>
            </p>
        </div>
        <div class="RightPanel">
            <div class="btn-toolbar" style="margin-bottom: 10px;">
                <%if (IsAdmin || IsManager){ %>
                <div class="btn-group">
                    <button type="button" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown">设为答案<span class="caret"></span></button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="javascript:void(0);" onclick="SetStatus(<%=Dt.Rows[i][0] %>,1);">取消标识</a></li>
                        <li><a href="javascript:void(0);" onclick="SetStatus(<%=Dt.Rows[i][0] %>,5);">设为标准答案</a></li>
                        <li><a href="javascript:void(0);" onclick="SetStatus(<%=Dt.Rows[i][0] %>,6);">设为最佳答案</a></li>
                    </ul>
                </div>
                <%} %>
                <%if ((int)Dt.Rows[i]["AddUserId"]==(int)Session["UserId"]){ %>
                <div class="btn-group">
                    <button type="button" class="btn btn-danger btn-sm" onclick="DeleteIt(<%=Dt.Rows[i][0] %>);">删除</button>
                </div>
                <%} %>
            </div>
            <%=Dt.Rows[i]["ContentText"] %>
        </div>
    </div>
</div>
<%} %>
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
