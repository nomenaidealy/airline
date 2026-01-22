package main.project.beans;

import java.time.LocalDate;

public class PaiementSocieteDetail {

    private int id;
    private PaiementSociete paiementSociete;
    private LocalDate datePaiement;
    private double montantPaye;

    public PaiementSocieteDetail() {}

    public PaiementSocieteDetail(int id, PaiementSociete paiementSociete, LocalDate datePaiement, double montantPaye) {
        this.id = id;
        this.paiementSociete = paiementSociete;
        this.datePaiement = datePaiement;
        this.montantPaye = montantPaye;
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

    public PaiementSociete getPaiementSociete() {
        return paiementSociete;
    }

    public void setPaiementSociete(PaiementSociete paiementSociete) {
        this.paiementSociete = paiementSociete;
    }

    public LocalDate getDatePaiement() {
        return datePaiement;
    }

    public void setDatePaiement(LocalDate datePaiement) {
        this.datePaiement = datePaiement;
    }

    public double getMontantPaye() {
        return montantPaye;
    }

    public void setMontantPaye(double montantPaye) {
        this.montantPaye = montantPaye;
    }
}
