<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.Booking" %>
<%@ page import="main.project.beans.Passenger" %>
<%@ page import="java.util.List" %>
<%
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    double totalAmountSum = 0.0;
    if (bookings != null) {
        for (Booking b : bookings) {
            totalAmountSum += b.getTotalAmount();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
     <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<div class="container mt-5">
    <!-- En-tête avec gradient -->
    <div class="card border-0 shadow-lg mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
        <div class="card-body text-white p-4">
            <h2 class="mb-0 fw-bold">
                <i class="bi bi-clipboard-check"></i> 📋 Réservations pour ce Vol
            </h2>
        </div>
    </div>
    
    <!-- Tableau des réservations -->
    <div class="card border-0 shadow">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="text-center fw-semibold">ID</th>
                            <th class="text-center fw-semibold">Référence</th>
                            <th class="text-center fw-semibold">Passager</th>
                            <th class="text-center fw-semibold">Siège</th>
                            <th class="text-center fw-semibold">Date</th>
                            <th class="text-center fw-semibold">Montant (Ar)</th>
                            <th class="text-center fw-semibold">Statut</th>
                            <th class="text-center fw-semibold">Classe ID</th>
                            <th class="text-center fw-semibold">Enfants</th>
                            <th class="text-center fw-semibold">Bébés</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (bookings != null && !bookings.isEmpty()) {
                            for (Booking b : bookings) { 
                                String statusBadge = "bg-success";
                                if (b.getStatus() != null) {
                                    if (b.getStatus().toLowerCase().contains("pending")) statusBadge = "bg-warning";
                                    if (b.getStatus().toLowerCase().contains("cancelled")) statusBadge = "bg-danger";
                                }
                        %>
                        <tr>
                            <td class="text-center"><strong class="text-primary">#<%= b.getId() %></strong></td>
                            <td class="text-center">
                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary px-3 py-2">
                                    <%= b.getBookingReference() %>
                                </span>
                            </td>
                            <td class="text-center"><%= b.getPassenger() != null ? b.getPassenger().getFirstName() + " " + b.getPassenger().getLastName() : "N/A" %></td>
                            <td class="text-center"><strong><%= b.getSeatNumber() %></strong></td>
                            <td class="text-center"><small><%= b.getBookingDate() != null ? b.getBookingDate() : "N/A" %></small></td>
                            <td class="text-center"><strong class="text-success"><%= String.format("%.2f", b.getTotalAmount()) %></strong></td>
                            <td class="text-center">
                                <span class="badge <%= statusBadge %> rounded-pill px-3">
                                    <%= b.getStatus() %>
                                </span>
                            </td>
                            <td class="text-center"><%= b.getAircraftClassSeatId() %></td>
                            <td class="text-center"><span class="badge bg-info"><%= b.getChildCount() %></span></td>
                            <td class="text-center"><span class="badge bg-secondary"><%= b.getBabyCount() %></span></td>
                        </tr>
                        <% } %>
                        <tr class="table-warning">
                            <td colspan="5" class="text-end fw-bold fs-5 py-3">💰 Total des réservations :</td>
                            <td colspan="5" class="fw-bold fs-5 text-success py-3"><%= String.format("%.2f", totalAmountSum) %> Ar</td>
                        </tr>
                        <% } else { %>
                        <tr>
                            <td colspan="10" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="bi bi-inbox" style="font-size: 3rem;"></i>
                                    <p class="fs-5 fw-semibold mt-3">Aucune réservation pour ce vol</p>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>