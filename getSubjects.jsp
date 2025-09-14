<%@ page import="java.sql.*" %>  
<%@ page session="true" %>
<%
    String fid = (String) session.getAttribute("faculty_id");
    String studentDept = (String) session.getAttribute("student_department");

    if (fid == null) {
        out.println("<p style='color:red; text-align:center;'>Session expired. Please login again.</p>");
        return;
    }
    if (studentDept == null) {
        out.println("<p style='color:red; text-align:center;'>Student department not set in session. Please login again.</p>");
        return;
    }

    String errorMsg = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String sem = request.getParameter("sem");
        String year = request.getParameter("year");
        String batchYear = request.getParameter("batchYear");
        String subjectId = request.getParameter("subject");
        String mid = request.getParameter("mid");

        // Fetch subject_name for the selected subjectId
        String subjectName = null;
        if (subjectId != null && !subjectId.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");
                PreparedStatement ps = con.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
                ps.setString(1, subjectId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    subjectName = rs.getString("subject_name");
                }
                rs.close();
                ps.close();
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
                errorMsg = "Error fetching subject name: " + e.getMessage();
            }
        }

        if (sem != null && year != null && batchYear != null && subjectId != null && mid != null &&
            !sem.isEmpty() && !year.isEmpty() && !batchYear.isEmpty() && !subjectId.isEmpty() && !mid.isEmpty()) {
            
            session.setAttribute("department", studentDept);
            session.setAttribute("sem", sem);
            session.setAttribute("year", year);
            session.setAttribute("batchYear", batchYear);
            session.setAttribute("subjectId", subjectId);
            session.setAttribute("subject_name", subjectName);
            session.setAttribute("mid", mid);

            response.sendRedirect("variouswaystoentermars.jsp");
            return;
        } else {
            errorMsg = "Please fill all fields before proceeding.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Select Subject and Details</title>
    <style>
        body {
            background: linear-gradient(135deg, #6a82fb, #fc5c7d);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
            margin: 0;
        }

        .container {
            background: white;
            padding: 30px 40px;
            border-radius: 12px;
            max-width: 450px;
            width: 100%;
            box-shadow: 0 12px 30px rgba(252, 92, 125, 0.25);
            text-align: center;
        }

        h2 {
            margin-bottom: 25px;
            color: #333;
            font-weight: 700;
            letter-spacing: 1px;
        }

        p.department {
            font-size: 16px;
            font-weight: 600;
            color: #555;
            margin-bottom: 25px;
        }

        form {
            text-align: left;
        }

        label {
            display: block;
            margin-top: 15px;
            margin-bottom: 6px;
            font-weight: 600;
            color: #444;
        }

        select {
            width: 100%;
            padding: 10px 14px;
            font-size: 16px;
            border-radius: 6px;
            border: 1.8px solid #bbb;
            transition: border-color 0.3s ease;
            cursor: pointer;
        }

        select:focus {
            outline: none;
            border-color: #fc5c7d;
            box-shadow: 0 0 10px rgba(252, 92, 125, 0.5);
        }

        input[type="submit"] {
            margin-top: 30px;
            width: 100%;
            background-color: #fc5c7d;
            color: white;
            font-weight: 700;
            font-size: 18px;
            padding: 12px 0;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #d94a59;
        }

        p.error-message {
            color: #d93025;
            font-weight: 600;
            margin-top: 20px;
            text-align: center;
        }

        @media (max-width: 480px) {
            .container {
                padding: 25px 20px;
            }
        }
        .back-button:hover {
            background-color: #007bff;
            color: white;
        }
    </style>
</head>
<body>

    <div class="container">
    <a href="facultylogin.jsp" class="back-button">&#8592; Back</a>
        <h2>Select Subject and Details</h2>

        <p class="department"><strong>Student Department:</strong> <%= studentDept %></p>

        <% if (!errorMsg.isEmpty()) { %>
            <p class="error-message"><%= errorMsg %></p>
        <% } %>

        <form method="post">
            <label for="sem">Semester:</label>
            <select name="sem" id="sem" required>
                <option value="" disabled selected>-- Select Semester --</option>
                <% for(int i=1; i<=8; i++) { %>
                    <option value="<%=i%>"><%=i%></option>
                <% } %>
            </select>

            <label for="year">Year:</label>
            <select name="year" id="year" required>
                <option value="" disabled selected>-- Select Year --</option>
                <% for(int i=1; i<=4; i++) { %>
                    <option value="<%=i%>"><%=i%></option>
                <% } %>
            </select>

            <label for="batchYear">Batch Year:</label>
            <select name="batchYear" id="batchYear" required>
                <option value="" disabled selected>-- Select Batch Year --</option>
                <% 
                    int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                    for(int y = currentYear; y >= currentYear - 10; y--) { 
                %>
                    <option value="<%=y%>"><%=y%></option>
                <% } %>
            </select>

            <label for="mid">Mid:</label>
            <select name="mid" id="mid" required>
                <option value="" disabled selected>-- Select Mid --</option>
                <option value="mid1">Mid 1</option>
                <option value="mid2">Mid 2</option>
            </select>

            <label for="subject">Subject:</label>
            <select name="subject" id="subject" required>
                <option value="" disabled selected>-- Select Subject --</option>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");
                        PreparedStatement ps = con.prepareStatement("SELECT subject_id, subject_name FROM subjects WHERE fid = ? AND dept = ?");
                        ps.setString(1, fid);
                        ps.setString(2, studentDept);
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                            String sid = rs.getString("subject_id");
                            String sname = rs.getString("subject_name");
                            out.println("<option value='" + sid + "'>" + sid + " - " + sname + "</option>");
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("<option disabled>Error loading subjects</option>");
                        e.printStackTrace();
                    }
                %>
            </select>

            <input type="submit" value="Proceed to Enter Marks">
        </form>
    </div>
</body>
</html>

