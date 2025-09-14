<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Faculty Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f6fa;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: #fff;
            padding: 40px 60px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        h2 {
            margin-bottom: 30px;
            color: #007bff;
        }
        button {
            padding: 15px 35px;
            margin: 10px;
            font-size: 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            color: #fff;
            background-color: #007bff;
            transition: background 0.3s;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Faculty Dashboard</h2>
        <form action="scheme.jsp" method="get" style="display:inline;">
            <button type="submit">Scheme</button>
        </form>
        <form action="marksEntry.jsp" method="get" style="display:inline;">
            <button type="submit">Post Marks</button>
        </form>
    </div>
    
    <!-- Back Button -->
<form action="variouswaystoentermars.jsp
" method="get" style="margin-bottom:20px;">
    <button type="submit" style="background:#f44336;color:#fff;padding:8px 16px;border:none;border-radius:5px;cursor:pointer;">
        &larr; Back
    </button>
</form>
    
</body>
</html>
