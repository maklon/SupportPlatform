<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>

<script runat="server">

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            SwitchMenu("MenuUser");
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" runat="Server">
    <div class="MainContainer caption text-right" style="padding-right: 30px;"><a href="UserInfoEdit.aspx" class="btn btn-primary">添加新用户</a></div>
    <div class="container" id="DataArea">
        <table class="table table-hover table-striped">
            <thead style="font-weight: bold; font-size: 16px;">
                <tr>
                    <td style="width: 10%">#</td>
                    <td style="width: 40%">用户名</td>
                    <td style="width: 20%">角色</td>
                    <td style="width: 20%">所属CP</td>
                    <td style="width: 10%">操作</td>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td></td>
                </tr>

            </tbody>
        </table>
    </div>
</asp:Content>

