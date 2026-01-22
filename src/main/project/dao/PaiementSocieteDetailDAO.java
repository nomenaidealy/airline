package main.project.dao;

import main.project.beans.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PaiementSocieteDetailDAO {
    
    private Connection connection;
    
    public PaiementSocieteDetailDAO(Connection connection) {
        this.connection = connection;
    }
    
    // =====================================================
    // INSERT
    // =====================================================
    public void insert(PaiementSocieteDetail detail) throws SQLException {
        String sql = """
            INSERT INTO paiement_societe_detail(paiement_societe_id, date_paiement, montant_paye) 
            VALUES (?, ?, ?) 
            RETURNING id
        """;
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, detail.getPaiementSociete().getId());
            ps.setDate(2, Date.valueOf(detail.getDatePaiement()));
            ps.setDouble(3, detail.getMontantPaye());
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                detail.setId(rs.getInt(1));
            }
        }
    }
    
    // =====================================================
    // FIND BY PAIEMENT SOCIETE
    // =====================================================
    public List<PaiementSocieteDetail> findByPaiementSociete(int paiementSocieteId) throws SQLException {
        List<PaiementSocieteDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM paiement_societe_detail WHERE paiement_societe_id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, paiementSocieteId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PaiementSocieteDetail detail = new PaiementSocieteDetail();
                detail.setId(rs.getInt("id"));
                
                PaiementSociete psRef = new PaiementSociete();
                psRef.setId(paiementSocieteId);
                detail.setPaiementSociete(psRef);
                
                detail.setDatePaiement(rs.getDate("date_paiement").toLocalDate());
                detail.setMontantPaye(rs.getDouble("montant_paye"));
                
                list.add(detail);
            }
        }
        return list;
    }
    
    // =====================================================
    // FIND ALL
    // =====================================================
    public List<PaiementSocieteDetail> findAll() throws SQLException {
        List<PaiementSocieteDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM paiement_societe_detail ORDER BY date_paiement DESC";
        
        try (Statement st = connection.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            
            while (rs.next()) {
                PaiementSocieteDetail detail = new PaiementSocieteDetail();
                detail.setId(rs.getInt("id"));
                
                PaiementSociete psRef = new PaiementSociete();
                psRef.setId(rs.getInt("paiement_societe_id"));
                detail.setPaiementSociete(psRef);
                
                detail.setDatePaiement(rs.getDate("date_paiement").toLocalDate());
                detail.setMontantPaye(rs.getDouble("montant_paye"));
                
                list.add(detail);
            }
        }
        return list;
    }
}