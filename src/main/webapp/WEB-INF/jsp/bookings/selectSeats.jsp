<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.FlightSeatPriceDetail" %>
<%@ page import="java.util.List" %>

<%
    List<FlightSeatPriceDetail> details = (List<FlightSeatPriceDetail>) request.getAttribute("flightDetails");
    Integer flightInstanceId = (Integer) request.getAttribute("flightInstanceId");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Choisir les sièges</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h2>🛫 Choix des sièges pour le vol</h2>
    <a href="flight-instances?action=details&id=<%= flightInstanceId %>" class="btn btn-secondary mb-3">⬅️ Retour au détail</a>

    <form action="bookings?action=createMultipleBookings" method="post">
        <input type="hidden" name="flightInstanceId" value="<%= flightInstanceId %>">
        
        <table class="table table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Classe</th>
                    <th>Sièges disponibles</th>
                    <th>Nombre à réserver</th>
                </tr>
            </thead>
            <tbody>
            <% if (details != null && !details.isEmpty()) {
                for (FlightSeatPriceDetail d : details) {
                    int available = d.getAvailableSeats();
            %>
                <tr>
                    <td><%= d.getClassName() %></td>
                    <td id="avail-<%= d.getClassName() %>"><%= available %></td>
                    <td>
                        <select name="seatNumbers" class="form-select">
                            <% for (int i = 1; i <= available; i++) { %>
                                <option value="<%= i %>"><%= i %></option>
                            <% } %>
                        </select>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="3" class="text-center">Aucune classe disponible</td>
                </tr>
            <% } %>
            </tbody>
        </table>

        <button type="submit" class="btn btn-primary">✅ Réserver</button>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
