<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string ClassName,TypeId, Action, SQL;
    int Id;
    string JsonResult;
    
    void Page_Load(object Sender, EventArgs e) {
        if (Request.Form["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }

        ResultInfo rInfo = new ResultInfo();
        
        
        Action = Request.Form["action"];
        
        if (Action == "DELETE") {
            SQL = "DELETE FROM ClassList WHERE Id=" + Id;
            try {
                MZ.ExecuteSQL(SQL);
            } catch (Exception ex) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = ex.Message;
            }
        } else {
            ClassName = Request.Form["name"];
            TypeId = Request.Form["type"];
            if (string.IsNullOrEmpty(ClassName)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "分类名称为空。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
            if (string.IsNullOrEmpty(TypeId) || !General.IsMatch(TypeId, "^[1-2]$") || TypeId == "0") {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "请选择分类的类型。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
            DB.SQLFiltrate(ref ClassName);
            if (Action == "ADDNEW") {
                SQL = "INSERT INTO ClassList (ClassName,TypeId) VALUES('" + ClassName + "'," + TypeId + ")";
            } else if (Action == "UPDATE") {
                SQL = "UPDATE ClassList SET ClassName='" + ClassName + "',TypeId=" + TypeId + " WHERE Id=" + Id;
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
