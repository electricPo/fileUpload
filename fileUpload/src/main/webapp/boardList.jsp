<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>

<%
		
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
		
	}



	/*
	SELECT b.board_title boardTitle, f.orifin_filename originFilename, f.save_filename saveFilename //나중에 다 뽑아야 함
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no
	ORDER BY b.createdate DESC
	*/

	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);

	
	//페이징

	int totalRow = 0;
	String totalRowSql = "select count(*) from board_file";
	PreparedStatement totalRowstmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowstmt.executeQuery();
		if(totalRowRs.next()){
			
			totalRow = totalRowRs.getInt(1); //=("count(*)") //lastPage 는 rowPerPage로 정해진다
		}
	
	//마지막 행 구하기
	
	int rowPerPage = 3;
	int beginRow = (currentPage-1)*rowPerPage +3;
	/*
		cp=1
		beginRow= (1-1)*3 +3 -> 3
		
		cp=2
		beginRow= (2-1)*3 +3 -> 6
				
		cp=3
		beginRow= (3-1)*3 +3 -> 9
	*/
	
	int endRow = beginRow + (rowPerPage-1); //endrow는 무엇을 기준으로?
		
		if(endRow > totalRow){
			
			endRow = totalRow;
		}
			

	//쿼리문
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle,f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path  FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while (rs.next()){
		HashMap<String, Object> m = new HashMap<>();
			m.put("boardNo", rs.getInt("boardNo"));
			m.put("boardFileNo", rs.getInt("boardFileNo"));
			m.put("boardTitle", rs.getString("boardTitle"));
			m.put("originFilename", rs.getString("originFilename"));
			m.put("saveFilename", rs.getString("saveFilename"));
			m.put("path", rs.getString("path"));
			list.add(m);
	}
%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<style>
	table, th, td {
		booder: 1px solid #ff0000;
	}
</style>
<body>
<!-- 상세보기 / 다운로드(로그인 이용자) -->
	<h1>PDF 자료 목록</h1>
	<table>
		<tr>
			<td>boardTitle</td>
			<td>filename</td>
			<td>수정</td>
			<td>삭제</td>

		</tr>
		
		<%
		
			for(HashMap<String, Object> m : list){
		%>
		
			<tr>
				<td><%=(String)m.get("boardTitle") %></td>
				
				<td>
					<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
							<%=(String)m.get("originFilename")%>
						</a>
					</td>
					<td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a></td>
					<td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
				</tr>

		
		<%
			}
		%>
	</table>
	
	
	<%
	//페이징 네비게이션

	
	
	//마지막 페이지가 10으로 떨어지지 않으니까
	
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1; //10으로 나누어 떨어지지 않는 나머지 게시글을 위한 1 페이지 생성
	}
	// 
	int pagePerPage = 3;
	
	int minPage = ((currentPage-1)/pagePerPage) * pagePerPage + 1;
	
	
	int maxPage = minPage +(pagePerPage -1);
	if(maxPage > lastPage){
		maxPage = lastPage;
	}
	
	%>
	
		<div class="container text-center">
	<% 
		      if(minPage > 1) {
						%>
						   <a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>   
						<%
						}
						
						for(int i = minPage; i<=maxPage; i=i+1) {
						   if(i == currentPage) {
						%>
						      <span><%=i%></span>&nbsp;
						<%         
						   } else {      
						%>
						      <a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;   
						<%   
						   }
						}
						
						if(maxPage != lastPage) {
						%>
						   <!--  maxPage + 1 -->
						   <a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
						<%
					 	      }
	
						%>
		</div>				
</body>
</html>