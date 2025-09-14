<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Choose Marks Entry Method</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f7fa;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 4px 15px rgba(0,0,0,0.2);
            text-align: center;
        }
        h2 {
            margin-bottom: 25px;
            color: #333;
        }
        button {
            padding: 12px 25px;
            margin: 10px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .single {
            background: #4CAF50;
            color: white;
        }
        .single:hover {
            background: #45a049;
        }
        .all {
            background: #2196F3;
            color: white;
        }
        .all:hover {
            background: #0b7dda;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Select Marks Entry Method</h2>
        
        <form action="enterSingleStudentMarks.jsp" method="get" style="display:inline;">
            <button type="submit" class="single">Enter Marks - One Student at a Time</button>
        </form>
        
        <form action="enterMarks.jsp" method="get" style="display:inline;">
            <button type="submit" class="all">Enter Marks - All Students</button>
        </form>
    </div>
    <!-- Back Button -->
<form action="getSubjects.jsp" method="get" style="margin-bottom:20px;">
    <button type="submit" style="background:#f44336;color:#fff;padding:8px 16px;border:none;border-radius:5px;cursor:pointer;">
        &larr; Back
    </button>
</form>
    
</body>
</html>
