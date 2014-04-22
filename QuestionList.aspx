<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>
<script runat="server">
    protected void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) Response.Redirect("Login.html", true);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" Runat="Server">
    <script type="text/javascript">
        var ClassId = 0;

        $(document).ready(function () {
            SwitchMenu("MenuDocument");

            $("#Dialog_OperateWaitting").dialog({
                autoOpen: false,
                modal: true,
                width: 400,
                closeText: "hide"
            });

            GetData(1);
        });

        function GetData(pageId) {
            $("#Dialog_OperateWaitting").dialog("open");
            $.get("Ajax/GetQuestionList.aspx", { cid: ClassId, page: pageId }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                $("#DataArea").html(data);
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" Runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="QuestionAddnew.aspx" class="btn btn-primary">开始咨询</a></div>
    <div class="container" id="DataArea">
        
    </div>
    <div id="Dialog_OperateWaitting" title="数据传递中...">
        <div class="caption text-center" id="Dialog_UploadWaitting_Text">正在传递数据</div>
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
        </div>
    </div>
</asp:Content>

