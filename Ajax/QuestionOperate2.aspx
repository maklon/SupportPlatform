<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    int Id, Val;
    string JsonResult, SQL, Action;
    ResultInfo rInfo = new ResultInfo();
    bool IsAdmin, IsManager;
    
    void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) {
            rInfo.ResultMessage = "登录已超时，请重新登录。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        if (Session["UserRole"].ToString() == "system") {
            IsAdmin = true;
        } else if (Session["UserRole"].ToString() == "manager") {
            IsManager = true;
        } else {
            IsAdmin = false; IsManager = false;
        }
        
        if (Request.QueryString["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }
        if (Request.QueryString["val"] == null) {
            Val = 0;
        } else {
            Val = Convert.ToInt32(Request["val"]);
        }

        Action = Request.QueryString["action"];
        SQL = "";
        if (Action == "ORDER" &&(IsAdmin || IsManager)) {
            SQL = "UPDATE QuestionList SET OrderId=" + Val + " WHERE Id=" + Id;
        } else if (Action == "STATUS" && (IsAdmin || IsManager)) {
            SQL = "UPDATE QuestionList SET Status=" + Val + " WHERE Id=" + Id;
        } else if (Action == "VISABLE" && (IsAdmin || IsManager)) {
            SQL = "UPDATE QuestionList SET VisableLevel=" + Val + " WHERE Id=" + Id;
        } else if (Action == "DELETE") {
            SQL = "UPDATE QuestionList SET Status=0 WHERE Id=" + Id + " AND AddUserId=" + Session["UserId"].ToString();
        } else {
            rInfo.ResultMessage = "不能识别的命令或权限不足。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }

        try {
            MZ.ExecuteSQL(SQL);
        } catch (Exception ex) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = ex.Message;
        }

        JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
        Response.Write(JsonResult);
    }

    void Page_Unload(object Sender, EventArgs e) {
        MZ = null;
    }

    public class ResultInfo
    {
        public int ResultCode;
        public string ResultMessage;

        public ResultInfo() {
            ResultCode = 0;
            ResultMessage = "";
        }

        public ResultInfo(int resultCode, string resultMessage) {
            this.ResultCode = resultCode;
            this.ResultMessage = resultMessage;
        }
    }
</script>
