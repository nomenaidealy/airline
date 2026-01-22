<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    FlightInstance fi = (FlightInstance) request.getAttribute("flightInstance");
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Réservations du Vol - <%= fi.getRoute().getFlightNumber() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2>🎫 Réservations pour le vol <%= fi.getRoute().getFlightNumber() %></h2>
    <p><strong>Départ:</strong> <%= fi.getRoute().getDepartureAirport().getCode() %> - <%= fi.getRoute().getDepartureAirport().getCity() %>
       | <strong>Arrivée:</strong> <%= fi.getRoute().getArrivalAirport().getCode() %> - <%= fi.getRoute().getArrivalAirport().getCity() %></p>
    <p><strong>Date du vol:</strong> <%= dateFormat.format(fi.getFlightDate()) %>
       | <strong>Heure départ:</strong> <%= sdf.format(fi.getDepartureTime()) %></p>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Référence</th>
                <th>Passager</th>
                <th>Siège</th>
                <th>Montant (€)</th>
                <th>Statut</th>
            </tr>
            </thead>
            <tbody>
            <% if (bookings != null && !bookings.isEmpty()) {
                for (Booking booking : bookings) { %>
            <tr>
                <td><%= booking.getBookingReference() %></td>
                <td><%= booking.getPassenger().getFirstName() + " " + booking.getPassenger().getLastName() %></td>
                <td><%= booking.getSeatNumber() %></td>
                <td><%= String.format("%.2f", booking.getTotalAmount()) %></td>
                <td>
                    <span class="badge <%= "confirmed".equals(booking.getStatus()) ? "bg-success" : "bg-danger" %>">
                        <%= booking.getStatus() %>
                    </span>
                </td>
            </tr>
            <% } } else { %>
            <tr>
                <td colspan="5" class="text-center">Aucune réservation pour ce vol</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <a href="flight-instances" class="btn btn-secondary mt-3">↩️ Retour aux vols</a>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
