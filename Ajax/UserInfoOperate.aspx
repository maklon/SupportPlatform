<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string UserName, Password, CPId, Role, Action, SQL;
    int Id;
    string JsonResult;
    
    void Page_Load(object Sender, EventArgs e) {
        if (Request["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }

        ResultInfo rInfo = new ResultInfo();

        Action = Request["action"];
        if (Action == "DELETE") {
            SQL = "DELETE FROM UserInfo WHERE Id=" + Id;
            try {
                MZ.ExecuteSQL(SQL);
            } catch (Exception ex) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = ex.Message;
            }
        } else {
            UserName = Request["uname"];
            Password = Request["pwd"];
            CPId = Request["cpid"];
            Role=Request["role"];
            if (string.IsNullOrEmpty(UserName) || string.IsNullOrEmpty(Password)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "用户名或密码为空。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
            if (string.IsNullOrEmpty(Role) || string.IsNullOrEmpty(CPId)) {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "用户角色与隶属类别为空。";
                JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
                Response.Write(JsonResult);
                Response.End();
            }
            DB.SQLFiltrate(ref UserName);
            DB.SQLFiltrate(ref Password);
            DB.SQLFiltrate(ref Role);
            if (Action == "ADDNEW") {
                SQL = "INSERT INTO UserInfo (UserName,Password,Role,CPId) VALUES ('"+UserName+"','"
                    + Password + "','" + Role + "'," + CPId + ")";
            } else if (Action == "UPDATE") {
                SQL = "UPDATE UserInfo SET UserName='" + UserName + "',Password='" + Password + "',Role='" + Role + "',"
                    + "CPId=" + CPId + " WHERE Id=" + Id;
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
