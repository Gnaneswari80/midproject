<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Generated Averages</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f6f9;
            padding: 30px;
        }

        h2 {
            text-align: center;
            color: #003366;
            margin-bottom: 30px;
        }

        table {
            border-collapse: collapse;
            width: 90%;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0px 0px 12px rgba(0, 0, 0, 0.1);
        }

        th, td {
            padding: 12px;
            border: 1px solid #ccc;
            text-align: center;
        }

        th {
            background-color: #003366;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f0f0f0;
        }

        p {
            text-align: center;
            font-size: 18px;
            color: #666;
        }
    </style>
</head>
<body>

<h2>Student Average Marks</h2>

<%
    List<Map<String, String>> avgList = (List<Map<String, String>>) request.getAttribute("avgList");

    if (avgList != null && !avgList.isEmpty()) {

        // Step 1: Get all unique subjects
        Set<String> subjects = new LinkedHashSet<>();
        Map<String, Map<String, Object>> groupedData = new LinkedHashMap<>();

        for (Map<String, String> row : avgList) {
            String sid = row.get("sid");
            String sname = row.get("sname");
            String subject = row.get("subject");
            String avg = row.get("avg");

            subjects.add(subject);

            if (!groupedData.containsKey(sid)) {
                Map<String, Object> stu = new HashMap<>();
                stu.put("sid", sid);
                stu.put("sname", sname);
                groupedData.put(sid, stu);
            }

            groupedData.get(sid).put(subject, avg);
        }
%>

<table>
    <tr>
        <th>Student ID</th>
        <th>Name</th>
        <% for (String subject : subjects) { %>
            <th><%= subject %></th>
        <% } %>
    </tr>

    <% for (Map<String, Object> stu : groupedData.values()) { %>
        <tr>
            <td><%= stu.get("sid") %></td>
            <td><%= stu.get("sname") %></td>
            <% for (String subject : subjects) { %>
                <td><%= stu.get(subject) != null ? stu.get(subject) : "-" %></td>
            <% } %>
        </tr>
    <% } %>
</table>

<%
    } else {
%>
    <p>No student data found.</p>
<%
    }
%>

</body>
</html>
