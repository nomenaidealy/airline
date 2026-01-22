package main.project.beans;

import java.util.ArrayList;
import java.util.List;

public class PaiementSociete {

    private int id;
    private Diffusion diffusion; // La diffusion concernée
    private List<PaiementSocieteDetail> paiements; // Liste des paiements déjà effectués

    public PaiementSociete() {
        this.paiements = new ArrayList<>();
    }

    public PaiementSociete(int id, Diffusion diffusion) {
        this.id = id;
        this.diffusion = diffusion;
        this.paiements = new ArrayList<>();
    }

    // =====================================================
    // GETTERS & SETTERS
    // =====================================================
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Diffusion getDiffusion() {
        return diffusion;
    }

    public void setDiffusion(Diffusion diffusion) {
        this.diffusion = diffusion;
    }

    public List<PaiementSocieteDetail> getPaiements() {
        return paiements;
    }

    public void setPaiements(List<PaiementSocieteDetail> paiements) {
        this.paiements = paiements;
    }

    public void addPaiement(PaiementSocieteDetail paiement) {
        this.paiements.add(paiement);
    }

    // =====================================================
    // MÉTHODES MÉTIER
    // =====================================================
    public double getMontantTotal() {
        return diffusion != null ? diffusion.getMontantTotal() : 0;
    }

    public double getMontantPaye() {
        return paiements.stream()
                .mapToDouble(PaiementSocieteDetail::getMontantPaye)
                .sum();
    }

    public double getResteAPayer() {
        return getMontantTotal() - getMontantPaye();
    }
}
