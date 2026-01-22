<%-- <%@ page import="main.project.beans.Employee" %>
<%
    Employee navEmployee = (Employee) session.getAttribute("employee");
%> --%>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="dashboard">✈️ GCA Airlines</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link" href="dashboard">Accueil</a>
                </li>
                <%-- <% if (navEmployee != null && (navEmployee.isAdmin() || navEmployee.isStaff())) { %> --%>
                <li class="nav-item">
                    <a class="nav-link" href="flight-instances">Vols</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="bookings">Réservations</a>
                </li>
                <%-- <% } %>
                <% if (navEmployee != null && (navEmployee.isAccountant() || navEmployee.isAdmin())) { %> --%>
                <li class="nav-item">
                    <a class="nav-link" href="payments">Finances</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="diffusions">Diffusions</a>
                </li>
                <%-- <% } %> --%>
            </ul>
            <%-- <% if (navEmployee != null) { %>
            <span class="navbar-text me-3">
                <%= navEmployee.getFullName() %> (<%= navEmployee.getRole() %>)
            </span>
            <a href="logout" class="btn btn-outline-light btn-sm">Déconnexion</a>
            <% } %> --%>
        </div>
    </div>
</nav>
