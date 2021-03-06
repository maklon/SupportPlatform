﻿<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string Title, Content, ClassId, LinkUrl, Action, SQL;
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

        Action = Request.Form["action"];
        if (Action == "DELETE") {
            SQL = "DELETE FROM DocumentList WHERE Id=" + Id;
            try {
                MZ.ExecuteSQL(SQL);
            } catch (Exception ex) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = ex.Message;
            }
        } else {
            Title = Request.Form["title"];
            Content = Server.UrlDecode(Request.Form["content"]);
            ClassId = Request.Form["cid"];
            LinkUrl=Request.Form["link"];
            if (string.IsNullOrEmpty(Title)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "标题为空。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
            if (string.IsNullOrEmpty(Content) && string.IsNullOrEmpty(LinkUrl)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "内容与重定向链接不能同时为空。";
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
            DB.SQLFiltrate(ref Title);
            DB.SQLFiltrate(ref Content);
            DB.SQLFiltrate(ref LinkUrl);
            if (Action == "ADDNEW") {
                SQL = "INSERT INTO DocumentList (ClassId,Title,ContentText,LinkUrl,AddUserId,LastEditUserId) VALUES ("+ClassId+",'"
                    + Title + "','" + Content + "','" + LinkUrl + "'," + Session["UserId"].ToString() + "," + Session["UserId"].ToString() + ")";
            } else if (Action == "UPDATE") {
                SQL = "UPDATE DocumentList SET Title='" + Title + "',ContentText='" + Content + "',LinkUrl='" + LinkUrl + "',"
                    + "LastEditUserId=" + Session["UserId"].ToString() + ",LastEditTime=GETDATE() WHERE Id=" + Id;
            } else {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "不能识别的指令。";
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
