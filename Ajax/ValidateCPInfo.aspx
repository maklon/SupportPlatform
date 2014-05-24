<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>

<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string SQL, CPCode, LoginAccount, VC;
    int Id;
    string JsonResult;
    string WebJsonData;

    //http://open.play.cn/dev/api/test_system/get_dev?cp_id=C00171

    void Page_Load(object Sender, EventArgs e) {
        ResultInfo rInfo = new ResultInfo();

        if (Session["ValidateImageCode"] == null) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "验证码已失效，请重新刷新页面。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            return;
        }
        CPCode = Request.QueryString["cpcode"];
        LoginAccount = Request.QueryString["account"];
        VC = Request.QueryString["vc"];
        if (string.IsNullOrEmpty(VC) || string.Compare(VC, Session["ValidateImageCode"].ToString(), true) != 0) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "验证码输入有误。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            return;
        }
        if (string.IsNullOrEmpty(CPCode) || string.IsNullOrEmpty(LoginAccount)) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "CPCode或登录账号为空。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            return;
        }
        DB.SQLFiltrate(ref CPCode);
        SQL = "SELECT * FROM CPInfo WHERE CPCode='" + CPCode + "'";
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            CPInfo cpInfo = new CPInfo();
            cpInfo.Id = Sr.GetInt32(0);
            cpInfo.venderCode = Sr.GetString(1);
            cpInfo.cnName = Sr.GetString(2);
            cpInfo.shortName = Sr.GetString(3);
            cpInfo.linkName = Sr.GetString(4);
            cpInfo.linkPhone = Sr.GetString(5);
            cpInfo.linkEmail = Sr.GetString(6);
            Sr.Close();
            if (cpInfo.linkPhone == LoginAccount) {
                Session["RegistryCPId"] = cpInfo.Id;
                string CPInfoJsonData;
                CPInfoJsonData = JsonConvert.SerializeObject(cpInfo, Formatting.Indented);
                rInfo.ResultCode = 0;
                rInfo.ResultMessage = CPInfoJsonData;
            } else {
                rInfo.ResultCode = 1;
                rInfo.ResultMessage = "你所填写的登录账号与系统登记的信息不符。";
            }
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        } else {
            Sr.Close();
        }

        WebRequest webRequest = WebRequest.Create("http://open.play.cn/dev/api/test_system/get_dev?cp_id=" + CPCode);
        WebResponse webResponse = null;
        Stream webStream = null;
        StreamReader streamReader = null;

        try {
            webResponse = webRequest.GetResponse();
            webStream = webResponse.GetResponseStream();
            streamReader = new StreamReader(webStream);
            WebJsonData = streamReader.ReadToEnd();

        } catch (Exception ex) {
            rInfo.ResultCode = 0;
            rInfo.ResultMessage = ex.Message;
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            return;
        } finally {
            if (streamReader != null) streamReader.Close();
            if (webStream != null) webStream.Close();
            if (webResponse != null) webResponse.Close();
        }
        WebData webData;
        webData = JsonConvert.DeserializeObject<WebData>(WebJsonData);
        if (webData.dataCount == 0) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "不存在CPCode为 " + CPCode + " 的厂商信息。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        CPInfo cpNewInfo = webData.data[0];
        if (cpNewInfo.linkPhone != LoginAccount) {
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "你所填写的登录账号与系统登记的信息不符。";
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            Response.End();
        }
        SQL = "INSERT INTO CPInfo (CPCode,CPName,CPNameShort,ContactName,ContactPhone,ContactMail) VALUES('"
            + cpNewInfo.venderCode + "','" + cpNewInfo.cnName + "','" + cpNewInfo.shortName + "','" + cpNewInfo.linkName + "','" + cpNewInfo.linkPhone
            + "','" + cpNewInfo.linkEmail + "')";
        try {
            MZ.ExecuteSQL(SQL);
        } catch (Exception ex) {
            rInfo.ResultCode = 0;
            rInfo.ResultMessage = ex.Message;
            JsonResult = JsonConvert.SerializeObject(rInfo, Formatting.Indented);
            Response.Write(JsonResult);
            return;
        }
        SQL = "SELECT * FROM CPInfo WHERE CPCode='" + CPCode + "'";
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            CPInfo cpInfo = new CPInfo();
            cpInfo.Id = Sr.GetInt32(0);
            cpInfo.venderCode = Sr.GetString(1);
            cpInfo.cnName = Sr.GetString(2);
            cpInfo.shortName = Sr.GetString(3);
            cpInfo.linkName = Sr.GetString(4);
            cpInfo.linkPhone = Sr.GetString(5);
            cpInfo.linkEmail = Sr.GetString(6);
            Sr.Close();
            Session["RegistryCPId"] = cpInfo.Id;
            string CPInfoJsonData;
            CPInfoJsonData = JsonConvert.SerializeObject(cpInfo, Formatting.Indented);
            rInfo.ResultCode = 0;
            rInfo.ResultMessage = CPInfoJsonData;
        } else {
            Sr.Close();
            rInfo.ResultCode = 1;
            rInfo.ResultMessage = "无法创建或查询到厂商信息，请稍候再试。";
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

    public class CPInfo
    {
        public int Id;
        public string venderCode, shortName, cnName, linkName, linkPhone, linkEmail;
        public bool isOnline;
    }

    public class WebData
    {
        public int dataCount;
        public List<CPInfo> data;
    }
</script>
