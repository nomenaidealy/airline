<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des Paiements - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>💳 Liste des Paiements</h2>
        <a href="payments" class="btn btn-secondary">↩️ Retour au tableau de bord</a>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Date</th>
                <th>Référence Réservation</th>
                <th>Vol</th>
                <th>Passager</th>
                <th>Siège</th>
                <th>Montant (€)</th>
                <th>Méthode</th>
                <th>Statut</th>
            </tr>
            </thead>
            <tbody>
            <% if (payments != null && !payments.isEmpty()) {
                for (Payment payment : payments) { %>
            <tr>
                <td><%= sdf.format(payment.getPaymentDate()) %></td>
                <td><strong><%= payment.getBooking().getBookingReference() %></strong></td>
                <td><%= payment.getBooking().getFlight().getFlightNumber() %></td>
                <td><%= payment.getBooking().getPassenger().getFullName() %></td>
                <td><span class="badge bg-info"><%= payment.getBooking().getSeatNumber() %></span></td>
                <td class="text-success"><strong><%= String.format("%.2f", payment.getAmount()) %> €</strong></td>
                <td>
                    <% String method = payment.getPaymentMethod();
                        String icon = "💳";
                        if ("cash".equals(method)) icon = "💵";
                        else if ("mobile_money".equals(method)) icon = "📱";
                        else if ("bank_transfer".equals(method)) icon = "🏦";
                    %>
                    <%= icon %> <%= method %>
                </td>
                <td>
                    <% String status = payment.getStatus();
                        String badgeClass = "paid".equals(status) ? "bg-success" :
                                "refunded".equals(status) ? "bg-warning" : "bg-danger";
                    %>
                    <span class="badge <%= badgeClass %>"><%= status %></span>
                </td>
            </tr>
            <% }
            } else { %>
            <tr>
                <td colspan="8" class="text-center">Aucun paiement enregistré</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <% if (payments != null && !payments.isEmpty()) {
        double total = 0;
        for (Payment p : payments) {
            if ("paid".equals(p.getStatus())) {
                total += p.getAmount();
            }
        }
    %>
    <div class="card mt-4">
        <div class="card-body">
            <h4>Total des paiements affichés: <span class="text-success"><%= String.format("%.2f", total) %> €</span></h4>
        </div>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>