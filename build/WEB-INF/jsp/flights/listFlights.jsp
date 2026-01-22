<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect("login");
        return;
    }
    List<Flight> flights = (List<Flight>) request.getAttribute("flights");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Vols - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <%
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        if (successMessage != null) {
            session.removeAttribute("successMessage");
    %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <%= successMessage %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% }
        if (errorMessage != null) {
            session.removeAttribute("errorMessage");
    %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <%= errorMessage %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>📋 Gestion des Vols</h2>
        <a href="flights?action=add" class="btn btn-primary">➕ Ajouter un vol</a>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Numéro Vol</th>
                <th>Départ</th>
                <th>Arrivée</th>
                <th>Date/Heure Départ</th>
                <th>Date/Heure Arrivée</th>
                <th>Avion</th>
                <th>Prix (€)</th>
                <th>Statut</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if (flights != null && !flights.isEmpty()) {
                for (Flight flight : flights) { %>
            <tr>
                <td><strong><%= flight.getFlightNumber() %></strong></td>
                <td><%= flight.getDepartureAirport().getCode() %> - <%= flight.getDepartureAirport().getCity() %></td>
                <td><%= flight.getArrivalAirport().getCode() %> - <%= flight.getArrivalAirport().getCity() %></td>
                <td><%= sdf.format(flight.getDepartureTime()) %></td>
                <td><%= sdf.format(flight.getArrivalTime()) %></td>
                <td><%= flight.getAircraft() != null ? flight.getAircraft().getRegistration() : "N/A" %></td>
                <td><%= String.format("%.2f", flight.getBasePrice()) %> €</td>
                <td>
                    <% String status = flight.getStatus();
                        String badgeClass = "bg-secondary";
                        if ("scheduled".equals(status)) badgeClass = "bg-primary";
                        else if ("departed".equals(status)) badgeClass = "bg-warning";
                        else if ("arrived".equals(status)) badgeClass = "bg-success";
                        else if ("cancelled".equals(status)) badgeClass = "bg-danger";
                    %>
                    <span class="badge <%= badgeClass %>"><%= status %></span>
                </td>
                <td>
                    <a href="flights?action=edit&id=<%= flight.getId() %>" class="btn btn-sm btn-warning">✏️</a>
                    <a href="flights?action=delete&id=<%= flight.getId() %>"
                       class="btn btn-sm btn-danger"
                       onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce vol ?')">🗑️</a>
                </td>
            </tr>
            <% }
            } else { %>
            <tr>
                <td colspan="9" class="text-center">Aucun vol disponible</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>