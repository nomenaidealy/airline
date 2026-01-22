<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Date" %>

<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect("login");
        return;
    }
    
    List<FlightInstance> instances = (List<FlightInstance>) request.getAttribute("flightInstances");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    
    // Paramètres de filtrage
    String filterDeparture = request.getParameter("filterDeparture") != null ? request.getParameter("filterDeparture").trim() : "";
    String filterArrival = request.getParameter("filterArrival") != null ? request.getParameter("filterArrival").trim() : "";
    String filterFlightDate = request.getParameter("filterFlightDate") != null ? request.getParameter("filterFlightDate").trim() : "";
    String filterDepartureTime = request.getParameter("filterDepartureTime") != null ? request.getParameter("filterDepartureTime").trim() : "";
    String filterMinPrice = request.getParameter("filterMinPrice") != null ? request.getParameter("filterMinPrice").trim() : "";
    String filterMaxPrice = request.getParameter("filterMaxPrice") != null ? request.getParameter("filterMaxPrice").trim() : "";
    
    // Filtrer les instances
    List<FlightInstance> filteredInstances = new ArrayList<>();
    if (instances != null) {
        for (FlightInstance fi : instances) {
            boolean matches = true;
            if (!filterDeparture.isEmpty()) {
                String depCode = fi.getRoute().getDepartureAirport() != null ? 
                    fi.getRoute().getDepartureAirport().getCode().toUpperCase() : "";
                if (!depCode.contains(filterDeparture.toUpperCase())) matches = false;
            }
            if (!filterArrival.isEmpty() && matches) {
                String arrCode = fi.getRoute().getArrivalAirport() != null ? 
                    fi.getRoute().getArrivalAirport().getCode().toUpperCase() : "";
                if (!arrCode.contains(filterArrival.toUpperCase())) matches = false;
            }
            if (!filterFlightDate.isEmpty() && matches) {
                String flightDateStr = dateFormat.format(fi.getFlightDate());
                if (!flightDateStr.contains(filterFlightDate)) matches = false;
            }
            if (!filterDepartureTime.isEmpty() && matches) {
                String depTimeStr = sdf.format(fi.getDepartureTime());
                if (!depTimeStr.contains(filterDepartureTime)) matches = false;
            }
            if (!filterMinPrice.isEmpty() && matches) {
                try {
                    double minPrice = Double.parseDouble(filterMinPrice);
                    if (fi.getBasePrice() < minPrice) matches = false;
                } catch (NumberFormatException e) {}
            }
            if (!filterMaxPrice.isEmpty() && matches) {
                try {
                    double maxPrice = Double.parseDouble(filterMaxPrice);
                    if (fi.getBasePrice() > maxPrice) matches = false;
                } catch (NumberFormatException e) {}
            }
            if (matches) filteredInstances.add(fi);
        }
    }
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
        if (successMessage != null) { session.removeAttribute("successMessage"); %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%= successMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% }
        if (errorMessage != null) { session.removeAttribute("errorMessage"); %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%= errorMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>📋 Gestion des Instances de Vol</h2>
        <a href="flight-instances?action=add" class="btn btn-primary">➕ Programmer un vol</a>
    </div>

    <!-- Filtrage -->
    <div class="card mb-4">
        <div class="card-header bg-light">
            <h5 class="mb-0">🔍 Filtrer les vols</h5>
        </div>
        <div class="card-body">
            <form method="get" action="flight-instances" class="row g-3">
                <div class="col-md-2">
                    <label class="form-label">Départ</label>
                    <input type="text" class="form-control" name="filterDeparture" placeholder="ex: TNR" value="<%= filterDeparture %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Arrivée</label>
                    <input type="text" class="form-control" name="filterArrival" placeholder="ex: CDG" value="<%= filterArrival %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Date du Vol</label>
                    <input type="text" class="form-control" name="filterFlightDate" placeholder="dd/MM/yyyy" value="<%= filterFlightDate %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Heure Départ</label>
                    <input type="text" class="form-control" name="filterDepartureTime" placeholder="HH:mm" value="<%= filterDepartureTime %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Prix Min (€)</label>
                    <input type="number" step="0.01" class="form-control" name="filterMinPrice" value="<%= filterMinPrice %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Prix Max (€)</label>
                    <input type="number" step="0.01" class="form-control" name="filterMaxPrice" value="<%= filterMaxPrice %>">
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">🔍 Filtrer</button>
                    <a href="flight-instances" class="btn btn-secondary">🔄 Réinitialiser</a>
                </div>
            </form>
        </div>
    </div>

    <!-- Tableau des vols -->
    <div class="alert alert-info">
        <strong><%= filteredInstances.size() %></strong> vol(s) trouvé(s)
        <% if (instances != null) { %>
            sur <strong><%= instances.size() %></strong> au total
        <% } %>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
                <tr>
                    <th>Numéro Vol</th>
                    <th>Départ</th>
                    <th>Arrivée</th>
                    <th>Date du Vol</th>
                    <th>Heure Départ</th>
                    <th>Heure Arrivée</th>
                    <th>Avion</th>
                    <th>Prix (€)</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (filteredInstances != null && !filteredInstances.isEmpty()) {
                    for (FlightInstance fi : filteredInstances) { %>
                <tr style="cursor:pointer" onclick="window.location='flight-instances?action=details&id=<%= fi.getId() %>'">
                    <td><strong><%= fi.getRoute().getFlightNumber() %></strong></td>
                    <td><%= fi.getRoute().getDepartureAirport() != null ? fi.getRoute().getDepartureAirport().getCode() + " - " + fi.getRoute().getDepartureAirport().getCity() : "N/A" %></td>
                    <td><%= fi.getRoute().getArrivalAirport() != null ? fi.getRoute().getArrivalAirport().getCode() + " - " + fi.getRoute().getArrivalAirport().getCity() : "N/A" %></td>
                    <td><%= dateFormat.format(fi.getFlightDate()) %></td>
                    <td><%= sdf.format(fi.getDepartureTime()) %></td>
                    <td><%= sdf.format(fi.getArrivalTime()) %></td>
                    <td><%= fi.getAircraft() != null ? fi.getAircraft().getRegistration() : "N/A" %></td>
                    <td><%= String.format("%.2f", fi.getBasePrice()) %> €</td>
                    <td>
                        <% String status = fi.getStatus();
                            String badgeClass = "bg-secondary";
                            if ("scheduled".equals(status)) badgeClass = "bg-primary";
                            else if ("boarding".equals(status)) badgeClass = "bg-info";
                            else if ("departed".equals(status)) badgeClass = "bg-warning";
                            else if ("arrived".equals(status)) badgeClass = "bg-success";
                            else if ("cancelled".equals(status)) badgeClass = "bg-danger";
                        %>
                        <span class="badge <%= badgeClass %>"><%= status %></span>
                    </td>
                    <td>
                        <a href="flight-instances?action=edit&id=<%= fi.getId() %>" class="btn btn-sm btn-warning">✏️</a>
                        <a href="flight-instances?action=delete&id=<%= fi.getId() %>"
                           class="btn btn-sm btn-danger"
                           onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette instance ?')">🗑️</a>
                    </td>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="10" class="text-center">
                        <% if (instances != null && !instances.isEmpty()) { %>
                            Aucun vol ne correspond à votre recherche
                        <% } else { %>
                            Aucun vol programmé
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
