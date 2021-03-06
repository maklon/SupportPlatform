﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript">
        var Role = "";

        $(document).ready(function () {
            SwitchMenu("MenuUser");

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
            $.get("Ajax/GetUserInfoList.aspx", { role: Role, page: pageId }, function (data) {
                $("#Dialog_OperateWaitting").dialog("close");
                $("#DataArea").html(data);
            });
        }

        function SwitchRole(r) {
            Role = r;
            GetData(1);
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;">
        <a href="javascript:void(0);" onclick="SwitchRole('');" class="label label-info">全部用户</a>&nbsp;
        <a href="javascript:void(0);" onclick="SwitchRole('system');" class="label label-info">系统管理员</a>&nbsp;
        <a href="javascript:void(0);" onclick="SwitchRole('manager');" class="label label-info">平台管理员</a>&nbsp;
        <a href="javascript:void(0);" onclick="SwitchRole('user');" class="label label-info">平台用户</a>&nbsp;
        <a href="UserInfoEdit.aspx" class="btn btn-primary">添加新用户</a></div>
    <div class="container" id="DataArea">
        
    </div>
    <div id="Dialog_OperateWaitting" title="数据传递中...">
        <div class="caption text-center" id="Dialog_UploadWaitting_Text">正在传递数据</div>
        <div class="progress progress-striped active">
            <div class="progress-bar" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"></div>
        </div>
    </div>
</asp:Content>

