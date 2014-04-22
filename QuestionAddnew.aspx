<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>
<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    SqlDataReader Sr;
    string SQL;
    bool IsAdmin;
    bool IsManager;
    int Id, ClassId,OrderId;
    string Title, LinkUrl, Content;

    protected void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null) Response.Redirect("Login.html", true);
        SQL = "SELECT * FROM ClassList WHERE TypeId=2";
        Sr = MZ.GetReader(SQL);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
    <script type="text/javascript">
        var docContent;
        var jObject;

        $(document).ready(function () {
            CKEDITOR.replace("Text_Content", {
                customConfig: "config_doc.js",
                height: 300,
                filebrowserUploadUrl: "./CKEditor_Upload_Image.aspx"
            });

            $("#Dialog_Info").dialog({
                autoOpen: false,
                buttons: {
                    "确定": function () {
                        $(this).dialog("close");
                    }
                }
            });

            $("#Dialog_OperateWaitting").dialog({
                autoOpen: false,
                modal: true,
                width: 400,
                closeText: "hide"
            });
        });

        function AddnewDoc() {
            if ($("#Text_Title").val() == "") {
                $("#Dialog_Info").ShowDialog("标题没有填写。");
                return;
            }
            docContent = CKEDITOR.instances.Text_Content.getData();
            if (docContent == "") {
                $("#Dialog_Info").ShowDialog("咨询的内容没有填写。");
                return;
            }
            if ($("#List_Class").val() == "0") {
                $("#Dialog_Info").ShowDialog("请选择咨询问题的分类。");
                return;
            }

            if (confirm("你确定要发起这条咨询？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $("#btn_addnew").attr("disabled", "disabled");
            $.post("Ajax/QuestionOperate.aspx", {
                action: "ADDNEW", id: 0, title: $("#Text_Title").val(), visable: $("#List_Visable").val(),
                cid: $("#List_Class").val(), content: encodeURIComponent(docContent)
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                $("#btn_addnew").removeAttr("disabled");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("咨询内容添加成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="javascript:void(0);" onclick="window.history.back();" class="btn btn-primary">返回</a> </div>
    <div class="container">
        <div class="form-group" id="Gp_Title">
            <label for="Text_Title">咨询问题</label>
            <input id="Text_Title" type="text" class="form-control" onblur="$(this).CheckIsEmpty('Gp_Title');" value="<%=Title %>" placeholder="咨询的问题概述">
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="Text_Tags">内容可见级别</label>
                    <select id="List_Visable" class="form-control">
                        <option value="5"><%=Session["CPNameShort"] %>下成员可见</option>
                        <option value="10" selected>所有成员可见</option>
                    </select>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="Text_Date">所属分类</label>
                    <select id="List_Class" class="form-control">
                        <option value="0" <%if (ClassId == 0) { Response.Write(" selected=\"selected\""); } %>>请选择文档所属分类</option>
                        <%while (Sr.Read()) { %>
                        <option value="<%=Sr.GetInt32(0) %>" <%if (ClassId == Sr.GetInt32(0)) { Response.Write(" selected=\"selected\""); } %>><%=Sr.GetString(2) %></option>
                        <%} Sr.Close(); %>
                    </select>
                </div>
            </div>
        </div>
        <div class="form-group">
            <label for="Text_Content">咨询详细内容</label>
            <textarea id="Text_Content" rows="5" class="form-control"><%=Content %></textarea>
        </div>
        <div class="form-group text-center">
            <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddnewDoc();">
        </div>
    </div>
    <div id="Dialog_Info" title="信息"></div>
    <div id="Dialog_OperateWaitting" title="数据传递中...">
        <div class="caption text-center" id="Dialog_UploadWaitting_Text">正在传递数据</div>
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
        </div>
    </div>
</asp:Content>

