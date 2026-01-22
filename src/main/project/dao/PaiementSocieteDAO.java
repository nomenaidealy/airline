package main.project.dao;

import main.project.beans.*;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PaiementSocieteDAO {

    private Connection connection;
    private DiffusionDAO diffusionDAO;

    public PaiementSocieteDAO(Connection connection) {
        this.connection = connection;
        this.diffusionDAO = new DiffusionDAO(connection);
    }

    // =====================================================
    // INSERT
    // =====================================================
    public void insert(PaiementSociete ps) throws SQLException {
        String sql = "INSERT INTO paiement_societe(diffusion_id) VALUES (?) RETURNING id";
        try (PreparedStatement psStmt = connection.prepareStatement(sql)) {
            psStmt.setInt(1, ps.getDiffusion().getId());
            ResultSet rs = psStmt.executeQuery();
            if (rs.next()) {
                ps.setId(rs.getInt(1));
            }
        }
    }

    // =====================================================
    // FIND BY DIFFUSION
    // =====================================================
    public PaiementSociete findByDiffusion(int diffusionId) throws SQLException {
        String sql = "SELECT * FROM paiement_societe WHERE diffusion_id = ?";
        PaiementSociete ps = null;

        try (PreparedStatement psStmt = connection.prepareStatement(sql)) {
            psStmt.setInt(1, diffusionId);
            ResultSet rs = psStmt.executeQuery();
            if (rs.next()) {
                Diffusion d = diffusionDAO.findAll().stream()
                        .filter(diff -> diff.getId() == diffusionId)
                        .findFirst()
                        .orElse(null);
                ps = new PaiementSociete(rs.getInt("id"), d);
                // Charger les paiements
                PaiementSocieteDetailDAO detailDAO = new PaiementSocieteDetailDAO(connection);
                ps.setPaiements(detailDAO.findByPaiementSociete(ps.getId()));
            }
        }
        return ps;
    }

    // =====================================================
    // FIND ALL
    // =====================================================
 public List<PaiementSociete> findAll() throws SQLException {
    List<PaiementSociete> list = new ArrayList<>();
    
    // Précharger toutes les diffusions
    List<Diffusion> allDiffusions = diffusionDAO.findAll();

    String sql = "SELECT * FROM paiement_societe";
    try (Statement st = connection.createStatement();
         ResultSet rs = st.executeQuery(sql)) {

        while (rs.next()) {
            int diffusionId = rs.getInt("diffusion_id");

            // Trouver la diffusion correspondante
            Diffusion d = allDiffusions.stream()
                    .filter(diff -> diff != null && diff.getId() == diffusionId)
                    .findFirst()
                    .orElse(null);

            PaiementSociete ps = new PaiementSociete(rs.getInt("id"), d);

            // Charger les paiements associés
            PaiementSocieteDetailDAO detailDAO = new PaiementSocieteDetailDAO(connection);
            ps.setPaiements(detailDAO.findByPaiementSociete(ps.getId()));

            list.add(ps);
        }
    }
    return list;
}

    // Ajoutez cette méthode dans votre classe PaiementSocieteDAO

public List<SocietyPaymentSummary> getSummaryBySociety() throws SQLException {
    String sql = """
        SELECT 
            s.id AS society_id,
            s.libelle AS society_name,
            COUNT(DISTINCT d.id) AS nombre_diffusions,
            SUM(d.nombre_diffusion * dp.montant) AS montant_total,
            COALESCE(SUM(psd.montant_paye), 0) AS montant_paye
        FROM society s
        INNER JOIN diffusion d ON s.id = d.society_id
        INNER JOIN diffusion_price dp ON d.diffusion_price_id = dp.id
        LEFT JOIN paiement_societe ps ON d.id = ps.diffusion_id
        LEFT JOIN paiement_societe_detail psd ON ps.id = psd.paiement_societe_id
        GROUP BY s.id, s.libelle
        ORDER BY s.libelle
    """;

    List<SocietyPaymentSummary> summaries = new ArrayList<>();
    
    try (Statement st = connection.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        
        while (rs.next()) {
            Society society = new Society();
            society.setId(rs.getInt("society_id"));
            society.setLibelle(rs.getString("society_name"));
            
            double montantTotal = rs.getDouble("montant_total");
            double montantPaye = rs.getDouble("montant_paye");
            int nombreDiffusions = rs.getInt("nombre_diffusions");
            
            SocietyPaymentSummary summary = new SocietyPaymentSummary(
                society, montantTotal, montantPaye, nombreDiffusions
            );
            
            summaries.add(summary);
        }
    }
    
    return summaries;
}

// Méthode pour filtrer par période
public List<SocietyPaymentSummary> getSummaryBySociety(LocalDate dateDebut, LocalDate dateFin) 
        throws SQLException {
    String sql = """
        SELECT 
            s.id AS society_id,
            s.libelle AS society_name,
            COUNT(DISTINCT d.id) AS nombre_diffusions,
            SUM(d.nombre_diffusion * dp.montant) AS montant_total,
            COALESCE(SUM(psd.montant_paye), 0) AS montant_paye
        FROM society s
        INNER JOIN diffusion d ON s.id = d.society_id
        INNER JOIN diffusion_price dp ON d.diffusion_price_id = dp.id
        LEFT JOIN paiement_societe ps ON d.id = ps.diffusion_id
        LEFT JOIN paiement_societe_detail psd ON ps.id = psd.paiement_societe_id
        WHERE d.diffusion_date BETWEEN ? AND ?
        GROUP BY s.id, s.libelle
        ORDER BY s.libelle
    """;

    List<SocietyPaymentSummary> summaries = new ArrayList<>();
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setDate(1, Date.valueOf(dateDebut));
        ps.setDate(2, Date.valueOf(dateFin));
        
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Society society = new Society();
            society.setId(rs.getInt("society_id"));
            society.setLibelle(rs.getString("society_name"));
            
            double montantTotal = rs.getDouble("montant_total");
            double montantPaye = rs.getDouble("montant_paye");
            int nombreDiffusions = rs.getInt("nombre_diffusions");
            
            SocietyPaymentSummary summary = new SocietyPaymentSummary(
                society, montantTotal, montantPaye, nombreDiffusions
            );
            
            summaries.add(summary);
        }
    }
    
    return summaries;
}

}
