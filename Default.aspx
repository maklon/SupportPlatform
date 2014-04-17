<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" %>
<script runat="server">
    protected void Page_Load(object Sender, EventArgs e) {
        
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="PageHead" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            SwitchMenu("MenuDefault");
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageContent" Runat="Server">
</asp:Content>

