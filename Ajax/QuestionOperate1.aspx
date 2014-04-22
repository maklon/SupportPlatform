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
    
    void Page_Load(object Sender, EventArgs e) {
        if (Request.Form["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }

        ResultInfo rInfo = new ResultInfo();


        Title = Request.Form["title"];
        Content = Server.UrlDecode(Request.Form["content"]);
        ClassId = Request.Form["cid"];
        Visable = Request.Form["visable"];
        if (string.IsNullOrEmpty(Title)) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "咨询标题为空。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        if (string.IsNullOrEmpty(Content)) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "咨询内容为空。";
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
        if (string.IsNullOrEmpty(Visable) || !General.IsMatch(Visable, "^\\d+$")) {
            Visable = "10";
        }
        DB.SQLFiltrate(ref Title);
        DB.SQLFiltrate(ref Content);

        if (Id == 0) {
            SQL = "INSERT INTO QuestionList (ParentId,ClassId,Title,Content,VisableLevel,AddUserId,AddUserCPId) VALUES(0,"
                + ClassId + ",'" + Title + "','" + Content + "'," + Visable + "," + Session["UserId"].ToString()
                + "," + Session["CPId"].ToString() + ")";
        } else {
            SQL = "INSERT INTO QuestionList (ParentId,Content,AddUserId,AddUserCPId) VALUES(" + Id + ",'"
                + Content + "'" + "," + Session["UserId"].ToString() + "," + Session["CPId"].ToString() + ");"
                + "UPDATE QuestionList SET Re=Re+1,LastReTime=GETDATE() WHERE Id=" + Id;
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

    private void TagInStore_AddNew(string tags) {
        if (string.IsNullOrEmpty(tags)) return;
        string[] taglist = tags.Split(',');
        SQL = "SELECT Id,Tags FROM DocumentList WHERE IsTagInStore=0";
        Sr = MZ.GetReader(SQL);
        while (Sr.Read()) {
            
        }
        Sr.Close();
        
    }
</script>
