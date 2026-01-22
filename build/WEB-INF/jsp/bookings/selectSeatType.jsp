<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.Booking" %>
<%@ page import="main.project.beans.Passenger" %>
<%@ page import="main.project.beans.FlightSeatPriceDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    List<FlightSeatPriceDetail> seatDetails = (List<FlightSeatPriceDetail>) request.getAttribute("flightDetails");
    Integer flightInstanceId = (Integer) request.getAttribute("flightInstanceId");
    Integer passengerId = (Integer) request.getAttribute("passengerId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
     <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<div class="container mt-5 mb-5">
    <!-- En-tête -->
    <div class="card border-0 shadow-lg mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
        <div class="card-body text-white p-4">
            <h3 class="mb-0 fw-bold">
                📋 Choisir le nombre de places par type
            </h3>
            <p class="mb-0 mt-2 opacity-75">Sélectionnez le nombre de passagers par classe et par type</p>
        </div>
    </div>
    
    <form method="post" action="bookings?action=createMultipleBookings">
        <input type="hidden" name="passengerId" value="<%= passengerId %>">
        <input type="hidden" name="flightInstanceId" value="<%= flightInstanceId %>">
        
        <% if (seatDetails != null && !seatDetails.isEmpty()) {
            for (FlightSeatPriceDetail detail : seatDetails) {
                BigDecimal babyPrice = (detail.getPrice() != null) ? detail.getPrice().multiply(new BigDecimal("0.1")) : BigDecimal.ZERO;
        %>
        
        <!-- Card pour chaque classe -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h4 class="mb-0 fw-bold text-primary">
                            <i class="bi bi-star-fill"></i> <%= detail.getClassName() %>
                        </h4>
                    </div>
                    <div class="col-md-6 text-md-end mt-3 mt-md-0">
                        <span class="badge bg-primary bg-opacity-10 text-primary border border-primary px-3 py-2 fs-6">
                            <i class="bi bi-people-fill"></i> <%= detail.getAvailableSeats() %> places disponibles
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="card-body p-4">
                <!-- Grille des prix -->
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="card bg-light border-0 h-100">
                            <div class="card-body text-center">
                                <div class="text-muted small mb-2">👨 Prix Adulte</div>
                                <div class="fs-4 fw-bold text-primary">
                                    <%= detail.getPrice() != null ? String.format("%.2f", detail.getPrice()) : "N/A" %> Ar
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-light border-0 h-100">
                            <div class="card-body text-center">
                                <div class="text-muted small mb-2">👦 Prix Enfant</div>
                                <div class="fs-4 fw-bold text-success">
                                    <%= detail.getChildPrice() != null ? String.format("%.2f", detail.getChildPrice()) : "N/A" %> Ar
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-light border-0 h-100">
                            <div class="card-body text-center">
                                <div class="text-muted small mb-2">👶 Prix Bébé</div>
                                <div class="fs-4 fw-bold text-info">
                                    <%= String.format("%.2f", babyPrice) %> Ar
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Inputs pour nombre de passagers -->
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="card border border-primary border-opacity-25 h-100">
                            <div class="card-body">
                                <label class="form-label fw-semibold text-primary mb-3">
                                    <i class="bi bi-person-fill"></i> Nombre d'adultes
                                </label>
                                <input type="number" 
                                       class="form-control form-control-lg" 
                                       name="seatsToBookAdult_<%= detail.getAircraftClassSeatId() %>" 
                                       min="0" 
                                       max="<%= detail.getAvailableSeats() %>" 
                                       value="0"
                                       placeholder="0">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border border-success border-opacity-25 h-100">
                            <div class="card-body">
                                <label class="form-label fw-semibold text-success mb-3">
                                    <i class="bi bi-person"></i> Nombre d'enfants
                                </label>
                                <input type="number" 
                                       class="form-control form-control-lg" 
                                       name="seatsToBookChild_<%= detail.getAircraftClassSeatId() %>" 
                                       min="0" 
                                       max="<%= detail.getAvailableSeats() %>" 
                                       value="0"
                                       placeholder="0">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border border-info border-opacity-25 h-100">
                            <div class="card-body">
                                <label class="form-label fw-semibold text-info mb-3">
                                    <i class="bi bi-person-hearts"></i> Nombre de bébés
                                </label>
                                <input type="number" 
                                       class="form-control form-control-lg" 
                                       name="seatsToBookBaby_<%= detail.getAircraftClassSeatId() %>" 
                                       min="0" 
                                       max="<%= detail.getAvailableSeats() %>" 
                                       value="0"
                                       placeholder="0">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <% } } else { %>
        
        <!-- État vide -->
        <div class="card border-0 shadow-sm">
            <div class="card-body text-center py-5">
                <div class="text-muted">
                    <i class="bi bi-exclamation-circle" style="font-size: 4rem;"></i>
                    <p class="fs-4 fw-semibold mt-3">Aucune classe disponible pour ce vol</p>
                </div>
            </div>
        </div>
        
        <% } %>
        
        <!-- Boutons d'action -->
        <div class="row mt-4">
            <div class="col-md-6 mb-3 mb-md-0">
                <% if (flightInstanceId != null) { %>
                <a href="bookings?action=listBookings&flightInstanceId=<%= flightInstanceId %>" 
                   class="btn btn-outline-secondary btn-lg w-100">
                    <i class="bi bi-arrow-left"></i> ⬅️ Retour aux détails du vol
                </a>
                <% } %>
            </div>
            <div class="col-md-6">
                <% if (seatDetails != null && !seatDetails.isEmpty()) { %>
                <button type="submit" class="btn btn-primary btn-lg w-100 shadow">
                    <i class="bi bi-check-circle"></i> Réserver les places
                </button>
                <% } %>
            </div>
        </div>
    </form>
</div>