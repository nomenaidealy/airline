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

@WebServlet("/paiements")
public class PaiementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("addPayment".equals(action)) {
            addPayment(request, response);
        }
    }

    private void addPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int societyId = Integer.parseInt(request.getParameter("societyId"));
            LocalDate datePaiement = LocalDate.parse(request.getParameter("datePaiement"));
            double montantPaye = Double.parseDouble(request.getParameter("montantPaye"));
            String moyenPaiement = request.getParameter("moyenPaiement");
            String remarque = request.getParameter("remarque");
            
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                
                try {
                    DiffusionDAO diffusionDAO = new DiffusionDAO(conn);
                    PaiementSocieteDAO paiementDAO = new PaiementSocieteDAO(conn);
                    PaiementSocieteDetailDAO detailDAO = new PaiementSocieteDetailDAO(conn);
                    
                    // Récupérer toutes les diffusions de cette société
                    List<Diffusion> diffusions = diffusionDAO.findBySociety(societyId);
                    
                    if (diffusions.isEmpty()) {
                        throw new Exception("Aucune diffusion trouvée pour cette société");
                    }
                    
                    // Pour chaque diffusion, créer ou récupérer le paiement_societe
                    double montantRestant = montantPaye;
                    
                    for (Diffusion diffusion : diffusions) {
                        if (montantRestant <= 0) break;
                        
                        // Vérifier si un paiement_societe existe pour cette diffusion
                        PaiementSociete ps = paiementDAO.findByDiffusion(diffusion.getId());
                        
                        if (ps == null) {
                            // Créer un nouveau paiement_societe
                            ps = new PaiementSociete();
                            ps.setDiffusion(diffusion);
                            paiementDAO.insert(ps);
                        }
                        
                        // Calculer le reste à payer pour cette diffusion
                        double montantTotalDiffusion = diffusion.getMontantTotal();
                        double dejaPaye = ps.getMontantPaye();
                        double resteAPayer = montantTotalDiffusion - dejaPaye;
                        
                        if (resteAPayer > 0) {
                            // Payer cette diffusion (partiellement ou totalement)
                            double montantAPayer = Math.min(montantRestant, resteAPayer);
                            
                            // Créer le détail du paiement
                            PaiementSocieteDetail detail = new PaiementSocieteDetail();
                            detail.setPaiementSociete(ps);
                            detail.setDatePaiement(datePaiement);
                            detail.setMontantPaye(montantAPayer);
                            
                            detailDAO.insert(detail);
                            
                            montantRestant -= montantAPayer;
                        }
                    }
                    
                    conn.commit();
                    
                    // Rediriger avec message de succès
                    HttpSession session = request.getSession();
                    session.setAttribute("successMessage", 
                        "Paiement de " + String.format("%.0f", montantPaye) + " Ar enregistré avec succès !");
                    response.sendRedirect("diffusions");
                    
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
                
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", 
                "Erreur lors de l'enregistrement du paiement : " + e.getMessage());
            response.sendRedirect("diffusions");
        }
    }
}