<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string UserName, Password, SQL;
    string JsonResult;

    protected void Page_Load(object sender, EventArgs e) {
        ResultInfo rInfo = new ResultInfo();
        UserName = Request["uname"];
        Password = Request["pwd"];
        if (string.IsNullOrEmpty(UserName) || string.IsNullOrEmpty(Password)) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "用户名或密码没有填写。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        DB.SQLFiltrate(ref UserName);
        DB.SQLFiltrate(ref Password);
        if (Session["RegistryCPId"] == null || (int)Session["RegistryCPId"] == 0) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "请先进行步骤1的信息认证。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        SQL = "SELECT Id FROM UserInfo WHERE UserName='" + UserName + "'";
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            Sr.Close();
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "已存在 " + UserName + " 的用户名，请重新选择。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        } else {
            Sr.Close();
        }
        SQL = "INSERT INTO UserInfo (UserName,Password,Role,CPId) VALUES('"
            + UserName + "','" + Password + "','user'," + Session["RegistryCPId"].ToString() + ")";
        rInfo.ResultCode = 0;
        rInfo.ResultMessage = "注册成功";
        try {
            MZ.ExecuteSQL(SQL);
        } catch (Exception ex) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = ex.Message;
        }
        JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
        Response.Write(JsonResult);
    }

    protected void Page_Unload(object sender, EventArgs e) {
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
