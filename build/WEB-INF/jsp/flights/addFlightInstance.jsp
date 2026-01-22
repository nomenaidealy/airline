<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>

<%
    List<FlightRoute> routes = (List<FlightRoute>) request.getAttribute("flightRoutes");
    List<Aircraft> aircrafts = (List<Aircraft>) request.getAttribute("aircrafts");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Programmer un Vol - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">➕ Programmer une Instance de Vol</h2>

    <div class="card">
        <div class="card-body">
            <form method="post" action="flight-instances">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="routeId" class="form-label">Route de Vol *</label>
                        <select class="form-select" id="routeId" name="routeId" required>
                            <option value="">Sélectionner une route...</option>
                            <% if (routes != null) {
                                for (FlightRoute route : routes) { %>
                            <option value="<%= route.getId() %>">
                                <%= route.getFlightNumber() %> 
                                (<%= route.getDepartureAirport() != null ? route.getDepartureAirport().getCode() : "?" %> 
                                → <%= route.getArrivalAirport() != null ? route.getArrivalAirport().getCode() : "?" %>)
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="flightDate" class="form-label">Date du Vol *</label>
                        <input type="date" class="form-control" id="flightDate" name="flightDate" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="departureTime" class="form-label">Heure de Départ *</label>
                        <input type="datetime-local" class="form-control" id="departureTime" name="departureTime" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="arrivalTime" class="form-label">Heure d'Arrivée *</label>
                        <input type="datetime-local" class="form-control" id="arrivalTime" name="arrivalTime" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="aircraftId" class="form-label">Avion *</label>
                        <select class="form-select" id="aircraftId" name="aircraftId" required>
                            <option value="">Sélectionner un avion...</option>
                            <% if (aircrafts != null) {
                                for (Aircraft aircraft : aircrafts) { %>
                            <option value="<%= aircraft.getId() %>">
                                <%= aircraft.getRegistration() %> - <%= aircraft.getModel() %> 
                                (<%= aircraft.getTotalSeats() %> places)
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="basePrice" class="form-label">Prix de Base (€) *</label>
                        <input type="number" step="0.01" class="form-control" id="basePrice" name="basePrice" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <label for="status" class="form-label">Statut *</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="scheduled">Scheduled</option>
                            <option value="boarding">Boarding</option>
                            <option value="departed">Departed</option>
                            <option value="arrived">Arrived</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </div>
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">💾 Enregistrer</button>
                    <a href="flight-instances" class="btn btn-secondary">↩️ Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>