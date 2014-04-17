<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" %>
<script runat="server">
    string RndName, UploadName, UploadDir, WebDir;
    string FileExt, FileExtAllow;
    int FileSize;
    string CKEditorFunc="0";

    protected void Page_Load(object sender, EventArgs e) {
        CKEditorFunc = Request.QueryString["CKEditorFuncNum"];
        try {
            HttpPostedFile UpFile;
            UpFile = Request.Files[0];
            if (UpFile.ContentLength > 0) {
                FileSize = UpFile.ContentLength / 1024;
                FileExt = UpFile.FileName.Substring(UpFile.FileName.LastIndexOf('.') + 1);
                string FileExtAllow = "jpg,bmp,gif,png";
                if (FileExtAllow.IndexOf(FileExt.ToLower()) == -1) {
                    CreateJavaScript("", "未经授权的文件扩展名。");
                    return;
                }
                UploadDir = Server.MapPath("/") + "\\PicLib\\" + DateTime.Today.ToString("yyyy-MM");
                WebDir = "/PicLib/" + DateTime.Today.ToString("yyyy-MM");
                System.IO.DirectoryInfo NewDir = new System.IO.DirectoryInfo(UploadDir);
                NewDir.Create();
                
                UploadName = DateTime.Now.ToString("MMddHHmmssffffff") + "." + FileExt;
                UpFile.SaveAs(UploadDir + "\\" + UploadName);
                CreateJavaScript(WebDir + "/" + UploadName, "");
            } else {
                CreateJavaScript( "", "未获取到上传文件。");
            }
        } catch (Exception ex) {
            CreateJavaScript( "", ex.Message);
        }
    }

    protected void Page_UnLoad(object sender, EventArgs e) {

    }

    private void CreateJavaScript(string FileUrl, string ErrorMsg) {
        Response.Write("<script type=\"text/javascript\">");
        Response.Write("window.parent.CKEDITOR.tools.callFunction(" + CKEditorFunc + ",'" + FileUrl + "','" + ErrorMsg + "');");
        Response.Write("</"+"script>");
    }
</script>

