<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%
    List<Map<String, Object>> flightRevenue = (List<Map<String, Object>>) request.getAttribute("flightRevenue");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revenus par Vol - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>✈️ Revenus par Vol</h2>
        <a href="payments" class="btn btn-secondary">↩️ Retour</a>
    </div>

    <div class="row">
        <% if (flightRevenue != null && !flightRevenue.isEmpty()) {
            double grandTotal = 0;
            for (Map<String, Object> row : flightRevenue) {
                grandTotal += (Double) row.get("totalRevenue");
            }
        %>

        <div class="col-md-12 mb-4">
            <div class="alert alert-info">
                <h4>Total des revenus: <strong><%= String.format("%.2f", grandTotal) %> €</strong></h4>
                <p class="mb-0">Nombre de vols avec revenus: <%= flightRevenue.size() %></p>
            </div>
        </div>

        <% for (Map<String, Object> row : flightRevenue) {
            String flightNumber = (String) row.get("flightNumber");
            Timestamp departureTime = (Timestamp) row.get("departureTime");
            String route = (String) row.get("route");
            int paymentCount = (Integer) row.get("paymentCount");
            double totalRevenue = (Double) row.get("totalRevenue");
            double percentage = (totalRevenue / grandTotal) * 100;
        %>
        <div class="col-md-6 mb-3">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <%= flightNumber %> - <%= route %>
                    </h5>
                    <small><%= sdf.format(departureTime) %></small>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-6">
                            <p class="mb-1"><strong>Nombre de paiements:</strong></p>
                            <h4 class="text-primary"><%= paymentCount %></h4>
                        </div>
                        <div class="col-6">
                            <p class="mb-1"><strong>Revenus totaux:</strong></p>
                            <h4 class="text-success"><%= String.format("%.2f", totalRevenue) %> €</h4>
                        </div>
                    </div>
                    <div class="progress mt-2">
                        <div class="progress-bar bg-success" role="progressbar"
                             style="width: <%= percentage %>%"
                             aria-valuenow="<%= percentage %>" aria-valuemin="0" aria-valuemax="100">
                            <%= String.format("%.1f", percentage) %>%
                        </div>
                    </div>
                    <small class="text-muted">
                        Moyenne par paiement: <%= String.format("%.2f", totalRevenue / paymentCount) %> €
                    </small>
                </div>
            </div>
        </div>
        <% }
        } else { %>
        <div class="col-md-12">
            <div class="alert alert-info">
                Aucun revenu enregistré pour le moment.
            </div>
        </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>