<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="main.project.beans.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect("login");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - GCA Airlines</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="dashboard">✈️ GCA Airlines</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link active" href="dashboard">Accueil</a>
                </li>
                <% if (employee.isAdmin() || employee.isStaff()) { %>
                <li class="nav-item">
                    <a class="nav-link" href="flight-instances">Vols</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="bookings">Réservations</a>
                </li>
                <% } %>
                <% if (employee.isAccountant() || employee.isAdmin()) { %>
                <li class="nav-item">
                    <a class="nav-link" href="payments">Finances</a>
                </li>
                <% } %>
            </ul>
            <span class="navbar-text me-3">
                    <%= employee.getFullName() %> (<%= employee.getRole() %>)
                </span>
            <a href="logout" class="btn btn-outline-light btn-sm">Déconnexion</a>
        </div>
    </div>
</nav>

<div class="container mt-5">
    <%
        String successMessage = (String) session.getAttribute("successMessage");
        if (successMessage != null) {
            session.removeAttribute("successMessage");
    %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <%= successMessage %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="row">
        <div class="col-md-12">
            <h1 class="mb-4">Tableau de bord</h1>
            <p class="lead">Bienvenue <%= employee.getFullName() %></p>
        </div>
    </div>

    <div class="row mt-4">
        <% if (employee.isAdmin() || employee.isStaff()) { %>
        <div class="col-md-4 mb-3">
            <div class="card text-white bg-primary">
                <div class="card-body">
                    <h5 class="card-title">📋 Gestion des Vols</h5>
                    <p class="card-text">Créer, modifier et consulter les vols</p>
                    <a href="flights" class="btn btn-light">Accéder</a>
                </div>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="card text-white bg-success">
                <div class="card-body">
                    <h5 class="card-title">🎫 Réservations</h5>
                    <p class="card-text">Gérer les passagers et réservations</p>
                    <a href="bookings" class="btn btn-light">Accéder</a>
                </div>
            </div>
        </div>
        <% } %>

        <% if (employee.isAccountant() || employee.isAdmin()) { %>
        <div class="col-md-4 mb-3">
            <div class="card text-white bg-warning">
                <div class="card-body">
                    <h5 class="card-title">💰 Finances</h5>
                    <p class="card-text">Consulter les paiements et rapports</p>
                    <a href="payments" class="btn btn-light">Accéder</a>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>