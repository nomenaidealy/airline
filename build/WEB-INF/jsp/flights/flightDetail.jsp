<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.FlightSeatPriceDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>

<%
    // Récupération des attributs passés depuis le servlet
    List<FlightSeatPriceDetail> details = (List<FlightSeatPriceDetail>) request.getAttribute("flightDetails");
    BigDecimal totalMax = (BigDecimal) request.getAttribute("totalMax");
    Integer flightInstanceId = (Integer) request.getAttribute("flightInstanceId");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Détails du Vol</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-5">
    <h2 class="mb-4">📋 Détails des Classes pour le Vol</h2>

    <a href="flight-instances" class="btn btn-secondary mb-3">⬅️ Retour à la liste des vols</a>

    <div class="table-responsive">
        <table class="table table-striped table-hover table-bordered align-middle">
            <thead class="table-dark text-center">
                <tr>
                    <th>Classe</th>
                    <th>Nombre total de sièges</th>
                    <th>Sièges disponibles</th>
                    <th>Prix (Ar)</th>
                </tr>
            </thead>
            <tbody>
            <% if (details != null && !details.isEmpty()) {
                for (FlightSeatPriceDetail d : details) { %>
                <tr class="text-center">
                    <td><%= d.getClassName() %></td>
                    <td><%= d.getTotalSeats() %></td>
                    <td><%= d.getAvailableSeats() %></td>
                    <td><%= d.getPrice() != null ? String.format("%.2f", d.getPrice()) : "N/A" %> Ar</td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="4" class="text-center fw-bold">Aucun détail disponible pour ce vol</td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <div class="mt-3">
        <p class="fw-bold fs-5">
            TOTAL MAXIMAL DES PLACES : 
            <%= totalMax != null ? String.format("%.2f", totalMax) : "N/A" %> Ar
        </p>
    </div>

    <%-- Lien pour créer une réservation --%>
    <% if (flightInstanceId != null) { %>
        <div class="mt-3">
            <a href="bookings?action=new&flightId=<%= flightInstanceId %>" class="btn btn-primary">
                ➕ Ajouter une réservation
            </a>
        </div>
    <% } %>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
