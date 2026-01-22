package main.project.servlets;

import main.project.beans.*;
import main.project.dao.*;
import main.project.utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/diffusions")
public class DiffusionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "filter":
                filterDiffusions(request, response);
                break;
            default:
                listDiffusions(request, response);
        }
    }

    private void listDiffusions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Récupérer les messages de session
        HttpSession session = request.getSession();
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
            session.removeAttribute("successMessage");
        }
        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
            session.removeAttribute("errorMessage");
        }

        try (Connection conn = DBConnection.getConnection()) {
            DiffusionDAO diffusionDAO = new DiffusionDAO(conn);
            PaiementSocieteDAO paiementDAO = new PaiementSocieteDAO(conn);
            
            List<Diffusion> diffusions = diffusionDAO.findAll();
            List<SocietyPaymentSummary> societySummaries = paiementDAO.getSummaryBySociety();

            double totalCA = diffusions.stream()
                .mapToDouble(Diffusion::getMontantTotal)
                .sum();
            
            double totalResteAPayer = societySummaries.stream()
                .mapToDouble(SocietyPaymentSummary::getResteAPayer)
                .sum();

            request.setAttribute("diffusions", diffusions);
            request.setAttribute("totalCA", totalCA);
            request.setAttribute("societySummaries", societySummaries);
            request.setAttribute("totalResteAPayer", totalResteAPayer);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", 
                "Erreur lors de la récupération des diffusions : " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/jsp/diffusions/listDiffusions.jsp")
                .forward(request, response);
    }

    private void filterDiffusions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String societyIdStr = request.getParameter("societyId");

        Integer month = parseInteger(monthStr);
        Integer year = parseInteger(yearStr);
        int societyId = parseInteger(societyIdStr) != null ? parseInteger(societyIdStr) : 0;

        try (Connection conn = DBConnection.getConnection()) {
            DiffusionDAO diffusionDAO = new DiffusionDAO(conn);
            PaiementSocieteDAO paiementDAO = new PaiementSocieteDAO(conn);
            
            List<Diffusion> diffusions = diffusionDAO.findAll();
            List<SocietyPaymentSummary> societySummaries;

            // Filtrage des diffusions par mois/année
            LocalDate start = null, end = null;
            
            if (month != null && year != null) {
                start = LocalDate.of(year, month, 1);
                end = start.withDayOfMonth(start.lengthOfMonth());
            } else if (year != null) {
                start = LocalDate.of(year, 1, 1);
                end = LocalDate.of(year, 12, 31);
            }
            
            if (start != null && end != null) {
                final LocalDate fStart = start;
                final LocalDate fEnd = end;
                diffusions.removeIf(d -> d.getDiffusionDate().isBefore(fStart) 
                    || d.getDiffusionDate().isAfter(fEnd));
                
                // Récapitulatif filtré par période
                societySummaries = paiementDAO.getSummaryBySociety(start, end);
            } else {
                societySummaries = paiementDAO.getSummaryBySociety();
            }

            // Filtrage par société
            if (societyId != 0) {
                final int fSocietyId = societyId;
                diffusions.removeIf(d -> d.getSociety().getId() != fSocietyId);
                societySummaries.removeIf(s -> s.getSociety().getId() != fSocietyId);
            }

            double totalCA = diffusions.stream()
                .mapToDouble(Diffusion::getMontantTotal)
                .sum();
            
            double totalResteAPayer = societySummaries.stream()
                .mapToDouble(SocietyPaymentSummary::getResteAPayer)
                .sum();

            request.setAttribute("diffusions", diffusions);
            request.setAttribute("totalCA", totalCA);
            request.setAttribute("societySummaries", societySummaries);
            request.setAttribute("totalResteAPayer", totalResteAPayer);
            request.setAttribute("selectedMonth", monthStr);
            request.setAttribute("selectedYear", yearStr);
            request.setAttribute("selectedSocietyId", societyIdStr);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", 
                "Erreur lors du filtrage : " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/jsp/diffusions/listDiffusions.jsp")
                .forward(request, response);
    }

    private Integer parseInteger(String str) {
        if (str != null && !str.isEmpty()) {
            try { return Integer.parseInt(str); } catch (NumberFormatException ignored) {}
        }
        return null;
    }
}