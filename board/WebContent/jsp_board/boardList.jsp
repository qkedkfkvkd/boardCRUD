<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>BOARD LIST</title>
</head>
<body>
<h1>BOARD LIST</h1>
<%
    // boardList.jsp페이지에는 currentPage라는 매개변수가 넘어와야 하는데
    // 매개변수가 안 넘어오는 경우 currentPage를 1이 대입된다.
    int currentPage = 1;
    if(request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }
    System.out.println("currentPage : "+currentPage); 
    
    int totalRowCount = 0;
	// 전체 게시글의 수를 구하는 코드
 
    String dbUrl = "jdbc:mysql://127.0.0.1:3306/jjdev?useUnicode=true&characterEncoding=euckr";
    String dbUser = "root";
    String dbPw = "java0000";
    Connection connection = null;
    PreparedStatement totalStatement = null;
    PreparedStatement listStatement = null;
    ResultSet totalResultSet = null;
    ResultSet listResultSet = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        connection = DriverManager.getConnection(dbUrl, dbUser, dbPw);
        
        String totalSql = "SELECT COUNT(*) FROM board";// board테이블의 전체행의 수를 반환
        // 페이징을 하기 위해서 전체 행의 수를 구해온다.
        
        totalStatement = connection.prepareStatement(totalSql);
        totalResultSet = totalStatement.executeQuery();
        if(totalResultSet.next()) {
            totalRowCount = totalResultSet.getInt(1);
        }
%>
    <div>전체행의 수 : <%=totalRowCount%></div>
<%    
    int pagePerRow = 10; // 페이지당 보여줄 글의 목록을 10개로 설정
    String listSql = "SELECT board_no, board_title, board_user, board_date "
    			   + "FROM board ORDER BY board_no DESC LIMIT ?, ?";
    // 페이징 기술 1.
    // Limit ?, ? 에서 첫번째 물음표는 시작 지점을 의미하며, 두번째 물음표는 화면에 표시될 리스트 갯수를 의미한다.
    // 배열과 비슷하게 시작지점을 0으로 - 0,10 으로 - 적으면 첫번째 부터 10번째 까지의 회원수를 볼 수 있다.
    listStatement = connection.prepareStatement(listSql);
    listStatement.setInt(1, (currentPage-1)*pagePerRow);
    // 현재페이지가 1페이지면 0행부터, 2페이지면 10행부터, 3페이지면 20행부터...
    
    listStatement.setInt(2, pagePerRow);
    // 두번째 매개변수로 현재 페이지에서 보여질 글의 수가 저장된 변수를 넣는다.
    
    listResultSet = listStatement.executeQuery();
%>
    <table border="1">
        <thead>
            <tr>
                <th>boardTitle</th>
                <th>boardUser</th>
                <th>boardDate</th>
            </tr>
        </thead>
        <tbody>
<%
            while(listResultSet.next()) {
%>
                <tr>
                    <td><a href="<%=request.getContextPath()%>/jsp_board/boardView.jsp?boardNo=<%=listResultSet.getInt("board_no")%>"><%=listResultSet.getString("board_title")%></a></td>
                    <td><%=listResultSet.getString("board_user")%></td>
                    <td><%=listResultSet.getString("board_date")%></td>
                </tr>
<%        
            }
%>
        </tbody>
    </table>
    <div>
        <a href="<%=request.getContextPath()%>/jsp_board/boardAddForm.jsp">게시글 입력</a>
    </div>
<%
    // 마지막 페이지는 전체글의수를 pagePerRow로 나누었을때 나누어 떨어지면 몫이 마지막 페이지 
    // ex) 전체글이 50개 / 10개씩 -> 마지막 페이지는 5페이지
    // 나누어 떨어지지 않으면
    // ex) 전체글이 51개 / 10개씩 -> 마지막 페이지는 6페이지
    int lastPage = totalRowCount/pagePerRow;
    if(totalRowCount % pagePerRow != 0) {
        lastPage++;
    }
%>
    <div>
<%
        if(currentPage>1) { // 현재 페이지가 1페이지보다 크면 이전페이지 링크를 추가
%>
            <a href="<%=request.getContextPath()%>/jsp_board/boardList.jsp?currentPage=<%=currentPage-1%>">이전</a>
<%
        }
        if(currentPage < lastPage) { // 현재 페이지가 마지막 페이지보다 작으면 다음페이지 링크를 추가
%>
            <a href="<%=request.getContextPath()%>/jsp_board/boardList.jsp?currentPage=<%=currentPage+1%>">다음</a>
<%
        }
%>
    </div>
<%
    } catch(Exception e) {
        e.printStackTrace();
        out.print("게시판 목록 가져오기 실패!");
    } finally {
        try {totalResultSet.close();} catch(Exception e){}
        try {listResultSet.close();} catch(Exception e){}
        try {totalStatement.close();} catch(Exception e){}
        try {listStatement.close();} catch(Exception e){}
        try {connection.close();} catch(Exception e){}
    }
%>
</body>
</html>

