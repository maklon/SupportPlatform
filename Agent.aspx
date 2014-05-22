<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" %>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>无标题文档</title>
</head>

<body>
<%
string agent;
agent=Request.ServerVariables["HTTP_USER_AGENT"];
Response.Write(agent);
%>
</body>
</html>
