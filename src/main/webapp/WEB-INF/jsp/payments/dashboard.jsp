<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.Employee" %>
<%
    // Employee employee = (Employee) session.getAttribute("employee");
    // if (employee == null || (!employee.isAccountant() && !employee.isAdmin())) {
    //     response.sendRedirect("dashboard");
    //     return;
    // }

    double totalRevenue = (Double) request.getAttribute("totalRevenue");
    double monthRevenue = (Double) request.getAttribute("monthRevenue");
    int monthCount = (Integer) request.getAttribute("monthCount");
    int totalCount = (Integer) request.getAttribute("totalCount");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finances - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%@ include file="../navbar.jsp" %>

<div class="container mt-4">
    <h2 class="mb-4">💰 Tableau de Bord Financier</h2>

    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card text-white bg-success">
                <div class="card-body">
                    <h6 class="card-title">Revenus Totaux</h6>
                    <h3 class="mb-0"><%= String.format("%.2f", totalRevenue) %> €</h3>
                    <small><%= totalCount %> paiements</small>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card text-white bg-primary">
                <div class="card-body">
                    <h6 class="card-title">Revenus ce Mois</h6>
                    <h3 class="mb-0"><%= String.format("%.2f", monthRevenue) %> €</h3>
                    <small><%= monthCount %> paiements</small>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card text-white bg-info">
                <div class="card-body">
                    <h6 class="card-title">Moyenne par Paiement</h6>
                    <h3 class="mb-0">
                        <%= totalCount > 0 ? String.format("%.2f", totalRevenue / totalCount) : "0.00" %> €
                    </h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card text-white bg-warning">
                <div class="card-body">
                    <h6 class="card-title">Paiements Total</h6>
                    <h3 class="mb-0"><%= totalCount %></h3>
                    <small>transactions</small>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body text-center">
                    <h5 class="card-title">📋 Liste des Paiements</h5>
                    <p class="card-text">Consulter tous les paiements enregistrés</p>
                    <a href="payments?action=list" class="btn btn-primary">Voir les paiements</a>
                </div>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body text-center">
                    <h5 class="card-title">✈️ Revenus par Vol</h5>
                    <p class="card-text">Analyser les revenus de chaque vol</p>
                    <a href="payments?action=byFlight" class="btn btn-success">Voir le rapport</a>
                </div>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body text-center">
                    <h5 class="card-title">📅 Revenus par Mois</h5>
                    <p class="card-text">Analyser les revenus mensuels</p>
                    <a href="payments?action=byMonth" class="btn btn-info">Voir le rapport</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>