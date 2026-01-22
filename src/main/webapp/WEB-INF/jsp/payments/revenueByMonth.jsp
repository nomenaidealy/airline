<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<Map<String, Object>> monthlyRevenue = (List<Map<String, Object>>) request.getAttribute("monthlyRevenue");
    String[] monthNames = {"", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
            "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"};
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revenus par Mois - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>📅 Revenus par Mois</h2>
        <a href="payments" class="btn btn-secondary">↩️ Retour</a>
    </div>

    <% if (monthlyRevenue != null && !monthlyRevenue.isEmpty()) {
        double grandTotal = 0;
        int totalPayments = 0;
        for (Map<String, Object> row : monthlyRevenue) {
            grandTotal += (Double) row.get("totalRevenue");
            totalPayments += (Integer) row.get("paymentCount");
        }
    %>

    <div class="row mb-4">
        <div class="col-md-4">
            <div class="card text-white bg-success">
                <div class="card-body text-center">
                    <h6>Total des Revenus</h6>
                    <h3><%= String.format("%.2f", grandTotal) %> €</h3>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-white bg-primary">
                <div class="card-body text-center">
                    <h6>Total des Paiements</h6>
                    <h3><%= totalPayments %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card text-white bg-info">
                <div class="card-body text-center">
                    <h6>Moyenne Mensuelle</h6>
                    <h3><%= String.format("%.2f", grandTotal / monthlyRevenue.size()) %> €</h3>
                </div>
            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="table-dark">
            <tr>
                <th>Période</th>
                <th>Nombre de Paiements</th>
                <th>Revenus Totaux (€)</th>
                <th>Moyenne par Paiement (€)</th>
                <th>% du Total</th>
                <th>Visualisation</th>
            </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> row : monthlyRevenue) {
                int year = (Integer) row.get("year");
                int month = (Integer) row.get("month");
                int paymentCount = (Integer) row.get("paymentCount");
                double totalRevenue = (Double) row.get("totalRevenue");
                double avgRevenue = totalRevenue / paymentCount;
                double percentage = (totalRevenue / grandTotal) * 100;
            %>
            <tr>
                <td><strong><%= monthNames[month] %> <%= year %></strong></td>
                <td><%= paymentCount %></td>
                <td class="text-success"><strong><%= String.format("%.2f", totalRevenue) %></strong></td>
                <td><%= String.format("%.2f", avgRevenue) %></td>
                <td><%= String.format("%.1f", percentage) %>%</td>
                <td>
                    <div class="progress" style="height: 25px;">
                        <div class="progress-bar bg-success" role="progressbar"
                             style="width: <%= percentage %>%"
                             aria-valuenow="<%= percentage %>" aria-valuemin="0" aria-valuemax="100">
                            <%= String.format("%.0f", percentage) %>%
                        </div>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
            <tfoot class="table-light">
            <tr>
                <th>TOTAL</th>
                <th><%= totalPayments %></th>
                <th class="text-success"><strong><%= String.format("%.2f", grandTotal) %> €</strong></th>
                <th><%= String.format("%.2f", grandTotal / totalPayments) %></th>
                <th>100%</th>
                <th></th>
            </tr>
            </tfoot>
        </table>
    </div>

    <% } else { %>
    <div class="alert alert-info">
        Aucun revenu enregistré pour le moment.
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>