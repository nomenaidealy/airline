package main.project.beans;

public class SocietyPaymentSummary {
    private Society society;
    private double montantTotal;      // Total à payer
    private double montantPaye;       // Total déjà payé
    private double resteAPayer;       // Reste à payer
    private int nombreDiffusions;     // Nombre total de diffusions

    public SocietyPaymentSummary() {}

    public SocietyPaymentSummary(Society society, double montantTotal, 
                                 double montantPaye, int nombreDiffusions) {
        this.society = society;
        this.montantTotal = montantTotal;
        this.montantPaye = montantPaye;
        this.nombreDiffusions = nombreDiffusions;
        this.resteAPayer = montantTotal - montantPaye;
    }

    // Getters & Setters
    public Society getSociety() {
        return society;
    }

    public void setSociety(Society society) {
        this.society = society;
    }

    public double getMontantTotal() {
        return montantTotal;
    }

    public void setMontantTotal(double montantTotal) {
        this.montantTotal = montantTotal;
        this.resteAPayer = montantTotal - montantPaye;
    }

    public double getMontantPaye() {
        return montantPaye;
    }

    public void setMontantPaye(double montantPaye) {
        this.montantPaye = montantPaye;
        this.resteAPayer = montantTotal - montantPaye;
    }

    public double getResteAPayer() {
        return resteAPayer;
    }

    public int getNombreDiffusions() {
        return nombreDiffusions;
    }

    public void setNombreDiffusions(int nombreDiffusions) {
        this.nombreDiffusions = nombreDiffusions;
    }

    public double getTauxPaiement() {
        return montantTotal > 0 ? (montantPaye / montantTotal) * 100 : 0;
    }
}