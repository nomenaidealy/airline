<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    Passenger passenger = (Passenger) request.getAttribute("passenger");
    List<FlightInstance> flightInstances = (List<FlightInstance>) request.getAttribute("flightInstances");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    
    // Récupérer les paramètres de filtrage
    String filterDeparture = request.getParameter("filterDeparture") != null ? request.getParameter("filterDeparture").trim() : "";
    String filterArrival = request.getParameter("filterArrival") != null ? request.getParameter("filterArrival").trim() : "";
    String filterFlightDate = request.getParameter("filterFlightDate") != null ? request.getParameter("filterFlightDate").trim() : "";
    String filterDepartureTime = request.getParameter("filterDepartureTime") != null ? request.getParameter("filterDepartureTime").trim() : "";
    
    // Filtrer les instances de vol
    List<FlightInstance> filteredInstances = new ArrayList<>();
    if (flightInstances != null) {
        for (FlightInstance fi : flightInstances) {
            boolean matches = true;
            
            // Filtre par aéroport de départ
            if (!filterDeparture.isEmpty()) {
                String depCode = fi.getRoute().getDepartureAirport() != null ? 
                    fi.getRoute().getDepartureAirport().getCode().toUpperCase() : "";
                if (!depCode.contains(filterDeparture.toUpperCase())) {
                    matches = false;
                }
            }
            
            // Filtre par aéroport d'arrivée
            if (!filterArrival.isEmpty() && matches) {
                String arrCode = fi.getRoute().getArrivalAirport() != null ? 
                    fi.getRoute().getArrivalAirport().getCode().toUpperCase() : "";
                if (!arrCode.contains(filterArrival.toUpperCase())) {
                    matches = false;
                }
            }
            
            // Filtre par date de vol
            if (!filterFlightDate.isEmpty() && matches) {
                String flightDateStr = dateFormat.format(fi.getFlightDate());
                if (!flightDateStr.contains(filterFlightDate)) {
                    matches = false;
                }
            }
            
            // Filtre par heure de départ
            if (!filterDepartureTime.isEmpty() && matches) {
                String depTimeStr = sdf.format(fi.getDepartureTime());
                if (!depTimeStr.contains(filterDepartureTime)) {
                    matches = false;
                }
            }
            
            if (matches) {
                filteredInstances.add(fi);
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sélection du Vol - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">✈️ Sélection du Vol</h2>

    <div class="card mb-4">
        <div class="card-header bg-info text-white">
            <h5 class="mb-0">👤 Informations du Passager</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <p><strong>Nom:</strong> <%= passenger.getFirstName() + " " + passenger.getLastName() %></p>
                    <p><strong>Email:</strong> <%= passenger.getEmail() != null ? passenger.getEmail() : "N/A" %></p>
                </div>
                <div class="col-md-6">
                    <p><strong>Passeport:</strong> <%= passenger.getPassportNumber() %></p>
                    <p><strong>Téléphone:</strong> <%= passenger.getPhone() != null ? passenger.getPhone() : "N/A" %></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Panneau de filtrage -->
    <div class="card mb-4">
        <div class="card-header bg-light">
            <h5 class="mb-0">🔍 Filtrer les vols disponibles</h5>
        </div>
        <div class="card-body">
            <form method="get" action="bookings" class="row g-3">
                <input type="hidden" name="action" value="selectFlight">
                <input type="hidden" name="passengerId" value="<%= passenger.getId() %>">
                
                <div class="col-md-3">
                    <label for="filterDeparture" class="form-label">Aéroport Départ</label>
                    <input type="text" class="form-control" id="filterDeparture" name="filterDeparture" 
                           placeholder="ex: TNR" value="<%= filterDeparture %>" maxlength="10">
                </div>
                
                <div class="col-md-3">
                    <label for="filterArrival" class="form-label">Aéroport Arrivée</label>
                    <input type="text" class="form-control" id="filterArrival" name="filterArrival" 
                           placeholder="ex: CDG" value="<%= filterArrival %>" maxlength="10">
                </div>
                
                <div class="col-md-3">
                    <label for="filterFlightDate" class="form-label">Date du Vol</label>
                    <input type="text" class="form-control" id="filterFlightDate" name="filterFlightDate" 
                           placeholder="dd/MM/yyyy" value="<%= filterFlightDate %>">
                </div>
                
                <div class="col-md-3">
                    <label for="filterDepartureTime" class="form-label">Heure Départ</label>
                    <input type="text" class="form-control" id="filterDepartureTime" name="filterDepartureTime" 
                           placeholder="HH:mm" value="<%= filterDepartureTime %>">
                </div>
                
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">🔍 Filtrer</button>
                    <a href="bookings?action=selectFlight&passengerId=<%= passenger.getId() %>" class="btn btn-secondary">
                        🔄 Réinitialiser
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Résultats -->
    <div class="alert alert-info">
        <strong><%= filteredInstances.size() %></strong> vol(s) trouvé(s) 
        <% if (flightInstances != null) { %>
            sur <strong><%= flightInstances.size() %></strong> au total
        <% } %>
    </div>

    <h4 class="mb-3">📅 Instances de Vol Disponibles</h4>

    <% if (filteredInstances != null && !filteredInstances.isEmpty()) {
        for (FlightInstance fi : filteredInstances) { %>
    <div class="card mb-3">
        <div class="card-body">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h5 class="card-title">
                        <span class="badge bg-primary"><%= fi.getRoute().getFlightNumber() %></span>
                    </h5>
                    <p class="mb-1">
                        <strong><%= fi.getRoute().getDepartureAirport().getCode() %></strong>
                        (<%= fi.getRoute().getDepartureAirport().getCity() %>)
                        →
                        <strong><%= fi.getRoute().getArrivalAirport().getCode() %></strong>
                        (<%= fi.getRoute().getArrivalAirport().getCity() %>)
                    </p>
                    <p class="mb-1">
                        📅 Vol du: <strong><%= dateFormat.format(fi.getFlightDate()) %></strong>
                    </p>
                    <p class="mb-1">
                        🛫 Départ: <%= sdf.format(fi.getDepartureTime()) %> |
                        🛬 Arrivée: <%= sdf.format(fi.getArrivalTime()) %>
                    </p>
                    <p class="mb-0">
                        ✈️ <%= fi.getAircraft() != null ? fi.getAircraft().getModel() : "N/A" %>
                        (<%= fi.getAircraft() != null ? fi.getAircraft().getRegistration() : "N/A" %>) -
                        <%= fi.getAircraft() != null ? fi.getAircraft().getTotalSeats() : "?" %> sièges
                    </p>
                </div>
                <div class="col-md-4 text-end">
                    <h4 class="text-primary"><%= String.format("%.2f", fi.getBasePrice()) %> €</h4>
                    <button class="btn btn-success" data-bs-toggle="modal"
                            data-bs-target="#seatModal<%= fi.getId() %>">
                        ✅ Réserver
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal pour sélection du siège -->
    <div class="modal fade" id="seatModal<%= fi.getId() %>" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Sélection du Siège - <%= fi.getRoute().getFlightNumber() %></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form method="post" action="bookings">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="createBooking">
                        <input type="hidden" name="passengerId" value="<%= passenger.getId() %>">
                        <input type="hidden" name="flightInstanceId" value="<%= fi.getId() %>">

                        <div class="mb-3">
                            <label class="form-label">Choisissez votre siège:</label>

                            <div class="mb-2">
                                <button type="submit" name="seatNumber" value="random"
                                        class="btn btn-primary w-100">
                                    🎲 Siège Aléatoire (Recommandé)
                                </button>
                            </div>

                            <div class="text-center my-2">
                                <small class="text-muted">ou</small>
                            </div>

                            <div>
                                <label for="seatManual<%= fi.getId() %>" class="form-label">
                                    Sélection manuelle (ex: 15C):
                                </label>
                                <input type="text" class="form-control"
                                       id="seatManual<%= fi.getId() %>"
                                       name="seatNumber"
                                       placeholder="Ex: 15C"
                                       maxlength="5">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            Annuler
                        </button>
                        <button type="submit" class="btn btn-success">
                            Confirmer la Réservation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <% }
    } else { %>
    <div class="alert alert-warning">
        <% if (flightInstances != null && !flightInstances.isEmpty()) { %>
            ⚠️ Aucun vol ne correspond à votre recherche
        <% } else { %>
            ℹ️ Aucun vol disponible pour le moment
        <% } %>
    </div>
    <% } %>

    <div class="mt-4">
        <a href="bookings" class="btn btn-secondary">↩️ Retour aux réservations</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>