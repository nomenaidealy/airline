<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>

<%
    // Employee employee = (Employee) session.getAttribute("employee");
    // if (employee == null) {
    //     response.sendRedirect("login");
    //     return;
    // }
    List<FlightRoute> routes = (List<FlightRoute>) request.getAttribute("flightRoutes");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Routes - GCA Airlines</title>
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
        <h2>✈️ Gestion des Routes de Vol</h2>
        <a href="flight-routes?action=add" class="btn btn-primary">➕ Ajouter une route</a>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Numéro Vol</th>
                <th>Départ</th>
                <th>Arrivée</th>
                <th>Distance (km)</th>
                <th>Durée estimée</th>
                <th>Statut</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if (routes != null && !routes.isEmpty()) {
                for (FlightRoute route : routes) { %>
            <tr>
                <td><strong><%= route.getFlightNumber() %></strong></td>
                <td>
                    <%= route.getDepartureAirport() != null ? 
                        route.getDepartureAirport().getCode() + " - " + route.getDepartureAirport().getCity() 
                        : "N/A" %>
                </td>
                <td>
                    <%= route.getArrivalAirport() != null ? 
                        route.getArrivalAirport().getCode() + " - " + route.getArrivalAirport().getCity() 
                        : "N/A" %>
                </td>
                <td><%= route.getDistance() != 0 ? route.getDistance() : "N/A" %></td>
                <td><%= route.getEstimatedDuration() != null ? route.getEstimatedDuration() : "N/A" %></td>
                <td>
                    <% String status = route.getStatus();
                        String badgeClass = "bg-secondary";
                        if ("active".equals(status)) badgeClass = "bg-success";
                        else if ("suspended".equals(status)) badgeClass = "bg-warning";
                        else if ("discontinued".equals(status)) badgeClass = "bg-danger";
                    %>
                    <span class="badge <%= badgeClass %>"><%= status %></span>
                </td>
                <td>
                    <a href="flight-routes?action=edit&id=<%= route.getId() %>" class="btn btn-sm btn-warning">✏️</a>
                    <a href="flight-routes?action=delete&id=<%= route.getId() %>"
                       class="btn btn-sm btn-danger"
                       onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette route ?')">🗑️</a>
                </td>
            </tr>
            <% }
            } else { %>
            <tr>
                <td colspan="7" class="text-center">Aucune route disponible</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>