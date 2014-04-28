<%@ Import Namespace="MaklonZjing.MSSQL" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">
    DB MZ = new DB(ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString);
    string SQL;
    int Id, VisableLevel, Status;
    SqlDataReader Sr;
    bool IsMe, IsAdmin, IsManager;

    void Page_Load(object Sender, EventArgs e) {
        if (Session["UserId"] == null || Session["UserRole"] == null) {
            Response.Redirect("Login.html", true);
        }
        if (Session["UserRole"].ToString() == "system") {
            IsAdmin = true;
        } else if (Session["UserRole"].ToString() == "manager") {
            IsManager = true;
        } else {
            IsAdmin = false;
            IsManager = false;
        }
        if (Request.QueryString["id"] == null) {
            Response.Redirect("Error.aspx?err=" + Server.UrlEncode("参数错误。"), true);
        } else {
            Id = Convert.ToInt32(Request.QueryString["id"]);
        }
        SQL = "SELECT QuestionList.*,ClassList.ClassName,UserInfo.UserName,CPInfo.CPNameShort FROM QuestionList "
            + "INNER JOIN ClassList ON QuestionList.ClassId=ClassList.Id "
            + "INNER JOIN UserInfo ON QuestionList.AddUserId=UserInfo.Id "
            + "INNER JOIN CPInfo ON QuestionList.AddUserCPId=CPInfo.Id "
            + "WHERE QuestionList.ParentId=0 AND QuestionList.Status>0 AND QuestionList.Id=" + Id;
        Sr = MZ.GetReader(SQL);
        if (Sr.Read()) {
            Status = Sr.GetInt32(7);
            VisableLevel = Sr.GetInt32(8);
        } else {
            Sr.Close();
            Response.Redirect("Error.aspx?err=" + Server.UrlEncode("没有满足条件的数据。"), true);
        }
        if (VisableLevel == 5 && Sr.GetInt32(11) != (int)Session["CPId"]) {
            Sr.Close();
            Response.Redirect("Error.aspx?err=" + Server.UrlEncode("当前的可见级别限制你不能查看内容。"), true);
        }
        if ((int)Session["UserId"] == Sr.GetInt32(10)) {
            IsMe = true;
        } else {
            IsMe = false;
        }
    }

    void Page_Unload(object Sender, EventArgs e) {
        MZ = null;
    }

    protected string GetStatusDisplayName(int status) {
        switch (status) {
            case 1:
                return "<span class=\"label label-warning\">等待回复</span>";
            case 2:
                return "<span class=\"label label-info\">讨论中</span>";
            case 3:
                return "<span class=\"label label-danger\">锁定</span>";
            case 10:
                return "<span class=\"label label-success\">完结</span>";
            default:
                return "<span class=\"label label-default\">未知</span>";
        }
    }

    protected string GetVisableLevelDisplayName(int visable) {
        switch (visable) {
            case 1:
                return "<span style=\"color:#d9534f; font-weight:bold;\">仅自己可见</span>";
            case 5:
                return "<span style=\"color:#5bc0de; font-weight:bold;\">仅本CP可见</span>";
            case 10:
                return "<span style=\"color:#5cb85c; font-weight:bold;\">全部可见</span>";
            default:
                return "<span style=\"color:#999999; font-weight:bold;\">未知</span>";
        }
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
    <script type="text/javascript">
        var Id=<%=Id%>;
        var jObject;

        function GetData(page){
            $("#DataArea").html("<div class=\"caption text-center\">正在载入数据...</div>");
            $.get("Ajax/GetQuestionAnswerList.aspx",{id:Id,page:page},function(data){
                $("#DataArea").html(data);
            });
        }

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

            GetData(1);
        });

        function AddnewDoc() {
            docContent = CKEDITOR.instances.Text_Content.getData();
            if (docContent == "") {
                $("#Dialog_Info").ShowDialog("没有任何回复内容。");
                return;
            }

            if (confirm("你确定要添加这条回复吗？") == false) return;
            $("#Dialog_OperateWaitting").dialog("open");
            $("#btn_addnew").attr("disabled", "disabled");
            $.post("Ajax/QuestionOperate1.aspx", {
                action: "RE", id: Id, content: encodeURIComponent(docContent)
            }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                $("#btn_addnew").removeAttr("disabled");
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("回复内容添加成功。");
                    GetData(1);
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function SwitchContent(){
            if ($("#btn_re").html()=="我要回复"){
                $("#ContentArea").slideDown("slow");
                $("#btn_re").html("隐藏回复框");
            }else{
                $("#ContentArea").slideUp("fast");
                $("#btn_re").html("我要回复");
            }
        }

        function SetOrder(val){
            $.get("Ajax/QuestionOperate2.aspx",{action:"ORDER",id:Id,val:val},function(data){
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("优先级设置成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function SetStatus(id,val){
            if (val==0){
                if (confirm("你确定要将此内容删除吗？")==false) return;
            }
            $.get("Ajax/QuestionOperate2.aspx",{action:"STATUS",id:id,val:val},function(data){
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    if (id==Id){
                        document.location.reload();
                    }else{
                        GetData(1);
                    }
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function SetVisable(val){
            $.get("Ajax/QuestionOperate2.aspx",{action:"VISABLE",id:Id,val:val},function(data){
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("可见级设置成功。");
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

        function DeleteIt(id){
            if (confirm("你确定要删除这条内容吗？")==false) return;
            $.get("Ajax/QuestionOperate2.aspx",{action:"DELETE",id:id,val:0},function(data){
                jObject = $.parseJSON(data);
                if (jObject.ResultCode == 0) {
                    $("#Dialog_Info").ShowDialog("删除成功。");
                    document.location.reload();
                } else {
                    $("#Dialog_Info").ShowDialog(jObject.ResultMessage);
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="container">
        <div class="QuestionParent">
            <div class="Title">
                <div class="col-md-9"><%=Sr.GetString(3) %></div>
                <div class="col-md-3 text-right"><%=Sr.GetDateTime(12) %></div>
            </div>
            <div class="QuestionContent QuestionContent_Default">
                <div class="LeftPanel">
                    <p>咨询人：<%=Sr.GetString(15) %></p>
                    <p>所属CP：<%=Sr.GetString(16) %></p>
                    <p>可见级别：<%=GetVisableLevelDisplayName(VisableLevel) %></p>
                    <p>当前状态：<%=GetStatusDisplayName(Status) %></p>
                </div>
                <div class="RightPanel">
                    <%if (IsAdmin || IsManager || IsMe) { %>
                    <div class="btn-toolbar" style="margin-bottom: 10px;">
                        <%if (IsAdmin || IsManager) { %>
                        <div class="btn-group">
                            <button type="button" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown" data-loading-text="正在设置..." id="btn_status">设置状态<span class="caret"></span></button>
                            <ul class="dropdown-menu" role="menu">
                                <li><a href="javascript:void(0);" onclick="SetStatus(<%=Id %>,0);">删除</a></li>
                                <li><a href="javascript:void(0);" onclick="SetStatus(<%=Id %>,1);">正常</a></li>
                                <li><a href="javascript:void(0);" onclick="SetStatus(<%=Id %>,3);">锁定回复</a></li>
                                <li><a href="javascript:void(0);" onclick="SetStatus(<%=Id %>,10);">结贴</a></li>
                            </ul>
                        </div>
                        <div class="btn-group">
                            <button type="button" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown" data-loading-text="正在设置..." id="btn_order">设置优先级<span class="caret"></span></button>
                            <ul class="dropdown-menu" role="menu">
                                <li><a href="javascript:void(0);" onclick="SetOrder(0);">0级（默认）</a></li>
                                <li><a href="javascript:void(0);" onclick="SetOrder(1);">1级</a></li>
                                <li><a href="javascript:void(0);" onclick="SetOrder(2);">2级</a></li>
                                <li><a href="javascript:void(0);" onclick="SetOrder(3);">3级</a></li>
                                <li><a href="javascript:void(0);" onclick="SetOrder(4);">4级</a></li>
                                <li><a href="javascript:void(0);" onclick="SetOrder(5);">5级（最高）</a></li>
                            </ul>
                        </div>
                        <%} %>
                        <%if (IsAdmin || IsManager) { %>
                        <div class="btn-group">
                            <button type="button" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown">更改可见级别<span class="caret"></span></button>
                            <ul class="dropdown-menu" role="menu">
                                <li><a href="javascript:void(0);" onclick="SetVisable(10);">全部可见</a></li>
                                <li><a href="javascript:void(0);" onclick="SetVisable(5);">仅<strong><%=Session["CPNameShort"] %></strong>下成员可见</a></li>
                            </ul>
                        </div>
                        <%} %>
                        <%if (IsMe) { %>
                        <div class="btn-group">
                            <button type="button" class="btn btn-danger btn-sm" onclick="DeleteIt(<%=Id %>);">删除</button>
                        </div>
                        <%} %>
                    </div>
                    <%} %>
                    <%=Sr.GetString(4) %>
                    <%Sr.Close(); %>
                </div>
            </div>
        </div>
    </div>
    <div class="container" id="DataArea">
        <div class="caption text-center">正在载入回复数据...</div>
    </div>
    <div class="container">
        <%if (Status != 3 && Status != 10) { %>
        <h3 class="text-right"><a href="javascript:void(0);" onclick="SwitchContent();" class="label label-primary" id="btn_re">我要回复</a></h3>
        <%} %>
        <div id="ContentArea" style="display: none;">
            <div class="form-group">
                <textarea id="Text_Content" rows="5" class="form-control"></textarea>
            </div>
            <div class="form-group text-center">
                <input id="btn_addnew" type="button" value="添加" class="btn btn-primary" onclick="AddnewDoc();">
            </div>
        </div>

    </div>
    <div id="Dialog_Info" title="信息"></div>
    <div id="Dialog_OperateWaitting" title="数据传递中...">
        <div class="caption text-center" id="Dialog_UploadWaitting_Text">正在处理...</div>
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
        </div>
    </div>
</asp:Content>

