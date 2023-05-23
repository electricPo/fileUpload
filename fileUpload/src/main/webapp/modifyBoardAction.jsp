<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "vo.*" %>


<%
//수정 성공하면? 실패하면? -> boardList.. 혹은 다르게도


		
	String dir = request.getServletContext().getRealPath("/upload");	
	System.out.println(dir);
	//최대 크기 지정
	int max = 100*1024*1024; 	
	
	MultipartRequest mReq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());	
		
	int boardNo = Integer.parseInt(mReq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mReq.getParameter("boardFileNo"));
	
	System.out.println(boardNo+"<-modifyBoardAction boardNo");
	System.out.println(boardFileNo+"<-modifyBoardAction boardFileNo");

	//1)board title 수정



	String boardTitle = mReq.getParameter("boardTitle");
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileUpload","root","java1234");

	String boardsql = "UPDATE board SET board_title = ? where board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardsql);
	boardStmt.setString(1,boardTitle);
	boardStmt.setInt(2,boardNo);
	
	System.out.println(boardStmt+"<-modifyBoardAction boardStmt");
	
	int boardRow = boardStmt.executeUpdate();

	
	//2)이전 boardFile을 삭제, 새로운 boardFile을 추가
	
	if(mReq.getOriginalFileName("boardFile") != null){ 
		
		//수정할 파일이 있으면 -> pdf 파일 유효성 검사, pdf가 아니면 업로드 한 파일 삭제
			if(mReq.getContentType("boardFile").equals("application/pdf") == false){ //pdf 파일이 아니면 새로 업로드 한 파일을 삭제
				System.out.println("PDF 파일이 아닙니다");
				String saveFilename	= mReq.getFilesystemName("boardFile");
				File f = new File(dir+"/"+saveFilename); //지우는 파일의 풀네임
				
				if(f.exists()){ //DB에 저장되지 않은 정보를 삭제하는 메소드
					f.delete();
					System.out.println(saveFilename+"파일삭제");
					
					}
				} else{ //pdf 파일이면 새로 업로드 후 db수정(update) 후 이전파일 삭제
					
					String type = mReq.getContentType("boardFile"); 
					String originFilename = mReq.getOriginalFileName("boardFile"); 
					String saveFilename = mReq.getFilesystemName("boardFile"); 
					
					
					BoardFile boardFile = new BoardFile();
					
					boardFile.setBoardFileNo(boardFileNo);
					boardFile.setType(type);
					boardFile.setOriginFilename(originFilename);
					boardFile.setSaveFilename(saveFilename);
					
					System.out.println(boardFileNo + "<-modifyBoardAction / boardFileNo");
					System.out.println(type + "<-modifyBoardAction / type");
					System.out.println(originFilename + "<-modifyBoardAction / originFilename");
					System.out.println(saveFilename + "<-modifyBoardAction / saveFilename");
					
					//이전파일 삭제
					String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no=?";
					PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
					saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
					ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
				
					String preSaveFilename = "";

						if(saveFilenameRs.next()){
							preSaveFilename = saveFilenameRs.getString("save_filename");
						}
						File f = new File(dir+"/"+preSaveFilename);
							if(f.exists()){
								f.delete();
							}
						
							
							String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?";
							PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
							boardFileStmt.setString(1, boardFile.getOriginFilename());
							boardFileStmt.setString(2, boardFile.getSaveFilename());
							boardFileStmt.setInt(3, boardFile.getBoardFileNo());
							int boardFileRow = boardFileStmt.executeUpdate();
							
							System.out.println(boardFileStmt + "<-modifyBoardAction / boardFileStmt");
					}
						
		}
	
	
	
	
	
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp" );






%>