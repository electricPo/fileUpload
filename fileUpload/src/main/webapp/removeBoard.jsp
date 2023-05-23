<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>

<%	


	//게시글 삭제 폼
	
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));


	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileUpload","root","java1234");
	
	
	
	String sql ="SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no=? AND f.board_file_no=?";
	
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,boardNo);
	stmt.setInt(2,boardFileNo);
	
	ResultSet rs = stmt.executeQuery();

	
	HashMap<String, Object> map = null;

	if(rs.next()) {
		map = new HashMap<>();
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("boardFileNo", rs.getInt("boardFileNo"));
		map.put("originFilename", rs.getString("originFilename"));
	}
	


%>




<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>


<h1>게시글 삭제</h1>

	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" 
	method="post" enctype="multipart/form-data">
	
	<input type="hidden" name="boardNo" value="<%=map.get("boardNo") %>">
	<input type="hidden" name="boardFileNo" value="<%=map.get("boardFileNo") %>">
	
	<table>
			<tr>
				<th>boardTitle</th>
				<td>
				
					<textarea rows="3" cols="50" name="boardTitle"
						required="required"><%=map.get("boardTitle") %> </textarea>
					
				</td>
			</tr>
			<tr>
				<th colspan="2">boardFile(삭제파일 : <%=map.get("originFilename") %>)</th>

			</tr>
	
	
	</table>
		<button type="submit">삭제</button>
	
	
	
	</form>

</body>
</html>