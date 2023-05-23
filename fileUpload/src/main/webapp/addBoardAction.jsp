<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="vo.*" %>
<%@ page import="java.io.*" %>
<%@ page import ="java.sql.*" %>

<%
	/*
	request.getSession().getServletContext().getRealPath("/")
	 현재 서비스가 돌아가고 있는 서블릿의 경로를 가져온다.
	  ->이것을 스트링 타입으로 변수선언
	*/
	
	String dir = request.getServletContext().getRealPath("/upload");
	  
	System.out.println(dir);
	
	int max = 100*1024*1024; //100M
	
	//request객체를 MultipartRequest를 API를 사용할 수 있도록 랩핑
	//DefaultFileRenamePolicy() : 이름이 중복되지 않도록 함
		
		/*
		일반적인 get post 방식 -> request.getParameter(); 
		cf.
		MultipartRequest -> multi.getParameter();
		
		*/
	
	MultipartRequest mReq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	//이때 파일 업로드 됨
	
	
	//업로드된 파일의 이름 반환
		//MultipartRequest api 를 사용해 스트림 내에서 ★문자값★ 반환 가능
	if(!mReq.getContentType("boardFile").equals("application/pdf")){ //넘어온 파일 확장자가 PDF가 '아닌' 경우 파일 삭제
		System.out.println("PDF 파일이 아닙니다");
	
		String saveFilename	= mReq.getFilesystemName("boardFile");
		File f = new File(dir+"/"+saveFilename); //지우는 파일의 풀네임
			if(f.exists()){ //DB에 저장되지 않은 정보를 삭제하는 메소드
				f.delete();
				System.out.println(dir+"/");
			}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp");
		return;
	}
	
	//1) input type="text" 값반환 api
		
	String boardTitle = mReq.getParameter("boardTitle");
	String memberId = mReq.getParameter("memberId");
	
	//VO 타입에 다시 넣기 위해 변수 선언
		//vo.Board
	Board board = new Board();
		
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	//2) input type="file" 값(파일메타정보)반환 api (원본파일 이름, 저장된 파일 이름, 컨텐츠 타입)
		//파일(바이너리)은 이미 MultipartRequest 객체생성시 이미지 저장
		
		//getContentType(); : 업로드된 파일의 컨텐트 타입을 반환, 업로드된 파일이 없으면 null을 반환
		//getOrignalFileName(); : 사용자가 지정해서 서버상에 업로드된 파일명을 반환, 이때의 파일명은 파일 중복을 고려한 파일명 변경 전의 이름을 말한다.
		// getFilesystemName(); : 사용자가 지정해서 서버 상에 실제로 업로드된 파일명을 반환
		
	String type = mReq.getContentType("boardFile"); 
	String originFilename = mReq.getOriginalFileName("boardFile"); 
	String saveFilename = mReq.getFilesystemName("boardFile"); 

	System.out.println(type + " <-- addBoardAction type"); //application/pdf
	System.out.println(originFilename + " <- addBoardAction originFilename"); //SQLD0517.pdf
	System.out.println(saveFilename + " <- addBoardAction saveFilename"); //SQLD0517.pdf
	
	//VO 타입에 다시 넣기 위해 변수 선언
		//vo.BoardFile
	BoardFile boardFile = new BoardFile();
	
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	/*
		INSERT INTO board(board_title, member_id, updatedate, createdate)
		VALUES(?, ? NOW(), NOW();)
		
		INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, ceratedate)
		VALUES(?, ?, ? ,?, NOW());
	
	
		PreparedStatement.RETURN_GENERATED_KEYS; // 방금 입력한 키 값을 뽑아주세요
		SELECT KEY -> 직전에 입력한 프라이머리 키값을 리턴한다
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileUpload","root","java1234");

	
	
	String boardSql ="INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES(?, ?, NOW(), NOW())";
	
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1,boardTitle);
	boardStmt.setString(2,memberId);
	
	boardStmt.executeUpdate(); //키값 저장
	ResultSet keyRs= boardStmt.getGeneratedKeys(); //생성키 자동으로 받아오기
	
	int boardNo = 0;
	if(keyRs.next()){
		boardNo = keyRs.getInt(1);
	}
	

	
	
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ? ,?, '/upload', NOW())";
	
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);

	fileStmt.executeUpdate();
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	
	
	
%>