<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Set, java.util.HashSet" %>
<%@ page import="main.project.beans.*" %>
<%@ page import="java.text.NumberFormat" %>
<%
    List<Diffusion> diffusions = (List<Diffusion>) request.getAttribute("diffusions");
    List<SocietyPaymentSummary> societySummaries = (List<SocietyPaymentSummary>) request.getAttribute("societySummaries");
    
    double totalCA = request.getAttribute("totalCA") != null ? (double) request.getAttribute("totalCA") : 0;
    double totalResteAPayer = request.getAttribute("totalResteAPayer") != null ? (double) request.getAttribute("totalResteAPayer") : 0;

    String selectedMonth = request.getAttribute("selectedMonth") != null ? (String) request.getAttribute("selectedMonth") : "";
    String selectedYear = request.getAttribute("selectedYear") != null ? (String) request.getAttribute("selectedYear") : "";
    String selectedSocietyId = request.getAttribute("selectedSocietyId") != null ? (String) request.getAttribute("selectedSocietyId") : "";

    NumberFormat nf = NumberFormat.getInstance();
    nf.setMaximumFractionDigits(0);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste des Diffusions</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <style>
        .table-warning { background-color: #fff3cd; }
        .table-success { background-color: #d1e7dd; }
        .badge-paye { background-color: #28a745; }
        .badge-impaye { background-color: #dc3545; }
    </style>
</head>
<body>
<div class="container mt-4">
    <h2>Liste des Diffusions</h2>

    <!-- Formulaire de filtrage -->
    <form method="get" action="diffusions" class="row g-3 mb-4">
        <input type="hidden" name="action" value="filter">

        <div class="col-auto">
            <label for="month" class="form-label">Mois</label>
            <input type="number" id="month" name="month" min="1" max="12" class="form-control"
                   value="<%= selectedMonth %>" placeholder="1-12">
        </div>

        <div class="col-auto">
            <label for="year" class="form-label">Année</label>
            <input type="number" id="year" name="year" min="2000" max="2100" class="form-control"
                   value="<%= selectedYear %>" placeholder="2025">
        </div>

        <div class="col-auto">
            <label for="societyId" class="form-label">Société</label>
            <select name="societyId" id="societyId" class="form-select">
                <option value="">--Toutes--</option>
                <%
                    if (diffusions != null) {
                        Set<Society> societies = new HashSet<>();
                        for (Diffusion d : diffusions) societies.add(d.getSociety());
                        for (Society s : societies) {
                            String selected = s.getId() == (selectedSocietyId.isEmpty() ? -1 : Integer.parseInt(selectedSocietyId)) ? "selected" : "";
                %>
                            <option value="<%= s.getId() %>" <%= selected %>><%= s.getLibelle() %></option>
                <%
                        }
                    }
                %>
            </select>
        </div>

        <div class="col-auto align-self-end">
            <button type="submit" class="btn btn-primary">Filtrer</button>
            <a href="diffusions" class="btn btn-secondary">Réinitialiser</a>
        </div>
    </form>

    <!-- Tableau des diffusions -->
    <h4>Détails des Diffusions</h4>
    <table class="table table-striped table-hover">
        <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>Société</th>
            <th>Vol (Départ → Arrivée)</th>
            <th>Date du vol</th>
            <th>Heure Départ</th>
            <th>Nombre de Diffusions</th>
            <th>Montant Total</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (diffusions != null && !diffusions.isEmpty()) {
                for (Diffusion d : diffusions) {
        %>
            <tr>
                <td><%= d.getId() %></td>
                <td><%= d.getSociety().getLibelle() %></td>
                <td><%= d.getDepartureAirportName() != null && d.getArrivalAirportName() != null
                        ? d.getDepartureAirportName() + " → " + d.getArrivalAirportName()
                        : "Vol #" + d.getFlightInstanceId() %></td>
                <td><%= d.getDiffusionDate() != null ? d.getDiffusionDate() : "-" %></td>
                <td><%= d.getDepartureTime() != null ? d.getDepartureTime() : "-" %></td>
                <td><%= d.getNombreDiffusion() %></td>
                <td><%= nf.format(d.getMontantTotal()) %> Ar</td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="7" class="text-center">Aucune diffusion trouvée</td>
            </tr>
        <%
            }
        %>
        </tbody>
        <tfoot class="table-warning">
        <tr>
            <th colspan="6">Total CA</th>
            <th><%= nf.format(totalCA) %> Ar</th>
        </tr>
        </tfoot>
    </table>

    <!-- Tableau récapitulatif par société -->
    <h4 class="mt-5">Récapitulatif des Paiements par Société</h4>
    <table class="table table-bordered table-hover">
        <thead class="table-primary">
        <tr>
            <th>Société</th>
            <th>Nb Diffusions</th>
            <th>Montant Total</th>
            <th>Montant Payé</th>
            <th>Reste à Payer</th>
            <th>Taux Paiement</th>
            <th>Statut</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (societySummaries != null && !societySummaries.isEmpty()) {
                for (SocietyPaymentSummary summary : societySummaries) {
                    double tauxPaiement = summary.getTauxPaiement();
                    String statusClass = summary.getResteAPayer() <= 0 ? "table-success" : "";
                    String badgeClass = summary.getResteAPayer() <= 0 ? "badge-paye" : "badge-impaye";
                    String statusText = summary.getResteAPayer() <= 0 ? "Payé" : "Impayé";
        %>
            <tr class="<%= statusClass %>">
                <td><strong><%= summary.getSociety().getLibelle() %></strong></td>
                <td class="text-center"><%= summary.getNombreDiffusions() %></td>
                <td class="text-end"><%= nf.format(summary.getMontantTotal()) %> Ar</td>
                <td class="text-end text-success"><%= nf.format(summary.getMontantPaye()) %> Ar</td>
                <td class="text-end <%= summary.getResteAPayer() > 0 ? "text-danger fw-bold" : "text-success" %>">
                    <%= nf.format(summary.getResteAPayer()) %> Ar
                </td>
                <td class="text-center">
                    <div class="progress" style="height: 20px;">
                        <div class="progress-bar <%= summary.getResteAPayer() <= 0 ? "bg-success" : "bg-warning" %>" 
                             role="progressbar" 
                             style="width: <%= tauxPaiement %>%;" 
                             aria-valuenow="<%= tauxPaiement %>" 
                             aria-valuemin="0" 
                             aria-valuemax="100">
                            <%= String.format("%.1f", tauxPaiement) %>%
                        </div>
                    </div>
                </td>
                <td class="text-center">
                    <span class="badge <%= badgeClass %>"><%= statusText %></span>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="7" class="text-center">Aucune donnée de paiement disponible</td>
            </tr>
        <%
            }
        %>
        </tbody>
        <tfoot class="table-warning">
        <tr>
            <th colspan="4">TOTAL GÉNÉRAL</th>
            <th class="text-end text-danger fw-bold"><%= nf.format(totalResteAPayer) %> Ar</th>
            <th colspan="2"></th>
        </tr>
        </tfoot>
    </table>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>