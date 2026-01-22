<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>

<%
    List<Airport> airports = (List<Airport>) request.getAttribute("airports");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajouter une Route - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">➕ Ajouter une Route de Vol</h2>

    <div class="card">
        <div class="card-body">
            <form method="post" action="flight-routes">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="flightNumber" class="form-label">Numéro de Vol *</label>
                        <input type="text" class="form-control" id="flightNumber" name="flightNumber" 
                               placeholder="ex: AF101" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label">Statut *</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="active">Active</option>
                            <option value="suspended">Suspended</option>
                            <option value="discontinued">Discontinued</option>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="departureAirportId" class="form-label">Aéroport de Départ *</label>
                        <select class="form-select" id="departureAirportId" name="departureAirportId" required>
                            <option value="">Sélectionner...</option>
                            <% if (airports != null) {
                                for (Airport airport : airports) { %>
                            <option value="<%= airport.getId() %>">
                                <%= airport.getCode() %> - <%= airport.getName() %> (<%= airport.getCity() %>)
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="arrivalAirportId" class="form-label">Aéroport d'Arrivée *</label>
                        <select class="form-select" id="arrivalAirportId" name="arrivalAirportId" required>
                            <option value="">Sélectionner...</option>
                            <% if (airports != null) {
                                for (Airport airport : airports) { %>
                            <option value="<%= airport.getId() %>">
                                <%= airport.getCode() %> - <%= airport.getName() %> (<%= airport.getCity() %>)
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="distance" class="form-label">Distance (km)</label>
                        <input type="number" class="form-control" id="distance" name="distance" 
                               placeholder="ex: 5500">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="estimatedDuration" class="form-label">Durée Estimée (heures:minutes)</label>
                        <input type="text" class="form-control" id="estimatedDuration" name="estimatedDuration" 
                               placeholder="ex: 10:30">
                    </div>
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">💾 Enregistrer</button>
                    <a href="flight-routes" class="btn btn-secondary">↩️ Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>