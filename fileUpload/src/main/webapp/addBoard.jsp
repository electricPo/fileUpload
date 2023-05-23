<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>addBoard + file</title>
<style>P
	table, th, td {
		booder: 1px solid #ff0000;
	}
</style>
</head>
<body>
	<h1>자료 업로드</h1>
	<!-- 
		MultipartRequest 쓸 때 주의점
			form 태그 method="post"
			form 태그 enctype="multipart/form-data" 
			input type="file" //파일 업로드용
	 -->
	
	
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" 
		method="post" 
		enctype="multipart/form-data"> <!-- 포스트 -->
	
		<table>
			<!-- 자료 업로드 제목글 -->
			<tr>
				<th>boardTitle</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea> <!-- required="required" : 입력갑 필수 -->
				</td>
			</tr>
			<!-- 로그인 사용자 id -->
			<%
			
				/// String memeberId = (String)session.getAttribute("loginMemberId");
				String memberId = "test";
			%>
			
			
			<tr>
				<th>memberId</th>
				<td>
					<input type="text" name="memberId" 
						value="<%= memberId %>" readonly="readonly">
				</td>
			</tr>
			
			<!--  -->
			<tr>
				<th>boardFile</th>	<!-- vo. board + boardFile = boardForm  총 세 개-->
				<td>
					<input type="file" name="boardFile" required="required">
				</td>
			</tr>
		</table>
		<button type="submit">파일 업로드</button>
	</form>
</body>
</html>