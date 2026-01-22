<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    
    // Récupération des paramètres de filtre
    String filterPassenger = request.getParameter("filterPassenger") != null ? request.getParameter("filterPassenger") : "";
    String filterFlight = request.getParameter("filterFlight") != null ? request.getParameter("filterFlight") : "";
    String filterStatus = request.getParameter("filterStatus") != null ? request.getParameter("filterStatus") : "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Réservations - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .filter-section {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
    </style>
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
        <h2>🎫 Gestion des Réservations</h2>
        <a href="bookings?action=new" class="btn btn-primary">➕ Nouvelle réservation</a>
    </div>

    <!-- Section des filtres -->
    <div class="filter-section">
        <h5 class="mb-3">🔍 Filtrer les réservations</h5>
        <form method="GET" action="bookings" class="row g-3">
            <div class="col-md-4">
                <label for="filterPassenger" class="form-label">Passager</label>
                <input type="text" class="form-control" id="filterPassenger" name="filterPassenger" 
                       placeholder="Nom ou prénom" value="<%= filterPassenger %>">
            </div>
            <div class="col-md-3">
                <label for="filterFlight" class="form-label">Numéro de vol</label>
                <input type="text" class="form-control" id="filterFlight" name="filterFlight" 
                       placeholder="Ex: AF123" value="<%= filterFlight %>">
            </div>
            <div class="col-md-3">
                <label for="filterStatus" class="form-label">Statut</label>
                <select class="form-select" id="filterStatus" name="filterStatus">
                    <option value="">Tous les statuts</option>
                    <option value="confirmed" <%= "confirmed".equals(filterStatus) ? "selected" : "" %>>Confirmée</option>
                    <option value="cancelled" <%= "cancelled".equals(filterStatus) ? "selected" : "" %>>Annulée</option>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100 me-2">Filtrer</button>
                <a href="bookings" class="btn btn-secondary">Réinitialiser</a>
            </div>
        </form>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Référence</th>
                <th>Passager</th>
                <th>Vol</th>
                <th>Trajet</th>
                <th>Date Vol</th>
                <th>Heure Départ</th>
                <th>Avion</th>
                <th>Siège</th>
                <th>Montant (€)</th>
                <th>Statut</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% 
            if (bookings != null && !bookings.isEmpty()) {
                int visibleCount = 0;
                double totalAmount = 0.0;
                for (Booking booking : bookings) {
                    // Application des filtres
                    String passengerName = booking.getPassenger().getFirstName() + " " + booking.getPassenger().getLastName();
                    String flightNumber = booking.getFlight().getFlightNumber();
                    String status = booking.getStatus();
                    
                    boolean matchPassenger = filterPassenger.isEmpty() || 
                        passengerName.toLowerCase().contains(filterPassenger.toLowerCase());
                    boolean matchFlight = filterFlight.isEmpty() || 
                        flightNumber.toLowerCase().contains(filterFlight.toLowerCase());
                    boolean matchStatus = filterStatus.isEmpty() || status.equals(filterStatus);
                    
                    if (matchPassenger && matchFlight && matchStatus) {
                        visibleCount++;
                        totalAmount += booking.getTotalAmount();
            %>
            <tr>
                <td><strong><%= booking.getBookingReference() %></strong></td>
                <td>
                    <%= booking.getPassenger().getFirstName() + " " + booking.getPassenger().getLastName() %>
                </td>
                <td><span class="badge bg-primary"><%= booking.getFlight().getFlightNumber() %></span></td>
                <td>
                    <%= booking.getFlight().getDepartureAirport().getCode() %> →
                    <%= booking.getFlight().getArrivalAirport().getCode() %>
                </td>
                <td>
                    <%= dateFormat.format(booking.getFlight().getDepartureTime()) %>
                </td>
                <td>
                    <%= sdf.format(booking.getFlight().getDepartureTime()) %>
                </td>
                <td>
                    <%= booking.getFlight().getAircraft() != null ? 
                        booking.getFlight().getAircraft().getRegistration() : "N/A" %>
                </td>
                <td><span class="badge bg-info"><%= booking.getSeatNumber() %></span></td>
                <td><%= String.format("%.2f", booking.getTotalAmount()) %> €</td>
                <td>
                    <% 
                        String badgeClass = "confirmed".equals(status) ? "bg-success" : "bg-danger";
                    %>
                    <span class="badge <%= badgeClass %>"><%= status %></span>
                </td>
                <td>
                    <% if ("confirmed".equals(booking.getStatus())) { %>
                    <a href="bookings?action=cancel&id=<%= booking.getId() %>"
                       class="btn btn-sm btn-danger"
                       onclick="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')">
                        ❌ Annuler
                    </a>
                    <% } else { %>
                    <span class="text-muted">Annulée</span>
                    <% } %>
                </td>
            </tr>
            <% 
                    }
                }
                if (visibleCount == 0) {
            %>
            <tr>
                <td colspan="11" class="text-center">Aucune réservation ne correspond aux critères de filtre</td>
            </tr>
            <%
                } else {
            %>
            <tr class="table-info fw-bold">
                <td colspan="8" class="text-end">TOTAL :</td>
                <td><%= String.format("%.2f", totalAmount) %> €</td>
                <td colspan="2"></td>
            </tr>
            <%
                }
            } else { 
            %>
            <tr>
                <td colspan="11" class="text-center">Aucune réservation disponible</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <% 
    // Afficher un résumé sous le tableau si des réservations sont affichées
    if (bookings != null && !bookings.isEmpty()) {
        int visibleCount = 0;
        double totalAmount = 0.0;
        for (Booking booking : bookings) {
            String passengerName = booking.getPassenger().getFirstName() + " " + booking.getPassenger().getLastName();
            String flightNumber = booking.getFlight().getFlightNumber();
            String status = booking.getStatus();
            
            boolean matchPassenger = filterPassenger.isEmpty() || 
                passengerName.toLowerCase().contains(filterPassenger.toLowerCase());
            boolean matchFlight = filterFlight.isEmpty() || 
                flightNumber.toLowerCase().contains(filterFlight.toLowerCase());
            boolean matchStatus = filterStatus.isEmpty() || status.equals(filterStatus);
            
            if (matchPassenger && matchFlight && matchStatus) {
                visibleCount++;
                totalAmount += booking.getTotalAmount();
            }
        }
        if (visibleCount > 0) {
    %>
    <div class="alert alert-info mt-3">
        <div class="row">
            <div class="col-md-6">
                <strong>📊 Résumé des réservations affichées:</strong>
            </div>
            <div class="col-md-6 text-end">
                <strong><%= visibleCount %></strong> réservation(s) | 
                <strong>Montant total: <%= String.format("%.2f", totalAmount) %> €</strong>
            </div>
        </div>
    </div>
    <% 
        }
    }
    %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>