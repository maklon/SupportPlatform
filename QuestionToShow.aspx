<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Page Language="C#" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    string SQL;
    int Id;
    
    void Page_Load(object Sender, EventArgs e) {
        if (Request.Form["id"] == null) {
            Id = 0;
        } else {
            Id = Convert.ToInt32(Request["id"]);
        }
        SQL = "UPDATE QuestionList SET Dot=Dot+1 WHERE Id=" + Id;
        try {
            MZ.ExecuteSQL(SQL);
            Server.TransferRequest("QuestionContent.aspx");
        } catch (Exception ex) {
            Response.Write(ex.Message);
        }
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
