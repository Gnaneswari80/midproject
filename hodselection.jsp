<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %> 
<%
    // Handle POST request: store values in session and redirect
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String sem = request.getParameter("sem");
        String year = request.getParameter("year");
        String batchYear = request.getParameter("batchYear");

        if (sem != null && year != null && batchYear != null &&
            !sem.isEmpty() && !year.isEmpty() && !batchYear.isEmpty()) {

            session.setAttribute("sem", sem);
            session.setAttribute("year", year);
            session.setAttribute("batchYear", batchYear);

            // Redirect after setting session attributes
            response.sendRedirect("hodsubjectselection.jsp");
            return;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Selection</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f5f5f5;
            position: relative;
        }
        h2 {
            color: #333;
        }
        form {
            background: white;
            padding: 20px;
            border-radius: 6px;
            max-width: 350px;
            box-shadow: 0 0 10px #ccc;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        select {
            width: 100%;
            padding: 7px;
            margin-top: 5px;
            border-radius: 4px;
            border: 1px solid #aaa;
        }
        input[type="submit"] {
            margin-top: 20px;
            width: 100%;
            padding: 10px;
            background: #007bff;
            border: none;
            color: white;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background: #0056b3;
        }
        /* Back button styling */
        button.back-btn {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 6px 12px;
            font-size: 14px;
            cursor: pointer;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }
        button.back-btn:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>

    <button class="back-btn" onclick="window.location.href='hodHomePage.jsp'">&larr; Back</button>

    <h2>    </h2>
    <form method="post" action="hodselection.jsp">
        <label for="sem">Semester:</label>
        <select name="sem" id="sem" required>
            <option value="">--Select Semester--</option>
            <% for(int i=1; i<=8; i++) { %>
                <option value="<%=i%>" <%= String.valueOf(i).equals(session.getAttribute("sem")) ? "selected" : "" %>><%= i %></option>
            <% } %>
        </select>

        <label for="year">Year:</label>
        <select name="year" id="year" required>
            <option value="">--Select Year--</option>
            <% for(int i=1; i<=4; i++) { %>
                <option value="<%=i%>" <%= String.valueOf(i).equals(session.getAttribute("year")) ? "selected" : "" %>><%= i %></option>
            <% } %>
        </select>

        <label for="batchYear">Batch Year:</label>
        <select name="batchYear" id="batchYear" required>
            <option value="">--Select Batch Year--</option>
            <%
                int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                String selectedBatchYear = (String)session.getAttribute("batchYear");
                for (int i = currentYear; i >= currentYear - 10; i--) {
            %>
                <option value="<%= i %>" <%= (selectedBatchYear != null && selectedBatchYear.equals(String.valueOf(i))) ? "selected" : "" %>><%= i %></option>
            <%
                }
            %>
        </select>

        <input type="submit" value="Submit">
    </form>

</body>
</html>
