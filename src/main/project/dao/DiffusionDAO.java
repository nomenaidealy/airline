package main.project.dao;

import main.project.beans.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class DiffusionDAO {

    private Connection connection;
    private SocietyDAO societyDAO;
    private DiffusionPriceDAO priceDAO;

    public DiffusionDAO(Connection connection) {
        this.connection = connection;
        this.societyDAO = new SocietyDAO(connection);
        this.priceDAO = new DiffusionPriceDAO(connection);
    }

    // ================= INSERT =================
    public void insert(Diffusion diffusion) throws SQLException {
        String sql = """
            INSERT INTO diffusion
            (society_id, flight_instance_id, diffusion_price_id, diffusion_date, nombre_diffusion)
            VALUES (?, ?, ?, ?, ?)
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, diffusion.getSociety().getId());
            ps.setInt(2, diffusion.getFlightInstanceId());
            ps.setInt(3, diffusion.getDiffusionPrice().getId());
            ps.setDate(4, Date.valueOf(diffusion.getDiffusionDate()));
            ps.setInt(5, diffusion.getNombreDiffusion());
            ps.executeUpdate();
        }
    }

    // ================= FIND ALL =================
    public List<Diffusion> findAll() throws SQLException {
        List<Diffusion> list = new ArrayList<>();
        String sql = "SELECT * FROM diffusion";

        try (Statement st = connection.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    // ================= FILTRE PAR SOCIÉTÉ =================
    public List<Diffusion> findBySociety(int societyId) throws SQLException {
        List<Diffusion> list = new ArrayList<>();
        String sql = "SELECT * FROM diffusion WHERE society_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, societyId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    // ================= FILTRE PAR FLIGHT INSTANCE =================
    public List<Diffusion> findByFlightInstance(int flightInstanceId) throws SQLException {
        List<Diffusion> list = new ArrayList<>();
        String sql = "SELECT * FROM diffusion WHERE flight_instance_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, flightInstanceId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    // ================= FILTRE PAR INTERVALLE DE DATE =================
    public List<Diffusion> findByDateRange(LocalDate debut, LocalDate fin) throws SQLException {
        List<Diffusion> list = new ArrayList<>();
        String sql = "SELECT * FROM diffusion WHERE diffusion_date BETWEEN ? AND ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(debut));
            ps.setDate(2, Date.valueOf(fin));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    // ================= MAPPING =================
    private Diffusion map(ResultSet rs) throws SQLException {
        Diffusion d = new Diffusion();
        d.setId(rs.getInt("id"));
        d.setDiffusionDate(rs.getDate("diffusion_date").toLocalDate());
        d.setNombreDiffusion(rs.getInt("nombre_diffusion"));
        d.setFlightInstanceId(rs.getInt("flight_instance_id"));

        d.setSociety(societyDAO.findById(rs.getInt("society_id")));
        d.setDiffusionPrice(priceDAO.findById(rs.getInt("diffusion_price_id")));

        // Champs vol temporaires
        // Ici tu peux faire un JOIN si besoin pour remplir les noms d'aéroports et l'heure
        d.setDepartureAirportName("N/A");
        d.setArrivalAirportName("N/A");
        d.setDepartureTime(null);

        return d;
    }
}
