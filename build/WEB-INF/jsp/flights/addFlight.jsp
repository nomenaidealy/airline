<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%
    List<Airport> airports = (List<Airport>) request.getAttribute("airports");
    List<Aircraft> aircrafts = (List<Aircraft>) request.getAttribute("aircrafts");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajouter un Vol - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">➕ Ajouter un Vol</h2>

    <div class="card">
        <div class="card-body">
            <form method="post" action="flights">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="flightNumber" class="form-label">Numéro de Vol *</label>
                        <input type="text" class="form-control" id="flightNumber" name="flightNumber" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label">Statut *</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="scheduled">Scheduled</option>
                            <option value="departed">Departed</option>
                            <option value="arrived">Arrived</option>
                            <option value="cancelled">Cancelled</option>
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
                            <option value="<%= airport.getId() %>"><%= airport.toString() %></option>
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
                            <option value="<%= airport.getId() %>"><%= airport.toString() %></option>
                            <% }
                            } %>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="departureTime" class="form-label">Date/Heure de Départ *</label>
                        <input type="datetime-local" class="form-control" id="departureTime" name="departureTime" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="arrivalTime" class="form-label">Date/Heure d'Arrivée *</label>
                        <input type="datetime-local" class="form-control" id="arrivalTime" name="arrivalTime" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="aircraftId" class="form-label">Avion *</label>
                        <select class="form-select" id="aircraftId" name="aircraftId" required>
                            <option value="">Sélectionner...</option>
                            <% if (aircrafts != null) {
                                for (Aircraft aircraft : aircrafts) { %>
                            <option value="<%= aircraft.getId() %>"><%= aircraft.toString() %></option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="basePrice" class="form-label">Prix de Base (€) *</label>
                        <input type="number" step="0.01" class="form-control" id="basePrice" name="basePrice" required>
                    </div>
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">💾 Enregistrer</button>
                    <a href="flights" class="btn btn-secondary">↩️ Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>