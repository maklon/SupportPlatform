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
        if (Session["UserRole"] == null && Session["UserRole"].ToString().IndexOf("system") == -1) {
            IsAdmin = false;
        } else {
            IsAdmin = true;
        }
        if (Session["UserRole"] == null && Session["UserRole"].ToString().IndexOf("manager") == -1) {
            IsManager = false;
        } else {
            IsManager = true;
        }
        if (!IsAdmin || !IsManager) Response.Redirect("Error.aspx?err=" + Server.UrlEncode("你没有权限访问此页。"), true);
        if (Request.QueryString["id"] == null) {
            Id = 0; ClassId = 0; OrderId = 0;
            Title = ""; Content = "";
        } else {
            Id = Convert.ToInt32(Request.QueryString["id"]);
            if (Id == 0) {
                Id = 0; ClassId = 0; ; OrderId = 0;
                Title = ""; Content = "";
            } else {
                SQL = "SELECT * FROM DocumentList WHERE Id=" + Id;
                Sr = MZ.GetReader(SQL);
                if (Sr.Read()) {
                    ClassId = Sr.GetInt32(1);
                    Title = Sr.GetString(2);
                    Content = Sr.GetString(3);
                    LinkUrl = Sr.GetString(4);
                    OrderId = Sr.GetInt32(5);
                    Sr.Close();
                } else {
                    Sr.Close();
                    Response.Redirect("Error.aspx?err=" + Server.UrlEncode("没有满足条件的数据。"), true);
                }
            }
        }

        SQL = "SELECT * FROM ClassList WHERE TypeId=1";
        Sr = MZ.GetReader(SQL);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
    <script type="text/javascript">
        var docContent;
        var Id = <%=Id%>;
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
            if (docContent == "" && $("#Text_Link").val() == "") {
                $("#Dialog_Info").ShowDialog("文档内容或重定向链接不能同时为空。");
                return;
            }
            if ($("#List_Class").val() == "0") {
                $("#Dialog_Info").ShowDialog("请选择文档的分类。");
                return;
            }

            if (confirm("你确定要添加这份文档吗？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $.post("Ajax/DocumentOperate.aspx", {
                action: "ADDNEW", id: 0, title: $("#Text_Title").val(), oid: $("#Text_OrderId").val(),
                cid: $("#List_Class").val(), link: $("#Text_Link").val(), content: encodeURIComponent(docContent)
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("文档内容添加成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function UpdateDoc() {
            if ($("#Text_Title").val() == "") {
                $("#Dialog_Info").ShowDialog("标题没有填写。");
                return;
            }
            docContent = CKEDITOR.instances.Text_Content.getData();
            if (docContent == "" && $("#Text_Link").val() == "") {
                $("#Dialog_Info").ShowDialog("文档内容或重定向链接不能同时为空。");
                return;
            }
            if ($("#List_Class").val() == "0") {
                $("#Dialog_Info").ShowDialog("请选择文档的分类。");
                return;
            }
            if (confirm("你确定要更新这份文档吗？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $.post("Ajax/DocumentOperate.aspx", {
                action: "UPDATE", id: Id, title: $("#Text_Title").val(), oid: $("#Text_OrderId").val(),
                cid: $("#List_Class").val(), link: $("#Text_Link").val(), content: encodeURIComponent(docContent)
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("文档内容更新成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function DeleteDoc() {
            if (confirm("你确定要删除这份文档吗？") == false) return;
            $("#btn_update").addClass("disabled");
            $("#btn_delete").addClass("disibled");
            $.post("Ajax/DocumentOperate.aspx", { action: "DELETE", id: Id }, function (data) {
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("文档删除成功。");
                    $("#btn_update").removeClass("disabled");
                    $("#btn_delete").removeClass("disibled");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                    $("#btn_update").removeClass("disabled");
                    $("#btn_delete").removeClass("disibled");
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="javascript:void(0);" onclick="window.history.back();" class="btn btn-primary">返回</a> </div>
    <div class="container">
        <div class="form-group" id="Gp_Title">
            <label for="Text_Title">文档标题</label>
            <input id="Text_Title" type="text" class="form-control" onblur="$(this).CheckIsEmpty('Gp_Title');" value="<%=Title %>" placeholder="文档的标题">
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="Text_Tags">排序因子</label>
                    <input id="Text_OrderId" type="text" class="form-control" value="<%=OrderId %>" placeholder="文档的排序因子，数值越大，越靠前">
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
            <label for="Text_Link">重定向链接</label>
            <input id="Text_Link" type="text" class="form-control" value="<%=LinkUrl %>" placeholder="重定向链接与内容不能同时为空，且重定向链接优先于内容显示。">
        </div>
        <div class="form-group">
            <label for="Text_Content">文档内容</label>
            <textarea id="Text_Content" rows="5" class="form-control"><%=Content %></textarea>
        </div>
        <div class="form-group text-center">
            <%if (Id == 0) { %>
            <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddnewDoc();">
            <%} else { %>
            <input id="btn_update" type="button" value="更新" class="btn btn-success" onclick="UpdateDoc();">
            <input id="btn_delete" type="button" value="删除" class="btn btn-danger" onclick="DeleteDoc();">
            <%} %>
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

