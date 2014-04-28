<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string Title, Content, ClassId,Visable, Action, SQL;
    int Id;
    string JsonResult;
    ResultInfo rInfo = new ResultInfo();
    
    void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) {
            rInfo.ResultMessage = "登录已超时，请重新登录。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        
        
        if (Request.Form["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }

        Title = Request.Form["title"];
        Content = Server.UrlDecode(Request.Form["content"]);
        ClassId = Request.Form["cid"];
        Visable = Request.Form["visable"];
        if (string.IsNullOrEmpty(Content)) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "咨询内容为空。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        if (Id == 0) {
            if (string.IsNullOrEmpty(Title)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "咨询标题为空。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }

            if (string.IsNullOrEmpty(ClassId) || !General.IsMatch(ClassId, "^\\d+$") || ClassId == "0") {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "请选择文档的分类。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
        }
        if (string.IsNullOrEmpty(Visable) || !General.IsMatch(Visable, "^\\d+$")) {
            Visable = "1";
        }
        DB.SQLFiltrate(ref Title);
        DB.SQLFiltrate(ref Content);

        if (Id == 0) {
            SQL = "INSERT INTO QuestionList (ParentId,ClassId,Title,ContentText,VisableLevel,AddUserId,AddUserCPId) VALUES(0,"
                + ClassId + ",'" + Title + "','" + Content + "'," + Visable + "," + Session["UserId"].ToString()
                + "," + Session["CPId"].ToString() + ")";
        } else {
            SQL = "INSERT INTO QuestionList (ParentId,ContentText,AddUserId,AddUserCPId) VALUES(" + Id + ",'"
                + Content + "'" + "," + Session["UserId"].ToString() + "," + Session["CPId"].ToString() + ");"
                + "UPDATE QuestionList SET Re=Re+1,Status=2,LastReTime=GETDATE() WHERE Id=" + Id; 
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
