<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Flight flight = (Flight) request.getAttribute("flight");
    List<Airport> airports = (List<Airport>) request.getAttribute("airports");
    List<Aircraft> aircrafts = (List<Aircraft>) request.getAttribute("aircrafts");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier un Vol - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">✏️ Modifier un Vol</h2>

    <div class="card">
        <div class="card-body">
            <form method="post" action="flights">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<%= flight.getId() %>">

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="flightNumber" class="form-label">Numéro de Vol *</label>
                        <input type="text" class="form-control" id="flightNumber" name="flightNumber"
                               value="<%= flight.getFlightNumber() %>" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label">Statut *</label>
                        <select class="form-select" id="status" name="status" required>
                            <option value="scheduled" <%= "scheduled".equals(flight.getStatus()) ? "selected" : "" %>>Scheduled</option>
                            <option value="departed" <%= "departed".equals(flight.getStatus()) ? "selected" : "" %>>Departed</option>
                            <option value="arrived" <%= "arrived".equals(flight.getStatus()) ? "selected" : "" %>>Arrived</option>
                            <option value="cancelled" <%= "cancelled".equals(flight.getStatus()) ? "selected" : "" %>>Cancelled</option>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="departureAirportId" class="form-label">Aéroport de Départ *</label>
                        <select class="form-select" id="departureAirportId" name="departureAirportId" required>
                            <% if (airports != null) {
                                for (Airport airport : airports) { %>
                            <option value="<%= airport.getId() %>"
                                    <%= airport.getId() == flight.getDepartureAirportId() ? "selected" : "" %>>
                                <%= airport.toString() %>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="arrivalAirportId" class="form-label">Aéroport d'Arrivée *</label>
                        <select class="form-select" id="arrivalAirportId" name="arrivalAirportId" required>
                            <% if (airports != null) {
                                for (Airport airport : airports) { %>
                            <option value="<%= airport.getId() %>"
                                    <%= airport.getId() == flight.getArrivalAirportId() ? "selected" : "" %>>
                                <%= airport.toString() %>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="departureTime" class="form-label">Date/Heure de Départ *</label>
                        <input type="datetime-local" class="form-control" id="departureTime" name="departureTime"
                               value="<%= sdf.format(flight.getDepartureTime()) %>" required>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="arrivalTime" class="form-label">Date/Heure d'Arrivée *</label>
                        <input type="datetime-local" class="form-control" id="arrivalTime" name="arrivalTime"
                               value="<%= sdf.format(flight.getArrivalTime()) %>" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="aircraftId" class="form-label">Avion *</label>
                        <select class="form-select" id="aircraftId" name="aircraftId" required>
                            <% if (aircrafts != null) {
                                for (Aircraft aircraft : aircrafts) { %>
                            <option value="<%= aircraft.getId() %>"
                                    <%= aircraft.getId() == flight.getAircraftId() ? "selected" : "" %>>
                                <%= aircraft.toString() %>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="basePrice" class="form-label">Prix de Base (€) *</label>
                        <input type="number" step="0.01" class="form-control" id="basePrice" name="basePrice"
                               value="<%= flight.getBasePrice() %>" required>
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